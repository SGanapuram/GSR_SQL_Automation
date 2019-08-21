CREATE TABLE [dbo].[eom_posting_batch]
(
[eom_pb_process_num] [int] NOT NULL,
[cost_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[booking_comp_num] [int] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[eom_posting_batch_updtrg]
on [dbo].[eom_posting_batch]
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
   raiserror ('(eom_posting_batch) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(eom_posting_batch) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.eom_pb_process_num = d.eom_pb_process_num )
begin
   raiserror ('(eom_posting_batch) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(eom_pb_process_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.eom_pb_process_num = d.eom_pb_process_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(eom_posting_batch) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[eom_posting_batch] ADD CONSTRAINT [eom_posting_batch_pk] PRIMARY KEY CLUSTERED  ([eom_pb_process_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[eom_posting_batch] ADD CONSTRAINT [eom_posting_batch_fk1] FOREIGN KEY ([booking_comp_num]) REFERENCES [dbo].[booking_company_info] ([acct_num])
GO
ALTER TABLE [dbo].[eom_posting_batch] ADD CONSTRAINT [eom_posting_batch_fk2] FOREIGN KEY ([cost_status_code]) REFERENCES [dbo].[cost_status] ([cost_status_code])
GO
ALTER TABLE [dbo].[eom_posting_batch] ADD CONSTRAINT [eom_posting_batch_fk3] FOREIGN KEY ([cost_type_code]) REFERENCES [dbo].[cost_type] ([cost_type_code])
GO
GRANT DELETE ON  [dbo].[eom_posting_batch] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[eom_posting_batch] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[eom_posting_batch] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[eom_posting_batch] TO [next_usr]
GO
