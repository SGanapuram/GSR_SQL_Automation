SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[udf_table_column_data_type]
(
   @schema_name    sysname = 'dbo',
   @table_name     sysname,
   @column_name    sysname
)
RETURNS sysname 
AS
BEGIN
   return (select case when DATA_TYPE in ('char', 'nchar')
                          then 
                             DATA_TYPE + '(' + cast(CHARACTER_MAXIMUM_LENGTH as varchar) + ')'
                       when DATA_TYPE in ('varchar', 'nvarchar', 'varbinary')
                          then 
                             case when CHARACTER_MAXIMUM_LENGTH = -1
                                     then DATA_TYPE + '(max)'
                                  else
                                     DATA_TYPE + '(' + cast(CHARACTER_MAXIMUM_LENGTH as varchar) + ')'
                             end                 
                       when DATA_TYPE in ('decimal', 'numeric')
                          then DATA_TYPE + '(' + cast(NUMERIC_PRECISION as varchar) + 
                                  case when NUMERIC_SCALE is not null 
                                          then ', ' + cast(NUMERIC_SCALE as varchar)
                                  end + ')'
                       when DATA_TYPE in ('smallint', 'tinyint', 'int', 'bigint', 'real', 'float', 'datetime', 'datetime2',
                                          'text', 'ntext', 'bit', 'time', 'date', 'smalldatetime', 'image')
                          then DATA_TYPE
                       else
                          case when CHARACTER_MAXIMUM_LENGTH = -1
                                  then 'xml'
                               else 
                                  DATA_TYPE + '??'
                          end         
                  end
           from INFORMATION_SCHEMA.COLUMNS
           where TABLE_SCHEMA = @schema_name and
                 TABLE_NAME = @table_name and
                 COLUMN_NAME = @column_name)  
END    
GO
GRANT EXECUTE ON  [dbo].[udf_table_column_data_type] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[udf_table_column_data_type] TO [next_usr]
GO
