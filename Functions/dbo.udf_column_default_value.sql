SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[udf_column_default_value]
(
   @schema_name    sysname = 'dbo',
   @table_name     sysname,
   @column_name    sysname
)
RETURNS varchar(max) 
AS
BEGIN
   return (SELECT dft.definition 
           FROM sys.default_constraints AS dft
                   INNER JOIN sys.columns AS col
                      ON col.object_id = dft.parent_object_id AND 
                         dft.parent_column_id = col.column_id
           WHERE dft.parent_object_id = OBJECT_ID(@schema_name + '.' + @table_name) and
                 col.name = @column_name)  
END    
GO
GRANT EXECUTE ON  [dbo].[udf_column_default_value] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[udf_column_default_value] TO [next_usr]
GO
