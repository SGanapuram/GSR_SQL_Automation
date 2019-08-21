CREATE TABLE [dbo].[FREIGHT_DBINFO]
(
[db_version] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[freight_module] [char] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[owner_code] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[major_revnum] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[minor_revnum] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[last_touch_date] [datetime] NOT NULL,
[data_source] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[usage] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[script_reference] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[note] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FREIGHT_DBINFO] ADD CONSTRAINT [PK_FREIGHT_DBINFO] PRIMARY KEY CLUSTERED  ([db_version]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[FREIGHT_DBINFO] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[FREIGHT_DBINFO] TO [next_usr]
GO
