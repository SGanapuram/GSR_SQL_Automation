CREATE TABLE [dbo].[aud_simple_formula]
(
[simple_formula_num] [int] NOT NULL,
[quote_commkt_key] [int] NOT NULL,
[quote_trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[quote_price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[quote_price_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[quote_diff] [float] NULL,
[quote_diff_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[quote_diff_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_simple_formula] ON [dbo].[aud_simple_formula] ([simple_formula_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_simple_formula_idx1] ON [dbo].[aud_simple_formula] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_simple_formula] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_simple_formula] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_simple_formula] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_simple_formula] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_simple_formula] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_simple_formula', NULL, NULL
GO
