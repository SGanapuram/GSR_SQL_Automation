CREATE TABLE [dbo].[external_comment_archive]
(
[oid] [int] NOT NULL,
[comment_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[archived_date] [datetime] NOT NULL CONSTRAINT [df_external_comment_archive_archived_date] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[external_comment_archive] ADD CONSTRAINT [external_comment_archive_pk] PRIMARY KEY CLUSTERED  ([oid], [archived_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[external_comment_archive] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[external_comment_archive] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[external_comment_archive] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[external_comment_archive] TO [next_usr]
GO
