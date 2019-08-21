CREATE TABLE [dbo].[aud_qp_option]
(
[oid] [int] NOT NULL,
[cp_formula_oid] [int] NULL,
[price_rule_oid] [int] NULL,
[quote_index] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_key] [int] NULL,
[quote_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[quote_point] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_string] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_qp_option] ON [dbo].[aud_qp_option] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_qp_option_idx1] ON [dbo].[aud_qp_option] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_qp_option] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_qp_option] TO [next_usr]
GO
