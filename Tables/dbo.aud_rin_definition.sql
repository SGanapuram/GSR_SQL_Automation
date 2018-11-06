CREATE TABLE [dbo].[aud_rin_definition]
(
[oid] [int] NOT NULL,
[rin_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rin_dcode] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rin_description] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rin_year] [smallint] NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_rin_definition_idx1] ON [dbo].[aud_rin_definition] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_rin_definition_idx2] ON [dbo].[aud_rin_definition] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_rin_definition] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_rin_definition] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_rin_definition] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_rin_definition] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_rin_definition] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_rin_definition', NULL, NULL
GO
