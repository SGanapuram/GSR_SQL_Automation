CREATE TABLE [dbo].[aud_acct_bookcomp_restrict]
(
[acct_bookcomp_key] [int] NOT NULL,
[acct_restriction_num] [int] NOT NULL,
[nobuy_restriction_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[nosell_restriction_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[order_type_group] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[restriction_eff_date] [datetime] NOT NULL,
[restriction_end_date] [datetime] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[tenor_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[allows_netout] [bit] NULL,
[allows_bookout] [bit] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_acct_bookcomp_restrict] ON [dbo].[aud_acct_bookcomp_restrict] ([acct_restriction_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_acct_bookcomp_restrict_idx1] ON [dbo].[aud_acct_bookcomp_restrict] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_acct_bookcomp_restrict] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_acct_bookcomp_restrict] TO [next_usr]
GO
