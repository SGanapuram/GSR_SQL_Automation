CREATE TABLE [dbo].[fixed_price_content_basis]
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
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fixed_price_content_basis] ADD CONSTRAINT [fixed_price_content_basis_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fixed_price_content_basis] ADD CONSTRAINT [fixed_price_content_basis_fk1] FOREIGN KEY ([cp_formula_oid]) REFERENCES [dbo].[contract_pricing_formula] ([oid])
GO
ALTER TABLE [dbo].[fixed_price_content_basis] ADD CONSTRAINT [fixed_price_content_basis_fk2] FOREIGN KEY ([price_rule_oid]) REFERENCES [dbo].[pricing_rule] ([oid])
GO
GRANT DELETE ON  [dbo].[fixed_price_content_basis] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[fixed_price_content_basis] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[fixed_price_content_basis] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[fixed_price_content_basis] TO [next_usr]
GO
