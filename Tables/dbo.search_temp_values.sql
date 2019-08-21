CREATE TABLE [dbo].[search_temp_values]
(
[spid] [smallint] NOT NULL,
[unique_id] [tinyint] NOT NULL,
[int_value] [int] NULL,
[code_value] [char] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[search_temp_values_updtrg]
on [dbo].[search_temp_values]
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
ALTER TABLE [dbo].[search_temp_values] ADD CONSTRAINT [search_temp_values_pk] PRIMARY KEY NONCLUSTERED  ([spid]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [search_temp_values] ON [dbo].[search_temp_values] ([spid], [unique_id], [int_value], [code_value]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[search_temp_values] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[search_temp_values] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[search_temp_values] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[search_temp_values] TO [next_usr]
GO
