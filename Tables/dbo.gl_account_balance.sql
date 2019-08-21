CREATE TABLE [dbo].[gl_account_balance]
(
[booking_comp_num] [int] NOT NULL,
[balance_date] [datetime] NOT NULL,
[balance_type] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_code] [char] (45) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[dept_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_balance] [float] NOT NULL,
[acct_balance_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[booking_period] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[gl_account_balance_updtrg]
on [dbo].[gl_account_balance]
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
   raiserror ('(gl_account_balance) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(gl_account_balance) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.booking_comp_num = d.booking_comp_num and 
                 i.balance_date = d.balance_date and 
                 i.balance_type = d.balance_type and 
                 i.acct_code = d.acct_code )
begin
   raiserror ('(gl_account_balance) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(booking_comp_num) or  
   update(balance_date) or  
   update(balance_type) or  
   update(acct_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.booking_comp_num = d.booking_comp_num and 
                                   i.balance_date = d.balance_date and 
                                   i.balance_type = d.balance_type and 
                                   i.acct_code = d.acct_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(gl_account_balance) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[gl_account_balance] ADD CONSTRAINT [gl_account_balance_pk] PRIMARY KEY CLUSTERED  ([booking_comp_num], [balance_date], [balance_type], [acct_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[gl_account_balance] ADD CONSTRAINT [gl_account_balance_fk1] FOREIGN KEY ([booking_comp_num]) REFERENCES [dbo].[booking_company_info] ([acct_num])
GO
ALTER TABLE [dbo].[gl_account_balance] ADD CONSTRAINT [gl_account_balance_fk2] FOREIGN KEY ([acct_balance_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[gl_account_balance] ADD CONSTRAINT [gl_account_balance_fk3] FOREIGN KEY ([dept_code]) REFERENCES [dbo].[department] ([dept_code])
GO
GRANT DELETE ON  [dbo].[gl_account_balance] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[gl_account_balance] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[gl_account_balance] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[gl_account_balance] TO [next_usr]
GO
