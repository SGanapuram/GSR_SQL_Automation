CREATE TABLE [dbo].[aud_ext_trandata_mapping]
(
[oid] [int] NOT NULL,
[alias_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[entity_id] [int] NOT NULL,
[external_key1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[external_key2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[external_key3] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[entity_key1_value_id] [int] NOT NULL,
[entity_key2_value_id] [int] NULL,
[entity_key3_value_id] [int] NULL,
[entity_key4_value_id] [int] NULL,
[entity_key5_value_id] [int] NULL,
[entity_key6_value_id] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ext_trandata_mapping] ON [dbo].[aud_ext_trandata_mapping] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ext_trandata_mapping_idx1] ON [dbo].[aud_ext_trandata_mapping] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_ext_trandata_mapping] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_ext_trandata_mapping] TO [next_usr]
GO
