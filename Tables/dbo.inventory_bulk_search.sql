CREATE TABLE [dbo].[inventory_bulk_search]
(
[sequence] [int] NOT NULL IDENTITY(1, 1),
[inv_num] [int] NULL,
[search_guid] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[search_time] [datetime] NOT NULL CONSTRAINT [DF__inventory__searc__7EE1CA6C] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[inventory_bulk_search] ADD CONSTRAINT [inventory_bulk_search_pk] PRIMARY KEY CLUSTERED  ([sequence]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [inventory_bulk_search_idx1] ON [dbo].[inventory_bulk_search] ([inv_num], [search_guid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[inventory_bulk_search] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[inventory_bulk_search] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[inventory_bulk_search] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[inventory_bulk_search] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'inventory_bulk_search', NULL, NULL
GO
