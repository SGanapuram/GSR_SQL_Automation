CREATE TABLE [dbo].[aud_uic_rpt_criteria]
(
[oid] [int] NOT NULL,
[report_type_id] [int] NOT NULL,
[criteria_desc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[display_entity_id] [int] NULL,
[display_value_selector] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[report_value_selector] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_uic_rpt_criteria] ON [dbo].[aud_uic_rpt_criteria] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_uic_rpt_criteria_idx1] ON [dbo].[aud_uic_rpt_criteria] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_uic_rpt_criteria] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_uic_rpt_criteria] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_uic_rpt_criteria] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_uic_rpt_criteria] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_uic_rpt_criteria] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_uic_rpt_criteria', NULL, NULL
GO
