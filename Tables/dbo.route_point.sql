CREATE TABLE [dbo].[route_point]
(
[oid] [int] NOT NULL,
[route_id] [int] NOT NULL,
[seq_num] [int] NOT NULL,
[latitue] [numeric] (9, 6) NOT NULL,
[longitude] [numeric] (9, 6) NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[route_point] ADD CONSTRAINT [route_point_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[route_point] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[route_point] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[route_point] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[route_point] TO [next_usr]
GO
