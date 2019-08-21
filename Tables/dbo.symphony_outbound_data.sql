CREATE TABLE [dbo].[symphony_outbound_data]
(
[row_id] [int] NOT NULL,
[entity_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[key1] [int] NULL,
[key2] [int] NULL,
[key3] [int] NULL,
[interface] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[operation] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[op_trans_id] [int] NOT NULL,
[file_id] [int] NULL,
[ready_to_send] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[type_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[archived_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[archived_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[archived_date] [datetime] NULL,
[purged_date] [datetime] NULL,
[hide_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[book_comp_num] [int] NULL,
[represented_cmdtys] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[status] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_symphony_outbound_data_status] DEFAULT ('PENDING'),
[duplicate_of] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[symphony_outbound_data_deltrg]
on [dbo].[symphony_outbound_data]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
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
   select @errmsg = '(symphony_outbound_data) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_symphony_outbound_data
(  
    row_id,
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
    status,
    duplicate_of,
    trans_id,
    resp_trans_id
)
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
   d.status,
   d.duplicate_of,
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

create trigger [dbo].[symphony_outbound_data_updtrg]
on [dbo].[symphony_outbound_data]
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
   raiserror ('(symphony_outbound_data) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(symphony_outbound_data) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.row_id = d.row_id)
begin
   select @errmsg = '(symphony_outbound_data) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.row_id) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
   return
end

/* RECORD_STAMP_END */

if update(row_id)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.row_id = d.row_id)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(symphony_outbound_data) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_symphony_outbound_data
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
       status,
       duplicate_of,
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
       d.status,
       d.duplicate_of,
       d.trans_id,
       i.trans_id
    from deleted d, inserted i
    where d.row_id = i.row_id

return
GO
ALTER TABLE [dbo].[symphony_outbound_data] ADD CONSTRAINT [chk_symphony_outbound_data_status] CHECK (([status]='ERROR' OR [status]='PROCESSED' OR [status]='DELETED' OR [status]='DUPLICATE' OR [status]='PENDING'))
GO
ALTER TABLE [dbo].[symphony_outbound_data] ADD CONSTRAINT [symphony_outbound_data_pk] PRIMARY KEY CLUSTERED  ([row_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[symphony_outbound_data] ADD CONSTRAINT [symphony_outbound_data_fk1] FOREIGN KEY ([archived_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[symphony_outbound_data] ADD CONSTRAINT [symphony_outbound_data_fk2] FOREIGN KEY ([book_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[symphony_outbound_data] ADD CONSTRAINT [symphony_outbound_data_fk3] FOREIGN KEY ([duplicate_of]) REFERENCES [dbo].[symphony_outbound_data] ([row_id])
GO
GRANT DELETE ON  [dbo].[symphony_outbound_data] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[symphony_outbound_data] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[symphony_outbound_data] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[symphony_outbound_data] TO [next_usr]
GO
