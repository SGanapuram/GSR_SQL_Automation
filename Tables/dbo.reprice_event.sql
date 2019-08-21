CREATE TABLE [dbo].[reprice_event]
(
[reprice_event_oid] [int] NOT NULL,
[entity_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[key1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key3] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key4] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_trans_id] [int] NOT NULL,
[event_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[reprice_event_deltrg]
on [dbo].[reprice_event]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   bigint

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
   select @errmsg = '(reprice_event) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_reprice_event
   (reprice_event_oid,
    entity_name,
    key1,
    key2,
    key3,
    key4,
    event_trans_id,
    event_type,
    trans_id,
    resp_trans_id)
select
   d.reprice_event_oid,
   d.entity_name,
   d.key1,
   d.key2,
   d.key3,
   d.key4,
   d.event_trans_id,
   d.event_type,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[reprice_event_updtrg]
on [dbo].[reprice_event]
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
   raiserror ('(reprice_event) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(reprice_event) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.reprice_event_oid = d.reprice_event_oid )
begin
   raiserror ('(reprice_event) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(reprice_event_oid) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.reprice_event_oid = d.reprice_event_oid )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(reprice_event) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */
if @dummy_update = 0
   insert dbo.aud_reprice_event
      (reprice_event_oid,
       entity_name,
       key1,
       key2,
       key3,
       key4,
       event_trans_id,
       event_type,
       trans_id,
       resp_trans_id)
   select
      d.reprice_event_oid,
      d.entity_name,
      d.key1,
      d.key2,
      d.key3,
      d.key4,
      d.event_trans_id,
      d.event_type,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.reprice_event_oid = i.reprice_event_oid 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[reprice_event] ADD CONSTRAINT [reprice_event_pk] PRIMARY KEY CLUSTERED  ([reprice_event_oid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [reprice_event_idx1] ON [dbo].[reprice_event] ([entity_name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[reprice_event] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[reprice_event] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[reprice_event] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[reprice_event] TO [next_usr]
GO
