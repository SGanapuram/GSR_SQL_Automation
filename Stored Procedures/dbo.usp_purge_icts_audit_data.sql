SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_purge_icts_audit_data]
(
   @archived_daysold  smallint = -1,
   @purged_daysold    smallint = -1,
   @debugon           char(1) = 'N'
)
as
set nocount on
set xact_abort on
declare @sql                   varchar(255),
        @keycnt                int,
        @keyval1               varchar(30),
        @keyval2               varchar(30),
        @keyval3               varchar(30),
        @keyval4               varchar(30),
        @keyval5               varchar(30),
        @keyval6               varchar(30),
        @keyval7               varchar(30),
        @keyval8               varchar(30),
        @entity_name           varchar(30),
        @tablename             varchar(30),
        @colname1              varchar(30),
        @colname2              varchar(30),
        @colname3              varchar(30),
        @colname4              varchar(30),
        @colname5              varchar(30),
        @colname6              varchar(30),
        @colname7              varchar(30),
        @colname8              varchar(30),
        @datatypename1         varchar(30),
        @datatypename2         varchar(30),
        @datatypename3         varchar(30),
        @datatypename4         varchar(30),
        @datatypename5         varchar(30),
        @datatypename6         varchar(30),
        @datatypename7         varchar(30),
        @datatypename8         varchar(30),
        @i                     int,
        @collist               varchar(255),
        @tempstr               varchar(255),
        @op_trans_id           bigint,
        @error_occurred        int,
        @rows_deleted          int,
        @rows_updated          int,
        @total_rows_deleted    int,
        @touch_key             numeric(32,0),
        @trans_id              bigint,
        @resp_trans_id         bigint,
        @archived_asof_date    datetime,
        @purged_asof_date      datetime,
        @chg_archived_ind_to_P tinyint

   if @archived_daysold is null or @archived_daysold = -1
   begin
      select @archived_asof_date = getdate()
   end
   else
   begin
      select @i = @archived_daysold * -1
      select @archived_asof_date = dateadd(day, @i, getdate())
   end

   if @purged_daysold is null or @purged_daysold = -1
   begin
      select @purged_asof_date = null
   end
   else
   begin
      select @i = @purged_daysold * -1
      select @purged_asof_date = dateadd(day, @i, getdate())
   end
                   
   create table #tblinfo
   (
      tablename      varchar(30) null,
      entity_name    varchar(30) null,
      keycnt         int null,
      keyname1       varchar(30) null,
      datatypename1  varchar(30) null,
      keyname2       varchar(30) null,
      datatypename2  varchar(30) null,
      keyname3       varchar(30) null,
      datatypename3  varchar(30) null,
      keyname4       varchar(30) null,
      datatypename4  varchar(30) null,
      keyname5       varchar(30) null,
      datatypename5  varchar(30) null,
      keyname6       varchar(30) null,
      datatypename6  varchar(30) null,
      keyname7       varchar(30) null,
      datatypename7  varchar(30) null,
      keyname8       varchar(30) null,
      datatypename8  varchar(30) null
   )
         
   create table #transids
   (
      trans_id       bigint null,
      resp_trans_id  bigint null
   )

   create table #trans_touch 
   (
      entity_name varchar(30)   NULL,
      key1        varchar(30)   NULL,
      key2        varchar(30)   NULL,
      key3        varchar(30)   NULL,
      key4        varchar(30)   NULL,
      key5        varchar(30)   NULL,
      key6        varchar(30)   NULL,
      key7        varchar(30)   NULL,
      key8        varchar(30)   NULL,
      touch_key   numeric(32,0) NULL
   )
   create nonclustered index trans_touch_idx1 on #trans_touch (touch_key)
   
   if @archived_asof_date is null
      declare mycursor CURSOR READ_ONLY for
         select distinct op_trans_id
         from send_to_SAP 
         where archived_ind = 'A'
         order by op_trans_id
   else
      declare mycursor CURSOR READ_ONLY for
         select distinct op_trans_id
         from send_to_SAP 
         where archived_ind = 'A' and
               convert(varchar, archived_date, 101) <= convert(varchar, @archived_asof_date, 101)
         order by op_trans_id
         
   open mycursor
   fetch next from mycursor into @op_trans_id
   while @@FETCH_STATUS = 0
   begin
      select @total_rows_deleted = 0

      /* Only process the op_trans_id when all the
         related send_to_SAP records have their
         archived_ind(s) set to 'A'. If anyone of
         these records has the archived_ind value 
         other than 'A', then do not process 
         op_trans_id
      */
      if @debugon = 'Y'
      begin
         print '***************************************************'
         print 'op_trans_id = ' + cast(@op_trans_id as varchar)   
      end
      
      if exists (select 1
                 from send_to_SAP
                 where archived_ind is null and
                       op_trans_id = @op_trans_id)
         goto nexttransid

      if @debugon = 'Y'
      begin
         select row_id,
                entity_name,
                key1,
                key2,
                key3
         from send_to_SAP
         where op_trans_id = @op_trans_id
      end
      
      insert into #trans_touch
      select entity_name,
             key1,
             key2,
             key3,
             key4,
             key5,
             key6,
             key7,
             key8,
             touch_key
      from transaction_touch
      where trans_id = @op_trans_id

      if @debugon = 'Y'
      begin
         select entity_name, key1, key2, key3, key4
         from #trans_touch
         order by touch_key
      end
      
      declare touchcur CURSOR FOR     
         select entity_name,
                key1,
                key2,
                key3,
                key4,
                key5,
                key6,
                key7,
                key8
         from #trans_touch
         order by touch_key
 
      open touchcur
      fetch next from touchcur into @entity_name,
                                    @keyval1,
                                    @keyval2,
                                    @keyval3,
                                    @keyval4,
                                    @keyval5,
                                    @keyval6,
                                    @keyval7,
                                    @keyval8
      while @@FETCH_STATUS = 0
      begin
         /* converting an entity_name to a table name */
         select @tablename = ''
         if not exists (select 1
                        from #tblinfo
                        where entity_name = @entity_name)
         begin
            select @i = 1 
            while @i <= LEN(@entity_name)
            begin
               select @tempstr = substring(@entity_name, @i, 1)  
               if ascii(@tempstr) >= ascii('A') and ascii(@tempstr) <= ascii('Z')
               begin
                  if @i > 1
                     select @tablename = @tablename + '_' + char(ascii(@tempstr) + 32)
                  else
                     select @tablename = char(ascii(@tempstr) + 32)
               end
               else
               begin  /* Entity name shall not have embedded '_' */
                  if @tempstr <> '_'
                     select @tablename = @tablename + @tempstr
               end   
               select @i = @i + 1
            end
            
            insert into #tblinfo
            select @tablename, 
                   @entity_name,
                   keycnt, 
                   col_name(id, key1), 
                   case when syskeys.key1 is not null 
                        then
