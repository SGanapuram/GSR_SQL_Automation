SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_interest_rates]
(
   @before_quote_date    datetime = NULL,
   @max_years_back       smallint = 0,
   @debugon              bit = 0
)
as
set nocount on
declare @after_quote_date    datetime,
        @number_years_back   smallint,
        @rows_affected       int,
        @smsg                varchar(255),
        @session_starttime   datetime,
        @session_endtime     datetime

   set @rows_affected = 0
   if @before_quote_date is null
   begin
      print 'Usage: exec dbo.usp_interest_rates @before_quote_date = ''mm/dd/yy'', [ @max_years_back = ? ]'
      print 'You must provide a date for the argument @before_quote_date!'
      return
   end

   if @debugon = 1
   begin
      create table #times
      ( 
         oid             int not null,
         step            varchar(40) null,
         starttime       datetime null,
         endtime         datetime null,
         rows_affected   int default 0 null
      )
      set @session_starttime = getdate()
      insert into #times 
         values(1, '(1) Creating temporary table', @session_starttime, null, 0)
   end

   create table #price_temp 
   (
      commkt_key              int      NOT NULL,
      price_source_code       char(8)  NOT NULL,
      trading_prd             char(8)  NOT NULL,
      price_quote_date        datetime NOT NULL,
      days                    smallint default 9999 NULL
    )

   create nonclustered index price_temp_idx999
        on #price_temp (commkt_key, price_source_code, trading_prd, price_quote_date)

   if @debugon = 1
   begin
      update #times
      set endtime = getdate()
      where oid = 1
   end   

   if @max_years_back > 0
   begin
      set @number_years_back = -1 * @max_years_back
      set @after_quote_date = dateadd(year, @number_years_back, convert(datetime, @before_quote_date))

      if @debugon = 1
      begin
         insert into #times 
            values(2, 'Copying data into temporary table', getdate(), null, 0)
      end

      insert into #price_temp
         (commkt_key, price_source_code, trading_prd, price_quote_date)
      select p.commkt_key,
             p.price_source_code,
             p.trading_prd,
             max(p.price_quote_date)
      from dbo.price p, 
           dbo.commodity_market cm with (nolock)
      where cm.commkt_key = p.commkt_key AND 
            cm.cmdty_code LIKE '%INT' AND 
            cm.mkt_code = 'INTRATES' AND 
            p.trading_prd LIKE 'DAY%' AND 
            p.price_source_code = 'INTERNAL' AND 
            p.avg_closed_price IS NOT NULL and
            p.price_quote_date between @after_quote_date and @before_quote_date
      group by p.commkt_key, p.price_source_code, p.trading_prd
      set @rows_affected = @@rowcount
      if @debugon = 1
      begin
         update #times
         set endtime = getdate(),
             rows_affected = @rows_affected
         where oid = 2
      end   
   end
   else
   begin
      if @debugon = 1
      begin
         insert into #times 
            values(3, 'Copying data into temporary table', getdate(), null, 0)
      end
      insert into #price_temp
         (commkt_key, price_source_code, trading_prd, price_quote_date)
      select p.commkt_key,
             p.price_source_code,
             p.trading_prd,
             max(p.price_quote_date)
      from dbo.price p, 
           dbo.commodity_market cm with (nolock)
      where cm.commkt_key = p.commkt_key AND 
            cm.cmdty_code LIKE '%INT' AND 
            cm.mkt_code = 'INTRATES' AND 
            p.trading_prd LIKE 'DAY%' AND 
            p.price_source_code = 'INTERNAL' AND 
            p.avg_closed_price IS NOT NULL and
            p.price_quote_date <= @before_quote_date
      group by p.commkt_key, p.price_source_code, p.trading_prd
      set @rows_affected = @@rowcount
      if @debugon = 1
      begin
         update #times
         set endtime = getdate(),
             rows_affected = @rows_affected
         where oid = 3
      end   
   end

   if @debugon = 1
   begin
      insert into #times 
         values(4, 'Calculating day offsets', getdate(), null, 0)
   end
   
   update #price_temp
   set days = datediff(day, price_quote_date, convert(datetime, @before_quote_date))
   set @rows_affected = @@rowcount
   if @debugon = 1
   begin
      update #times
      set endtime = getdate(),
          rows_affected = @rows_affected
      where oid = 4
   end   

/* DEBUG 
   select * from #price_temp
   order by commkt_key, price_source_code, trading_prd, price_quote_date, days
*/

   -- The following delete statement was modified to include the WHERE clause
   -- 'where pt.commkt_key = pt2.commkt_key' in subquery because it is possible
   -- that #price_temp table may have more than 1 unique commkt_key.
   --
   -- We want to delete records for each commkt_key in the #price_temp table
   -- whose 'days' is not the least.
   --
   -- Kishore, Peter     7/27/2005
   delete pt
   from #price_temp pt
   where days > (select min(days)
                 from #price_temp pt2
                 where pt.commkt_key = pt2.commkt_key)

   if @debugon = 1
   begin
      insert into #times 
         values(5, 'Returning resultset', getdate(), null, 0)
   end
   select cm.cmdty_code,
          p.trading_prd,
          p.avg_closed_price,
          p1.days          
   from dbo.price p, 
        #price_temp p1,
        dbo.commodity_market cm with (nolock)
   where p1.commkt_key = cm.commkt_key and
         p1.commkt_key = p.commkt_key and
         p1.price_source_code = p.price_source_code and
         p1.trading_prd = p.trading_prd and
         p1.price_quote_date = p.price_quote_date
   order by cm.cmdty_code, p.trading_prd
   set @rows_affected = @@rowcount
   if @debugon = 1
   begin
      set @session_endtime = getdate()
      update #times
      set endtime = @session_endtime,
          rows_affected = @rows_affected
      where oid = 5
   end   

   if @debugon = 1
   begin
      declare @oid        int,
              @step       varchar(40),
              @starttime  varchar(30),
              @endtime    varchar(30)

      print ' '
      select @oid = min(oid)
      from #times

      while @oid is not null
      begin
         select @step = step,
                @starttime = convert(varchar, starttime, 109),
                @endtime = convert(varchar, endtime, 109),
                @rows_affected = rows_affected
         from #times
         where oid = @oid

         select @smsg = convert(varchar, @oid) + '. ' + @step
         print @smsg
         print '    STARTED  AT  : ' + @starttime
         print '    FINISHED AT  : ' + @endtime
         print '    ROWS AFFECTED: ' + convert(varchar, @rows_affected)
         
         select @oid = min(oid)
         from #times
         where oid > @oid
      end 
      drop table #times
      print ' '
      print 'SESSION:'
      print '    STARTED  AT      : ' + convert(varchar, @session_starttime, 109)
      print '    FINISHED AT      : ' + convert(varchar, @session_endtime, 109)
      print '    DURATION (in ms) : ' + convert(varchar, datediff(ms, @session_starttime, @session_endtime))
   end

   drop table #price_temp
return
GO
GRANT EXECUTE ON  [dbo].[usp_interest_rates] TO [next_usr]
GO
