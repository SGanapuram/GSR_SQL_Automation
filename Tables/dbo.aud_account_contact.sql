CREATE TABLE [dbo].[aud_account_contact]
(
[acct_num] [int] NOT NULL,
[acct_cont_num] [int] NOT NULL,
[acct_cont_last_name] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_cont_first_name] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_cont_nick_name] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_title] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_addr_line_1] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_addr_line_2] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_addr_line_3] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_addr_line_4] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_addr_city] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[state_code] [nchar] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[country_code] [nchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_addr_zip_code] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_home_ph_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_off_ph_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_oth_ph_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_telex_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_fax_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_email] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_function] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_num] [smallint] NULL,
[acct_cont_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account_contact] ON [dbo].[aud_account_contact] ([acct_num], [acct_cont_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account_contact_idx1] ON [dbo].[aud_account_contact] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_account_contact] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_account_contact] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_account_contact] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_account_contact] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_account_contact] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_account_contact', NULL, NULL
GO
