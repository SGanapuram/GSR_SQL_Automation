CREATE TABLE [dbo].[aud_account]
(
[acct_num] [int] NOT NULL,
[acct_short_name] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_full_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_parent_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_sub_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_vat_code] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_fiscal_code] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_sub_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[contract_cmnt_num] [int] NULL,
[man_input_sec_qty_required] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[legal_entity_num] [int] NULL,
[risk_transfer_ind_code] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[govt_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[allows_netout] [bit] NOT NULL CONSTRAINT [df_aud_account_allows_netout] DEFAULT ((0)),
[allows_bookout] [bit] NOT NULL CONSTRAINT [df_aud_account_allows_bookout] DEFAULT ((0)),
[master_agreement_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account] ON [dbo].[aud_account] ([acct_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account_idx1] ON [dbo].[aud_account] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_account] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_account] TO [next_usr]
GO
