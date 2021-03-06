CREATE TABLE [dbo].[uic_reporting_history]
(
[report_mod_id] [int] NOT NULL,
[values_config_id] [int] NOT NULL,
[old_value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[new_value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
ALTER TABLE [dbo].[uic_reporting_history] ADD CONSTRAINT [uic_reporting_history_pk] PRIMARY KEY CLUSTERED  ([report_mod_id], [values_config_id]) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[uic_reporting_history] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[uic_reporting_history] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[uic_reporting_history] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[uic_reporting_history] TO [next_usr]
GO
