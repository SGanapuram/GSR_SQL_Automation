CREATE TABLE [dbo].[aud_entity_tag_option]
(
[entity_tag_id] [int] NOT NULL,
[tag_option] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tag_option_desc] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tag_option_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_entity_tag_option_idx] ON [dbo].[aud_entity_tag_option] ([entity_tag_id], [tag_option], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_entity_tag_option_idx1] ON [dbo].[aud_entity_tag_option] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_entity_tag_option] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_entity_tag_option] TO [next_usr]
GO
