CREATE TABLE [dbo].[msi_md_inbound_material]
(
[fdd_id] [int] NOT NULL,
[cmdty_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_short_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_full_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[prim_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sec_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[msi_md_inbound_material] ADD CONSTRAINT [msi_md_inbound_material_fk1] FOREIGN KEY ([fdd_id]) REFERENCES [dbo].[feed_detail_data] ([oid])
GO
GRANT DELETE ON  [dbo].[msi_md_inbound_material] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[msi_md_inbound_material] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[msi_md_inbound_material] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[msi_md_inbound_material] TO [next_usr]
GO
