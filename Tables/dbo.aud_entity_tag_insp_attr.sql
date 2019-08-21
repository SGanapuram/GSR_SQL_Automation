CREATE TABLE [dbo].[aud_entity_tag_insp_attr]
(
[entity_tag_id] [int] NOT NULL,
[entity_tag_attr_name] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[entity_tag_attr_value] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_entity_tag_insp_attr_idx] ON [dbo].[aud_entity_tag_insp_attr] ([entity_tag_id], [entity_tag_attr_name], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_entity_tag_insp_attr_idx1] ON [dbo].[aud_entity_tag_insp_attr] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_entity_tag_insp_attr] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_entity_tag_insp_attr] TO [next_usr]
GO
