CREATE TABLE [dbo].[aud_account_bank_info]
(
[acct_bank_id] [int] NOT NULL,
[acct_num] [int] NOT NULL,
[bank_name] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bank_acct_num] [int] NULL,
[addr_acct_num] [int] NULL,
[addr_acct_addr_num] [smallint] NULL,
[vc_acct_num] [int] NULL,
[gl_acct_code] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[gl_acct_descr] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[p_or_r_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bank_acct_no] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bank_addr] [varchar] (90) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[swift_code] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_method_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_send_id] [smallint] NULL,
[acct_bank_routing_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_bank_info_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[corresp_bank_name] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[corresp_bank_routing_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[further_credit_to] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[currency_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[corresp_swift_code] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[corresp_bank_acct_no] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[corresp_bank_instr_type_id] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[book_comp_num] [int] NULL,
[further_credit_to_ext_acct_key] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[selling_office_num] [smallint] NULL,
[bank_short_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_bank_iban_num] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_bank_city] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_bank_country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[corresp_bank_iban_num] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[corresp_bank_city] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[corresp_bank_country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[special_payment_instr] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account_bank_info_idx1] ON [dbo].[aud_account_bank_info] ([acct_bank_id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account_bank_info_idx2] ON [dbo].[aud_account_bank_info] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_account_bank_info] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_account_bank_info] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_account_bank_info] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_account_bank_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_account_bank_info] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_account_bank_info', NULL, NULL
GO
