CREATE TABLE [dbo].[aud_allocation_item_spec]
(
[alloc_num] [int] NOT NULL,
[alloc_item_num] [smallint] NOT NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spec_actual_value] [float] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_allocation_item_spec] ON [dbo].[aud_allocation_item_spec] ([alloc_num], [alloc_item_num], [spec_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_allocation_item_spec_idx1] ON [dbo].[aud_allocation_item_spec] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_allocation_item_spec] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_allocation_item_spec] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_allocation_item_spec] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_allocation_item_spec] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_allocation_item_spec] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_allocation_item_spec', NULL, NULL
GO
