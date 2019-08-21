CREATE TABLE [dbo].[contract_pricing_formula]
(
[oid] [int] NOT NULL,
[conc_contract_oid] [int] NULL,
[use_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[contract_pricing_formula] ADD CONSTRAINT [contract_pricing_formula_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[contract_pricing_formula] ADD CONSTRAINT [contract_pricing_formula_fk1] FOREIGN KEY ([conc_contract_oid]) REFERENCES [dbo].[conc_contract] ([oid])
GO
GRANT DELETE ON  [dbo].[contract_pricing_formula] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[contract_pricing_formula] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[contract_pricing_formula] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[contract_pricing_formula] TO [next_usr]
GO
