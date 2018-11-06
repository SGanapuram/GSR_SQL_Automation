CREATE TABLE [dbo].[aud_cost_template_grp_item]
(
[cost_template_group_oid] [int] NOT NULL,
[cost_template_oid] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_template_grp_item] ON [dbo].[aud_cost_template_grp_item] ([cost_template_group_oid], [cost_template_oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_template_grp_item_idx1] ON [dbo].[aud_cost_template_grp_item] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_cost_template_grp_item] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_cost_template_grp_item] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_cost_template_grp_item] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_cost_template_grp_item] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_cost_template_grp_item] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_cost_template_grp_item', NULL, NULL
GO
