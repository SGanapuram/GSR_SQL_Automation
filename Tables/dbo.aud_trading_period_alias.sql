CREATE TABLE [dbo].[aud_trading_period_alias]
(
[commkt_key] [int] NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alias_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alias_high_low_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trading_prd_alias_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alias_format_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trading_period_alias] ON [dbo].[aud_trading_period_alias] ([commkt_key], [trading_prd], [price_source_code], [alias_source_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trading_period_alias_idx1] ON [dbo].[aud_trading_period_alias] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_trading_period_alias] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trading_period_alias] TO [next_usr]
GO
