SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_show_table_FKEYs]
(
   @schemaname  sysname = 'dbo',
   @tablename   sysname = NULL
)
as
begin
DECLARE @rkey_tablename   sysname,
        @constraint_name  sysname,
        @smsg             varchar(255)

   if @tablename is null 
   begin
      print 'Please provide a table name'
      print 'Usage: exec usp_show_table_FKEYs @tablename = ''?'''
      return
   end

   if NOT exists (select 1
                  from sys.tables
                  where name = @tablename)
   begin      
      select @smsg = 'Could not find the table ''' + @tablename + ''' in the database ''' + db_name(dbid) + '''!'
      from master.dbo.sysprocesses 
      where spid = @@spid      
      print @smsg
      return
   end

   DECLARE mycur CURSOR FOR
      select name,
             OBJECT_NAME(referenced_object_id)           
      from sys.foreign_keys
      where OBJECT_SCHEMA_NAME(parent_object_id) = @schemaname and
            OBJECT_NAME(parent_object_id) = @tablename
      order by name
    FOR READ ONLY

   OPEN mycur
   FETCH NEXT FROM mycur INTO @constraint_name, @rkey_tablename
   while (@@FETCH_STATUS = 0)
   begin
      print 'Constraint: ' + @constraint_name + ' ---> refers to table <' + @rkey_tablename + '>'

      FETCH NEXT FROM mycur INTO @constraint_name, @rkey_tablename
   end
   CLOSE mycur
   DEALLOCATE mycur
end
return
GO
GRANT EXECUTE ON  [dbo].[usp_show_table_FKEYs] TO [next_usr]
GO
GRANT EXECUTE ON  [dbo].[usp_show_table_FKEYs] TO [public]
GO
