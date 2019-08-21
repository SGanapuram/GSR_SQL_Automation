CREATE TABLE [dbo].[specification_alias]
(
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alias_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spec_alias_name] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[specification_alias] ADD CONSTRAINT [specification_alias_pk] PRIMARY KEY CLUSTERED  ([spec_code], [alias_source_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[specification_alias] ADD CONSTRAINT [specification_alias_fk1] FOREIGN KEY ([spec_code]) REFERENCES [dbo].[specification] ([spec_code])
GO
ALTER TABLE [dbo].[specification_alias] ADD CONSTRAINT [specification_alias_fk2] FOREIGN KEY ([alias_source_code]) REFERENCES [dbo].[alias_source] ([alias_source_code])
GO
GRANT DELETE ON  [dbo].[specification_alias] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[specification_alias] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[specification_alias] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[specification_alias] TO [next_usr]
GO
