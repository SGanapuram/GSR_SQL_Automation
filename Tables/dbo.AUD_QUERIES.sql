CREATE TABLE [dbo].[AUD_QUERIES]
(
[fldchrQueryName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[category] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[operation] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[userid] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[date_op] [datetime] NOT NULL
) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[AUD_QUERIES] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[AUD_QUERIES] TO [next_usr]
GO
