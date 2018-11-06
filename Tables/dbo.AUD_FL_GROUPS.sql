CREATE TABLE [dbo].[AUD_FL_GROUPS]
(
[groupName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[description] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[builtin] [int] NULL,
[operation] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[userid] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[date_op] [datetime] NOT NULL
) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[AUD_FL_GROUPS] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[AUD_FL_GROUPS] TO [next_usr]
GO
