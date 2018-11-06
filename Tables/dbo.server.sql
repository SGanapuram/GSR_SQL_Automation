CREATE TABLE [dbo].[server]
(
[last_sequence] [numeric] (32, 0) NULL,
[name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[type] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[server] ADD CONSTRAINT [server_pk] PRIMARY KEY CLUSTERED  ([name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[server] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[server] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[server] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[server] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'server', NULL, NULL
GO
