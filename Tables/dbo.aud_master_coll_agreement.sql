CREATE TABLE [dbo].[aud_master_coll_agreement]
(
[mca_num] [int] NOT NULL,
[cr_analyst_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mca_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mca_enabled] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[main_curr] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[issue_date] [datetime] NOT NULL,
[expiration_date] [datetime] NULL,
[mca_review_date] [datetime] NULL,
[review_email_group] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mca_cmnt_num] [int] NULL,
[mca_formula_num] [int] NULL,
[mtm_amount] [float] NULL,
[mtm_amount_date] [datetime] NULL,
[coll_balance] [float] NULL,
[coll_balance_date] [datetime] NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[order_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tenor] [int] NULL,
[counterparty_inv_num] [int] NOT NULL,
[booking_inv_num] [int] NULL,
[b_contract_limit] [float] NULL,
[b_limit_curr_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[b_contract_increment] [float] NULL,
[b_increment_curr_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[b_pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[b_pay_method_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[c_contract_limit] [float] NOT NULL,
[c_limit_curr_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[c_contract_increment] [float] NOT NULL,
[c_increment_curr_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[c_pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[c_pay_method_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_master_coll_agreemen_idx1] ON [dbo].[aud_master_coll_agreement] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_master_coll_agreement] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_master_coll_agreement] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_master_coll_agreement] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_master_coll_agreement] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_master_coll_agreement] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_master_coll_agreement', NULL, NULL
GO
