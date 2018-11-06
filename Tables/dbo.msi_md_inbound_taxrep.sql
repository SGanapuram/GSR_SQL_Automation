CREATE TABLE [dbo].[msi_md_inbound_taxrep]
(
[fdd_id] [int] NOT NULL,
[acct_short_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_full_name] [varchar] (510) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_type_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_parent_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_sub_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[country_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_acct_short_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[vat_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[av_country_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[vat_type_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[acct_num] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[msi_md_inbound_taxrep] ADD CONSTRAINT [msi_md_inbound_taxrep_fk1] FOREIGN KEY ([fdd_id]) REFERENCES [dbo].[feed_detail_data] ([oid])
GO
GRANT DELETE ON  [dbo].[msi_md_inbound_taxrep] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[msi_md_inbound_taxrep] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[msi_md_inbound_taxrep] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[msi_md_inbound_taxrep] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'msi_md_inbound_taxrep', NULL, NULL
GO
