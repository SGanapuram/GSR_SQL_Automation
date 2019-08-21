CREATE TABLE [dbo].[archive_tid_mtm]
(
[dist_num] [int] NOT NULL,
[mtm_pl_asof_date] [datetime] NOT NULL,
[open_pl] [float] NULL,
[closed_pl] [float] NULL,
[addl_cost_sum] [float] NULL,
[delta] [float] NULL,
[trans_id] [int] NOT NULL,
[vega] [numeric] (20, 8) NULL,
[volatility] [numeric] (20, 8) NULL,
[theta] [numeric] (20, 8) NULL,
[curr_conv_rate] [numeric] (20, 8) NULL,
[curr_code_conv_from] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[curr_code_conv_to] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[interest_rate] [numeric] (20, 8) NULL,
[price_diff_value] [numeric] (20, 8) NULL,
[dist_qty] [numeric] (20, 8) NULL,
[alloc_qty] [numeric] (20, 8) NULL,
[trade_value] [numeric] (20, 8) NULL,
[market_value] [numeric] (20, 8) NULL,
[curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[gamma] [numeric] (20, 8) NULL,
[discount_factor] [numeric] (20, 8) NULL,
[rho] [numeric] (20, 8) NULL,
[drift] [numeric] (20, 8) NULL,
[trade_modified_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_archive_tid_mtm_trade_modified_ind] DEFAULT ('N'),
[commkt_key] [int] NULL,
[pos_num] [int] NULL,
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[qty_uom_code_conv_to] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sec_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sec_conversion_factor] [numeric] (20, 8) NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[last_trade_date] [datetime] NULL,
[dist_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[opt_model_type] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[leg_total_days] [int] NULL,
[opt_priced_days] [int] NULL,
[opt_priced_price] [numeric] (20, 8) NULL,
[opt_avg_correlation] [numeric] (20, 8) NULL,
[priced_qty] [numeric] (20, 8) NULL,
[qty_uom_conv_rate] [numeric] (20, 8) NULL,
[avg_price] [numeric] (20, 8) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[archive_tid_mtm] ADD CONSTRAINT [archive_tid_mtm_pk] PRIMARY KEY CLUSTERED  ([dist_num], [mtm_pl_asof_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[archive_tid_mtm] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[archive_tid_mtm] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[archive_tid_mtm] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[archive_tid_mtm] TO [next_usr]
GO
