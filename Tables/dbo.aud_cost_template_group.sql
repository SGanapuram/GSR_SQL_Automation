CREATE TABLE [dbo].[aud_cost_template_group]
(
[oid] [int] NOT NULL,
[template_group_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_template_group] ON [dbo].[aud_cost_template_group] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_template_group_idx1] ON [dbo].[aud_cost_template_group] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_cost_template_group] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_cost_template_group] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_cost_template_group] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_cost_template_group] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_cost_template_group] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_cost_template_group', NULL, NULL
GO
