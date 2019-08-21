CREATE TABLE [dbo].[pay_rule_fixprice_info]
(
[oid] [int] NOT NULL,
[cp_formula_oid] [int] NULL,
[price_rule_oid] [int] NULL,
[spec_from_value] [float] NULL,
[spec_to_value] [float] NULL,
[fixed_price] [float] NULL,
[fixed_price_basis] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pay_rule_fixprice_info] ADD CONSTRAINT [pay_rule_fixprice_info_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pay_rule_fixprice_info] ADD CONSTRAINT [pay_rule_fixprice_info_fk1] FOREIGN KEY ([cp_formula_oid]) REFERENCES [dbo].[contract_pricing_formula] ([oid])
GO
ALTER TABLE [dbo].[pay_rule_fixprice_info] ADD CONSTRAINT [pay_rule_fixprice_info_fk2] FOREIGN KEY ([price_rule_oid]) REFERENCES [dbo].[pricing_rule] ([oid])
GO
GRANT DELETE ON  [dbo].[pay_rule_fixprice_info] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[pay_rule_fixprice_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[pay_rule_fixprice_info] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[pay_rule_fixprice_info] TO [next_usr]
GO
