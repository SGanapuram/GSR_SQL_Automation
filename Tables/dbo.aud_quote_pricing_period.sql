CREATE TABLE [dbo].[aud_quote_pricing_period]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[accum_num] [smallint] NOT NULL,
[qpp_num] [smallint] NOT NULL,
[formula_num] [int] NULL,
[formula_body_num] [tinyint] NULL,
[formula_comp_num] [smallint] NULL,
[real_trading_prd] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[risk_trading_prd] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[nominal_start_date] [datetime] NULL,
[nominal_end_date] [datetime] NULL,
[quote_start_date] [datetime] NULL,
[quote_end_date] [datetime] NULL,
[num_of_pricing_days] [smallint] NULL,
[num_of_days_priced] [smallint] NULL,
[total_qty] [float] NOT NULL,
[priced_qty] [float] NULL,
[qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[priced_price] [float] NULL,
[open_price] [float] NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[last_pricing_date] [datetime] NULL,
[manual_override_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[cal_impact_start_date] [datetime] NULL,
[cal_impact_end_date] [datetime] NULL,
[calendar_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trigger_num] [tinyint] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_quote_pricing_period_idx1] ON [dbo].[aud_quote_pricing_period] ([formula_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [aud_quote_pricing_period] ON [dbo].[aud_quote_pricing_period] ([risk_trading_prd], [real_trading_prd], [formula_comp_num], [formula_body_num], [formula_num], [qpp_num], [accum_num], [item_num], [order_num], [trade_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_quote_pricing_period_idx] ON [dbo].[aud_quote_pricing_period] ([trade_num], [order_num], [item_num], [accum_num], [qpp_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_quote_pricing_period_idx2] ON [dbo].[aud_quote_pricing_period] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_quote_pricing_period] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_quote_pricing_period] TO [next_usr]
GO
