CREATE TABLE [dbo].[aud_exch_tools_trade]
(
[external_trade_oid] [int] NOT NULL,
[accepted_action] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[accepted_broker] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[accepted_company] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[accepted_trader] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[buyer_account] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commodity] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[creation_date] [datetime] NOT NULL,
[exch_tools_trade_num] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[input_action] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[input_broker] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[input_company] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[input_trader] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price] [float] NOT NULL,
[quantity] [float] NOT NULL,
[seller_account] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trading_period] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[begin_date] [datetime] NULL,
[end_date] [datetime] NULL,
[call_put] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[strike_price] [float] NULL,
[buyer_comm_cost] [float] NULL,
[buyer_comm_curr] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[seller_comm_cost] [float] NULL,
[seller_comm_curr] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[buyer_clrng_broker] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[seller_clrng_broker] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[external_comment_oid] [int] NULL,
[acct_contact] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[gtc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trade_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[risk_market] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[title_market] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qty_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_date_from] [datetime] NULL,
[del_date_to] [datetime] NULL,
[mot] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[title_transfer] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_deemed_date] [datetime] NULL,
[price_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_currency] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[template_trade_num] [int] NULL,
[float_market_quote1] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[float_market_quote2] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[float_qty1] [numeric] (20, 8) NULL,
[float_qty2] [numeric] (20, 8) NULL,
[premium_date] [datetime] NULL,
[auto_exerc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[product_id] [int] NULL,
[memo_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_exch_tools_trade] ON [dbo].[aud_exch_tools_trade] ([external_trade_oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_exch_tools_trade_idx1] ON [dbo].[aud_exch_tools_trade] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_exch_tools_trade] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_exch_tools_trade] TO [next_usr]
GO
