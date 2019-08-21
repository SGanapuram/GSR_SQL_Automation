CREATE TABLE [dbo].[msi_outbound_data]
(
[fdd_id] [int] NOT NULL,
[entity_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key1] [int] NULL,
[key2] [int] NULL,
[key3] [int] NULL,
[trigger_event_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[interface_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[entity_operation] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[op_trans_id] [int] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[msi_outbound_data] ADD CONSTRAINT [msi_outbound_data_fk1] FOREIGN KEY ([fdd_id]) REFERENCES [dbo].[feed_detail_data] ([oid])
GO
GRANT DELETE ON  [dbo].[msi_outbound_data] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[msi_outbound_data] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[msi_outbound_data] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[msi_outbound_data] TO [next_usr]
GO
