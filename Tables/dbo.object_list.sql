CREATE TABLE [dbo].[object_list]
(
[object_class] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[table_view_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[object_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[reference_default] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[object_list_updtrg]
on [dbo].[object_list]
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

GO
ALTER TABLE [dbo].[object_list] ADD CONSTRAINT [object_list_pk] PRIMARY KEY CLUSTERED  ([object_class]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[object_list] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[object_list] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[object_list] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[object_list] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'object_list', NULL, NULL
GO
