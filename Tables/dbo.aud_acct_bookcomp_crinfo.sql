CREATE TABLE [dbo].[aud_acct_bookcomp_crinfo]
(
[acct_bookcomp_key] [int] NOT NULL,
[dflt_cr_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_acct_bookcomp_crinfo] ON [dbo].[aud_acct_bookcomp_crinfo] ([acct_bookcomp_key], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_acct_bookcomp_crinfo_idx1] ON [dbo].[aud_acct_bookcomp_crinfo] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_acct_bookcomp_crinfo] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_acct_bookcomp_crinfo] TO [next_usr]
GO
