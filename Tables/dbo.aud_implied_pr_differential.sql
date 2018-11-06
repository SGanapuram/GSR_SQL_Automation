CREATE TABLE [dbo].[aud_implied_pr_differential]
(
[differential] [numeric] (14, 4) NOT NULL,
[editor_id] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[implied_commkt_key] [int] NOT NULL,
[implied_price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[implied_trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[oid] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[source_commkt_key] [int] NOT NULL,
[source_price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[source_trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_implied_pr_differential] ON [dbo].[aud_implied_pr_differential] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_implied_pr_different_idx1] ON [dbo].[aud_implied_pr_differential] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_implied_pr_differential] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_implied_pr_differential] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_implied_pr_differential] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_implied_pr_differential] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_implied_pr_differential] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_implied_pr_differential', NULL, NULL
GO
