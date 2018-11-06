SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_archive_feed_data]
(
   @COMPLETED_daysold      int = 1,
   @VAL_FAILED_daysold     int = 7,
   @PENDING_daysold        int = 14,
   @PROCESSING_daysold     int = 14,
   @PROC_SCHLD_daysold     int = 14,
   @OUTBOUND_SCHLD_daysold int = 14,
   @purge_archive_daysold  int = 365,
   @debugon                bit = 0
)
as
set nocount on
set xact_abort on
declare @oid                              int, 
        @rows_affected                    int,
        @total_FE_rows_archived           int,
        @total_FE_rows_deleted            int,
        @total_FT_rows_archived           int,
        @total_FT_rows_deleted            int,
        @total_FDA_rows_archived          int,
        @total_FDA_rows_deleted           int,
        @total_FD_rows_archived           int,
        @total_FD_rows_deleted            int,
        @total_FXXT_rows_archived         int,
        @total_FXXT_rows_deleted          int,
        @tablename                        varchar(80),
        @total_archived_rows_purged       int,
        @errcode                          int,
        @smsg                             varchar(255),
        @feed_data_id1                    int,
        @feed_data_id2                    int,
        @last_feed_data_id                int,
        @stepid                           smallint,
        @archived_date                    datetime

   select @archived_date = convert(datetime, convert(varchar, getdate(), 101))

   -- Check if the triggers are enabled, then disable them
   if OBJECTPROPERTY(object_id('dbo.feed_data_deltrg'), 'ExecIsTriggerDisabled') = 0
      exec('alter table dbo.feed_data disable trigger feed_data_deltrg')
   if OBJECTPROPERTY(object_id('dbo.feed_detail_data_deltrg'), 'ExecIsTriggerDisabled') = 0
      exec('alter table dbo.feed_detail_data disable trigger feed_detail_data_deltrg')
   if OBJECTPROPERTY(object_id('dbo.feed_xsd_xml_text_deltrg'), 'ExecIsTriggerDisabled') = 0
      exec('alter table dbo.feed_xsd_xml_text disable trigger feed_xsd_xml_text_deltrg')

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

   create table #feeds
   (
      feed_data_id   int not null PRIMARY KEY
   )

   create table #xsd_xml_text_ids
   (
      oid       int primary key
   )
   
   insert into #rows_affected 
      (tablename, rows_deleted, rows_added) values('feed_data', 0, 0)
   insert into #rows_affected 
      (tablename, rows_deleted, rows_added) values('feed_detail_data', 0, 0)
   insert into #rows_affected 
      (tablename, rows_deleted, rows_added) values('feed_error', 0, 0)
   insert into #rows_affected 
      (tablename, rows_deleted, rows_added) values('feed_transaction', 0, 0)
   insert into #rows_affected 
      (tablename, rows_deleted, rows_added) values('feed_xsd_xml_text', 0, 0)
   insert into #rows_affected 
      (tablename, rows_deleted, rows_added) values('feed_data_archive', 0, 0)
   insert into #rows_affected 
      (tablename, rows_deleted, rows_added) values('feed_detail_data_archive', 0, 0)
   insert into #rows_affected 
      (tablename, rows_deleted, rows_added) values('feed_error_archive', 0, 0)
   insert into #rows_affected 
      (tablename, rows_deleted, rows_added) values('feed_transaction_archive', 0, 0)
   insert into #rows_affected 
      (tablename, rows_deleted, rows_added) values('feed_xsd_xml_text_archive', 0, 0)
         
   select @errcode = 0,
          @rows_affected = 0
          
   if @COMPLETED_daysold is null or @COMPLETED_daysold < 0
      select @COMPLETED_daysold = 1

   if @VAL_FAILED_daysold is null or @VAL_FAILED_daysold < 0
      select @VAL_FAILED_daysold = 7

   if @PENDING_daysold is null or @PENDING_daysold < 0
      select @PENDING_daysold = 14

   if @PROCESSING_daysold is null or @PROCESSING_daysold < 0
      select @PROCESSING_daysold = 14

   if @PROC_SCHLD_daysold is null or @PROC_SCHLD_daysold < 0
      select @PROC_SCHLD_daysold = 14

   if @OUTBOUND_SCHLD_daysold is null or @OUTBOUND_SCHLD_daysold < 0
      select @OUTBOUND_SCHLD_daysold = 14

   if @purge_archive_daysold is null or @purge_archive_daysold < 0
      select @purge_archive_daysold = 365

   insert into #times
      (oid, step, starttime)
    values(0, 'Purge Session', getdate())

   /* --------------------------------------------------------
      STEP 1
         Purging old feed_data_archive records if their 
         archived dates are @purge_archive_daysold
      -------------------------------------------------------- */
   select @stepid = 1
   insert into #times
      (oid, step, starttime)
    values(@stepid, 'Purged old feed_data archive records', getdate())

   /* feed_data_archive */
   begin tran
   delete dbo.feed_data_archive
   where datediff(day, archived_date, getdate()) > @purge_archive_daysold
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
   where tablename = 'feed_data_archive'

   /* --------------------------------------------------------
      STEP 2
         Purging old feed_detail_data_archive records 
         if their archived dates are @purge_archive_daysold
      -------------------------------------------------------- */
   select @stepid = 2
   insert into #times
      (oid, step, starttime)
    values(@stepid, 'Purged old feed_detail_data archive records', getdate())

   begin tran
   delete dbo.feed_detail_data_archive
   where datediff(day, archived_date, getdate()) > @purge_archive_daysold
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
   where tablename = 'feed_detail_data_archive'

   /* --------------------------------------------------------
      STEP 3
         Purging old feed_error_archive records 
         if their archived dates are @purge_archive_daysold
      -------------------------------------------------------- */
   select @stepid = 3
   insert into #times
      (oid, step, starttime)
    values(@stepid, 'Purged old feed_error archive records', getdate())

   begin tran
   delete dbo.feed_error_archive
   where datediff(day, archived_date, getdate()) > @purge_archive_daysold
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
   where tablename = 'feed_error_archive'
   
   /* --------------------------------------------------------
      STEP 4
         Purging old feed_transaction_archive records 
         if their archived dates are @purge_archive_daysold
      -------------------------------------------------------- */
   select @stepid = 4
   insert into #times
      (oid, step, starttime)
    values(@stepid, 'Purged old feed_transaction archive records', getdate())

   begin tran
   delete dbo.feed_transaction_archive
   where datediff(day, archived_date, getdate()) > @purge_archive_daysold
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
   where tablename = 'feed_transaction_archive'

   /* --------------------------------------------------------
      STEP 5
         Purging old feed_xsd_xml_text_archive records 
         if their archived dates are @purge_archive_daysold
      -------------------------------------------------------- */
   select @stepid = 5
   insert into #times
      (oid, step, starttime)
    values(@stepid, 'Purged old feed_xsd_xml_text archive records', getdate())


   /* feed_xsd_xml_text_archive */
   begin tran
   delete dbo.feed_xsd_xml_text_archive
   where datediff(day, archived_date, getdate()) > @purge_archive_daysold
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
   where tablename = 'feed_xsd_xml_text_archive'
 
   /* ------------------------------------------------
       STEP 6
          Obtaining the qualified records and save 
          them in a temporary table
      ------------------------------------------------ */
   select @stepid = 6
   insert into #times
      (oid, step, starttime)
    values(@stepid, 'Filled the temp table ''#feeds'' with the keys selected for archive', getdate())

   if @COMPLETED_daysold > 0
   begin
      insert into #feeds (feed_data_id)
      select f.oid
      from dbo.feed_data f,
           dbo.icts_transaction t
      where f.status = 'COMPLETED' and
            f.trans_id = t.trans_id and
            datediff(day, t.tran_date, getdate()) > @COMPLETED_daysold             
   end
   
   if @VAL_FAILED_daysold > 0
   begin
      insert into #feeds (feed_data_id)
      select f.oid
      from dbo.feed_data f,
           dbo.icts_transaction t
      where f.status = 'VAL_FAILED' and
            f.trans_id = t.trans_id and
            datediff(day, t.tran_date, getdate()) > @VAL_FAILED_daysold             
   end

   if @PENDING_daysold > 0
   begin
      insert into #feeds (feed_data_id)
      select f.oid
      from dbo.feed_data f,
           dbo.icts_transaction t
      where f.status = 'PENDING' and
            f.trans_id = t.trans_id and
            datediff(day, t.tran_date, getdate()) > @PENDING_daysold             
   end

   if @PROCESSING_daysold > 0
   begin
      insert into #feeds (feed_data_id)
      select f.oid
      from dbo.feed_data f,
           dbo.icts_transaction t
      where f.status = 'PROCESSING' and
            f.trans_id = t.trans_id and
            datediff(day, t.tran_date, getdate()) > @PROCESSING_daysold             
   end

   if @PROC_SCHLD_daysold > 0
   begin
      insert into #feeds (feed_data_id)
      select f.oid
      from dbo.feed_data f,
           dbo.icts_transaction t
      where f.status = 'PROC_SCHLD' and
            f.trans_id = t.trans_id and
            datediff(day, t.tran_date, getdate()) > @PROC_SCHLD_daysold             
   end

   if @OUTBOUND_SCHLD_daysold > 0
   begin
      insert into #feeds (feed_data_id)
      select f.oid
      from dbo.feed_data f,
           dbo.icts_transaction t
      where f.status = 'OUTBOUND_SCHLD' and
            f.trans_id = t.trans_id and
            datediff(day, t.tran_date, getdate()) > @OUTBOUND_SCHLD_daysold             
   end
   
   update #times
   set endtime = getdate()
   where oid = @stepid
   
   if (select count(*) from #feeds) = 0
   begin
      print '=> No feed data records found to be archived!'
      goto endofsp
   end

   /* ---------------------------------------------------------
       STEP 7
          Archiving the records in main tables to the 
          archive tables, and then delete records being 
          archived from main tables
      --------------------------------------------------------- */
   select @stepid = 7
   insert into #times
      (oid, step, starttime)
    values(@stepid, 'Archived records in main tables', getdate())
 
   select @total_FE_rows_archived = 0,
          @total_FE_rows_deleted = 0,
          @total_FT_rows_archived = 0,
          @total_FT_rows_deleted = 0,
          @total_FDA_rows_archived = 0,
          @total_FDA_rows_deleted = 0,
          @total_FD_rows_archived = 0,
          @total_FD_rows_deleted = 0,
          @total_FXXT_rows_archived = 0,
          @total_FXXT_rows_deleted = 0
                 
   select @feed_data_id1 = 1
   select @last_feed_data_id = max(feed_data_id) from #feeds

   while @feed_data_id1 <= @last_feed_data_id
   begin 
      select @feed_data_id2 = @feed_data_id1 + 1000  
      if @debugon = 1
      begin  
         select @smsg = '=> Archiving feed_data_touch records between ' + convert(varchar, @feed_data_id1) + ' and ' + convert(varchar, @feed_data_id2)
         print @smsg
      end

      begin tran
      insert into dbo.feed_error_archive
           (oid, feed_data_id, feed_detail_data_id, description, trans_id, archived_date)
      select oid, feed_data_id, feed_detail_data_id, description, trans_id, @archived_date
      from dbo.feed_error
      where feed_data_id between @feed_data_id1 and @feed_data_id2
      select @rows_affected = @@rowcount,
             @errcode = @@error
      if @errcode > 0
      begin
         if @@trancount > 0
            rollback tran
         goto endofsp
      end
      select @total_FE_rows_archived = @total_FE_rows_archived + @rows_affected
      if @debugon = 1
      begin
         if @rows_affected > 0
         begin
            select @smsg = '=> feed_error_archive: ' + convert(varchar, @total_FE_rows_archived) + ' records added so far ...' + convert(varchar, getdate(), 109)
            print @smsg
         end
      end

      insert into dbo.feed_transaction_archive
            (oid, feed_data_id, feed_detail_data_id, entity_id,  
             key1, key2, key3, key4, key5, key6, source, operation, 
             archived_date)
      select oid, feed_data_id, feed_detail_data_id, entity_id,  
             key1, key2, key3, key4, key5, key6, source, operation, 
             @archived_date
      from dbo.feed_transaction
      where feed_data_id between @feed_data_id1 and @feed_data_id2
      select @rows_affected = @@rowcount,
             @errcode = @@error
      if @errcode > 0
      begin
         if @@trancount > 0
            rollback tran
         goto endofsp
      end
      select @total_FT_rows_archived = @total_FT_rows_archived + @rows_affected
      if @debugon = 1
      begin
         if @rows_affected > 0
         begin
            select @smsg = '=> feed_transaction_archive: ' + convert(varchar, @total_FT_rows_archived) + ' records added so far ...' + convert(varchar, getdate(), 109)
            print @smsg
         end
      end

      insert into dbo.feed_detail_data_archive
            (oid, feed_data_id, request_xml_id, etl_timestamp, 
             status, trans_id, archived_date)
      select oid, feed_data_id, request_xml_id, etl_timestamp, 
             status, trans_id, @archived_date
      from dbo.feed_detail_data
      where feed_data_id between @feed_data_id1 and @feed_data_id2
      select @rows_affected = @@rowcount,
             @errcode = @@error
      if @errcode > 0
      begin
         if @@trancount > 0
            rollback tran
         goto endofsp
      end
      select @total_FDA_rows_archived = @total_FDA_rows_archived + @rows_affected
      if @debugon = 1
      begin
         if @rows_affected > 0
         begin
            select @smsg = '=> feed_detail_data_archive: ' + convert(varchar, @total_FDA_rows_archived) + ' records added so far ...' + convert(varchar, getdate(), 109)
            print @smsg
         end
      end
      
      insert into dbo.feed_data_archive
            (oid, request_xml_id, response_xml_id, number_of_rows, 
             feed_id, status, trans_id, archived_date)
      select oid, request_xml_id, response_xml_id, number_of_rows, 
             feed_id, status, trans_id, @archived_date
      from dbo.feed_data
      where oid between @feed_data_id1 and @feed_data_id2
      select @rows_affected = @@rowcount,
             @errcode = @@error
      if @errcode > 0
      begin
         if @@trancount > 0
            rollback tran
         goto endofsp
      end
      select @total_FD_rows_archived = @total_FD_rows_archived + @rows_affected
      if @debugon = 1
      begin
         if @rows_affected > 0
         begin
            select @smsg = '=> feed_data_archive: ' + convert(varchar, @total_FD_rows_archived) + ' records added so far ...' + convert(varchar, getdate(), 109)
            print @smsg
         end
      end
      
      /* ------------------------------ */
      /* Purge records from main tables */    
      delete dbo.feed_error 
      where feed_data_id between @feed_data_id1 and @feed_data_id2
      select @rows_affected = @@rowcount,
             @errcode = @@error
      if @errcode > 0
      begin
         if @@trancount > 0
            rollback tran
         goto endofsp
      end
      select @total_FE_rows_deleted = @total_FE_rows_deleted + @rows_affected
      if @debugon = 1
      begin
         if @rows_affected > 0
         begin
            select @smsg = 'feed_error: ' + convert(varchar, @total_FE_rows_deleted) + ' records deleted so far ...' + convert(varchar, getdate(), 109)
            print @smsg
         end
      end

      delete dbo.feed_transaction 
      where feed_data_id between @feed_data_id1 and @feed_data_id2
      select @rows_affected = @@rowcount,
             @errcode = @@error
      if @errcode > 0
      begin
         if @@trancount > 0
            rollback tran
         goto endofsp
      end
      select @total_FT_rows_deleted = @total_FT_rows_deleted + @rows_affected
      if @debugon = 1
      begin
         if @rows_affected > 0
         begin
            select @smsg = 'feed_transaction: ' + convert(varchar, @total_FT_rows_deleted) + ' records deleted so far ...' + convert(varchar, getdate(), 109)
            print @smsg
         end
      end

      delete dbo.feed_detail_data 
      where feed_data_id between @feed_data_id1 and @feed_data_id2
      select @rows_affected = @@rowcount,
             @errcode = @@error
      if @errcode > 0
      begin
         if @@trancount > 0
            rollback tran
         goto endofsp
      end
      select @total_FDA_rows_deleted = @total_FDA_rows_deleted + @rows_affected
      if @debugon = 1
      begin
         if @rows_affected > 0
         begin
            select @smsg = 'feed_detail_data: ' + convert(varchar, @total_FDA_rows_deleted) + ' records deleted so far ...' + convert(varchar, getdate(), 109)
            print @smsg
         end
      end

      delete dbo.feed_data 
      where oid between @feed_data_id1 and @feed_data_id2
      select @rows_affected = @@rowcount,
             @errcode = @@error
      if @errcode > 0
      begin
         if @@trancount > 0
            rollback tran
         goto endofsp
      end
      commit tran
      select @total_FD_rows_deleted = @total_FD_rows_deleted + @rows_affected
      if @debugon = 1
      begin
         if @rows_affected > 0
         begin
            select @smsg = 'feed_data: ' + convert(varchar, @total_FD_rows_deleted) + ' records deleted so far ...' + convert(varchar, getdate(), 109)
            print @smsg
         end
      end
                 
      select @feed_data_id1 = @feed_data_id2 + 1
   end /* while */

   update #times
   set endtime = getdate()
   where oid = @stepid

   update #rows_affected
   set rows_added = @total_FE_rows_archived
   where tablename = 'feed_error_archive'

   update #rows_affected
   set rows_deleted = @total_FE_rows_deleted
   where tablename = 'feed_error'
 
   update #rows_affected
   set rows_added = @total_FT_rows_archived
   where tablename = 'feed_transaction_archive'

   update #rows_affected
   set rows_deleted = @total_FT_rows_deleted
   where tablename = 'feed_transaction'
   
   update #rows_affected
   set rows_added = @total_FDA_rows_archived
   where tablename = 'feed_detail_data_archive'

   update #rows_affected
   set rows_deleted = @total_FDA_rows_deleted
   where tablename = 'feed_detail_data'

   update #rows_affected
   set rows_added = @total_FD_rows_archived
   where tablename = 'feed_data_archive'

   update #rows_affected
   set rows_deleted = @total_FD_rows_deleted
   where tablename = 'feed_data'

 
   /* ---------------------------------------------------------
       STEP 8
          Archiving the records in the feed_xsd_xml_text table 
          to the archive tables, and then delete records from
          the feed_xsd_xml_text table
      --------------------------------------------------------- */
   select @stepid = 8
   insert into #times
      (oid, step, starttime)
    values(@stepid, 'Archived feed_xsd_xml_text records table', getdate())
   
   insert into #xsd_xml_text_ids (oid)
   select distinct request_xsd_id
   from dbo.feed_definition
   where request_xsd_id is not null
   union 
   select distinct response_xsd_id
   from dbo.feed_definition
   where response_xsd_id is not null
   union 
   select distinct mapping_xml_id
   from dbo.feed_definition
   where mapping_xml_id is not null
   union
   select distinct request_xml_id
   from dbo.feed_data
   where request_xml_id is not null
   union
   select distinct response_xml_id
   from dbo.feed_data
   where response_xml_id is not null
    union
   select distinct request_xml_id
   from dbo.feed_detail_data 
   where request_xml_id is not null
   
   select @total_FXXT_rows_archived = 0,
          @total_FXXT_rows_deleted = 0
 
   begin tran   
   insert into dbo.feed_xsd_xml_text_archive
         (oid, doc_text, trans_id, archived_date)
   select oid, doc_text, trans_id, @archived_date
   from dbo.feed_xsd_xml_text f
   where not exists (select 1
                     from #xsd_xml_text_ids b
                     where f.oid = b.oid)
   select @rows_affected = @@rowcount,
          @errcode = @@error
   if @errcode > 0
   begin
      if @@trancount > 0
         rollback tran
      goto endofsp
   end
   select @total_FXXT_rows_archived = @total_FXXT_rows_archived + @rows_affected
   if @debugon = 1
   begin
      if @rows_affected > 0
      begin
         select @smsg = '=> feed_xsd_xml_text_archive: ' + convert(varchar, @total_FXXT_rows_archived) + ' records added so far ...' + convert(varchar, getdate(), 109)
         print @smsg
      end
   end                    

   delete f 
   from dbo.feed_xsd_xml_text f
   where not exists (select 1
                     from #xsd_xml_text_ids b
                     where f.oid = b.oid)
   select @rows_affected = @@rowcount,
          @errcode = @@error
   if @errcode > 0
   begin
      if @@trancount > 0
         rollback tran
      goto endofsp
   end
   commit tran
   select @total_FXXT_rows_deleted = @total_FXXT_rows_deleted + @rows_affected
   if @debugon = 1
   begin
      if @rows_affected > 0
      begin
          select @smsg = 'feed_xsd_xml_text: ' + convert(varchar, @total_FXXT_rows_deleted) + ' records deleted so far ...' + convert(varchar, getdate(), 109)
          print @smsg
      end
   end

   update #times
   set endtime = getdate()
   where oid = @stepid

   update #rows_affected
   set rows_added = @total_FXXT_rows_archived
   where tablename = 'feed_xsd_xml_text_archive'

   update #rows_affected
   set rows_deleted = @total_FXXT_rows_deleted
   where tablename = 'feed_xsd_xml_text'
        
endofsp:
   drop table #feeds
   drop table #xsd_xml_text_ids
 
   -- Enable triggers  
   if OBJECTPROPERTY(object_id('dbo.feed_data_deltrg'), 'ExecIsTriggerDisabled') = 1
      exec('alter table dbo.feed_data enable trigger feed_data_deltrg')
   if OBJECTPROPERTY(object_id('dbo.feed_detail_data_deltrg'), 'ExecIsTriggerDisabled') = 1
      exec('alter table dbo.feed_detail_data enable trigger feed_detail_data_deltrg')
   if OBJECTPROPERTY(object_id('dbo.feed_xsd_xml_text_deltrg'), 'ExecIsTriggerDisabled') = 1
      exec('alter table dbo.feed_xsd_xml_text enable trigger feed_xsd_xml_text_deltrg')
  
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
   print '    ACTION          : Archived feed data records and '
   print '                      purged archived records which are '
   print '                      older than the following given days:'
   if @COMPLETED_daysold > 0
   begin
      select @smsg = '                          COMPLETED        ' + cast(@COMPLETED_daysold as varchar) + ' days'
      print @smsg
   end
   if @VAL_FAILED_daysold > 0
   begin
      select @smsg = '                          VAL_FAILED       ' + cast(@VAL_FAILED_daysold as varchar) + ' days'
      print @smsg
   end
   if @PENDING_daysold > 0
   begin
      select @smsg = '                          PENDING          ' + cast(@PENDING_daysold as varchar) + ' days'
      print @smsg
   end
   if @PROCESSING_daysold > 0
   begin
      select @smsg = '                          PROCESSING       ' + cast(@PROCESSING_daysold as varchar) + ' days'
      print @smsg
   end
   if @PROC_SCHLD_daysold > 0
   begin
      select @smsg = '                          PROC_SCHLD       ' + cast(@PROC_SCHLD_daysold as varchar) + ' days'
      print @smsg
   end
   if @OUTBOUND_SCHLD_daysold > 0
   begin
      select @smsg = '                          OUTBOUND_SCHLD   ' + cast(@OUTBOUND_SCHLD_daysold as varchar) + ' days'
      print @smsg
   end
   if @purge_archive_daysold > 0
   begin
      select @smsg = '                          ARCHIVED(Purged) ' + cast(@purge_archive_daysold as varchar) + ' days'
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
 
   declare @total_rows_added int,
           @total_rows_deleted  int
  
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
GRANT EXECUTE ON  [dbo].[usp_archive_feed_data] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_archive_feed_data', NULL, NULL
GO
