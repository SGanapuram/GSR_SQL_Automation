CREATE TABLE [dbo].[aud_acct_fiscal_rep]
(
[acct_fiscal_rep_id] [int] NOT NULL,
[acct_num] [int] NOT NULL,
[country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[fiscal_rep_acct_num] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_acct_fiscal_rep] ON [dbo].[aud_acct_fiscal_rep] ([acct_fiscal_rep_id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_acct_fiscal_rep_idx1] ON [dbo].[aud_acct_fiscal_rep] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_acct_fiscal_rep] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_acct_fiscal_rep] TO [next_usr]
GO
