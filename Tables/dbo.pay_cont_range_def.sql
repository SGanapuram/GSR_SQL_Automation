CREATE TABLE [dbo].[pay_cont_range_def]
(
[oid] [int] NOT NULL,
[cp_formula_oid] [int] NULL,
[price_rule_oid] [int] NULL,
[dim_num] [smallint] NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[per_spec_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_from_value] [float] NULL,
[spec_to_value] [float] NULL,
[commkt_key] [int] NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pay_cont_range_def] ADD CONSTRAINT [pay_cont_range_def_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pay_cont_range_def] ADD CONSTRAINT [pay_cont_range_def_fk1] FOREIGN KEY ([cp_formula_oid]) REFERENCES [dbo].[contract_pricing_formula] ([oid])
GO
ALTER TABLE [dbo].[pay_cont_range_def] ADD CONSTRAINT [pay_cont_range_def_fk2] FOREIGN KEY ([price_rule_oid]) REFERENCES [dbo].[pricing_rule] ([oid])
GO
GRANT DELETE ON  [dbo].[pay_cont_range_def] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[pay_cont_range_def] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[pay_cont_range_def] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[pay_cont_range_def] TO [next_usr]
GO
