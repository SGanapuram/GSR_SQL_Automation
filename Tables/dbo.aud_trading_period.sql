CREATE TABLE [dbo].[aud_trading_period]
(
[commkt_key] [int] NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[last_trade_date] [datetime] NULL,
[opt_exp_date] [datetime] NULL,
[first_del_date] [datetime] NULL,
[last_del_date] [datetime] NULL,
[first_issue_date] [datetime] NULL,
[last_issue_date] [datetime] NULL,
[last_quote_date] [datetime] NULL,
[trading_prd_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[opt_eval_method] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trading_period] ON [dbo].[aud_trading_period] ([commkt_key], [trading_prd], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trading_period_idx1] ON [dbo].[aud_trading_period] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_trading_period] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trading_period] TO [next_usr]
GO
