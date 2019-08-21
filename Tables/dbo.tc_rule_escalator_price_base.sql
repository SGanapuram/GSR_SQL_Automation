CREATE TABLE [dbo].[tc_rule_escalator_price_base]
(
[oid] [int] NOT NULL,
[cp_formula_oid] [int] NULL,
[price_rule_oid] [int] NULL,
[from_value] [float] NULL,
[to_value] [float] NULL,
[inc_dec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inc_dec_value] [float] NULL,
[floor_or_ceiling_value] [float] NULL,
[app_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tc_value] [float] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tc_rule_escalator_price_base] ADD CONSTRAINT [tc_rule_escalator_price_base_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tc_rule_escalator_price_base] ADD CONSTRAINT [tc_rule_escalator_price_base_fk1] FOREIGN KEY ([cp_formula_oid]) REFERENCES [dbo].[contract_pricing_formula] ([oid])
GO
ALTER TABLE [dbo].[tc_rule_escalator_price_base] ADD CONSTRAINT [tc_rule_escalator_price_base_fk2] FOREIGN KEY ([price_rule_oid]) REFERENCES [dbo].[pricing_rule] ([oid])
GO
GRANT DELETE ON  [dbo].[tc_rule_escalator_price_base] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tc_rule_escalator_price_base] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tc_rule_escalator_price_base] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tc_rule_escalator_price_base] TO [next_usr]
GO
