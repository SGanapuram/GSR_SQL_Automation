CREATE TABLE [dbo].[aud_portfolio_ext_info]
(
[port_num] [int] NOT NULL,
[pl_change_limit] [numeric] (20, 8) NULL,
[pl_change_limit_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pl_new_limit] [numeric] (20, 8) NULL,
[pl_new_limit_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[outright_pos_limit] [numeric] (20, 8) NULL,
[outright_pos_limit_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spread_pos_limit] [numeric] (20, 8) NULL,
[spread_pos_limit_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[risk_neutral_stock_volume] [numeric] (20, 8) NULL,
[noise_band_min_volume] [numeric] (20, 8) NULL,
[noise_band_max_volume] [numeric] (20, 8) NULL,
[noise_band_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[var_limit] [numeric] (20, 8) NULL,
[var_limit_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_portfolio_ext_info] ON [dbo].[aud_portfolio_ext_info] ([port_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_portfolio_ext_info_idx1] ON [dbo].[aud_portfolio_ext_info] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_portfolio_ext_info] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_portfolio_ext_info] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_portfolio_ext_info] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_portfolio_ext_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_portfolio_ext_info] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_portfolio_ext_info', NULL, NULL
GO
