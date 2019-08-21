CREATE TABLE [dbo].[aud_trade_item_edpl]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[open_trade_value] [numeric] (20, 8) NULL,
[closed_trade_value] [numeric] (20, 8) NULL,
[market_value] [numeric] (20, 8) NULL,
[trade_qty] [numeric] (20, 8) NULL,
[latest_pl] [numeric] (20, 8) NULL,
[day_pl] [numeric] (20, 8) NULL,
[trade_modified_after_pass] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[asof_date] [datetime] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[addl_cost_sum] [numeric] (20, 8) NULL
) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_trade_item_edpl] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_edpl] TO [next_usr]
GO
