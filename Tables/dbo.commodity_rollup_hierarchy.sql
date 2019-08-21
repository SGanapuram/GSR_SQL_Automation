CREATE TABLE [dbo].[commodity_rollup_hierarchy]
(
[parent_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rollup_type_code] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[commodity_rollup_hierar_updtrg]
on [dbo].[commodity_rollup_hierarchy]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errorNumber      int,
        @errmsg           varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

select @dummy_update = 0

/* RECORD_STAMP_BEGIN */
if not update(trans_id) 
begin
   raiserror ('(commodity_rollup_hierarchy) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(commodity_rollup_hierarchy) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.parent_cmdty_code = d.parent_cmdty_code and 
                 i.cmdty_code = d.cmdty_code and 
                 i.rollup_type_code = d.rollup_type_code )
begin
   raiserror ('(commodity_rollup_hierarchy) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(parent_cmdty_code) or  
   update(cmdty_code) or  
   update(rollup_type_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.parent_cmdty_code = d.parent_cmdty_code and 
                                   i.cmdty_code = d.cmdty_code and 
                                   i.rollup_type_code = d.rollup_type_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(commodity_rollup_hierarchy) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[commodity_rollup_hierarchy] ADD CONSTRAINT [commodity_rollup_hierarchy_pk] PRIMARY KEY CLUSTERED  ([parent_cmdty_code], [cmdty_code], [rollup_type_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[commodity_rollup_hierarchy] ADD CONSTRAINT [commodity_rollup_hierarchy_fk1] FOREIGN KEY ([parent_cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[commodity_rollup_hierarchy] ADD CONSTRAINT [commodity_rollup_hierarchy_fk2] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[commodity_rollup_hierarchy] ADD CONSTRAINT [commodity_rollup_hierarchy_fk3] FOREIGN KEY ([rollup_type_code]) REFERENCES [dbo].[commodity_rollup_type] ([rollup_type_code])
GO
GRANT DELETE ON  [dbo].[commodity_rollup_hierarchy] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[commodity_rollup_hierarchy] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[commodity_rollup_hierarchy] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[commodity_rollup_hierarchy] TO [next_usr]
GO
