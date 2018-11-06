CREATE TABLE [dbo].[loc_type_by_order]
(
[order_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[loc_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[loc_type_by_order_updtrg]
on [dbo].[loc_type_by_order]
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
   raiserror ('(loc_type_by_order) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(loc_type_by_order) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.order_type_code = d.order_type_code and 
                 i.loc_type_code = d.loc_type_code )
begin
   raiserror ('(loc_type_by_order) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(order_type_code) or  
   update(loc_type_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.order_type_code = d.order_type_code and 
                                   i.loc_type_code = d.loc_type_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(loc_type_by_order) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[loc_type_by_order] ADD CONSTRAINT [loc_type_by_order_pk] PRIMARY KEY CLUSTERED  ([order_type_code], [loc_type_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[loc_type_by_order] ADD CONSTRAINT [loc_type_by_order_fk1] FOREIGN KEY ([loc_type_code]) REFERENCES [dbo].[location_type] ([loc_type_code])
GO
ALTER TABLE [dbo].[loc_type_by_order] ADD CONSTRAINT [loc_type_by_order_fk2] FOREIGN KEY ([order_type_code]) REFERENCES [dbo].[order_type] ([order_type_code])
GO
GRANT DELETE ON  [dbo].[loc_type_by_order] TO [admin_group]
GO
GRANT INSERT ON  [dbo].[loc_type_by_order] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[loc_type_by_order] TO [admin_group]
GO
GRANT UPDATE ON  [dbo].[loc_type_by_order] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[loc_type_by_order] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'loc_type_by_order', NULL, NULL
GO
