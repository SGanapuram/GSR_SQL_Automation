CREATE TABLE [dbo].[alias]
(
[table_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[key_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[column_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[alias_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[complex_name] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[alias_updtrg]
on [dbo].[alias]
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
   raiserror ('(alias) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(alias) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.table_name = d.table_name and 
                 i.key_name = d.key_name )
begin
   raiserror ('(alias) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(table_name) or 
   update(key_name) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.table_name = d.table_name and 
                                   i.key_name = d.key_name )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(alias) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[alias] ADD CONSTRAINT [alias_pk] PRIMARY KEY CLUSTERED  ([table_name], [key_name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[alias] TO [admin_group]
GO
GRANT INSERT ON  [dbo].[alias] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[alias] TO [admin_group]
GO
GRANT UPDATE ON  [dbo].[alias] TO [admin_group]
GO
GRANT DELETE ON  [dbo].[alias] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[alias] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[alias] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[alias] TO [next_usr]
GO
