CREATE TABLE [dbo].[AUD_FL_GROUPS_USERS]
(
[fleetimeUser] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[groupName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[operation] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[userid] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[date_op] [datetime] NOT NULL
) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[AUD_FL_GROUPS_USERS] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[AUD_FL_GROUPS_USERS] TO [next_usr]
GO
