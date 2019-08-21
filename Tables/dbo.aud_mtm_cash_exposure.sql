CREATE TABLE [dbo].[aud_mtm_cash_exposure]
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
[resp_trans_id] [int] NOT NULL,
[gross_mtm_exp_amt] [numeric] (20, 8) NULL,
[alt_cash_exp_rec_amt] [numeric] (20, 8) NULL,
[alt_cash_exp_pay_amt] [numeric] (20, 8) NULL,
[alt_cash_flow_rec_exp_amt] [numeric] (20, 8) NULL,
[alt_cash_flow_pay_exp_amt] [numeric] (20, 8) NULL,
[overdue_mtm_exp_amt] [numeric] (20, 8) NULL,
[overdue_gross_mtm_exp_amt] [numeric] (20, 8) NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_mtm_cash_exposure] ON [dbo].[aud_mtm_cash_exposure] ([exposure_num], [exp_date], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_mtm_cash_exposure_idx1] ON [dbo].[aud_mtm_cash_exposure] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_mtm_cash_exposure] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_mtm_cash_exposure] TO [next_usr]
GO
