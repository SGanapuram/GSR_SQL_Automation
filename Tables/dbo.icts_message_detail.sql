CREATE TABLE [dbo].[icts_message_detail]
(
[oid] [int] NOT NULL,
[message_id] [int] NOT NULL,
[icts_entity_id] [int] NOT NULL,
[key1] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[key2] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key3] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key4] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key5] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key6] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[op_trans_id] [int] NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[icts_message_detail_deltrg]
on [dbo].[icts_message_detail]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   int

select @num_rows = @@rowcount
if @num_rows = 0
   return

/* AUDIT_CODE_BEGIN */
select @atrans_id = max(trans_id)
from dbo.icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(lc) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,10,1)
   if @@trancount > 0 rollback tran

   return
end

insert dbo.aud_icts_message_detail
   (oid,
    message_id,
    icts_entity_id,
    key1,
    key2,
    key3,
    key4,
    key5,
    key6,
    op_trans_id,
    trans_id,
    resp_trans_id)
select
   d.oid,
   d.message_id,
   d.icts_entity_id,
   d.key1,
   d.key2,
   d.key3,
   d.key4,
   d.key5,
   d.key6,
   d.op_trans_id,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'DELETE',
       'IctsMessageDetail',
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
from dbo.icts_transaction it,
     deleted d
where it.trans_id = @atrans_id and
      it.type != 'E'
 
/* END_TRANSACTION_TOUCH */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[icts_message_detail_instrg]
on [dbo].[icts_message_detail]
for insert
as
declare @num_rows        int

select @num_rows = @@rowcount
if @num_rows = 0
   return
   
/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'INSERT',
       'IctsMessageDetail',
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

create trigger [dbo].[icts_message_detail_updtrg]
on [dbo].[icts_message_detail]
for update
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
   raiserror ('(icts_message_detail) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(icts_message_detail) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid)
begin
   raiserror ('(icts_message_detail) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(oid)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.oid = d.oid)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(icts_message_detail) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_icts_message_detail
      (oid,
       message_id,
       icts_entity_id,
       key1,
       key2,
       key3,
       key4,
       key5,
       key6,
       op_trans_id,
       trans_id,
       resp_trans_id)
   select
      d.oid,
      d.message_id,
      d.icts_entity_id,
      d.key1,
      d.key2,
      d.key3,
      d.key4,
      d.key5,
      d.key6,
      d.op_trans_id,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid 

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'UPDATE',
       'IctsMessageDetail',
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
ALTER TABLE [dbo].[icts_message_detail] ADD CONSTRAINT [icts_message_detail_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [icts_message_detail_idx1] ON [dbo].[icts_message_detail] ([trans_id]) INCLUDE ([icts_entity_id], [key1], [key2], [key3], [key4], [key5], [key6], [op_trans_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[icts_message_detail] ADD CONSTRAINT [icts_message_detail_fk1] FOREIGN KEY ([message_id]) REFERENCES [dbo].[icts_message] ([oid])
GO
ALTER TABLE [dbo].[icts_message_detail] ADD CONSTRAINT [icts_message_detail_fk2] FOREIGN KEY ([icts_entity_id]) REFERENCES [dbo].[icts_entity_name] ([oid])
GO
GRANT DELETE ON  [dbo].[icts_message_detail] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[icts_message_detail] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[icts_message_detail] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[icts_message_detail] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'icts_message_detail', NULL, NULL
GO
