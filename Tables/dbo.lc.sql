CREATE TABLE [dbo].[lc]
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
[guarantor_acct_num] [int] NULL,
[pcg_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[collateral_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_netting_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_lc_lc_netting_ind] DEFAULT ('N'),
[lc_template_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_lc_lc_template_ind] DEFAULT ('N'),
[other_lcs_rel_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_lc_other_lcs_rel_ind] DEFAULT ('N'),
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
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [chk_lc_lc_dispute_status] CHECK (([lc_dispute_status]='REJECTED' OR [lc_dispute_status]='RESOLVED' OR [lc_dispute_status]='SUBMITTED'))
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [chk_lc_lc_netting_ind] CHECK (([lc_netting_ind]='N' OR [lc_netting_ind]='Y'))
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [chk_lc_lc_priority] CHECK (([lc_priority]='URGENT' OR [lc_priority]='HIGH' OR [lc_priority]='NORMAL'))
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [chk_lc_lc_template_ind] CHECK (([lc_template_ind]='N' OR [lc_template_ind]='Y'))
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [chk_lc_other_lcs_rel_ind] CHECK (([other_lcs_rel_ind]='N' OR [other_lcs_rel_ind]='Y'))
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_pk] PRIMARY KEY CLUSTERED  ([lc_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [lc_TS_idx90] ON [dbo].[lc] ([lc_issuing_bank]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_fk1] FOREIGN KEY ([lc_applicant]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_fk10] FOREIGN KEY ([lc_usage_code]) REFERENCES [dbo].[lc_usage] ([lc_usage_code])
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_fk11] FOREIGN KEY ([lc_office_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_fk12] FOREIGN KEY ([collateral_type_code]) REFERENCES [dbo].[collateral_type] ([collateral_type_code])
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_fk13] FOREIGN KEY ([lc_template_creator]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_fk2] FOREIGN KEY ([lc_beneficiary]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_fk3] FOREIGN KEY ([lc_advising_bank]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_fk4] FOREIGN KEY ([lc_issuing_bank]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_fk5] FOREIGN KEY ([lc_negotiating_bank]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_fk6] FOREIGN KEY ([lc_confirming_bank]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_fk7] FOREIGN KEY ([lc_cr_analyst_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_fk8] FOREIGN KEY ([lc_status_code]) REFERENCES [dbo].[lc_status] ([lc_status_code])
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_fk9] FOREIGN KEY ([lc_type_code]) REFERENCES [dbo].[lc_type] ([lc_type_code])
GO
GRANT DELETE ON  [dbo].[lc] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[lc] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[lc] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[lc] TO [next_usr]
GO
