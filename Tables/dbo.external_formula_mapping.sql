CREATE TABLE [dbo].[external_formula_mapping]
(
[oid] [int] NOT NULL,
[quote_string] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_source] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_key] [int] NULL,
[price_point] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[ui_index] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ui_source] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ui_point] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ui_formula_str] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[element_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[element_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[per_spec_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[external_formula_mapping] ADD CONSTRAINT [external_formula_mapping_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[external_formula_mapping] ADD CONSTRAINT [external_formula_mapping_fk1] FOREIGN KEY ([price_source]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
ALTER TABLE [dbo].[external_formula_mapping] ADD CONSTRAINT [external_formula_mapping_fk2] FOREIGN KEY ([commkt_key]) REFERENCES [dbo].[commodity_market] ([commkt_key])
GO
ALTER TABLE [dbo].[external_formula_mapping] ADD CONSTRAINT [external_formula_mapping_fk3] FOREIGN KEY ([ui_source]) REFERENCES [dbo].[market] ([mkt_code])
GO
ALTER TABLE [dbo].[external_formula_mapping] ADD CONSTRAINT [external_formula_mapping_fk4] FOREIGN KEY ([spec_code]) REFERENCES [dbo].[specification] ([spec_code])
GO
ALTER TABLE [dbo].[external_formula_mapping] ADD CONSTRAINT [external_formula_mapping_fk5] FOREIGN KEY ([spec_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[external_formula_mapping] ADD CONSTRAINT [external_formula_mapping_fk6] FOREIGN KEY ([per_spec_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[external_formula_mapping] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[external_formula_mapping] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[external_formula_mapping] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[external_formula_mapping] TO [next_usr]
GO
