CREATE TABLE [dbo].[aud_trade_item_dist]
(
[dist_num] [int] NOT NULL,
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[accum_num] [smallint] NULL,
[qpp_num] [smallint] NULL,
[pos_num] [int] NULL,
[real_port_num] [int] NOT NULL,
[dist_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[real_synth_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[is_equiv_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[what_if_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bus_date] [datetime] NOT NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[dist_qty] [float] NOT NULL,
[alloc_qty] [float] NOT NULL,
[discount_qty] [float] NOT NULL,
[priced_qty] [float] NOT NULL,
[qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[qty_uom_code_conv_to] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qty_uom_conv_rate] [float] NULL,
[price_curr_code_conv_to] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_curr_conv_rate] [float] NULL,
[price_uom_code_conv_to] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_uom_conv_rate] [float] NULL,
[spread_pos_group_num] [int] NULL,
[delivered_qty] [float] NULL,
[open_pl] [float] NULL,
[pl_asof_date] [datetime] NULL,
[closed_pl] [float] NULL,
[addl_cost_sum] [float] NULL,
[sec_conversion_factor] [float] NULL,
[sec_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_key] [int] NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[estimate_qty] [numeric] (20, 8) NULL,
[formula_num] [int] NULL,
[formula_body_num] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_dist_idx] ON [dbo].[aud_trade_item_dist] ([dist_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [aud_trade_item_dist] ON [dbo].[aud_trade_item_dist] ([dist_qty], [real_port_num], [item_num], [order_num], [trade_num], [dist_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_dist_idx3] ON [dbo].[aud_trade_item_dist] ([trade_num], [order_num], [item_num], [dist_type], [is_equiv_ind], [what_if_ind], [real_port_num], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_dist_idx2] ON [dbo].[aud_trade_item_dist] ([trade_num], [order_num], [item_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_dist_idx1] ON [dbo].[aud_trade_item_dist] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_trade_item_dist] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_dist] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_trade_item_dist] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_trade_item_dist] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_dist] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_trade_item_dist', NULL, NULL
GO
