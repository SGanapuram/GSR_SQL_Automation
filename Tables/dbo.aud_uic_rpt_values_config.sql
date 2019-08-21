CREATE TABLE [dbo].[aud_uic_rpt_values_config]
(
[oid] [int] NOT NULL,
[entity_id] [int] NOT NULL,
[entity_value_selector] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_uic_rpt_values_config] ON [dbo].[aud_uic_rpt_values_config] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_uic_rpt_values_config_idx1] ON [dbo].[aud_uic_rpt_values_config] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_uic_rpt_values_config] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_uic_rpt_values_config] TO [next_usr]
GO
