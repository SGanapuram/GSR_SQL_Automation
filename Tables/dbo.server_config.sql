CREATE TABLE [dbo].[server_config]
(
[als_module_group_id] [int] NOT NULL,
[als_module_group_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[multi_instances_ind] [bit] NOT NULL CONSTRAINT [DF__server_co__multi__2EE5E349] DEFAULT ((0)),
[critical_ind] [bit] NOT NULL CONSTRAINT [DF__server_co__criti__2FDA0782] DEFAULT ((0)),
[trans_type_mask] [int] NOT NULL CONSTRAINT [DF__server_co__trans__30CE2BBB] DEFAULT ((0)),
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[server_config_updtrg]
on [dbo].[server_config]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @errmsg           varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

/* RECORD_STAMP_BEGIN */
if not update(trans_id) 
begin
   raiserror ('(server_config) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(server_config) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.als_module_group_id = d.als_module_group_id)
begin
   raiserror ('(server_config) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(als_module_group_id)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.als_module_group_id = d.als_module_group_id)
   if (@count_num_rows <> @num_rows)
   begin
      raiserror ('(server_config) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[server_config] ADD CONSTRAINT [server_config_pk] PRIMARY KEY CLUSTERED  ([als_module_group_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [server_config_idx1] ON [dbo].[server_config] ([als_module_group_desc]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[server_config] TO [admin_group]
GO
GRANT INSERT ON  [dbo].[server_config] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[server_config] TO [admin_group]
GO
GRANT UPDATE ON  [dbo].[server_config] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[server_config] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'server_config', NULL, NULL
GO
