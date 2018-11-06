CREATE TABLE [dbo].[aud_acct_bookcomp_collatera]
(
[acct_collat_num] [int] NOT NULL,
[mca_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mca_eff_date] [datetime] NULL,
[net_pay_agree_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[net_out_agree_eff_date] [datetime] NULL,
[net_out_cont_num] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[isda_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[isda_eff_date] [datetime] NULL,
[acct_bookcomp_key] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_acct_bookcomp_collatera] ON [dbo].[aud_acct_bookcomp_collatera] ([acct_collat_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_acct_bookcomp_collatera_idx1] ON [dbo].[aud_acct_bookcomp_collatera] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_acct_bookcomp_collatera] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_acct_bookcomp_collatera] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_acct_bookcomp_collatera] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_acct_bookcomp_collatera] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_acct_bookcomp_collatera] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_acct_bookcomp_collatera', NULL, NULL
GO
