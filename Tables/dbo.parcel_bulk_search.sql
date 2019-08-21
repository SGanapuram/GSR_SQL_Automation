CREATE TABLE [dbo].[parcel_bulk_search]
(
[sequence] [int] NOT NULL IDENTITY(1, 1),
[parcel_id] [int] NOT NULL,
[alloc_num] [int] NULL,
[alloc_item_num] [int] NULL,
[reference] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[search_guid] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[search_time] [datetime] NULL CONSTRAINT [df_parcel_bulk_search_search_time] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[parcel_bulk_search] ADD CONSTRAINT [parcel_bulk_search_pk] PRIMARY KEY CLUSTERED  ([sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[parcel_bulk_search] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[parcel_bulk_search] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[parcel_bulk_search] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[parcel_bulk_search] TO [next_usr]
GO
