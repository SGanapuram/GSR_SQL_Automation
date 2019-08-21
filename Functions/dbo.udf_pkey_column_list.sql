SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[udf_pkey_column_list]
(
   @schema_name    sysname = 'dbo',
   @table_name     sysname
)
RETURNS varchar(4000) 
AS
BEGIN
declare @column_list    varchar(4000)

   select @column_list = COALESCE(@column_list + ',', '') + column_name
   from [dbo].[udf_table_pkey_columns_and_their_datatypes](@schema_name, @table_name)

   return @column_list
END
GO
GRANT EXECUTE ON  [dbo].[udf_pkey_column_list] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[udf_pkey_column_list] TO [next_usr]
GO
