CREATE TABLE [dbo].[aud_fx_hedge_rate]
(
[fx_hedge_rate_num] [int] NOT NULL,
[commkt_key] [int] NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[clr_brkr_num] [int] NOT NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[from_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[to_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[conv_rate] [numeric] (20, 8) NOT NULL,
[mul_div_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fx_hedge_rate] ON [dbo].[aud_fx_hedge_rate] ([fx_hedge_rate_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fx_hedge_rate_idx1] ON [dbo].[aud_fx_hedge_rate] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_fx_hedge_rate] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_fx_hedge_rate] TO [next_usr]
GO
