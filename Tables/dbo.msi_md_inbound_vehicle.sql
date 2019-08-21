CREATE TABLE [dbo].[msi_md_inbound_vehicle]
(
[fdd_id] [int] NOT NULL,
[mot_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_type_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_short_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_full_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[imo_num] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[msi_md_inbound_vehicle] ADD CONSTRAINT [msi_md_inbound_vehicle_fk1] FOREIGN KEY ([fdd_id]) REFERENCES [dbo].[feed_detail_data] ([oid])
GO
GRANT DELETE ON  [dbo].[msi_md_inbound_vehicle] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[msi_md_inbound_vehicle] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[msi_md_inbound_vehicle] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[msi_md_inbound_vehicle] TO [next_usr]
GO
