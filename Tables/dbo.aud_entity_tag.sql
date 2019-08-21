CREATE TABLE [dbo].[aud_entity_tag]
(
[entity_tag_key] [int] NOT NULL,
[entity_tag_id] [int] NOT NULL,
[key1] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key2] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key3] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key4] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key5] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key6] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key7] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key8] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[target_key1] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[target_key2] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[target_key3] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[target_key4] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[target_key5] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[target_key6] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[target_key7] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[target_key8] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_entity_tag_idx] ON [dbo].[aud_entity_tag] ([entity_tag_key], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_entity_tag_idx1] ON [dbo].[aud_entity_tag] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_entity_tag] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_entity_tag] TO [next_usr]
GO
