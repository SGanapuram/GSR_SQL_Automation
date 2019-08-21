CREATE TABLE [dbo].[formula_component]
(
[formula_num] [int] NOT NULL,
[formula_body_num] [tinyint] NOT NULL,
[formula_comp_num] [smallint] NOT NULL,
[formula_comp_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[formula_comp_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[formula_comp_ref] [int] NULL,
[formula_comp_val] [float] NULL,
[commkt_key] [int] NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_comp_val_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_comp_pos_num] [int] NOT NULL,
[formula_comp_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_comp_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_comp_cmnt] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[linear_factor] [float] NULL,
[trans_id] [int] NOT NULL,
[is_type_weight_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_comp_label] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[per_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[uom_ratio_factor] [numeric] (20, 8) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[formula_component] ADD CONSTRAINT [formula_component_pk] PRIMARY KEY NONCLUSTERED  ([formula_num], [formula_body_num], [formula_comp_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [formula_component_idx2] ON [dbo].[formula_component] ([formula_comp_type], [trading_prd], [commkt_key]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [formula_component] ON [dbo].[formula_component] ([price_source_code], [trading_prd], [commkt_key]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[formula_component] ADD CONSTRAINT [formula_component_fk1] FOREIGN KEY ([formula_comp_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[formula_component] ADD CONSTRAINT [formula_component_fk4] FOREIGN KEY ([price_source_code]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
ALTER TABLE [dbo].[formula_component] ADD CONSTRAINT [formula_component_fk5] FOREIGN KEY ([commkt_key], [trading_prd]) REFERENCES [dbo].[trading_period] ([commkt_key], [trading_prd])
GO
ALTER TABLE [dbo].[formula_component] ADD CONSTRAINT [formula_component_fk6] FOREIGN KEY ([formula_comp_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[formula_component] ADD CONSTRAINT [formula_component_fk7] FOREIGN KEY ([per_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[formula_component] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[formula_component] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[formula_component] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[formula_component] TO [next_usr]
GO
