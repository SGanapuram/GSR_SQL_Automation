CREATE TABLE [dbo].[user_group_permission]
(
[user_group_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[function_num] [int] NOT NULL,
[perm_level] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[user_group_permission_updtrg]
on [dbo].[user_group_permission]
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
   raiserror ('(user_group_permission) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(user_group_permission) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.user_group_code = d.user_group_code and 
                 i.function_num = d.function_num )
begin
   raiserror ('(user_group_permission) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(user_group_code) or  
   update(function_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.user_group_code = d.user_group_code and 
                                   i.function_num = d.function_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(user_group_permission) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[user_group_permission] ADD CONSTRAINT [user_group_permission_pk] PRIMARY KEY CLUSTERED  ([user_group_code], [function_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[user_group_permission] ADD CONSTRAINT [user_group_permission_fk1] FOREIGN KEY ([function_num]) REFERENCES [dbo].[icts_function] ([function_num])
GO
ALTER TABLE [dbo].[user_group_permission] ADD CONSTRAINT [user_group_permission_fk2] FOREIGN KEY ([user_group_code]) REFERENCES [dbo].[user_group] ([user_group_code])
GO
GRANT DELETE ON  [dbo].[user_group_permission] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[user_group_permission] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[user_group_permission] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[user_group_permission] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'user_group_permission', NULL, NULL
GO
