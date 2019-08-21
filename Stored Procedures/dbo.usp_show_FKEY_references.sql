SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_show_FKEY_references]
(
   @tablename   sysname = NULL
)
as
begin
DECLARE @columnlist       varchar(255),
        @fkeyid           int,
        @constid          int,
        @keyno            smallint,
        @keycnt           smallint,
        @colname          sysname,
        @smsg             varchar(255)
      

   if @tablename is null 
   begin
      print 'Please provide a table name'
      print 'Usage: exec usp_show_FKEY_references @tablename = ''?'''
      return
   end

   if NOT exists (select 1
                  from sys.tables
                  where schema_id = SCHEMA_ID('dbo') and
                        name = @tablename)
   begin      
      select @smsg = 'Could not find the table ''' + @tablename + ''' in the database ''' + db_name(dbid) + '''!'
      from master.sys.sysprocesses 
      where spid = @@spid      
      print @smsg
      return
   end

   create table #temp 
   (
      tablename      sysname null,
      constraintname sysname null,
      columns        varchar(255) null
    )

   DECLARE mycur CURSOR FOR
      select fkeyid, 
             constid,
             keycnt           
      from sys.sysreferences
      where rkeyid = object_id(@tablename)
      order by object_name(fkeyid), object_name(constid)
    FOR READ ONLY

   OPEN mycur
   FETCH NEXT FROM mycur INTO @fkeyid, @constid, @keycnt
   while (@@FETCH_STATUS = 0)
   begin
      select @columnlist = ''
      select @keyno = 1
      while  @keyno <= @keycnt
      begin
         select @colname = col.name
         from sys.syscolumns col, 
              sys.sysforeignkeys k
         where k.constid = @constid and
               k.fkeyid = @fkeyid and
               k.keyno = @keyno and
               k.fkeyid = col.id and
               k.fkey = col.colid 
         if @columnlist != ''
            select @columnlist = @columnlist + ', '
         select @columnlist = @columnlist + @colname
         select @keyno = @keyno + 1
      end
      insert into #temp
        values(object_name(@fkeyid), object_name(@constid), @columnlist)
      FETCH NEXT FROM mycur INTO @fkeyid, @constid, @keycnt
   end
   CLOSE mycur
   DEALLOCATE mycur
   select *
   from #temp
   order by tablename, constraintname
   
   drop table #temp
end
return
GO
GRANT EXECUTE ON  [dbo].[usp_show_FKEY_references] TO [next_usr]
GO
GRANT EXECUTE ON  [dbo].[usp_show_FKEY_references] TO [public]
GO
