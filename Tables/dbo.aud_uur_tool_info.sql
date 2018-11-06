CREATE TABLE [dbo].[aud_uur_tool_info]
(
[oid] [int] NOT NULL IDENTITY(1, 1),
[uurt_scope] [char] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[uurt_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[uurt_version] [char] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[last_updated] [datetime] NOT NULL,
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_uur_tool_info] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_uur_tool_info] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_uur_tool_info] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_uur_tool_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_uur_tool_info] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[aud_uur_tool_info] TO [uurt]
GO
GRANT SELECT ON  [dbo].[aud_uur_tool_info] TO [uurt]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_uur_tool_info', NULL, NULL
GO
