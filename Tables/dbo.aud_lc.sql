CREATE TABLE [dbo].[aud_lc]
(
[lc_num] [int] NOT NULL,
[lc_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lc_exp_imp_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lc_usage_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lc_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lc_final_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lc_evergreen_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_evergreen_roll_days] [smallint] NULL,
[lc_evergreen_ext_days] [smallint] NULL,
[lc_stale_doc_allow_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_stale_doc_days] [smallint] NULL,
[lc_loi_presented_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_negotiate_clause] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_confirm_reqd_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_confirm_date] [datetime] NULL,
[lc_issue_date] [datetime] NULL,
[lc_request_date] [datetime] NULL,
[lc_exp_date] [datetime] NULL,
[lc_exp_event] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_exp_days] [smallint] NULL,
[lc_exp_days_oper] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_office_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_short_cmnt] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_cr_analyst_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_transact_or_blanket] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_applicant] [int] NULL,
[lc_beneficiary] [int] NULL,
[lc_advising_bank] [int] NULL,
[lc_issuing_bank] [int] NULL,
[lc_negotiating_bank] [int] NULL,
[lc_confirming_bank] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[guarantor_acct_num] [int] NULL,
[pcg_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[collateral_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_netting_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_aud_lc_lc_netting_ind] DEFAULT ('N'),
[lc_template_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_aud_lc_lc_template_ind] DEFAULT ('N'),
[other_lcs_rel_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_aud_lc_other_lcs_rel_ind] DEFAULT ('N'),
[lc_template_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_template_creator] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[external_ref_key] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_dispute_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_dispute_status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_priority] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_custom_column1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_custom_column2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lc] ON [dbo].[aud_lc] ([lc_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lc_idx1] ON [dbo].[aud_lc] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_lc] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_lc] TO [next_usr]
GO
