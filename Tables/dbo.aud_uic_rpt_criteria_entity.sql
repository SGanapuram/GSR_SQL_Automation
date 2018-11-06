CREATE TABLE [dbo].[aud_uic_rpt_criteria_entity]
(
[oid] [int] NOT NULL,
[report_criteria_id] [int] NOT NULL,
[entity_id] [int] NOT NULL,
[entity_criteria_selector] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_uic_rpt_criteria_entity] ON [dbo].[aud_uic_rpt_criteria_entity] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_uic_rpt_criteria_ent_idx1] ON [dbo].[aud_uic_rpt_criteria_entity] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_uic_rpt_criteria_entity] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_uic_rpt_criteria_entity] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_uic_rpt_criteria_entity] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_uic_rpt_criteria_entity] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_uic_rpt_criteria_entity] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_uic_rpt_criteria_entity', NULL, NULL
GO
