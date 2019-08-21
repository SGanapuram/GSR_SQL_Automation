CREATE TABLE [dbo].[aud_formula_comp_price_term]
(
[formula_num] [int] NOT NULL,
[formula_body_num] [tinyint] NOT NULL,
[formula_comp_num] [smallint] NOT NULL,
[qpt_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[fcpt_pricing_days] [smallint] NULL,
[fcpt_price_cal_days_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fcpt_start_end_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fcpt_relative_days] [smallint] NULL,
[fcpt_rel_price_cal_days_ind] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fcpt_roll_accum_prd_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_formula_comp_price_term] ON [dbo].[aud_formula_comp_price_term] ([formula_num], [formula_body_num], [formula_comp_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_formula_comp_price_t_idx1] ON [dbo].[aud_formula_comp_price_term] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_formula_comp_price_term] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_formula_comp_price_term] TO [next_usr]
GO
