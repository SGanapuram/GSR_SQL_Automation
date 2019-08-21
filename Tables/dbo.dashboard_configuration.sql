CREATE TABLE [dbo].[dashboard_configuration]
(
[config_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[config_value] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dashboard_configuration] ADD CONSTRAINT [dashboard_configuration_pk] PRIMARY KEY CLUSTERED  ([config_name]) ON [PRIMARY]
GO
