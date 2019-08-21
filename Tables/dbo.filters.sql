CREATE TABLE [dbo].[filters]
(
[application] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[table_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[column_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alias_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[display_db] [tinyint] NULL,
[type] [int] NULL,
[length] [int] NULL,
[allow_null] [tinyint] NULL,
[filter_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[filters_updtrg]
on [dbo].[filters]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errorNumber      int,
        @errmsg           varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

select @dummy_update = 0


return
GO
ALTER TABLE [dbo].[filters] ADD CONSTRAINT [filters_pk] PRIMARY KEY CLUSTERED  ([application], [table_name], [column_name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[filters] TO [admin_group]
GO
GRANT INSERT ON  [dbo].[filters] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[filters] TO [admin_group]
GO
GRANT UPDATE ON  [dbo].[filters] TO [admin_group]
GO
GRANT DELETE ON  [dbo].[filters] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[filters] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[filters] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[filters] TO [next_usr]
GO
