CREATE TABLE [dbo].[aud_market_formula_default]
(
[oid] [int] NOT NULL,
[risk_mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_num] [int] NOT NULL,
[active_ind] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_market_formula_default_idx1] ON [dbo].[aud_market_formula_default] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_market_formula_default_idx2] ON [dbo].[aud_market_formula_default] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_market_formula_default] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_market_formula_default] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_market_formula_default] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_market_formula_default] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_market_formula_default] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_market_formula_default', NULL, NULL
GO
