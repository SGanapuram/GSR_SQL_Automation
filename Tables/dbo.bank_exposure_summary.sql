CREATE TABLE [dbo].[bank_exposure_summary]
(
[acct_num] [int] NOT NULL,
[exp_amt] [float] NULL,
[exp_imp_exp_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[bank_exposure_summary_updtrg]
on [dbo].[bank_exposure_summary]
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
   raiserror ('(bank_exposure_summary) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(bank_exposure_summary) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.acct_num = d.acct_num  and 
                 i.exp_imp_exp_ind = d.exp_imp_exp_ind )
begin
   raiserror ('(bank_exposure_summary) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(acct_num) or 
   update(exp_imp_exp_ind) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.acct_num = d.acct_num  and 
                                   i.exp_imp_exp_ind = d.exp_imp_exp_ind )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(bank_exposure_summary) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[bank_exposure_summary] ADD CONSTRAINT [bank_exposure_summary_pk] PRIMARY KEY CLUSTERED  ([acct_num], [exp_imp_exp_ind]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[bank_exposure_summary] ADD CONSTRAINT [bank_exposure_summary_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
GRANT DELETE ON  [dbo].[bank_exposure_summary] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[bank_exposure_summary] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[bank_exposure_summary] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[bank_exposure_summary] TO [next_usr]
GO
