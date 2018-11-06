CREATE TABLE [dbo].[aud_inventory_voyage]
(
[inv_num] [int] NOT NULL,
[voyage_code] [char] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[num_of_b_ds] [smallint] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_inventory_voyage_idx] ON [dbo].[aud_inventory_voyage] ([inv_num], [voyage_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_inventory_voyage] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_inventory_voyage] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_inventory_voyage] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_inventory_voyage] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_inventory_voyage] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_inventory_voyage', NULL, NULL
GO
