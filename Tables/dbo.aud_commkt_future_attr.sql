CREATE TABLE [dbo].[aud_commkt_future_attr]
(
[commkt_key] [int] NOT NULL,
[commkt_fut_attr_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_lot_size] [float] NOT NULL,
[commkt_lot_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_settlement_ind] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_price_fmt] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_trading_mth_ind] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_nearby_mask] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_min_price_var] [float] NULL,
[commkt_max_price_var] [float] NULL,
[commkt_spot_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_price_freq] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_price_freq_as_of] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_price_series] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_spot_mth_qty] [float] NULL,
[commkt_fwd_mth_qty] [float] NULL,
[commkt_total_open_qty] [float] NULL,
[commkt_formula_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_interpol_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_num_mth_out] [smallint] NULL,
[commkt_support_price_type] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_same_as_mkt_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_same_as_cmdty_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_forex_mkt_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_forex_cmdty_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_price_div_mul_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_limit_move_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_point_conv_num] [float] NULL,
[sec_price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sec_alias_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commkt_future_attr] ON [dbo].[aud_commkt_future_attr] ([commkt_key], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commkt_future_attr_idx1] ON [dbo].[aud_commkt_future_attr] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_commkt_future_attr] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_commkt_future_attr] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_commkt_future_attr] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_commkt_future_attr] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_commkt_future_attr] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_commkt_future_attr', NULL, NULL
GO
