CREATE TABLE [dbo].[aud_credit_limit]
(
[credit_limit_num] [int] NOT NULL,
[limit_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[limit_direction] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[limit_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cr_analyst_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[limit_amt] [float] NOT NULL,
[curr_exp_amt] [float] NULL,
[limit_alarm_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[review_email_group] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[limit_cmnt_num] [int] NULL,
[acct_num] [int] NULL,
[lc_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_country_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[order_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[gross_net_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[exposure_method_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[include_subsidiary_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[limit_amt_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[res_exp_amt] [float] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[limit_line_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[limit_sub_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[book_comp_num] [int] NULL,
[prev_review_date] [datetime] NULL,
[next_review_date] [datetime] NULL,
[review_adv_notice_days] [smallint] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_credit_limit] ON [dbo].[aud_credit_limit] ([credit_limit_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_credit_limit_idx1] ON [dbo].[aud_credit_limit] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_credit_limit] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_credit_limit] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_credit_limit] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_credit_limit] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_credit_limit] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_credit_limit', NULL, NULL
GO
