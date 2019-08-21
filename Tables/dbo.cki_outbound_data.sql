CREATE TABLE [dbo].[cki_outbound_data]
(
[row_id] [int] NOT NULL,
[fdd_id] [int] NULL,
[entity_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key1] [int] NULL,
[key2] [int] NULL,
[key3] [int] NULL,
[interface_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[entity_operation] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[status] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[op_trans_id] [int] NULL,
[trans_id] [int] NOT NULL,
[duplicate_of] [int] NULL,
[update_operation_ext] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cki_outbound_data] ADD CONSTRAINT [cki_outbound_data_pk] PRIMARY KEY CLUSTERED  ([row_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cki_outbound_data] ADD CONSTRAINT [cki_outbound_data_fk1] FOREIGN KEY ([fdd_id]) REFERENCES [dbo].[feed_detail_data] ([oid])
GO
GRANT DELETE ON  [dbo].[cki_outbound_data] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cki_outbound_data] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cki_outbound_data] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cki_outbound_data] TO [next_usr]
GO
