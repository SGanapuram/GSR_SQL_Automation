CREATE TABLE [dbo].[msi_md_inbound_location]
(
[fdd_id] [int] NOT NULL,
[loc_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[loc_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[office_loc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_loc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[loc_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_loc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[loc_num] [smallint] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[msi_md_inbound_location] ADD CONSTRAINT [msi_md_inbound_location_fk1] FOREIGN KEY ([fdd_id]) REFERENCES [dbo].[feed_detail_data] ([oid])
GO
GRANT DELETE ON  [dbo].[msi_md_inbound_location] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[msi_md_inbound_location] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[msi_md_inbound_location] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[msi_md_inbound_location] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'msi_md_inbound_location', NULL, NULL
GO
