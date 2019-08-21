CREATE TABLE [dbo].[aud_trade_item_fill]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[item_fill_num] [smallint] NOT NULL,
[fill_qty] [float] NULL,
[fill_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fill_price] [float] NULL,
[fill_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fill_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fill_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fill_date] [datetime] NULL,
[bsi_fill_num] [int] NULL,
[efp_post_date] [datetime] NULL,
[inhouse_trade_num] [int] NULL,
[inhouse_order_num] [smallint] NULL,
[inhouse_item_num] [smallint] NULL,
[inhouse_fill_num] [smallint] NULL,
[in_out_house_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[outhouse_profit_center] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[outhouse_acct_alloc] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fill_closed_qty] [float] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[broker_fifo_qty] [numeric] (20, 8) NULL,
[port_match_qty] [numeric] (20, 8) NULL,
[fifo_qty] [numeric] (20, 8) NULL,
[external_trade_num] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_fill] ON [dbo].[aud_trade_item_fill] ([trade_num], [order_num], [item_num], [item_fill_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_fill_idx1] ON [dbo].[aud_trade_item_fill] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_trade_item_fill] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_fill] TO [next_usr]
GO
