CREATE TABLE [dbo].[aud_conc_exec_weight]
(
[oid] [int] NOT NULL,
[contract_execution_oid] [int] NOT NULL,
[measure_date] [datetime] NULL,
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[prim_qty] [float] NULL,
[prim_qty_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sec_qty] [float] NULL,
[sec_qty_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[short_comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[use_in_pl_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[weight_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[weight_detail_num] [int] NULL,
[group_num] [int] NULL,
[line_num] [int] NULL,
[result_date] [datetime] NULL,
[conc_ref_document_oid] [int] NULL,
[title_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[moisture_percent] [float] NULL,
[franchise_percent] [float] NULL,
[insp_acct_num] [int] NULL,
[final_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[loc_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[loc_country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[conc_ref_result_type_oid] [int] NULL,
[cargo_condition_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_exec_weight] ON [dbo].[aud_conc_exec_weight] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_exec_weight_idx1] ON [dbo].[aud_conc_exec_weight] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_conc_exec_weight] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_conc_exec_weight] TO [next_usr]
GO
