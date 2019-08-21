CREATE TABLE [dbo].[msi_md_inbound_bank]
(
[fdd_id] [int] NOT NULL,
[bank_acct_num] [int] NULL,
[bank_name] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bank_addr] [varchar] (90) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bank_acct_no] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[swift_code] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_short_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[p_or_r_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_method_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_bank_info_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[msi_md_inbound_bank] ADD CONSTRAINT [msi_md_inbound_bank_fk1] FOREIGN KEY ([fdd_id]) REFERENCES [dbo].[feed_detail_data] ([oid])
GO
GRANT DELETE ON  [dbo].[msi_md_inbound_bank] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[msi_md_inbound_bank] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[msi_md_inbound_bank] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[msi_md_inbound_bank] TO [next_usr]
GO
