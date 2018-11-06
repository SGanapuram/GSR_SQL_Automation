CREATE TABLE [dbo].[aud_exceptions_additions]
(
[excp_addns_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[excp_addns_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_exceptions_additions_idx] ON [dbo].[aud_exceptions_additions] ([excp_addns_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_exceptions_additions] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_exceptions_additions] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_exceptions_additions] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_exceptions_additions] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_exceptions_additions] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_exceptions_additions', NULL, NULL
GO