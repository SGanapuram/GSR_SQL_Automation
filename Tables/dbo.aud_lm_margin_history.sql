CREATE TABLE [dbo].[aud_lm_margin_history]
(
[oid] [int] NOT NULL,
[margin_asof_day] [datetime] NOT NULL,
[parent_acct_num] [int] NULL,
[clr_brkr_num] [int] NOT NULL,
[span_initial_margin] [decimal] (20, 8) NOT NULL,
[span_maintenance] [decimal] (20, 8) NOT NULL,
[net_future_value] [decimal] (20, 8) NOT NULL,
[net_option_value] [decimal] (20, 8) NOT NULL,
[new_trade_basis] [decimal] (20, 8) NOT NULL,
[premium] [decimal] (20, 8) NOT NULL,
[initial_margin] [decimal] (20, 8) NOT NULL,
[variation] [decimal] (20, 8) NOT NULL,
[margin_requirement] [decimal] (20, 8) NOT NULL,
[balance_forward] [decimal] (20, 8) NOT NULL,
[payment_due] [decimal] (20, 8) NOT NULL,
[payment] [decimal] (20, 8) NOT NULL,
[new_balance] [decimal] (20, 8) NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lm_margin_history] ON [dbo].[aud_lm_margin_history] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lm_margin_history_idx1] ON [dbo].[aud_lm_margin_history] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_lm_margin_history] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_lm_margin_history] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_lm_margin_history] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_lm_margin_history] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_lm_margin_history] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_lm_margin_history', NULL, NULL
GO
