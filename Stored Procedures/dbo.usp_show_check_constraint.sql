SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_show_check_constraint]
(
   @table_name      sysname = NULL,
   @column_name     sysname = NULL
)
as
declare @smsg              varchar(255),
        @dbname            sysname,
        @constraint_name   sysname,
        @logical_expr      varchar(800)
       
   if @table_name is null OR @column_name is null
   begin
      print "Usage: exec usp_check_constraint_name @table_name = '?', @column_name = '?'"
      print "You must give a table name and a column name"
      return
   end

   if object_id('dbo.' + @table_name) is null
   begin
      select @dbname = db_name()
      select @smsg = "Could not find the table '" + @table_name + " in database '" + @dbname + "'."
      print @smsg
      return 
   end

   if not exists (select 1
                  from sys.columns
                  where object_id = object_id('dbo.' + @table_name) and
                        name = @column_name)
   begin
      select @dbname = db_name()
      select @smsg = "Could not find the column '" + @column_name + " in table '" + @table_name + "'."
      print @smsg
      return 
   end
                  
   select @constraint_name = obj2.name
   from sys.sysconstraints cons, 
        sys.sysobjects obj1, 
        sys.sysobjects obj2
   where cons.id = obj1.id and
         obj1.uid = 1 and
         obj1.name = @table_name and
         col_name(cons.id, cons.colid) = @column_name and         
         (cons.status & 4) = 4 and
         obj2.id = cons.constid and
         obj2.xtype = 'C '


   select @logical_expr = substring(text, 1, 512)
   from sys.syscomments
   where id = (select cons.constid
               from sys.sysconstraints cons, 
                    sys.sysobjects obj1, 
                    sys.sysobjects obj2
               where cons.id = obj1.id and
                     obj1.uid = 1 and
                     obj1.name = @table_name and
                     col_name(cons.id, cons.colid) = @column_name and         
                     (cons.status & 4) = 4 and
                     obj2.id = cons.constid and
                     obj2.xtype = 'C ')

   print 'Table name       = ' + @table_name
   print 'Column name      = ' + @column_name
   print 'Constraint name  = ' + @constraint_name
   print 'Logical Expr. (only show the first 512 characters): ' 
   print '==> ' + @logical_expr
return
GO
GRANT EXECUTE ON  [dbo].[usp_show_check_constraint] TO [public]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_show_check_constraint', NULL, NULL
GO
