SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_archive_trans_touch]
(
   @archive_daysold       int = 7,
   @purge_daysold         int = 180
)
as
set nocount on
set xact_abort on
declare @rows_affected           int,
        @errcode                 int,
        @smsg                    varchar(255),
        @oid                     int,
        @stepid                  smallint,
        @archive_date            datetime
        
   create table #times
   (
      oid                int,
      step               varchar(80),
      starttime          datetime null,
      endtime            datetime null,
      rows_affected      int default 0 null
   )

   select @errcode = 0,
          @rows_affected = 0,
          @archive_date = convert(datetime, convert(varchar, getdate(), 101))
          
   if @archive_daysold is null or @archive_daysold < 0
      select @archive_daysold = 7

   if @purge_daysold is null or @purge_daysold < 0
      select @purge_daysold = 180

   insert into #times
      (oid, step, starttime)
    values(0, 'Purge Session Started', getdate())

   /* ------------------------------------------------
      STEP 1
         Purging old records from transaction_touch_archive
         table 
      ------------------------------------------------ */
   select @stepid = 1
   insert into #times
      (oid, step, starttime)
    values(@stepid, 'Purged old transaction_touch_archive records', getdate())

   begin tran
   delete dbo.transaction_touch_archive
   where datediff(day, tran_date, @archive_date) > @purge_daysold
   select @rows_affected = @@rowcount,
          @errcode = @@error
   if @errcode > 0
   begin
      rollback tran
      goto endofsp
   end
   commit tran
   update #times
   set endtime = getdate(),
       rows_affected = @rows_affected
   where oid = @stepid

   /* ------------------------------------------------
      STEP 2
         Archiving the transaction_touch records 
         whose tran_date is older than a given days
      ------------------------------------------------ */
   select @stepid = 2
   insert into #times
      (oid, step, starttime)
    values(@stepid, 'Archived als_run records', getdate())
        
   begin tran
   insert into dbo.transaction_touch_archive
   select @archive_date,
          tt.operation,
          tt.entity_name,
          tt.touch_type,
          tt.key1,
          tt.key2,
          tt.key3,
          tt.key4,
          tt.key5,
          tt.key6,
          tt.key7,
          tt.key8,
          tt.trans_id,
          tt.sequence,
          tt.touch_key,
          it.tran_date
   from dbo.transaction_touch tt,
        dbo.icts_transaction it
   where datediff(day, it.tran_date, @archive_date) > @archive_daysold and
         tt.trans_id = it.trans_id and
         tt.sequence = it.sequence     
   select @rows_affected = @@rowcount,
          @errcode = @@error
   if @errcode > 0
   begin
      rollback tran
      goto endofsp
   end
   update #times
   set endtime = getdate(),
       rows_affected = @rows_affected
   where oid = @stepid

   if @rows_affected > 0
   begin
      /* ------------------------------------------------
         STEP 3
            deleting transaction_touch records which were
            archived to transaction_touch_archive table
         ------------------------------------------------ */
      select @stepid = 3
      insert into #times
         (oid, step, starttime)
        values(@stepid, 'Removed transaction_touch records', getdate())

      delete dbo.transaction_touch
      from dbo.transaction_touch tt,
           dbo.icts_transaction it
      where datediff(day, it.tran_date, @archive_date) > @archive_daysold and
            tt.trans_id = it.trans_id and
            tt.sequence = it.sequence
      select @rows_affected = @@rowcount,
             @errcode = @@error
      if @errcode > 0
      begin
         rollback tran
         goto endofsp
      end
      commit tran
      update #times
      set endtime = getdate(),
          rows_affected = @rows_affected
      where oid = @stepid
   end
   else
      commit tran      

endofsp:
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
   print '========================================================================'
   print ' PURGE SESSION'
   select @smsg = '    STARTED  AT     : ' + @starttime
   print @smsg       
   select @smsg = '    FINISHED AT     : ' + @endtime
   print @smsg
   select @smsg = '    DURATION (in ms): ' + @duration
   print @smsg
   print '    ACTIONS         : 1. Archived transaction_touch records whose '
   select @smsg = '                         tran_dates are older than ' + convert(varchar, @archive_daysold) + ' day(s) and'
   print @smsg
   print '                         then purged transaction_touch records being archived.'
   print '                      2. Purged transaction_touch_acrhive records whose '
   select @smsg = '                         tran_dates are older than ' + convert(varchar, @purge_daysold) + ' day(s).'
   print @smsg
   print '------------------------------------------------------------------------'
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
             @duration = convert(varchar, datediff(ms, starttime, endtime)),
             @rows_affected = rows_affected
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
      select @smsg = '    ROWS AFFECTED   : ' + convert(varchar, @rows_affected)
      print @smsg
      print ' '
   end 
   drop table #times
GO
GRANT EXECUTE ON  [dbo].[usp_archive_trans_touch] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_archive_trans_touch', NULL, NULL
GO
