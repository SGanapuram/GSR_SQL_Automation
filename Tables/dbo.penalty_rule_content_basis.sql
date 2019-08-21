CREATE TABLE [dbo].[penalty_rule_content_basis]
(
[oid] [int] NOT NULL,
[cp_formula_oid] [int] NULL,
[price_rule_oid] [int] NULL,
[spec_from_value] [float] NULL,
[spec_to_value] [float] NULL,
[inc_dec_value] [float] NULL,
[penalty_charge] [float] NULL,
[floor_or_ceiling_basis] [float] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[penalty_rule_content_basis] ADD CONSTRAINT [penalty_rule_content_basis_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[penalty_rule_content_basis] ADD CONSTRAINT [penalty_rule_content_basis_fk1] FOREIGN KEY ([cp_formula_oid]) REFERENCES [dbo].[contract_pricing_formula] ([oid])
GO
ALTER TABLE [dbo].[penalty_rule_content_basis] ADD CONSTRAINT [penalty_rule_content_basis_fk2] FOREIGN KEY ([price_rule_oid]) REFERENCES [dbo].[pricing_rule] ([oid])
GO
GRANT DELETE ON  [dbo].[penalty_rule_content_basis] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[penalty_rule_content_basis] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[penalty_rule_content_basis] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[penalty_rule_content_basis] TO [next_usr]
GO
