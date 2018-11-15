CREATE TABLE [dbo].[ai_est_actual_bulk_search]
(
[sequence] [int] NOT NULL IDENTITY(1, 1),
[alloc_num] [int] NULL,
[alloc_item_num] [int] NULL,
[ai_est_actual_num] [int] NULL,
[search_guid] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[search_time] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ai_est_actual_bulk_search] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[ai_est_actual_bulk_search] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[ai_est_actual_bulk_search] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[ai_est_actual_bulk_search] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'ai_est_actual_bulk_search', NULL, NULL
GO
