SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_purge_icts_audit_data2]
(
   @daysold        int = 30,
   @debugon        char(1) = 'N'
)
as
set nocount on
declare @sql                varchar(255),
        @entity_name        varchar(80),
        @table_name         varchar(80),
        @procname           varchar(80),
        @i                  int,
        @tempstr            varchar(255),
        @op_trans_id        int,
        @error_occurred     int,
        @rows_deleted       int,
        @rows_updated       int,
        @total_rows_deleted int,
        @smsg               varchar(255)

   create table #skip_purge_aud_tables 
   (
      entity_name varchar(80), 
      table_name varchar(80) null
   )

   create nonclustered index skip_purge_aud_tables_idx1 
         on #skip_purge_aud_tables(entity_name)
   create nonclustered index skip_purge_aud_tables_idx2 
         on #skip_purge_aud_tables(table_name)

   if exists (select 1
              from send_to_SAP
              where op_trans_id > 0)
   begin
      declare mycursor CURSOR for
         select entity_name, max(op_trans_id)
         from send_to_SAP
         group by entity_name
         order by entity_name

      open mycursor
      fetch next from mycursor into @entity_name, @op_trans_id       
      while @@FETCH_STATUS = 0
      begin
         if @debugon = 'Y'
         begin
            select @smsg = 'DEBUG: entity = ' + @entity_name + ', max op_trans_id = ' + convert(varchar, @op_trans_id)
            print @smsg
         end
         insert into #skip_purge_aud_tables (entity_name)
         select distinct a.entity_name
         from transaction_touch a
         where trans_id = @op_trans_id and
               not exists (select 1
                           from #skip_purge_aud_tables b
                           where a.entity_name = b.entity_name)

         fetch next from mycursor into @entity_name, @op_trans_id       
      end
      close mycursor
      deallocate mycursor

      declare mycursor CURSOR for
         select entity_name
         from #skip_purge_aud_tables

      open mycursor
      fetch next from mycursor into @entity_name
      while @@FETCH_STATUS = 0
      begin
         select @table_name = ''
         select @i = 1 
         while @i <= datalength(@entity_name)
         begin
            select @tempstr = substring(@entity_name, @i, 1)  
            if ascii(@tempstr) >= ascii('A') and ascii(@tempstr) <= ascii('Z')
            begin
               if @i > 1
                  select @table_name = @table_name + '_' + char(ascii(@tempstr) + 32)
               else
                  select @table_name = char(ascii(@tempstr) + 32)
            end
            else
            begin  /* Entity name shall not have embedded '_' */
               if @tempstr <> '_'
                  select @table_name = @table_name + @tempstr
            end   
            select @i = @i + 1
         end
     
         select @table_name = 'aud_' + @table_name
         if object_id(@table_name) is not null
         begin
            update #skip_purge_aud_tables
            set table_name = @table_name
            where entity_name = @entity_name
         end
         else
         begin
            select @smsg = 'The table ''' + @table_name + ' does not exist!'
            print @smsg
            break
         end
         fetch next from mycursor into @entity_name
      end
      close mycursor
      deallocate mycursor

      if @debugon = 'Y'
         select * from #skip_purge_aud_tables order by entity_name
   end

   create table #purge_aud_tables
   (
      name      varchar(80)
   )

   -- copy tables into temporary table to avoid locking up the sysobjects 
   -- table
   insert into #purge_aud_tables (name)
   select name
   from sysobjects obj
   where type = 'U' and
         name like 'aud_%' and
         not exists (select 1
                     from #skip_purge_aud_tables b
                     where obj.name = b.table_name)
      
   declare mycursor CURSOR for
      select name
      from #purge_aud_tables
      order by name

   open mycursor
   fetch next from mycursor into @table_name
   while @@FETCH_STATUS = 0
   begin
      select @procname = 'x_' + substring(@table_name, 1, 28)
      if object_id(@table_name) is not null
      begin
         if object_id(@procname) is not null
         begin         
            select @sql = 'exec ' + @procname + ' @daysold = ' + convert(varchar, @daysold)
            if @debugon = 'Y'
            begin
               print 'DEBUG: SQL = ' + @sql
            end
            exec(@sql)
         end
         else
         begin
            select @smsg = 'The procedure ''' + @procname + ''' does not exist!'
            print @smsg
            break
         end
      end

      fetch next from mycursor into @table_name
   end
   close mycursor
   deallocate mycursor
   drop table #skip_purge_aud_tables  
   drop table #purge_aud_tables
return 0
GO
GRANT EXECUTE ON  [dbo].[usp_purge_icts_audit_data2] TO [ictspurge]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_purge_icts_audit_data2', NULL, NULL
GO
