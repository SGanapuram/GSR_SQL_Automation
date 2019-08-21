CREATE TABLE [dbo].[aud_entity_tag_definition]
(
[oid] [int] NOT NULL,
[entity_tag_name] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[entity_tag_desc] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[target_entity_id] [int] NULL,
[tag_required_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tag_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[entity_id] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_entity_tag_definition_idx] ON [dbo].[aud_entity_tag_definition] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_entity_tag_definition_idx1] ON [dbo].[aud_entity_tag_definition] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_entity_tag_definition] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_entity_tag_definition] TO [next_usr]
GO