/********************************************************************************
                           (select t.name 
                            from syscolumns c, systypes t
                            where c.id = syskeys.id and 
                                  c.colid = syskeys.key1 and
                                  c.usertype *= t.usertype)
*********************************************************************************/
                           (select t.name
                            from syscolumns c
                                left outer join systypes t
                                on c.usertype = t.usertype
                                and c.id = syskeys.id
                                and c.colid = syskeys.key1)                                  
                        else null
                   end,
                   col_name(id, key2), 
                   case when syskeys.key2 is not null 
                        then 
/********************************************************************************
                           (select t.name 
                            from syscolumns c, systypes t
                            where c.id = syskeys.id and 
                                  c.colid = syskeys.key2 and
                                  c.usertype *= t.usertype)
*********************************************************************************/
                           (select t.name
                            from syscolumns c
                                left outer join systypes t
                                on c.usertype = t.usertype
                                and c.id = syskeys.id
                                and c.colid = syskeys.key2)                                  
                        else null
                   end,
                   col_name(id, key3), 
                   case when syskeys.key3 is not null 
                        then
/********************************************************************************
                           (select t.name 
                            from syscolumns c, systypes t
                            where c.id = syskeys.id and 
                                  c.colid = syskeys.key3 and
                                  c.usertype *= t.usertype)
*********************************************************************************/
                           (select t.name
                            from syscolumns c
                                left outer join systypes t
                                on c.usertype = t.usertype
                                and c.id = syskeys.id
                                and c.colid = syskeys.key3)                                  
                        else null
                   end,
                   col_name(id, key4), 
                   case when syskeys.key4 is not null 
                        then 
