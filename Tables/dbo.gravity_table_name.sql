CREATE TABLE [dbo].[gravity_table_name]
(
[gravity_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[gravity_table_name] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[gravity_table_effect_date] [datetime] NOT NULL,
[price_adj_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_adj_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[gravity_table_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[gravity_table_name_updtrg]
on [dbo].[gravity_table_name]
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
   raiserror ('(gravity_table_name) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(gravity_table_name) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.gravity_source_code = d.gravity_source_code and 
                 i.gravity_table_name = d.gravity_table_name and 
                 i.gravity_table_effect_date = d.gravity_table_effect_date )
begin
   raiserror ('(gravity_table_name) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(gravity_source_code) or  
   update(gravity_table_name) or  
   update(gravity_table_effect_date) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.gravity_source_code = d.gravity_source_code and 
                                   i.gravity_table_name = d.gravity_table_name and 
                                   i.gravity_table_effect_date = d.gravity_table_effect_date )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(gravity_table_name) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[gravity_table_name] ADD CONSTRAINT [gravity_table_name_pk] PRIMARY KEY CLUSTERED  ([gravity_source_code], [gravity_table_name], [gravity_table_effect_date]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[gravity_table_name] ADD CONSTRAINT [gravity_table_name_fk1] FOREIGN KEY ([price_adj_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[gravity_table_name] ADD CONSTRAINT [gravity_table_name_fk2] FOREIGN KEY ([price_adj_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[gravity_table_name] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[gravity_table_name] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[gravity_table_name] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[gravity_table_name] TO [next_usr]
GO
