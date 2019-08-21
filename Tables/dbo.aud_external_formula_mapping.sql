CREATE TABLE [dbo].[aud_external_formula_mapping]
(
[oid] [int] NOT NULL,
[quote_string] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_source] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_key] [int] NULL,
[price_point] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[ui_index] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ui_source] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ui_point] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ui_formula_str] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[element_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[element_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[per_spec_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_external_formula_mapping] ON [dbo].[aud_external_formula_mapping] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_external_formula_mapping_idx1] ON [dbo].[aud_external_formula_mapping] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_external_formula_mapping] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_external_formula_mapping] TO [next_usr]
GO
