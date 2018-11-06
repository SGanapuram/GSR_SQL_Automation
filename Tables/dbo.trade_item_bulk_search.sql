CREATE TABLE [dbo].[trade_item_bulk_search]
(
[sequence] [int] NOT NULL IDENTITY(1, 1),
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[item_type] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[real_port_num] [int] NULL,
[search_guid] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[search_time] [datetime] NULL CONSTRAINT [DF__trade_ite__searc__11D639FD] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_bulk_search] ADD CONSTRAINT [PK__trade_it__DA24123E66EBDBF8] PRIMARY KEY CLUSTERED  ([sequence]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_bulk_search_idx1] ON [dbo].[trade_item_bulk_search] ([search_guid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_bulk_search_idx2] ON [dbo].[trade_item_bulk_search] ([trade_num], [order_num], [item_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[trade_item_bulk_search] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_item_bulk_search] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_item_bulk_search] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_item_bulk_search] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'trade_item_bulk_search', NULL, NULL
GO
