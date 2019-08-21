CREATE TABLE [dbo].[aud_spread_composition]
(
[spread_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[comp_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trading_prd_offset] [int] NOT NULL,
[long_short_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spread_qty_factor] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[product_id] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_spread_composition] ON [dbo].[aud_spread_composition] ([spread_cmdty_code], [comp_cmdty_code], [trading_prd_offset], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_spread_composition_idx1] ON [dbo].[aud_spread_composition] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_spread_composition] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_spread_composition] TO [next_usr]
GO
