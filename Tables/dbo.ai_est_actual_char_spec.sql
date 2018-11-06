CREATE TABLE [dbo].[ai_est_actual_char_spec]
(
[alloc_num] [int] NOT NULL,
[alloc_item_num] [smallint] NOT NULL,
[ai_est_actual_num] [smallint] NOT NULL,
[attr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[attr_value] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ai_est_actual_char_spec_updtrg]
on [dbo].[ai_est_actual_char_spec]
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
   raiserror ('(ai_est_actual_char_spec) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(ai_est_actual_char_spec) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.alloc_num = d.alloc_num and 
                 i.alloc_item_num = d.alloc_item_num and 
                 i.ai_est_actual_num = d.ai_est_actual_num and 
                 i.attr_code = d.attr_code )
begin
   raiserror ('(ai_est_actual_char_spec) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(alloc_num) or  
   update(alloc_item_num) or  
   update(ai_est_actual_num) or  
   update(attr_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.alloc_num = d.alloc_num and 
                                   i.alloc_item_num = d.alloc_item_num and 
                                   i.ai_est_actual_num = d.ai_est_actual_num and 
                                   i.attr_code = d.attr_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(ai_est_actual_char_spec) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[ai_est_actual_char_spec] ADD CONSTRAINT [ai_est_actual_char_spec_pk] PRIMARY KEY CLUSTERED  ([alloc_num], [alloc_item_num], [ai_est_actual_num], [attr_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ai_est_actual_char_spec] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[ai_est_actual_char_spec] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[ai_est_actual_char_spec] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[ai_est_actual_char_spec] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'ai_est_actual_char_spec', NULL, NULL
GO
