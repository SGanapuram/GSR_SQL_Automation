CREATE TABLE [dbo].[aud_commodity_market_formula]
(
[commkt_key] [int] NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[low_bid_formula_num] [int] NULL,
[high_asked_formula_num] [int] NULL,
[avg_closed_formula_num] [int] NULL,
[low_bid_simple_formula_num] [int] NULL,
[high_asked_simple_formula_num] [int] NULL,
[avg_closed_simple_formula_num] [int] NULL,
[cmf_num] [int] NOT NULL,
[mpt_num] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commodity_market_formula] ON [dbo].[aud_commodity_market_formula] ([commkt_key], [trading_prd], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commodity_market_for_idx1] ON [dbo].[aud_commodity_market_formula] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_commodity_market_formula] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_commodity_market_formula] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_commodity_market_formula] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_commodity_market_formula] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_commodity_market_formula] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_commodity_market_formula', NULL, NULL
GO
