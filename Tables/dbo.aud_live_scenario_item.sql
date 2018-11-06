CREATE TABLE [dbo].[aud_live_scenario_item]
(
[oid] [int] NOT NULL,
[live_scenario_id] [int] NOT NULL,
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[alloc_num] [int] NULL,
[alloc_item_num] [smallint] NULL,
[sub_alloc_num] [smallint] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_live_scenario_item] ON [dbo].[aud_live_scenario_item] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_live_scenario_item_idx1] ON [dbo].[aud_live_scenario_item] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_live_scenario_item] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_live_scenario_item] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_live_scenario_item] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_live_scenario_item] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_live_scenario_item] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_live_scenario_item', NULL, NULL
GO