/********************************************************************************
                           (select t.name 
                            from syscolumns c, systypes t
                            where c.id = syskeys.id and 
                                  c.colid = syskeys.key4 and
                                  c.usertype *= t.usertype)
*********************************************************************************/
                           (select t.name
                            from syscolumns c
                                left outer join systypes t
                                on c.usertype = t.usertype
                                and c.id = syskeys.id
                                and c.colid = syskeys.key4)                                  
                        else null
                   end,
                   col_name(id, key5), 
                   case when syskeys.key5 is not null 
                        then 
/********************************************************************************
                           (select t.name 
                            from syscolumns c, systypes t
                            where c.id = syskeys.id and 
                                  c.colid = syskeys.key5 and
                                  c.usertype *= t.usertype)
*********************************************************************************/
                           (select t.name
                            from syscolumns c
                                left outer join systypes t
                                on c.usertype = t.usertype
                                and c.id = syskeys.id
                                and c.colid = syskeys.key5)                                  
                        else null
                   end,
                   col_name(id, key6), 
                   case when syskeys.key6 is not null 
                        then 
/********************************************************************************
                           (select t.name 
                            from syscolumns c, systypes t
                            where c.id = syskeys.id and 
                                  c.colid = syskeys.key6 and
                                  c.usertype *= t.usertype)
*********************************************************************************/
                           (select t.name
                            from syscolumns c
                                left outer join systypes t
                                on c.usertype = t.usertype
                                and c.id = syskeys.id
                                and c.colid = syskeys.key6)                                  
                        else null
                   end,
                   col_name(id, key7), 
                   case when syskeys.key7 is not null 
                        then
/********************************************************************************
                           (select t.name 
                            from syscolumns c, systypes t
                            where c.id = syskeys.id and 
                                  c.colid = syskeys.key7 and
                                  c.usertype *= t.usertype)
*********************************************************************************/
                           (select t.name
                            from syscolumns c
                                left outer join systypes t
                                on c.usertype = t.usertype
                                and c.id = syskeys.id
                                and c.colid = syskeys.key7) 
                        else null
                   end,
                   col_name(id, key8),
                   case when syskeys.key8 is not null 
                        then
