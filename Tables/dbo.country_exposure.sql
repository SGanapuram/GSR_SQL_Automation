CREATE TABLE [dbo].[country_exposure]
(
[country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[country_exp_pay_amt] [float] NULL,
[country_exp_recv_amt] [float] NULL,
[country_exp_profit_amt] [float] NULL,
[country_exp_loss_amt] [float] NULL,
[country_exp_gross_amt] [float] NULL,
[country_flw_pay_amt] [float] NULL,
[country_flw_rec_amt] [float] NULL,
[country_exp_profit_qty] [float] NULL,
[country_exp_loss_qty] [float] NULL,
[country_rexp_pay_amt] [float] NULL,
[country_rexp_recv_amt] [float] NULL,
[country_rexp_profit_amt] [float] NULL,
[country_rexp_loss_amt] [float] NULL,
[country_rexp_gross_amt] [float] NULL,
[country_rflw_pay_amt] [float] NULL,
[country_rflw_rec_amt] [float] NULL,
[country_rexp_profit_qty] [float] NULL,
[country_rexp_loss_qty] [float] NULL,
[country_sexp_pay_amt] [float] NULL,
[country_sexp_recv_amt] [float] NULL,
[country_sexp_profit_amt] [float] NULL,
[country_sexp_loss_amt] [float] NULL,
[country_sexp_gross_amt] [float] NULL,
[country_sflw_pay_amt] [float] NULL,
[country_sflw_rec_amt] [float] NULL,
[country_sexp_profit_qty] [float] NULL,
[country_sexp_loss_qty] [float] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[country_exposure_updtrg]
on [dbo].[country_exposure]
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
   raiserror ('(country_exposure) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(country_exposure) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.country_code = d.country_code )
begin
   raiserror ('(country_exposure) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(country_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.country_code = d.country_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(country_exposure) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[country_exposure] ADD CONSTRAINT [country_exposure_pk] PRIMARY KEY CLUSTERED  ([country_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[country_exposure] ADD CONSTRAINT [country_exposure_fk1] FOREIGN KEY ([country_code]) REFERENCES [dbo].[country] ([country_code])
GO
GRANT DELETE ON  [dbo].[country_exposure] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[country_exposure] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[country_exposure] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[country_exposure] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'country_exposure', NULL, NULL
GO
