CREATE TABLE [dbo].[eipp_task]
(
[oid] [int] NOT NULL,
[creation_date] [datetime] NOT NULL,
[eipp_entity_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key3] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key4] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[eipp_status] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[eipp_substatus] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[task_name_oid] [int] NOT NULL,
[task_xml] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[op_trans_id] [int] NULL,
[trans_id] [int] NOT NULL,
[substatus_xml] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[eipp_task_deltrg]
on [dbo].[eipp_task]
instead of delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   bigint

select @num_rows = @@rowcount
if @num_rows = 0
   return

delete dbo.eipp_task 
from deleted d
where eipp_task.oid = d.oid

/* AUDIT_CODE_BEGIN */
select @atrans_id = max(trans_id)
from dbo.icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(eipp_task) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,16,1)
   if @@trancount > 0 rollback tran

   return
end


insert dbo.aud_eipp_task
   (oid,
    creation_date,
    eipp_entity_name,
    key1,
    key2,
    key3,
    key4,
    eipp_status,
    eipp_substatus,
    task_name_oid,
    task_xml,
    op_trans_id,
    trans_id,
    resp_trans_id,
    substatus_xml)
select
   d.oid,
   d.creation_date,
   d.eipp_entity_name,
   d.key1,
   d.key2,
   d.key3,
   d.key4,
   d.eipp_status,
   d.eipp_substatus,
   d.task_name_oid,
   d.task_xml,
   d.op_trans_id,
   d.trans_id,
   @atrans_id,
   d.substatus_xml
from deleted d

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'DELETE',
       'EIPPTask',
       'DIRECT',
       convert(varchar(40), d.oid),
       null,
       null,
       null,
       null,
       null,
       null,
       null,
       @atrans_id,
       it.sequence
from deleted d, dbo.icts_transaction it
where it.trans_id = @atrans_id and
      it.type != 'E'
 
/* END_TRANSACTION_TOUCH */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[eipp_task_instrg]
on [dbo].[eipp_task]
for insert
as
declare @num_rows        int,
        @count_num_rows  int,
        @errmsg          varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

   /* BEGIN_TRANSACTION_TOUCH */
 
   insert dbo.transaction_touch
   select 'INSERT',
          'EIPPTask',
          'DIRECT',
          convert(varchar(40), i.oid),
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          i.trans_id,
          it.sequence
   from inserted i, dbo.icts_transaction it
   where i.trans_id = it.trans_id and
         it.type != 'E'
 
   /* END_TRANSACTION_TOUCH */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[eipp_task_updtrg]
on [dbo].[eipp_task]
instead of update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errmsg           varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

select @dummy_update = 0

/* RECORD_STAMP_BEGIN */
if not update(trans_id) 
begin
   raiserror ('(eipp_task) The change needs to be attached with a new trans_id',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* added by Peter Lo  Sep-4-2002 */
if exists (select 1
           from master.dbo.sysprocesses
           where spid = @@spid and
                (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                 program_name like 'Microsoft SQL Server Management Studio%') )
begin
   if (select count(*) from inserted, deleted where inserted.trans_id <= deleted.trans_id) > 0
   begin
      select @errmsg = '(eipp_task) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid )
begin
   raiserror ('(eipp_task) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(oid) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.oid = d.oid )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(eipp_task) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

update dbo.eipp_task
set creation_date = i.creation_date,
    eipp_entity_name = i.eipp_entity_name,
    key1 = i.key1,
    key2 = i.key2,
    key3 = i.key3,
    key4 = i.key4,
    eipp_status = i.eipp_status,
    eipp_substatus = i.eipp_substatus,
    task_name_oid = i.task_name_oid,
    task_xml = i.task_xml,
    op_trans_id = i.op_trans_id,
    trans_id = i.trans_id,
    substatus_xml = i.substatus_xml
from deleted d, inserted i
where eipp_task.oid = d.oid and
      d.oid = i.oid

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_eipp_task
      (oid,
       creation_date,
       eipp_entity_name,
       key1,
       key2,
       key3,
       key4,
       eipp_status,
       eipp_substatus,
       task_name_oid,
       task_xml,    
       op_trans_id,
       trans_id,
       resp_trans_id,
       substatus_xml)
   select
      d.oid,
      d.creation_date,
      d.eipp_entity_name,
      d.key1,
      d.key2,
      d.key3,
      d.key4,
      d.eipp_status,
      d.eipp_substatus,
      d.task_name_oid,
      d.task_xml,
      d.op_trans_id,
      d.trans_id,
      i.trans_id,
      d.substatus_xml
   from deleted d, inserted i
   where d.oid = i.oid 

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'UPDATE',
       'EIPPTask',
       'DIRECT',
       convert(varchar(40), i.oid),
       null,
       null,
       null,
       null,
       null,
       null,
       null,
       i.trans_id,
       it.sequence
from inserted i, dbo.icts_transaction it
where i.trans_id = it.trans_id and
      it.type != 'E'

/* END_TRANSACTION_TOUCH */

return
GO
ALTER TABLE [dbo].[eipp_task] ADD CONSTRAINT [chk_eipp_task_eipp_status] CHECK (([eipp_status]='Complete' OR [eipp_status]='Ack' OR [eipp_status]='Deliver' OR [eipp_status]='Process'))
GO
ALTER TABLE [dbo].[eipp_task] ADD CONSTRAINT [chk_eipp_task_eipp_substatus] CHECK (([eipp_substatus]='CFCInvalidCostCommodity' OR [eipp_substatus]='CFCInvalidPayer' OR [eipp_substatus]='CFCInvalidReceiver' OR [eipp_substatus]='CFCInvalidIssuer' OR [eipp_substatus]='CFCInvalidCurrency' OR [eipp_substatus]='CFCInvalidPortfolio' OR [eipp_substatus]='CFCInvalidCostType' OR [eipp_substatus]='CFCInvalidBusnDate' OR [eipp_substatus]='CFCInvalidBatchCount' OR [eipp_substatus]='CFCInvalidAccount' OR [eipp_substatus]='DDCInvalidInvoiceId' OR [eipp_substatus]='DDCBadXML' OR [eipp_substatus]='DDCInvalidDueDate' OR [eipp_substatus]='DDCBadCostVoucher' OR [eipp_substatus]='Success'))
GO
ALTER TABLE [dbo].[eipp_task] ADD CONSTRAINT [eipp_task_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [eipp_task_idx1] ON [dbo].[eipp_task] ([eipp_status], [creation_date]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[eipp_task] ADD CONSTRAINT [eipp_task_fk1] FOREIGN KEY ([task_name_oid]) REFERENCES [dbo].[eipp_task_name] ([oid])
GO
GRANT DELETE ON  [dbo].[eipp_task] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[eipp_task] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[eipp_task] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[eipp_task] TO [next_usr]
GO
