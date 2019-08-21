CREATE TABLE [dbo].[aud_penalty_rule_content_basis]
(
[oid] [int] NOT NULL,
[cp_formula_oid] [int] NULL,
[price_rule_oid] [int] NULL,
[spec_from_value] [float] NULL,
[spec_to_value] [float] NULL,
[inc_dec_value] [float] NULL,
[penalty_charge] [float] NULL,
[floor_or_ceiling_basis] [float] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_penalty_rule_content_basis] ON [dbo].[aud_penalty_rule_content_basis] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_penalty_rule_content_basis_idx1] ON [dbo].[aud_penalty_rule_content_basis] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_penalty_rule_content_basis] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_penalty_rule_content_basis] TO [next_usr]
GO
