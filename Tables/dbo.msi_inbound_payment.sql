CREATE TABLE [dbo].[msi_inbound_payment]
(
[fdd_id] [int] NOT NULL,
[symphony_toi] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ps_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sap_invoice_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sap_order_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[payment_date] [datetime] NULL,
[payment_amount] [float] NULL,
[payment_currency] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cancel_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[symphony_ship_num] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[symphony_parcel_num] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sap_shipment_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sap_delivery_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sap_position_num] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[msi_inbound_payment] ADD CONSTRAINT [msi_inbound_payment_fk1] FOREIGN KEY ([fdd_id]) REFERENCES [dbo].[feed_detail_data] ([oid])
GO
GRANT DELETE ON  [dbo].[msi_inbound_payment] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[msi_inbound_payment] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[msi_inbound_payment] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[msi_inbound_payment] TO [next_usr]
GO
