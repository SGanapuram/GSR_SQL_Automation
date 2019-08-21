SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[udf_table_pkey_columns_and_their_datatypes] 
(
   @schema_name  sysname = 'dbo',
   @table_name   sysname
)
RETURNS TABLE 
AS
RETURN 
(
   -- Using TOP so that I can use ORDER BY clause
   select TOP 30 
      b.COLUMN_NAME as column_name,
      case when c.DATA_TYPE in ('char', 'nvarchar', 'varchar')
              then 
                 case when c.CHARACTER_MAXIMUM_LENGTH = -1
                         then 
                             c.DATA_TYPE + '(max)'
                      else
                         c.DATA_TYPE + '(' + cast(c.CHARACTER_MAXIMUM_LENGTH as varchar) + ')'
                 end
           when c.DATA_TYPE in ('decimal', 'numeric')
              then 
                 c.DATA_TYPE + '(' + cast(c.NUMERIC_PRECISION as varchar) +
                   case when c.NUMERIC_SCALE > 0
                           then ', ' + cast(c.NUMERIC_SCALE as varchar) 
                        else
                           ''
                   end + ')'
           else  /* c.DATA_TYPE in ('float', 'bigint', 'smallint', 'text', 'xml',
                                'tinyint', 'image', 'bit', 'real', 'datetime', 'date') */
              c.DATA_TYPE 
      end as data_type
   from INFORMATION_SCHEMA.TABLE_CONSTRAINTS a,
        INFORMATION_SCHEMA.KEY_COLUMN_USAGE b,
        INFORMATION_SCHEMA.COLUMNS c
   where a.TABLE_CATALOG = db_name() and
         a.TABLE_SCHEMA = @schema_name and
         a.TABLE_NAME = @table_name and
         a.CONSTRAINT_TYPE = 'PRIMARY KEY' and
         a.TABLE_CATALOG = b.TABLE_CATALOG and
         a.TABLE_SCHEMA = b.TABLE_SCHEMA and
         a.TABLE_NAME = b.TABLE_NAME and
         a.CONSTRAINT_NAME = b.CONSTRAINT_NAME and
         b.TABLE_CATALOG = c.TABLE_CATALOG and
         b.TABLE_SCHEMA = c.TABLE_SCHEMA and
         b.TABLE_NAME = c.TABLE_NAME and
         b.COLUMN_NAME = c.COLUMN_NAME
   order by b.ORDINAL_POSITION
)
GO
GRANT SELECT ON  [dbo].[udf_table_pkey_columns_and_their_datatypes] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[udf_table_pkey_columns_and_their_datatypes] TO [next_usr]
GO
