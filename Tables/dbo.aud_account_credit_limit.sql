CREATE TABLE [dbo].[aud_account_credit_limit]
(
[acct_num] [int] NOT NULL,
[acct_limit_num] [smallint] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inc_out_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[limit_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[limit_eff_date] [datetime] NOT NULL,
[limit_exp_date] [datetime] NOT NULL,
[limit_qty] [float] NULL,
[limit_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[limit_amt] [float] NULL,
[limit_amt_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[prim_cr_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sec_cr_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cr_anly_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account_credit_limit] ON [dbo].[aud_account_credit_limit] ([acct_num], [acct_limit_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account_credit_limit_idx1] ON [dbo].[aud_account_credit_limit] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_account_credit_limit] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_account_credit_limit] TO [next_usr]
GO
