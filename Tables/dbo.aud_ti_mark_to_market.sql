CREATE TABLE [dbo].[aud_ti_mark_to_market]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[mtm_pl_asof_date] [datetime] NOT NULL,
[acct_num] [int] NULL,
[real_port_num] [int] NULL,
[trader_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[creation_date] [datetime] NOT NULL,
[contr_date] [datetime] NULL,
[order_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[booking_comp_num] [int] NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[risk_mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[last_trade_date] [datetime] NULL,
[contr_qty] [numeric] (20, 8) NULL,
[contr_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_qty_periodicity] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[open_qty] [numeric] (20, 8) NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ti_mark_to_market_idx] ON [dbo].[aud_ti_mark_to_market] ([trade_num], [order_num], [item_num], [mtm_pl_asof_date], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ti_mark_to_market_idx1] ON [dbo].[aud_ti_mark_to_market] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_ti_mark_to_market] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_ti_mark_to_market] TO [next_usr]
GO
