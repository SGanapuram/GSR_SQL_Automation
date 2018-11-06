CREATE TABLE [dbo].[mtm_cash_exposure]
(
[exposure_num] [int] NOT NULL,
[exp_date] [datetime] NOT NULL,
[cash_exp_rec_amt] [float] NULL,
[cash_exp_pay_amt] [float] NULL,
[cash_exp_net_amt] [float] NULL,
[cash_flow_rec_exp_amt] [float] NULL,
[cash_flow_pay_exp_amt] [float] NULL,
[mtm_exp_amt] [float] NULL,
[exp_type] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[gross_mtm_exp_amt] [numeric] (20, 8) NULL,
[alt_cash_exp_rec_amt] [numeric] (20, 8) NULL,
[alt_cash_exp_pay_amt] [numeric] (20, 8) NULL,
[alt_cash_flow_rec_exp_amt] [numeric] (20, 8) NULL,
[alt_cash_flow_pay_exp_amt] [numeric] (20, 8) NULL,
[overdue_mtm_exp_amt] [numeric] (20, 8) NULL,
[overdue_gross_mtm_exp_amt] [numeric] (20, 8) NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[mtm_cash_exposure_deltrg]
on [dbo].[mtm_cash_exposure]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
        @atrans_id int

select @num_rows = @@rowcount
if @num_rows = 0
   return

/* The following codes were commented out reguested by Mitch Lee 
   for performance concern   Jan-10-2002 */
/* AUDIT_CODE_BEGIN 
select @atrans_id = max(trans_id)
from dbo.icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(mtm_cash_exposure) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,10,1)
   if @@trancount > 0 rollback tran

   return
end


insert dbo.aud_mtm_cash_exposure
   (exposure_num,	
    exp_date,
    cash_exp_rec_amt,				
    cash_exp_pay_amt,		
    cash_exp_net_amt,		
    cash_flow_rec_exp_amt,		
    cash_flow_pay_exp_amt,		
    mtm_exp_amt,
    exp_type,		
    gross_mtm_exp_amt,
    alt_cash_exp_rec_amt,
    alt_cash_exp_pay_amt,	
    alt_cash_flow_rec_exp_amt,
    alt_cash_flow_pay_exp_amt,
    overdue_mtm_exp_amt,
    overdue_gross_mtm_exp_amt,
    trans_id,
    resp_trans_id)
select
   d.exposure_num,	
   d.exp_date,
   d.cash_exp_rec_amt,				
   d.cash_exp_pay_amt,		
   d.cash_exp_net_amt,	
   d.cash_flow_rec_exp_amt,		
   d.cash_flow_pay_exp_amt,		
   d.mtm_exp_amt,
   d.exp_type,		
   d.gross_mtm_exp_amt,
   d.alt_cash_exp_rec_amt,
   d.alt_cash_exp_pay_amt,	
   d.alt_cash_flow_rec_exp_amt,
   d.alt_cash_flow_pay_exp_amt,
   d.overdue_mtm_exp_amt,
   d.overdue_gross_mtm_exp_amt,
   d.trans_id,
   @atrans_id
from deleted d

 AUDIT_CODE_END */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[mtm_cash_exposure_updtrg]
on [dbo].[mtm_cash_exposure]
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
   raiserror ('(mtm_cash_exposure) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(mtm_cash_exposure) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.exposure_num = d.exposure_num and
                 i.exp_date = d.exp_date )
begin
   raiserror ('(mtm_cash_exposure) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(exposure_num) or
   update(exp_date)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.exposure_num = d.exposure_num and
                                   i.exp_date = d.exp_date )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(mtm_cash_exposure) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end
  
return
GO
ALTER TABLE [dbo].[mtm_cash_exposure] ADD CONSTRAINT [mtm_cash_exposure_pk] PRIMARY KEY NONCLUSTERED  ([exposure_num], [exp_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[mtm_cash_exposure] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[mtm_cash_exposure] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[mtm_cash_exposure] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[mtm_cash_exposure] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'mtm_cash_exposure', NULL, NULL
GO
