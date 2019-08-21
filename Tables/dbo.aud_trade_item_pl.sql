CREATE TABLE [dbo].[aud_trade_item_pl]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[mtm_pl] [float] NULL,
[mtm_pl_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pl_asof_date] [datetime] NULL,
[contr_mtm_pl] [float] NULL,
[addl_cost_sum] [float] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[price_fx_rate] [numeric] (20, 8) NULL
) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_trade_item_pl] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_pl] TO [next_usr]
GO
