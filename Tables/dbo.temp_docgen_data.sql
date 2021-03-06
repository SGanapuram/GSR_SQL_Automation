CREATE TABLE [dbo].[temp_docgen_data]
(
[key1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key6] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[entity_id] [int] NULL,
[attr_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[attr_value] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[executor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[creation_time] [datetime] NULL CONSTRAINT [df_temp_docgen_data_creation_time] DEFAULT (getdate())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[temp_docgen_data] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[temp_docgen_data] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[temp_docgen_data] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[temp_docgen_data] TO [next_usr]
GO
