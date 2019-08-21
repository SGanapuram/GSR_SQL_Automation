CREATE TABLE [dbo].[aud_fixed_price_content_basis]
(
[oid] [int] NOT NULL,
[cp_formula_oid] [int] NULL,
[price_rule_oid] [int] NULL,
[spec_from_value] [float] NULL,
[spec_to_value] [float] NULL,
[inc_dec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inc_dec_value] [float] NULL,
[floor_or_ceiling_value] [float] NULL,
[app_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price] [float] NULL,
[fixed_pricing_basis] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fixed_price_content_basis] ON [dbo].[aud_fixed_price_content_basis] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fixed_price_content_basis_idx1] ON [dbo].[aud_fixed_price_content_basis] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_fixed_price_content_basis] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_fixed_price_content_basis] TO [next_usr]
GO
