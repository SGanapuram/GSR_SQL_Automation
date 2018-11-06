CREATE TABLE [dbo].[aud_ag_external_codes]
(
[oid] [int] NOT NULL,
[code] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[description] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[entity_type] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[source] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[ext_char_col1] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ext_char_col2] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ext_char_col3] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ext_int_col1] [int] NULL,
[ext_int_col2] [int] NULL,
[ext_int_col3] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ag_external_codes] ON [dbo].[aud_ag_external_codes] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ag_external_codes_idx1] ON [dbo].[aud_ag_external_codes] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_ag_external_codes] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_ag_external_codes] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_ag_external_codes] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_ag_external_codes] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_ag_external_codes] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_ag_external_codes', NULL, NULL
GO
