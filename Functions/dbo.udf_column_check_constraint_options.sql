SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[udf_column_check_constraint_options]
(
   @schema_name    sysname = 'dbo',
   @table_name     sysname,
   @column_name    sysname
)
RETURNS varchar(max) 
AS
BEGIN
   return (SELECT chk.definition as options
           FROM sys.check_constraints AS chk
                   INNER JOIN sys.columns AS col
                      ON col.object_id = chk.parent_object_id AND 
                         chk.parent_column_id = col.column_id
           WHERE chk.parent_object_id = OBJECT_ID(@schema_name + '.' + @table_name) and
                 col.name = @column_name)  
END    
GO
GRANT EXECUTE ON  [dbo].[udf_column_check_constraint_options] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[udf_column_check_constraint_options] TO [next_usr]
GO
