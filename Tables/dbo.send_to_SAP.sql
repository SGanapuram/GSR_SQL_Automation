CREATE TABLE [dbo].[send_to_SAP]
(
[row_id] [int] NOT NULL,
[entity_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[key1] [int] NULL,
[key2] [int] NULL,
[key3] [int] NULL,
[interface] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[operation] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[op_trans_id] [int] NOT NULL,
[file_id] [int] NULL,
[ready_to_send] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[type_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[archived_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[archived_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[archived_date] [datetime] NULL,
[purged_date] [datetime] NULL,
[hide_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[book_comp_num] [int] NULL,
[represented_cmdtys] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[send_to_SAP_deltrg]
on [dbo].[send_to_SAP]
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
   select @errmsg = '(send_to_SAP) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_send_to_SAP
   (row_id,
    entity_name,
    key1,
    key2,
    key3,
    interface,
    operation,
    op_trans_id,
    file_id,
    ready_to_send,
    type_code,
    archived_ind,
    archived_init,
    archived_date,
    purged_date,
    hide_ind,
    book_comp_num,
    represented_cmdtys,
    trans_id,
    resp_trans_id)
select
   d.row_id,
   d.entity_name,
   d.key1,
   d.key2,
   d.key3,
   d.interface,
   d.operation,
   d.op_trans_id,
   d.file_id,
   d.ready_to_send,
   d.type_code,
   d.archived_ind,
   d.archived_init,
   d.archived_date,
   d.purged_date,
   d.hide_ind,
   d.book_comp_num,
   d.represented_cmdtys,
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

create trigger [dbo].[send_to_SAP_updtrg]
on [dbo].[send_to_SAP]
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
   raiserror ('(send_to_SAP) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(send_to_SAP) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.row_id = d.row_id )
begin
   raiserror ('(send_to_SAP) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(row_id)    
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.row_id = d.row_id )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(send_to_SAP) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_send_to_SAP
      (row_id,
       entity_name,
       key1,
       key2,
       key3,
       interface,
       operation,
       op_trans_id,
       file_id,
       ready_to_send,
       type_code,
       archived_ind,
       archived_init,
       archived_date,
       purged_date,
       hide_ind,
       book_comp_num,
       represented_cmdtys,
       trans_id,
       resp_trans_id)
    select
       d.row_id,
       d.entity_name,
       d.key1,
       d.key2,
       d.key3,
       d.interface,
       d.operation,
       d.op_trans_id,
       d.file_id,
       d.ready_to_send,
       d.type_code,
       d.archived_ind,
       d.archived_init,
       d.archived_date,
       d.purged_date,
       d.hide_ind,
       d.book_comp_num,
       d.represented_cmdtys,
       d.trans_id,
       i.trans_id
    from deleted d, inserted i
    where d.row_id = i.row_id
  
/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[send_to_SAP] ADD CONSTRAINT [send_to_SAP_pk] PRIMARY KEY CLUSTERED  ([row_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [send_to_SAP_idx1] ON [dbo].[send_to_SAP] ([archived_ind]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [send_to_SAP_idx2] ON [dbo].[send_to_SAP] ([archived_ind], [purged_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [send_to_SAP_idx3] ON [dbo].[send_to_SAP] ([op_trans_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[send_to_SAP] ADD CONSTRAINT [send_to_SAP_fk2] FOREIGN KEY ([archived_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[send_to_SAP] ADD CONSTRAINT [send_to_SAP_fk3] FOREIGN KEY ([book_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
GRANT DELETE ON  [dbo].[send_to_SAP] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[send_to_SAP] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[send_to_SAP] TO [ictspurge]
GO
GRANT DELETE ON  [dbo].[send_to_SAP] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[send_to_SAP] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[send_to_SAP] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[send_to_SAP] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'send_to_SAP', NULL, NULL
GO
