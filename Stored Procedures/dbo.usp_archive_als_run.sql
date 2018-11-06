SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_archive_als_run]
(
   @daysold                int = 30,
   @FAILED_daysold         int = 0,
   @PENDING_daysold        int = 0,
   @DBSAVEFAILED_daysold   int = 0,
   @UNNEEDED_daysold       int = 0,
   @MISSINGDATA_daysold    int = 0,
   @CRASHED_daysold        int = 0,
   @debugon                bit = 0
)
as
set nocount on
set xact_abort on
declare @rows_affected           int,
        @total_rows_added        int,
        @total_rows_deleted      int,
        @tablename               varchar(80),
        @errcode                 int,
        @smsg                    varchar(255),
        @oid                     int,
        @oid1                    int,
        @oid2                    int,
        @last_oid                int,
        @stepid                  smallint,
        @COMPLETED_status_id     int,
        @FAILED_status_id        int,
        @PENDING_status_id       int,
        @DBSAVEFAILED_status_id  int,
        @UNNEEDED_status_id      int,
        @MISSINGDATA_status_id   int,
        @CRASHED_status_id       int,
        @archived_date           datetime
        
   select @PENDING_status_id = 0,
          @COMPLETED_status_id = 2,
          @FAILED_status_id = 3,
          @DBSAVEFAILED_status_id = 4,
          @UNNEEDED_status_id = 5,
          @MISSINGDATA_status_id = 6,
          @CRASHED_status_id = 7

   select @archived_date = convert(datetime, convert(varchar, getdate(), 101))

   create table #times
   (
      oid                int,
      step               varchar(80),
      starttime          datetime null,
      endtime            datetime null
   )

   create table #rows_affected
   (
      tablename          varchar(80),
      rows_deleted       int default 0 null,
      rows_added         int default 0 null
   )

   create table #alsruns
   (
      oid                   numeric(18, 0) IDENTITY PRIMARY KEY,
      sequence              numeric(32, 0) not null,
      als_module_group_id   int not null
   )

   create nonclustered index xx010_alsruns_idx1
      on #alsruns (oid, als_module_group_id, sequence) 

   insert into #rows_affected 
      (tablename, rows_deleted, rows_added) values('als_run', 0, 0)
   insert into #rows_affected 
      (tablename, rows_deleted, rows_added) values('als_run_touch', 0, 0)
   insert into #rows_affected 
      (tablename, rows_deleted, rows_added) values('als_run_archive', 0, 0)
   insert into #rows_affected 
      (tablename, rows_deleted, rows_added) values('als_run_touch_archive', 0, 0)
         
   select @errcode = 0,
          @rows_affected = 0
   if @daysold is null or @daysold < 0
      select @daysold = 30

   if @FAILED_daysold is null or @FAILED_daysold < 0
      select @FAILED_daysold = 0

   if @PENDING_daysold is null or @PENDING_daysold < 0
      select @PENDING_daysold = 0

   if @DBSAVEFAILED_daysold is null or @DBSAVEFAILED_daysold < 0
      select @DBSAVEFAILED_daysold = 0

   if @UNNEEDED_daysold is null or @UNNEEDED_daysold < 0
      select @UNNEEDED_daysold = 0

   if @MISSINGDATA_daysold is null or @MISSINGDATA_daysold < 0
      select @MISSINGDATA_daysold = 0

   if @CRASHED_daysold is null or @CRASHED_daysold < 0
      select @CRASHED_daysold = 0

   insert into #times
      (oid, step, starttime)
    values(0, 'Purge Session', getdate())

   /* ------------------------------------------------
      STEP 1
         Purging old als_run_archive records if their 
         archived dates are @daysold
      ------------------------------------------------ */
   select @stepid = 1
   insert into #times
      (oid, step, starttime)
    values(@stepid, 'Purged old als_run_archive records', getdate())

   begin tran
   delete dbo.als_run_archive
   where datediff(day, archived_date, getdate()) > @daysold

   select @rows_affected = @@rowcount,
          @errcode = @@error
   if @errcode > 0
   begin
      if @@trancount > 0
         rollback tran
      goto endofsp
   end
   commit tran
   
   update #times
   set endtime = getdate()
   where oid = @stepid

   update #rows_affected
   set rows_deleted = @rows_affected
   where tablename = 'als_run_archive'

   /* ------------------------------------------------
      STEP 2
         For als_run_archive records being purged,
         purging the associated als_run_touch_archive 
         records
      ------------------------------------------------ */
   select @stepid = 2
   insert into #times
      (oid, step, starttime)
    values(@stepid, 'Purged old als_run_touch_archive records', getdate())

   begin tran
   delete dbo.als_run_touch_archive
   from dbo.als_run_touch_archive a
   where not exists (select 1
                     from dbo.als_run_archive b
                     where b.als_module_group_id = a.als_module_group_id and
                           b.sequence = a.sequence) and
         datediff(day, archived_date, getdate()) > @daysold

   select @rows_affected = @@rowcount,
          @errcode = @@error
   if @errcode > 0
   begin
      if @@trancount > 0
         rollback tran
      goto endofsp
   end
   commit tran

   update #times
   set endtime = getdate()
   where oid = @stepid

   update #rows_affected
   set rows_deleted = @rows_affected
   where tablename = 'als_run_touch_archive'

   /* ------------------------------------------------
       STEP 3
          Obtaining the qualified records and save 
          them in a temporary table
      ------------------------------------------------ */
   select @stepid = 3
   insert into #times
      (oid, step, starttime)
    values(@stepid, 'Filled the temp table ''#alsruns'' with the keys selected for archive', getdate())

   insert into #alsruns
       (sequence, als_module_group_id)
      select sequence,
             als_module_group_id
      from dbo.als_run
      where als_run_status_id = @COMPLETED_status_id

   if @FAILED_daysold > 0
   begin
      insert into #alsruns
           (sequence, als_module_group_id)
        select sequence,
               als_module_group_id
        from dbo.als_run
        where als_run_status_id = @FAILED_status_id and
              datediff(day, creation_time, getdate()) > @FAILED_daysold 
   end
      
   if @PENDING_daysold > 0
   begin
      insert into #alsruns
         (sequence, als_module_group_id)
        select sequence,
               als_module_group_id
        from dbo.als_run
        where als_run_status_id = @PENDING_status_id and
              datediff(day, creation_time, getdate()) > @PENDING_daysold 
   end 

   if @DBSAVEFAILED_daysold > 0
   begin
      insert into #alsruns
         (sequence, als_module_group_id)
        select sequence,
               als_module_group_id
        from dbo.als_run
        where als_run_status_id = @DBSAVEFAILED_status_id and
              datediff(day, creation_time, getdate()) > @DBSAVEFAILED_daysold 
   end 

   if @UNNEEDED_daysold > 0
   begin
      insert into #alsruns
         (sequence, als_module_group_id)
        select sequence,
               als_module_group_id
        from dbo.als_run
        where als_run_status_id = @UNNEEDED_status_id and
              datediff(day, creation_time, getdate()) > @UNNEEDED_daysold 
   end 

   if @MISSINGDATA_daysold > 0
   begin
      insert into #alsruns
         (sequence, als_module_group_id)
        select sequence,
               als_module_group_id
        from dbo.als_run
        where als_run_status_id = @MISSINGDATA_status_id and
              datediff(day, creation_time, getdate()) > @MISSINGDATA_daysold 
   end 

   if @CRASHED_daysold > 0
   begin
      insert into #alsruns
         (sequence, als_module_group_id)
        select sequence,
               als_module_group_id
        from dbo.als_run
        where als_run_status_id = @CRASHED_status_id and
              datediff(day, creation_time, getdate()) > @CRASHED_daysold 
   end 

   update #times
   set endtime = getdate()
   where oid = @stepid
   
   if (select count(*) from #alsruns) = 0
   begin
      print '=> No als_run records found to be archived!'
      goto endofsp
   end

   /* ---------------------------------------------------------
       STEP 4
          Archiving the als_run_touch records to the 
          als_run_touch_archive table and delete records being 
          archived from als_run_touch table
      --------------------------------------------------------- */
   select @stepid = 4
   insert into #times
      (oid, step, starttime)
    values(@stepid, 'Archived als_run_touch records', getdate())
 
   select @total_rows_added = 0,
          @total_rows_deleted = 0
        
   select @oid1 = 1
   select @last_oid = max(oid) from #alsruns

   while @oid1 <= @last_oid
   begin 
      select @oid2 = @oid1 + 1000  
      if @debugon = 1
      begin  
         select @smsg = '=> Archiving als_run_touch records between ' + convert(varchar, @oid1) + ' and ' + convert(varchar, @oid2)
         print @smsg
      end

      begin tran
      insert into dbo.als_run_touch_archive
               (als_module_group_id, operation, entity_name,
                key1, key2, key3, key4, key5, key6, key7, key8,
                trans_id, sequence, touch_key, archived_date)
      select als_module_group_id,
             operation,
             entity_name,
             key1,
             key2,
             key3,
             key4,
             key5,
             key6,
             key7,
             key8,
             trans_id,
             sequence,
             touch_key,
             @archived_date
      from dbo.als_run_touch a
      where exists (select 1
                    from #alsruns b
                    where a.sequence = b.sequence and
                          a.als_module_group_id = b.als_module_group_id and
                          b.oid between @oid1 and @oid2)
      select @rows_affected = @@rowcount,
             @errcode = @@error
      if @errcode > 0
      begin
         if @@trancount > 0
            rollback tran
         goto endofsp
      end
      select @total_rows_added = @total_rows_added + @rows_affected
      if @debugon = 1
      begin
         if @rows_affected > 0
         begin
            select @smsg = '=> als_run_touch_archive: ' + convert(varchar, @total_rows_added) + ' records added so far ...' + convert(varchar, getdate(), 109)
            print @smsg
         end
      end
         
      delete dbo.als_run_touch 
      from dbo.als_run_touch a
      where exists (select 1
                    from #alsruns b
                    where a.sequence = b.sequence and
                          a.als_module_group_id = b.als_module_group_id and
                          b.oid between @oid1 and @oid2)
      select @rows_affected = @@rowcount,
             @errcode = @@error
      if @errcode > 0
      begin
         if @@trancount > 0
            rollback tran
         goto endofsp
      end
      commit tran
      select @total_rows_deleted = @total_rows_deleted + @rows_affected
      if @debugon = 1
      begin
         if @rows_affected > 0
         begin
            select @smsg = 'als_run_touch: ' + convert(varchar, @total_rows_deleted) + ' records deleted so far ...' + convert(varchar, getdate(), 109)
            print @smsg
         end
      end
         
      select @oid1 = @oid2 + 1
   end /* while */

   update #times
   set endtime = getdate()
   where oid = @stepid

   update #rows_affected
   set rows_added = @total_rows_added
   where tablename = 'als_run_touch_archive'

   update #rows_affected
   set rows_deleted = @total_rows_deleted
   where tablename = 'als_run_touch'
 
   /* ---------------------------------------------------------
       STEP 5
          Archiving the als_run records to als_run_archive 
          table and delete records being archived from als_run 
          table
      --------------------------------------------------------- */
   select @stepid = 5
   insert into #times
      (oid, step, starttime)
    values(@stepid, 'Archived als_run records', getdate())

   select @total_rows_added = 0,
          @total_rows_deleted = 0
        
   select @oid1 = 1
   select @last_oid = max(oid) from #alsruns

   while @oid1 <= @last_oid
   begin 
      select @oid2 = @oid1 + 1000  
      if @debugon = 1
      begin  
         select @smsg = '=> Archiving als_run records between ' + convert(varchar, @oid1) + ' and ' + convert(varchar, @oid2)
         print @smsg
      end
   
      begin tran
      insert into dbo.als_run_archive
           (sequence,als_module_group_id,instance_num,
            als_run_status_id,start_time,end_time,trans_id,
            creation_time, archived_date)
      select sequence,
             als_module_group_id,
             instance_num,
             als_run_status_id,
             start_time,
             end_time,
             trans_id,
             creation_time,
             @archived_date
      from dbo.als_run a
      where exists (select 1
                    from #alsruns b
                    where a.sequence = b.sequence and
                          a.als_module_group_id = b.als_module_group_id and
                          b.oid between @oid1 and @oid2)
      select @rows_affected = @@rowcount,
             @errcode = @@error
      if @errcode > 0
      begin
         if @@trancount > 0
            rollback tran
         goto endofsp
      end
      select @total_rows_added = @total_rows_added + @rows_affected
      if @debugon = 1
      begin
         if @rows_affected > 0
         begin
            select @smsg = '=> als_run_archive: ' + convert(varchar, @total_rows_added) + ' records added so far ...' + convert(varchar, getdate(), 109)
            print @smsg
         end
      end

      delete dbo.als_run
      from dbo.als_run a
      where exists (select 1
                    from #alsruns b
                    where a.sequence = b.sequence and
                          a.als_module_group_id = b.als_module_group_id and
                          b.oid between @oid1 and @oid2)
      select @rows_affected = @@rowcount,
             @errcode = @@error
      if @errcode > 0
      begin
         if @@trancount > 0
            rollback tran
         goto endofsp
      end
      commit tran
      select @total_rows_deleted = @total_rows_deleted + @rows_affected
      if @debugon = 1
      begin
         if @rows_affected > 0
         begin
            select @smsg = '=> als_run: ' + convert(varchar, @total_rows_deleted) + ' records deleted so far ...' + convert(varchar, getdate(), 109)
            print @smsg
         end
      end
               
      select @oid1 = @oid2 + 1
   end /* while */

   update #times
   set endtime = getdate()
   where oid = @stepid

   update #rows_affected
   set rows_added = @total_rows_added
   where tablename = 'als_run_archive'

   update #rows_affected
   set rows_deleted = @total_rows_deleted
   where tablename = 'als_run'

endofsp:

   drop table #alsruns
   update #times
   set endtime = getdate()
   where oid = 0

   declare @step       varchar(80),
           @starttime  varchar(30),
           @endtime    varchar(30),
           @duration   varchar(30)

   select @starttime = convert(varchar, starttime, 109),
          @endtime = convert(varchar, endtime, 109),
          @duration = convert(varchar, datediff(ms, starttime, endtime))
   from #times
   where oid = 0

   print ' '
   print '===================================================================='
   print ' PURGE SESSION'
   select @smsg = '    STARTED  AT     : ' + @starttime
   print @smsg       
   select @smsg = '    FINISHED AT     : ' + @endtime
   print @smsg
   select @smsg = '    DURATION (in ms): ' + @duration
   print @smsg
   print '    ACTION          : Archived als_run records and '
   print '                      als_run_touch records, and purged'
   print '                      archived records which are older than'
   print '                      the following given days:'
   select @smsg = '                          COMPLETED       ' + cast(@daysold as varchar) + ' days'
   print @smsg
   if @FAILED_daysold > 0
   begin
      select @smsg = '                          FAILED          ' + cast(@FAILED_daysold as varchar) + ' days'
      print @smsg
   end
   if @PENDING_daysold > 0
   begin
      select @smsg = '                          PENDING         ' + cast(@PENDING_daysold as varchar) + ' days'
      print @smsg
   end
   if @DBSAVEFAILED_daysold > 0
   begin
      select @smsg = '                          DBSAVEFAILED    ' + cast(@DBSAVEFAILED_daysold as varchar) + ' days'
      print @smsg
   end
   if @UNNEEDED_daysold > 0
   begin
      select @smsg = '                          UNNEEDED        ' + cast(@UNNEEDED_daysold as varchar) + ' days'
      print @smsg
   end
   if @MISSINGDATA_daysold > 0
   begin
      select @smsg = '                          MISSINGDATA     ' + cast(@MISSINGDATA_daysold as varchar) + ' days'
      print @smsg
   end
   if @MISSINGDATA_daysold > 0
   begin
      select @smsg = '                          CRASHED         ' + cast(@MISSINGDATA_daysold as varchar) + ' days'
      print @smsg
   end
   print '---------------------------------------------------------------------'
   print ' '

   select @oid = 0
   while (1 = 1)
   begin
      select @oid = min(oid)
      from #times
      where oid > @oid

      if @oid is null
         break

      select @step = step,
             @starttime = convert(varchar, starttime, 109),
             @endtime = convert(varchar, endtime, 109),
             @duration = convert(varchar, datediff(ms, starttime, endtime))
      from #times
      where oid = @oid

      select @smsg = 'STEP #' + convert(varchar, @oid) + ' - ' + @step
      print @smsg
      select @smsg = '    STARTED  AT     : ' + @starttime
      print @smsg       
      select @smsg = '    FINISHED AT     : ' + @endtime
      print @smsg
      select @smsg = '    DURATION (in ms): ' + @duration
      print @smsg
      print ' '
   end 
   drop table #times
   print ' '
   
   select @tablename = min(tablename)
   from #rows_affected
   while @tablename is not null
   begin
      select @total_rows_added = rows_added,
             @total_rows_deleted = rows_deleted
      from #rows_affected
      where tablename = @tablename

      select @smsg = 'TABLE - ' + @tablename
      print @smsg
      select @smsg = '    Rows added   : ' + cast(@total_rows_added as varchar)
      print @smsg
      select @smsg = '    Rows deleted : ' + cast(@total_rows_deleted as varchar)
      print @smsg
      print ' '
      
      select @tablename = min(tablename)
      from #rows_affected
      where tablename > @tablename
   end
   drop table #rows_affected
GO
GRANT EXECUTE ON  [dbo].[usp_archive_als_run] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_archive_als_run', NULL, NULL
GO
