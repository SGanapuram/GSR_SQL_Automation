CREATE TABLE [dbo].[aud_conc_assay]
(
[oid] [int] NOT NULL,
[conc_contract_oid] [int] NOT NULL,
[conc_prior_ver_oid] [int] NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[per_spec_uom_code] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_min_value] [float] NULL,
[spec_min_value_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_max_value] [float] NULL,
[spec_max_value_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_typical_value] [float] NULL,
[spec_typical_value_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_regulatory_limit] [float] NULL,
[spec_regulatory_limit_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[primary_type] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[secondary_type] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[row_order_num] [int] NULL,
[analysis_basis] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[umpire_rule] [int] NULL,
[sl_applicable] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[splitting_limit] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_assay] ON [dbo].[aud_conc_assay] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_assay_idx1] ON [dbo].[aud_conc_assay] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_conc_assay] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_conc_assay] TO [next_usr]
GO
