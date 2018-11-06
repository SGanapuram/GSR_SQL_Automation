CREATE TABLE [dbo].[msi_inbound_actual]
(
[fdd_id] [int] NOT NULL,
[symphony_toi] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ps_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sap_shipment_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[actual_posting_date] [datetime] NULL,
[actual_date] [datetime] NULL,
[actual_density] [float] NULL,
[actual_cancel_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[symphony_ship_num] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[symphony_parcel_num] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sap_delivery_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sap_position_num] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sap_order_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[sales_quant] [float] NULL,
[sales_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_quant] [float] NULL,
[price_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[actual_sec_gross_qty] [float] NULL,
[actual_sec_gross_qty_uom] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[actual_sec_net_qty] [float] NULL,
[actual_sec_net_qty_uom] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[nor_date] [datetime] NULL,
[nor_acpt_date] [datetime] NULL,
[load_compl_date] [datetime] NULL,
[load_cmnc_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[msi_inbound_actual] ADD CONSTRAINT [msi_inbound_actual_fk1] FOREIGN KEY ([fdd_id]) REFERENCES [dbo].[feed_detail_data] ([oid])
GO
GRANT DELETE ON  [dbo].[msi_inbound_actual] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[msi_inbound_actual] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[msi_inbound_actual] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[msi_inbound_actual] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'msi_inbound_actual', NULL, NULL
GO
