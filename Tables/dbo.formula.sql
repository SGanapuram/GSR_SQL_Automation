CREATE TABLE [dbo].[formula]
(
[formula_num] [int] NOT NULL,
[formula_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[formula_type] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[formula_use] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[formula_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[formula_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_precision] [tinyint] NULL,
[parent_formula_num] [int] NULL,
[cmnt_num] [int] NULL,
[use_alt_source_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[monthly_pricing_inds] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_formula_monthly_pricing_inds] DEFAULT ('NN'),
[use_exec_price_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_rounding_level] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[modular_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_assay_final_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[max_qp_opt_end_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[formula] ADD CONSTRAINT [formula_pk] PRIMARY KEY CLUSTERED  ([formula_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [formula_idx1] ON [dbo].[formula] ([parent_formula_num], [formula_name]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [formula_TS_idx90] ON [dbo].[formula] ([parent_formula_num], [formula_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[formula] ADD CONSTRAINT [formula_fk2] FOREIGN KEY ([formula_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[formula] ADD CONSTRAINT [formula_fk3] FOREIGN KEY ([formula_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[formula] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[formula] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[formula] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[formula] TO [next_usr]
GO
