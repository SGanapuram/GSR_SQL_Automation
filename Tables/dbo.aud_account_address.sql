CREATE TABLE [dbo].[aud_account_address]
(
[acct_num] [int] NOT NULL,
[acct_addr_num] [smallint] NOT NULL,
[acct_addr_line_1] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_addr_line_2] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_line_3] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_line_4] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_city] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[state_code] [nchar] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[country_code] [nchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_addr_zip_code] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_ph_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_telex_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_fax_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_telex_ansback] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_fax_ansback] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_addr_email] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[accounting_system_id] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account_address] ON [dbo].[aud_account_address] ([acct_num], [acct_addr_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account_address_idx1] ON [dbo].[aud_account_address] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_account_address] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_account_address] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_account_address] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_account_address] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_account_address] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_account_address', NULL, NULL
GO
