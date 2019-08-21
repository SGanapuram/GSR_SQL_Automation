CREATE TABLE [dbo].[aud_account_ext_info]
(
[acct_num] [int] NOT NULL,
[fld_value1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fld_value2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fld_value3] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fld_value4] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fld_value5] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account_ext_info] ON [dbo].[aud_account_ext_info] ([acct_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account_ext_info_idx1] ON [dbo].[aud_account_ext_info] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_account_ext_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_account_ext_info] TO [next_usr]
GO
