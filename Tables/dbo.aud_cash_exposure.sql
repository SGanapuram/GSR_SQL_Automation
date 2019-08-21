CREATE TABLE [dbo].[aud_cash_exposure]
(
[exposure_num] [int] NOT NULL,
[cash_exp_num] [smallint] NOT NULL,
[cash_exp_date] [datetime] NOT NULL,
[cash_is_due_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cash_exp_rec_amt] [float] NULL,
[cash_exp_pay_amt] [float] NULL,
[cash_exp_net_amt] [float] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cash_exposure] ON [dbo].[aud_cash_exposure] ([exposure_num], [cash_exp_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cash_exposure_idx1] ON [dbo].[aud_cash_exposure] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_cash_exposure] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_cash_exposure] TO [next_usr]
GO
