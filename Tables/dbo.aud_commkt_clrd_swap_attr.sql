CREATE TABLE [dbo].[aud_commkt_clrd_swap_attr]
(
[commkt_key] [int] NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_lot_size] [decimal] (20, 8) NOT NULL,
[commkt_lot_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_settlement_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_trading_mth_ind] [char] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_nearby_mask] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_num_mth_out] [smallint] NOT NULL,
[comp_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trading_prd_offset] [int] NOT NULL,
[long_short_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spread_qty_factor] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[margin_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_aud_commkt_clrd_swap_attr_margin_type] DEFAULT ('P')
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commkt_clrd_swap_attr] ON [dbo].[aud_commkt_clrd_swap_attr] ([commkt_key], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commkt_clrd_swap_attr_idx1] ON [dbo].[aud_commkt_clrd_swap_attr] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_commkt_clrd_swap_attr] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_commkt_clrd_swap_attr] TO [next_usr]
GO
