CREATE TABLE [dbo].[currency_exposure]
(
[exposure_num] [int] NOT NULL,
[cash_exp_num] [smallint] NOT NULL,
[curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cash_exp_pay_amt] [float] NULL,
[cash_exp_recv_amt] [float] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[currency_exposure_updtrg]
on [dbo].[currency_exposure]
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
   raiserror ('(currency_exposure) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(currency_exposure) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.exposure_num = d.exposure_num and 
                 i.cash_exp_num = d.cash_exp_num and 
                 i.curr_code = d.curr_code )
begin
   raiserror ('(currency_exposure) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(exposure_num) or  
   update(cash_exp_num) or  
   update(curr_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.exposure_num = d.exposure_num and 
                                   i.cash_exp_num = d.cash_exp_num and 
                                   i.curr_code = d.curr_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(currency_exposure) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[currency_exposure] ADD CONSTRAINT [currency_exposure_pk] PRIMARY KEY CLUSTERED  ([exposure_num], [cash_exp_num], [curr_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[currency_exposure] ADD CONSTRAINT [currency_exposure_fk1] FOREIGN KEY ([curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[currency_exposure] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[currency_exposure] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[currency_exposure] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[currency_exposure] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'currency_exposure', NULL, NULL
GO
