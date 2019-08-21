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
GRANT INSERT ON  [dbo].[aud_cost_template_group] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_cost_template_group] TO [next_usr]
GO
