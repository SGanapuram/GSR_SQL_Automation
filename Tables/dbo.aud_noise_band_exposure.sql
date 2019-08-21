CREATE TABLE [dbo].[aud_noise_band_exposure]
(
[port_num] [int] NOT NULL,
[asof_date] [datetime] NOT NULL,
[rnsv_exposure] [numeric] (20, 4) NULL,
[rnsv_exposure_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rnsv_mtm_value] [numeric] (20, 4) NULL,
[weighted_trade_value] [numeric] (20, 4) NULL,
[weighted_trade_price] [numeric] (20, 4) NULL,
[rnsv_mtm_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[net_exposure_volume] [numeric] (20, 4) NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[market_value] [numeric] (20, 4) NULL,
[weighted_market_price] [numeric] (20, 4) NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_noise_band_exposure] ON [dbo].[aud_noise_band_exposure] ([port_num], [asof_date], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_noise_band_exposure_idx1] ON [dbo].[aud_noise_band_exposure] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_noise_band_exposure] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_noise_band_exposure] TO [next_usr]
GO
