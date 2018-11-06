CREATE TABLE [dbo].[msi_inbound_contract_term]
(
[fdd_id] [int] NOT NULL,
[symphony_toi] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sap_contract_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sap_contract_item_num] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[msi_inbound_contract_term] ADD CONSTRAINT [msi_inbound_contract_term_fk1] FOREIGN KEY ([fdd_id]) REFERENCES [dbo].[feed_detail_data] ([oid])
GO
GRANT DELETE ON  [dbo].[msi_inbound_contract_term] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[msi_inbound_contract_term] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[msi_inbound_contract_term] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[msi_inbound_contract_term] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'msi_inbound_contract_term', NULL, NULL
GO
