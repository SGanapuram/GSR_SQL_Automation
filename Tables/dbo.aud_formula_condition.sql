CREATE TABLE [dbo].[aud_formula_condition]
(
[formula_num] [int] NOT NULL,
[formula_cond_num] [smallint] NOT NULL,
[formula_cond_type] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[formula_cond_date] [datetime] NULL,
[formula_cond_quote_range] [tinyint] NULL,
[formula_cond_last_next_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[src_commkt_key] [int] NULL,
[src_trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[src_price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[src_val_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[basis_commkt_key] [int] NULL,
[basis_trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[basis_price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[basis_val_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_formula_condition] ON [dbo].[aud_formula_condition] ([formula_num], [formula_cond_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_formula_condition_idx1] ON [dbo].[aud_formula_condition] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_formula_condition] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_formula_condition] TO [next_usr]
GO