/********************************************************************************
                           (select t.name 
                            from syscolumns c, systypes t
                            where c.id = syskeys.id and 
                                  c.colid = syskeys.key8 and
                                  c.usertype *= t.usertype)
*********************************************************************************/
                           (select t.name
                            from syscolumns c
                                left outer join systypes t
                                on c.usertype = t.usertype
                                and c.id = syskeys.id
                                and c.colid = syskeys.key8)                                  
                        else null
                   end
            from syskeys 
            where id = object_id(@tablename) and 
                  type = 1
         end
         
         select @keycnt = keycnt,
                @tablename = tablename,
                @colname1 = keyname1,
                @colname2 = keyname2,
                @colname3 = keyname3,
                @colname4 = keyname4,
                @colname5 = keyname5,
                @colname6 = keyname6,
                @colname7 = keyname7,
                @colname8 = keyname8,
                @datatypename1 = datatypename1,
                @datatypename2 = datatypename2,
                @datatypename3 = datatypename3,
                @datatypename4 = datatypename4,
                @datatypename5 = datatypename5,
                @datatypename6 = datatypename6,
                @datatypename7 = datatypename7,
                @datatypename8 = datatypename8
         from #tblinfo
         where entity_name = @entity_name

         /* Get all the <trans_id, resp_trans_id> pairs for the
            aud_xxx's primary key
         */         
         select @sql = 'insert into #transids select trans_id, resp_trans_id '
         select @sql = @sql + 'from aud_' + @tablename + ' where '
         select @collist = ''
         select @i = 1
         while @i <= @keycnt
         begin
            if @i = 1
            begin
               if @datatypename1 in ('char', 'varchar', 'datetime', 'text')
                  select @tempstr = @colname1 + ' = ''' + @keyval1 + ''''
               else
                  select @tempstr = @colname1 + ' = ' + @keyval1
            end
            if @i = 2
            begin
               if @datatypename2 in ('char', 'varchar', 'datetime', 'text')
                  select @tempstr = @colname2 + ' = ''' + @keyval2 + ''''
               else
                  select @tempstr = @colname2 + ' = ' + @keyval2
            end
            if @i = 3
            begin
               if @datatypename3 in ('char', 'varchar', 'datetime', 'text')
                  select @tempstr = @colname3 + ' = ''' + @keyval3 + ''''
               else
                  select @tempstr = @colname3 + ' = ' + @keyval3
            end
            if @i = 4
            begin
               if @datatypename4 in ('char', 'varchar', 'datetime', 'text')
                  select @tempstr = @colname4 + ' = ''' + @keyval4 + ''''
               else
                  select @tempstr = @colname4 + ' = ' + @keyval4
            end
            if @i = 5
            begin
               if @datatypename5 in ('char', 'varchar', 'datetime', 'text')
                  select @tempstr = @colname5 + ' = ''' + @keyval5 + ''''
               else
                  select @tempstr = @colname5 + ' = ' + @keyval5
            end
            if @i = 6
            begin
               if @datatypename6 in ('char', 'varchar', 'datetime', 'text')
                  select @tempstr = @colname6 + ' = ''' + @keyval6 + ''''
               else
                  select @tempstr = @colname6 + ' = ' + @keyval6
            end
            if @i = 7
            begin
               if @datatypename7 in ('char', 'varchar', 'datetime', 'text')
                  select @tempstr = @colname7 + ' = ''' + @keyval7 + ''''
               else
                  select @tempstr = @colname7 + ' = ' + @keyval7
            end
            if @i = 8
            begin
               if @datatypename8 in ('char', 'varchar', 'datetime', 'text')
                  select @tempstr = @colname8 + ' = ''' + @keyval8 + ''''
               else
                  select @tempstr = @colname8 + ' = ' + @keyval8
            end
             
            if @i = 1
               select @collist = @tempstr
            else
               select @collist = @collist + ' and ' + @tempstr
               
            select @i = @i + 1
         end
         select @sql = @sql + @collist
         if @debugon = 'Y'
            print 'DEBUG: SQL = ' + @sql
         exec(@sql)         
         if @@rowcount > 0
         begin
            /* We want to always keep at least one audit record for <primary key> */
            set rowcount 1
            select @trans_id = trans_id,
                   @resp_trans_id = resp_trans_id
            from #transids
            order by trans_id desc
            set rowcount 0

            if @debugon = 'Y' 
            begin   
               print 'BEFORE'        
               select * from #transids order by trans_id desc
               print ' '
            end
                    
            /* remove the latest audit record for the <primary key> */
            delete #transids
            where trans_id = @trans_id and
                  resp_trans_id = @resp_trans_id

            /* we only want to save the records whose trans_id <= desired op_trans_id and
               resp_trans_id > desired op_trans_id
            */                                 
            delete #transids
            where trans_id > @op_trans_id or
                  resp_trans_id <= @op_trans_id

            if @debugon = 'Y' 
            begin   
               print 'AFTER'        
               select * from #transids order by trans_id desc
               print ' '
            end
           
            if (select count(*) from #transids) > 0
            begin
               begin tran
               select @sql = 'delete aud_' + @tablename + ' from aud_' + @tablename + ' a, #transids b where '
               select @sql = @sql + @collist + ' and a.trans_id = b.trans_id and '
               select @sql = @sql + 'a.resp_trans_id = b.resp_trans_id'
               if @debugon = 'Y'
                  print 'DEBUG: SQL = ' + @sql
               exec(@sql)
               select @rows_deleted = @@rowcount,
                      @error_occurred = @@error
               if @error_occurred > 0 or @rows_deleted = 0
               begin
                  rollback tran
                  if @error_occurred > 0
                  begin
                     close touchcur
                     deallocate touchcur      
                     close mycursor
                     deallocate mycursor
                     goto errexit
                  end
                  print '=> aud_' + @tablename + ': No rows deleted.'
               end
               else
               begin
                  commit tran
                  print '=> aud_' + @tablename + ': ' + cast(@rows_deleted as varchar) + ' rows deleted.'
               end
               select @total_rows_deleted = @total_rows_deleted + @rows_deleted
               truncate table #transids
            end                    
         end /* if */
         else
         begin
            if @debugon = 'Y'
               print '=> aud_' + @tablename + ': No audit records found!'
         end
            
         fetch next from touchcur into @entity_name,
                                       @keyval1,
                                       @keyval2,
                                       @keyval3,
                                       @keyval4,
                                       @keyval5,
                                       @keyval6,
                                       @keyval7,
                                       @keyval8
      end /* while (#trans_touch) */
      close touchcur
      deallocate touchcur      
      truncate table #trans_touch

      select @chg_archived_ind_to_P = 0
      if @total_rows_deleted > 0
      begin
         if @debugon = 'Y'     
            print 'Setting archived_ind for op_trans_id #' + cast(@op_trans_id as varchar) + ' to ''P'' ...' 
         select @chg_archived_ind_to_P = 1
      end
      else
      begin
         if exists (select 1
                    from send_to_SAP
                    where archived_ind = 'P' and
                          op_trans_id = @op_trans_id)  
            select @chg_archived_ind_to_P = 1
         else
         begin
            if @debugon = 'Y'
               print 'The archived_ind was not changed from ''A'' to ''P'' because no audit records were removed!'
         end
      end 

      if @chg_archived_ind_to_P = 1
      begin
         begin tran
         update send_to_SAP
         set archived_ind = 'P',
             purged_date = getdate()
         where op_trans_id = @op_trans_id  
         select @rows_updated = @@rowcount,
                @error_occurred = @@error
         if @error_occurred > 0 or @rows_updated = 0
         begin
            rollback tran
            if @error_occurred > 0
            begin
               close mycursor
               deallocate mycursor
               goto errexit
            end
            print '=> send_to_SAP: No row was updated.'
         end
         else
         begin
            commit tran
            if @rows_updated = 1
               print '=> send_to_SAP: 1 row was updated (archived_ind ''A'' --> ''P'').'
            else
               print '=> send_to_SAP: ' + cast(@rows_updated as varchar) + ' rows were updated (archived_ind ''A'' --> ''P'').'
         end   
         print ' ' 
         select @chg_archived_ind_to_P = 0
      end

nexttransid:
      fetch next from mycursor into @op_trans_id
   end /* while */
   close mycursor
   deallocate mycursor
   
   if @purged_asof_date is not null
   begin
      print ' '
      print 'Removing send_to_SAP records whose archived_ind = ''P'' ....'

      declare @key1              int,
              @key2              int,
              @key3              int,
              @interface         varchar(20),
              @operation         varchar(10) 

      declare mycursor CURSOR READ_ONLY for
         select interface,
                entity_name,
                operation,
                key1,
                key2,
                key3,
                max(op_trans_id)
         from send_to_SAP
         where archived_ind = 'P' and
               convert(varchar, purged_date, 101) <= convert(varchar, @purged_asof_date, 101)
         group by interface, entity_name, operation, key1, key2, key3
         order by interface, entity_name, operation, key1, key2, key3
         

            
      select @total_rows_deleted = 0
      open mycursor
      fetch mycursor into @interface,
                          @entity_name,
                          @operation,
                          @key1,
                          @key2,
                          @key3,
                          @op_trans_id
      while @@FETCH_STATUS = 0
      begin
         if @debugon = 'Y'
         begin
            print '=> interface = ' + @interface + ', entity_name = ' + @entity_name + ', operation = ' + @operation + ', '
            print '   key1 = ' + cast(@key1 as varchar) + ', key2 = ' + cast(@key2 as varchar) + ', key3 = ' + cast(@key3 as varchar) + ', max op_trans_id = ' + cast(@op_trans_id as varchar)  
         end
         begin tran
         delete send_to_SAP
         where archived_ind = 'P' and
               convert(varchar, purged_date, 101) <= convert(varchar, @purged_asof_date, 101) and
               interface = @interface and
               entity_name = @entity_name and
               operation = @operation and
               key1 = @key1 and
               key2 = @key2 and
               key3 = @key3 and
               op_trans_id <> @op_trans_id
         select @rows_deleted = @@rowcount,
                @error_occurred = @@error
         if @error_occurred > 0 or @rows_deleted = 0
         begin
            rollback tran
            if @error_occurred > 0
            begin
               close mycursor
               deallocate mycursor
               goto errexit
            end
            if @debugon = 'Y'
               print '=> No rows were removed.'
         end
         else
         begin
            commit tran
            if @debugon = 'Y'
               print '=> ' + cast(@rows_deleted as varchar) + ' rows were removed.'
            select @total_rows_deleted = @total_rows_deleted + @rows_deleted
         end

         fetch next from mycursor into @interface,
                                       @entity_name,
                                       @operation,
                                       @key1,
                                       @key2,
                                       @key3,
                                       @op_trans_id
      end /* while */
      close mycursor
      deallocate mycursor
      
      print ' '
      if @total_rows_deleted = 0
         print '   No rows were removed from the send_to_SAP table.'
      else
         print '   Total rows removed from the send_to_SAP table = ' + cast(@total_rows_deleted as varchar)    
  end
endofsp:
  return 0
  
errexit:
  return 1
GO
