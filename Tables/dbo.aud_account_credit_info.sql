CREATE TABLE [dbo].[aud_account_credit_info]
(
[acct_num] [int] NOT NULL,
[cr_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[dflt_cr_anly_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[primary_sic_num] [smallint] NULL,
[acct_bus_desc] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[first_trade_date] [datetime] NULL,
[doing_bus_since_date] [datetime] NULL,
[acct_cr_info_source] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fiscal_year_end_date] [datetime] NULL,
[last_fin_doc_date] [datetime] NULL,
[acct_fin_rep_freq] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[confident_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[confident_sign_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_audit_code] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[invoice_freq] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[invoice_date] [datetime] NULL,
[invoice_formula] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dflt_telex_hold_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bus_restriction_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[dflt_cr_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pvt_ind_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bank_telex_cap_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pei_guarantee_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[broker_pns_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[exposure_priority_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[prim_cr_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sec_cr_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_agency_acct_num] [int] NULL,
[credit_rating] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[country_risk] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pvt_public_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[use_dflt_cr_info] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [DF__aud_accou__use_d__17635F73] DEFAULT ('N'),
[sector_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_bus_desc1] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_bus_desc2] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[margin_doc_email] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[minimum_transfer_amt] [numeric] (20, 8) NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account_credit_info] ON [dbo].[aud_account_credit_info] ([acct_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account_credit_info_idx1] ON [dbo].[aud_account_credit_info] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_account_credit_info] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_account_credit_info] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_account_credit_info] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_account_credit_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_account_credit_info] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_account_credit_info', NULL, NULL
GO
