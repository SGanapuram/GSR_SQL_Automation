CREATE TABLE [dbo].[TI_bulk_ignore]
(
[alloc_num] [int] NOT NULL,
[alloc_item_num] [smallint] NOT NULL,
[etl_timestamp] [datetime] NULL,
[psmvol_oid] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_bulk_ignore] ADD CONSTRAINT [TI_bulk_ignore_pk] PRIMARY KEY CLUSTERED  ([alloc_num], [alloc_item_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_bulk_ignore] ADD CONSTRAINT [TI_bulk_ignore_fk1] FOREIGN KEY ([alloc_num], [alloc_item_num]) REFERENCES [dbo].[allocation_item] ([alloc_num], [alloc_item_num])
GO
ALTER TABLE [dbo].[TI_bulk_ignore] ADD CONSTRAINT [TI_bulk_ignore_fk2] FOREIGN KEY ([psmvol_oid]) REFERENCES [dbo].[TI_PSMV_feed] ([oid])
GO
GRANT DELETE ON  [dbo].[TI_bulk_ignore] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[TI_bulk_ignore] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[TI_bulk_ignore] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[TI_bulk_ignore] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'TI_bulk_ignore', NULL, NULL
GO
