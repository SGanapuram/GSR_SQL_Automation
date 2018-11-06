CREATE TABLE [dbo].[aud_position]
(
[pos_num] [int] NOT NULL,
[real_port_num] [int] NOT NULL,
[pos_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[is_equiv_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[what_if_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_key] [int] NULL,
[trading_prd] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_num] [int] NULL,
[formula_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[option_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[settlement_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[strike_price] [float] NULL,
[strike_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[strike_price_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[put_call_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[opt_exp_date] [datetime] NULL,
[opt_start_date] [datetime] NULL,
[opt_periodicity] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[opt_price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_short_name] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[desired_opt_eval_method] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[desired_otc_opt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[is_hedge_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[long_qty] [float] NOT NULL,
[short_qty] [float] NOT NULL,
[discount_qty] [float] NULL,
[priced_qty] [float] NULL,
[qty_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[avg_purch_price] [float] NULL,
[avg_sale_price] [float] NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sec_long_qty] [float] NULL,
[sec_short_qty] [float] NULL,
[sec_discount_qty] [float] NULL,
[sec_priced_qty] [float] NULL,
[sec_pos_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[pos_status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[last_mtm_price] [numeric] (20, 8) NULL,
[rolled_qty] [numeric] (20, 8) NULL,
[sec_rolled_qty] [numeric] (20, 8) NULL,
[is_cleared_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_body_num] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_position_idx] ON [dbo].[aud_position] ([pos_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_position] ON [dbo].[aud_position] ([pos_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_position_idx1] ON [dbo].[aud_position] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_position] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_position] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_position] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_position] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_position] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_position', NULL, NULL
GO
