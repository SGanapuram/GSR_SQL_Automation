CREATE TABLE [dbo].[aud_acct_sub_type]
(
[acct_sub_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_sub_type_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_acct_sub_type_idx] ON [dbo].[aud_acct_sub_type] ([acct_sub_type_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_acct_sub_type] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_acct_sub_type] TO [next_usr]
GO
