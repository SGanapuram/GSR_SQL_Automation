CREATE TABLE [dbo].[aud_formula_component]
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
[resp_trans_id] [int] NOT NULL,
[is_type_weight_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_comp_label] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[per_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[uom_ratio_factor] [numeric] (20, 8) NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_formula_component_idx1] ON [dbo].[aud_formula_component] ([formula_num], [formula_body_num], [formula_comp_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [aud_formula_component] ON [dbo].[aud_formula_component] ([price_source_code], [trading_prd], [commkt_key]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_formula_component_idx2] ON [dbo].[aud_formula_component] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_formula_component] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_formula_component] TO [next_usr]
GO
