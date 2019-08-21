CREATE TABLE [dbo].[entity_key_name]
(
[entity_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[key_num] [int] NOT NULL,
[key_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[key_data_type] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[entity_key_name] ADD CONSTRAINT [entity_key_name_pk] PRIMARY KEY CLUSTERED  ([entity_name], [key_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[entity_key_name] TO [admin_group]
GO
GRANT INSERT ON  [dbo].[entity_key_name] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[entity_key_name] TO [admin_group]
GO
GRANT UPDATE ON  [dbo].[entity_key_name] TO [admin_group]
GO
GRANT DELETE ON  [dbo].[entity_key_name] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[entity_key_name] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[entity_key_name] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[entity_key_name] TO [next_usr]
GO
