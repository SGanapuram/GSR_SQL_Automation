SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[udf_table_colinfo]
(
   @schema_name    sysname = 'dbo',
   @table_name     sysname
)
RETURNS TABLE 
AS
RETURN 
(   
     select ORDINAL_POSITION as column_id,
            COLUMN_NAME as column_name,
            case when DATA_TYPE in ('char', 'nchar')
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
                 when DATA_TYPE in ('smallint', 'tinyint', 'int', 'real', 'float', 'datetime', 'datetime2',
                                    'text', 'ntext', 'bit', 'time', 'date', 'smalldatetime', 'image')
                    then DATA_TYPE
                 else
                    case when CHARACTER_MAXIMUM_LENGTH = -1
                            then 'xml'
                         else 
                            DATA_TYPE + '??'
                    end         
            end as datatype,
            case when IS_NULLABLE = 'YES' 
                    then 1
                 else 0
            end as null_flag
     from INFORMATION_SCHEMA.COLUMNS
     where TABLE_SCHEMA = @schema_name and
           TABLE_NAME = @table_name  
)    
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'FUNCTION', N'udf_table_colinfo', NULL, NULL
GO
