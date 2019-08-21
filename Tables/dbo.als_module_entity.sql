CREATE TABLE [dbo].[als_module_entity]
(
[als_module_group_id] [int] NOT NULL,
[entity_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[operation_type_mask] [int] NULL CONSTRAINT [df_als_module_entity_operation_type_mask] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[als_module_entity_updtrg]
on [dbo].[als_module_entity]
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
   raiserror ('(als_module_entity) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(als_module_entity) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.als_module_group_id = d.als_module_group_id and
                 i.entity_name = d.entity_name )
begin
   raiserror ('(als_module_entity) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(als_module_group_id) or
   update(entity_name)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.als_module_group_id = d.als_module_group_id and
                                   i.entity_name = d.entity_name )
   if (@count_num_rows <> @num_rows)
   begin
      raiserror ('(als_module_entity) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[als_module_entity] ADD CONSTRAINT [als_module_entity_pk] PRIMARY KEY CLUSTERED  ([als_module_group_id], [entity_name]) WITH (ALLOW_PAGE_LOCKS=OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[als_module_entity] ADD CONSTRAINT [als_module_entity_fk1] FOREIGN KEY ([als_module_group_id]) REFERENCES [dbo].[server_config] ([als_module_group_id])
GO
GRANT DELETE ON  [dbo].[als_module_entity] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[als_module_entity] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[als_module_entity] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[als_module_entity] TO [next_usr]
GO
