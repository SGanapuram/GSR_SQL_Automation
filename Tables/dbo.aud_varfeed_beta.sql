CREATE TABLE [dbo].[aud_varfeed_beta]
(
[commkt_key] [int] NOT NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[val_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[risk_factor] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_beta] [numeric] (20, 8) NULL,
[vol_beta] [numeric] (20, 8) NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_varfeed_beta] ON [dbo].[aud_varfeed_beta] ([commkt_key], [price_source_code], [val_type], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_varfeed_beta_idx1] ON [dbo].[aud_varfeed_beta] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_varfeed_beta] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_varfeed_beta] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_varfeed_beta] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_varfeed_beta] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_varfeed_beta] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_varfeed_beta', NULL, NULL
GO
