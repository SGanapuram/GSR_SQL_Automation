CREATE TABLE [dbo].[msi_inbound_otdata]
(
[fdd_id] [int] NOT NULL,
[PS_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[Symphony_parcel_oid] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[nor_tender_date] [datetime] NULL,
[nor_accp_date] [datetime] NULL,
[disch_cmnc_date] [datetime] NULL,
[disch_compl_date] [datetime] NULL,
[load_disch_date] [datetime] NULL,
[Id_gross_qty] [float] NULL,
[ld_gross_qty_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ld_net_qty] [float] NULL,
[ld_net_qty_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ld_sec_gross_qty] [float] NULL,
[Id_sec_gross_qty_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ld_sec_net_qty] [float] NULL,
[ld_sec_net_qty_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[msi_inbound_otdata] ADD CONSTRAINT [msi_inbound_otdata_pk] PRIMARY KEY CLUSTERED  ([fdd_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[msi_inbound_otdata] ADD CONSTRAINT [msi_inbound_otdata_fk1] FOREIGN KEY ([fdd_id]) REFERENCES [dbo].[feed_detail_data] ([oid])
GO
GRANT DELETE ON  [dbo].[msi_inbound_otdata] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[msi_inbound_otdata] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[msi_inbound_otdata] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[msi_inbound_otdata] TO [next_usr]
GO
