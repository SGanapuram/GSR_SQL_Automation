CREATE TABLE [dbo].[dashboard_configuration]
(
[config_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[config_value] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dashboard_configuration] ADD CONSTRAINT [PK__dashboar__DACDDDEB4B78CBAD] PRIMARY KEY CLUSTERED  ([config_name]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[dashboard_configuration] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[dashboard_configuration] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[dashboard_configuration] TO [next_usr]
GO
