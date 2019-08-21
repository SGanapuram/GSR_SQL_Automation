CREATE TABLE [dbo].[trading_period]
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
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trading_period] ADD CONSTRAINT [trading_period_pk] PRIMARY KEY CLUSTERED  ([commkt_key], [trading_prd]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trading_period_POSGRID_idx1] ON [dbo].[trading_period] ([commkt_key], [trading_prd]) INCLUDE ([last_issue_date], [last_trade_date], [trading_prd_desc]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trading_period] ADD CONSTRAINT [trading_period_uk1] UNIQUE NONCLUSTERED  ([commkt_key], [trading_prd], [last_del_date], [last_trade_date]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trading_period] ADD CONSTRAINT [trading_period_fk1] FOREIGN KEY ([commkt_key]) REFERENCES [dbo].[commodity_market] ([commkt_key])
GO
GRANT DELETE ON  [dbo].[trading_period] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trading_period] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trading_period] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trading_period] TO [next_usr]
GO
