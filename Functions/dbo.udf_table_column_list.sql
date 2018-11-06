SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[udf_table_column_list]
(
   @table_name     sysname
)
RETURNS varchar(MAX)
AS
BEGIN
declare @collist        varchar(max),
        @rows_affected  int

   set @collist = ''
   set @rows_affected = 0
   select @collist = case when @collist = '' then @collist + name
	                         else @collist + ',' + name 
	                 end 
   from sys.columns
   where object_id = OBJECT_ID('dbo.' + @table_name, 'U') 
   select @rows_affected = @@rowcount
   
   if @rows_affected = 0
      set @collist = ''
      
   return @collist
END
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'FUNCTION', N'udf_table_column_list', NULL, NULL
GO
