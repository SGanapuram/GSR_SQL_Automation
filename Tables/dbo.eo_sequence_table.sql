CREATE TABLE [dbo].[eo_sequence_table]
(
[table_name] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[counter] [int] NOT NULL CONSTRAINT [df_eo_sequence_table_counter] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[eo_sequence_table] ADD CONSTRAINT [eo_sequence_table_pk] PRIMARY KEY CLUSTERED  ([table_name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[eo_sequence_table] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[eo_sequence_table] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[eo_sequence_table] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[eo_sequence_table] TO [next_usr]
GO
