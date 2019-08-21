CREATE TABLE [dbo].[aud_formula]
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
[resp_trans_id] [int] NOT NULL,
[monthly_pricing_inds] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_aud_formula_monthly_pricing_inds] DEFAULT ('NN'),
[use_exec_price_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_rounding_level] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[modular_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_assay_final_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[max_qp_opt_end_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_formula] ON [dbo].[aud_formula] ([formula_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_formula_idx1] ON [dbo].[aud_formula] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_formula] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_formula] TO [next_usr]
GO
