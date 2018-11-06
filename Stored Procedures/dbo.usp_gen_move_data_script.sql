SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_gen_move_data_script]
(
   @tablename          varchar(128),
   @debugon            bit = 0
)
as
set nocount on
declare @colid                    int,
        @column_name              varchar(128),
        @last_colid               int,
        @dbname                   varchar(128),
        @ident_flag               bit 
        
   select @dbname = db_name()

   create table #table_layout
   ( 
      colid                    int primary key,
      column_name              varchar(128) not null
   )

   insert into #table_layout
      (colid, column_name)
   select ORDINAL_POSITION,
          COLUMN_NAME
   from INFORMATION_SCHEMA.COLUMNS
   where TABLE_CATALOG = @dbname and
         TABLE_SCHEMA = 'dbo' and
         TABLE_NAME = @tablename
   order by ORDINAL_POSITION

   print 'print '' '''
   print 'print ''Copying records in TEMP table to the ''external_trade'' table ...'''
   print 'go'
   print ' '

   -- Find out if the table has an IDENTITY column
   select @ident_flag = 0
   select @colid = min(colid)
   from #table_layout

   while @colid is not null
   begin
      select @column_name = column_name
      from #table_layout
      where colid = @colid
      
      if COLUMNPROPERTY(object_id('dbo.' + @tablename), @column_name, 'IsIdentity') = 1
      begin
         select @ident_flag = 1
         break
      end

      select @colid = min(colid)
      from #table_layout
      where colid > @colid
   end
   if @ident_flag = 1
   begin
      print 'set IDENTITY_INSERT ' + @tablename + ' ON'
      print 'go'
      print ' '
   end
   
   print 'insert into dbo.' + @tablename
   print '('

   select @last_colid = max(colid)
   from #table_layout

   select @colid = min(colid)
   from #table_layout

   while @colid is not null
   begin
      select @column_name = column_name
      from #table_layout
      where colid = @colid

      if @debugon = 1
      begin   
         print '****'
         print 'COLUMN #' + cast(@colid as varchar)
         print 'COLUMN NAME    = ' + @column_name
      end   
      
      if @last_colid > @colid
         print '  ' + @column_name + ','
      else
         print '  ' + @column_name
      
      select @colid = min(colid)
      from #table_layout
      where colid > @colid
   end
   print ')'
   print 'select'

   select @colid = min(colid)
   from #table_layout

   while @colid is not null
   begin
      select @column_name = column_name
      from #table_layout
      where colid = @colid

      if @last_colid > @colid
         print '  ' + @column_name + ','
      else
         print '  ' + @column_name
               
      select @colid = min(colid)
      from #table_layout
      where colid > @colid
   end
   print 'from dbo.' + @tablename
   print 'go'
   print ' '

   if @ident_flag = 1
   begin
      print 'set IDENTITY_INSERT ' + @tablename + ' OFF'
      print 'go'
      print ' '
   end

   print 'declare @rowcount int'
   print 'declare @rowcount1 int'
   print ' '
   print 'select @rowcount = count(*)'
   print 'from dbo.' + @tablename 
   print ' '
   print 'select @rowcount1 = count(*)'
   print 'from dbo.' + @tablename + '_TEMP'
   print ' '

   print 'if (@rowcount = @rowcount1)'
   print 'begin'
   print '   print ''Records in temp table were copied to the ''''' + @tablename + ''''' table successfully, drop temp table!'''
   print '   drop table dbo.' + @tablename + '_TEMP'
   print 'end'
   print 'else'
   print '   print ''Failed to copy records in temp table to ''''' + @tablename + ''''' table!'''
   print 'go'
   
   drop table #table_layout
GO
GRANT EXECUTE ON  [dbo].[usp_gen_move_data_script] TO [public]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_gen_move_data_script', NULL, NULL
GO
