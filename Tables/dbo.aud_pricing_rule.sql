CREATE TABLE [dbo].[aud_pricing_rule]
(
[oid] [int] NOT NULL,
[cp_formula_oid] [int] NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[per_spec_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[base_value] [float] NULL,
[use_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[rule_type_ind] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[curr_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_basis] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[min_charge] [float] NULL,
[max_charge] [float] NULL,
[max_content] [float] NULL,
[min_content] [float] NULL,
[rule_direction_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qp_decl_option_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[parent_pricing_rule_oid] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_pricing_rule] ON [dbo].[aud_pricing_rule] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_pricing_rule_idx1] ON [dbo].[aud_pricing_rule] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_pricing_rule] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_pricing_rule] TO [next_usr]
GO
