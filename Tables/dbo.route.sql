CREATE TABLE [dbo].[route]
(
[oid] [int] NOT NULL,
[route_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[from_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[to_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[route] ADD CONSTRAINT [route_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[route] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[route] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[route] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[route] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'route', NULL, NULL
GO
