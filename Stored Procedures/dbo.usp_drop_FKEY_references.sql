SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_drop_FKEY_references]
(
   @tablename   sysname,
   @owner       sysname = 'dbo'
)
as
set nocount on

declare @fkey_tablename   sysname,
        @constraint_name  sysname,
        @sqlcmd           varchar(255),
        @smsg             varchar(255),
        @dbowner          sysname,
        @fulltablename    sysname

   if @tablename is null 
   begin
      print 'Please provide a table name'
      print 'Usage: exec usp_drop_FKEY_references @tablename = ''?'' [, @owner = ''?'']'
      return
   end

   if @owner is null
      select @dbowner = 'dbo'
   else
      select @dbowner = @owner

   if user_id(@dbowner) is null
   begin
      print 'Please provide a valid db owner'
      print 'Usage: exec usp_drop_FKEY_references @tablename = ''?'' [, @owner = ''?'']'
      return
   end
            
   if NOT exists (select 1
                  from sysobjects
                  where type = 'U' and
                        uid = user_id(@dbowner) and
                        name = @tablename)
   begin      
      select @smsg = 'Could not find the table ''' + @dbowner + '.' + @tablename + ''' in the database ''' + db_name(dbid) + '''!'
      from master.dbo.sysprocesses 
      where spid = @@spid      
      print @smsg
      return
   end

   select @fulltablename = @dbowner + '.' + @tablename
   DECLARE mycur CURSOR FOR
      select object_name(fkeyid), 
             object_name(constid)           
      from sysreferences
      where rkeyid = object_id(@fulltablename)
      order by object_name(fkeyid), object_name(constid)
    FOR READ ONLY

   OPEN mycur
   FETCH NEXT FROM mycur INTO @fkey_tablename, @constraint_name
   while (@@FETCH_STATUS = 0)
   begin
      select @sqlcmd = 'alter table ' + @fkey_tablename + ' drop constraint ' + @constraint_name
      print @sqlcmd
      exec (@sqlcmd)
      FETCH NEXT FROM mycur INTO @fkey_tablename, @constraint_name
   end
   CLOSE mycur
   DEALLOCATE mycur
return
GO
GRANT EXECUTE ON  [dbo].[usp_drop_FKEY_references] TO [next_usr]
GO
