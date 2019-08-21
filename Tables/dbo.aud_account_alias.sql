CREATE TABLE [dbo].[aud_account_alias]
(
[acct_num] [int] NOT NULL,
[acct_addr_num] [smallint] NOT NULL,
[alias_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_alias_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account_alias] ON [dbo].[aud_account_alias] ([acct_num], [acct_addr_num], [alias_source_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account_alias_idx1] ON [dbo].[aud_account_alias] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_account_alias] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_account_alias] TO [next_usr]
GO
