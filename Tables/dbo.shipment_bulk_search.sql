CREATE TABLE [dbo].[shipment_bulk_search]
(
[sequence] [int] NOT NULL IDENTITY(1, 1),
[shipment_id] [int] NOT NULL,
[search_guid] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alloc_num] [int] NOT NULL,
[reference] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[search_time] [datetime] NULL CONSTRAINT [DF__shipment___searc__0FEDF18B] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[shipment_bulk_search] ADD CONSTRAINT [shipment_bulk_search_pk] PRIMARY KEY CLUSTERED  ([sequence]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [shipment_bulk_search_idx1] ON [dbo].[shipment_bulk_search] ([shipment_id], [search_guid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[shipment_bulk_search] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[shipment_bulk_search] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[shipment_bulk_search] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[shipment_bulk_search] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'shipment_bulk_search', NULL, NULL
GO
