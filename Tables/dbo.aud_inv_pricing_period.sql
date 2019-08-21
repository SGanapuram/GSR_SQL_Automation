CREATE TABLE [dbo].[aud_inv_pricing_period]
(
[inv_num] [int] NOT NULL,
[inv_price_start_date] [datetime] NULL,
[inv_price_end_date] [datetime] NULL,
[num_of_pricing_days] [smallint] NULL,
[inv_price_excl_sat] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_price_excl_sun] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_price_excl_hol] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_inv_pricing_period] ON [dbo].[aud_inv_pricing_period] ([inv_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_inv_pricing_period_idx1] ON [dbo].[aud_inv_pricing_period] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_inv_pricing_period] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_inv_pricing_period] TO [next_usr]
GO
