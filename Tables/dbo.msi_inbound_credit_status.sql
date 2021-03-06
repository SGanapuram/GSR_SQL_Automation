CREATE TABLE [dbo].[msi_inbound_credit_status]
(
[fdd_id] [int] NOT NULL,
[symphony_toi] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ps_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sap_order_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tradeitem_credit_status] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[msi_inbound_credit_status] ADD CONSTRAINT [msi_inbound_credit_status_fk1] FOREIGN KEY ([fdd_id]) REFERENCES [dbo].[feed_detail_data] ([oid])
GO
GRANT DELETE ON  [dbo].[msi_inbound_credit_status] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[msi_inbound_credit_status] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[msi_inbound_credit_status] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[msi_inbound_credit_status] TO [next_usr]
GO
