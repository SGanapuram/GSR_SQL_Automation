CREATE TABLE [dbo].[calendar_detail]
(
[calendar_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[calendar_date] [datetime] NOT NULL,
[calendar_date_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[calendar_date_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[calendar_detail] ADD CONSTRAINT [calendar_detail_pk] PRIMARY KEY CLUSTERED  ([calendar_code], [calendar_date]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[calendar_detail] ADD CONSTRAINT [calendar_detail_fk1] FOREIGN KEY ([calendar_code]) REFERENCES [dbo].[calendar] ([calendar_code])
GO
GRANT DELETE ON  [dbo].[calendar_detail] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[calendar_detail] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[calendar_detail] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[calendar_detail] TO [next_usr]
GO
