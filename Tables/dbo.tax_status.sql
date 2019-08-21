CREATE TABLE [dbo].[tax_status]
(
[tax_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tax_status_desc] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tax_status] ADD CONSTRAINT [tax_status_pk] PRIMARY KEY CLUSTERED  ([tax_status_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tax_status] TO [admin_group]
GO
GRANT INSERT ON  [dbo].[tax_status] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[tax_status] TO [admin_group]
GO
GRANT UPDATE ON  [dbo].[tax_status] TO [admin_group]
GO
GRANT DELETE ON  [dbo].[tax_status] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tax_status] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tax_status] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tax_status] TO [next_usr]
GO
