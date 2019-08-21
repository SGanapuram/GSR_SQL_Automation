SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_price_rows]
(
   @before_quote_date    datetime = NULL,  
   @max_years_back       smallint = 0,  
   @commkt_key           int = 0,  
   @price_source_code    char(8) = NULL 
) 
as  
set nocount on  
declare @after_quote_date        datetime,  
        @number_years_back       smallint,  
        @my_before_quote_date    datetime,  
        @my_commkt_key           int,  
        @my_price_source_code    char(8),
		@dirty_flag              bit,
        @last_fetched_date       varchar(30)		
  
   select @number_years_back = @max_years_back,  
          @my_before_quote_date = @before_quote_date,  
          @my_commkt_key = @commkt_key,  
          @my_price_source_code = @price_source_code  
            
   if @before_quote_date is null  
   begin        
      print 'You must provide a date for the argument @before_quote_date!'  
      goto reportusage  
   end  
  
   if (@commkt_key > 0 and @price_source_code is null)  
   begin  
      print 'You must provide a price_source_code (or commkt_Key) if you give a commkt_key (or price_source_code)!'  
      goto reportusage  
   end  
  
   if @commkt_key >= 0 and @price_source_code is not null  
      select @number_years_back = 0  
  
   if @number_years_back > 0  
   begin  
      select @number_years_back = -1 * @number_years_back  
      select @after_quote_date = dateadd(year, @number_years_back, @my_before_quote_date)

set @dirty_flag = 1
      set @last_fetched_date = '01/01/1900'
	  if object_id('tempdb..##price_dataset_4_pass', 'U') is null
	  begin
	     RAISERROR('DEBUG: Creating temporary table  ##price_dataset_4_pass ...', 0, 1) with nowait
	     create table ##price_dataset_4_pass
         (
		    oid                     int IDENTITY primary key,
            commkt_key              int         not null,
            price_source_code       char(8)     not null,
            trading_prd             char(8)     not null,
            price_quote_date        datetime    not null,
            low_bid_price           float       null,
            high_asked_price        float       null,
            avg_closed_price        float       null,
            low_bid_creation_ind    char(1)     null,
            high_asked_creation_ind char(1)     null,
            avg_closed_creation_ind char(1)     null,
			delta_in_days           int         null,
			fetched_date            varchar(30) not null
         )
	  end
	  begin
	     set @dirty_flag = (select isnull(dirty_flag, 0)
		                    from dbo.dirty_prices_alert
							where oid = 1)
         set @last_fetched_date = (select isnull(fetched_date, '01/01/1900')	  
	                               from ##price_dataset_4_pass
	                               where oid = (select min(oid)
								                from ##price_dataset_4_pass))	  					  
	     if @dirty_flag = 0 and
	        @last_fetched_date >= convert(varchar, getdate(), 101)
		 begin
		    RAISERROR('DEBUG: data is available in ##price_dataset_4_pass ...', 0, 1) with nowait

			goto returndata
		 end

		 RAISERROR('DEBUG: price data has been changed or it belongs to previoys day, so fetch price data from the price table ...', 0, 1) with nowait
		 exec('truncate table ##price_dataset_4_pass')
      end
       			
	  RAISERROR('DEBUG: Executing query to fetch price data ...', 0, 1) with nowait
	  
  
      ;WITH cte_price 
      AS
      (select  
          commkt_key,
          price_source_code,
		  price_quote_date,
          trading_prd,
          low_bid_price,
          high_asked_price,
          avg_closed_price,
          low_bid_creation_ind,
          high_asked_creation_ind,
          avg_closed_creation_ind
       from dbo.price
	   where price_quote_date between @after_quote_date and @before_quote_date
      )
	  insert into ##price_dataset_4_pass
	        (commkt_key,
             price_source_code,
             trading_prd,
             price_quote_date,
             low_bid_price,
             high_asked_price,
             avg_closed_price,
             low_bid_creation_ind,
             high_asked_creation_ind,
             avg_closed_creation_ind,
             delta_in_days,
             fetched_date)
      select
         p1.commkt_key,
         p1.price_source_code,
         p1.trading_prd,
         convert(varchar(12), p1.price_quote_date, 101),
         p1.low_bid_price,
         p1.high_asked_price,
         p1.avg_closed_price,
         p1.low_bid_creation_ind,
         p1.high_asked_creation_ind,
         p1.avg_closed_creation_ind,
         datediff (day, p1.price_quote_date, @before_quote_date),
		 convert(varchar, getdate(), 101)
      from cte_price p1
	          JOIN (select commkt_key,
                           price_source_code,
                           trading_prd,
                           max(price_quote_date) as price_quote_date
                    from cte_price
                    group by commkt_key, price_source_code, trading_prd) p2
			     ON p2.commkt_key = p1.commkt_key and 
                    p2.price_source_code = p1.price_source_code and 
                    p2.trading_prd = p1.trading_prd and 
                    p2.price_quote_date = p1.price_quote_date 
      OPTION (MAXDOP 12)
	  
	  update dbo.dirty_prices_alert
		set dirty_flag = 0
		where oid = 1

returndata:	  
	 select 
	    commkt_key,
        price_source_code,
        trading_prd,
        convert(varchar(12), price_quote_date, 101) price_quote_date,
        low_bid_price,
        high_asked_price,
        avg_closed_price,
        low_bid_creation_ind,
        high_asked_creation_ind,
        avg_closed_creation_ind,
        delta_in_days
     from ##price_dataset_4_pass  
	  
	  return  
   end  
  
   create table #price_temp  
   (  
      commkt_key              int      NOT NULL,  
      price_source_code       char(8)  NOT NULL,  
      trading_prd             char(8)  NOT NULL,  
      price_quote_date        datetime NOT NULL  
   )  
  
   if @commkt_key >= 0 and @price_source_code is not null  
   begin  
      insert into #price_temp  
      select commkt_key,  
             price_source_code,  
             trading_prd,  
             max(price_quote_date)  
      from price  
      where price_quote_date <= @my_before_quote_date and  
            commkt_key = @my_commkt_key and  
            price_source_code = @my_price_source_code  
      group by commkt_key, price_source_code, trading_prd  
   end  
   else  
   begin  
      insert into #price_temp  
      select commkt_key,  
             price_source_code,  
             trading_prd,  
             max(price_quote_date)  
      from price  
      where price_quote_date <= @my_before_quote_date  
      group by commkt_key, price_source_code, trading_prd  
   end  
  
   select  
      p1.commkt_key,  
      p1.price_source_code,  
      p1.trading_prd,  
      convert(char(10), p1.price_quote_date, 101),  
      p1.low_bid_price,  
      p1.high_asked_price,  
      p1.avg_closed_price,  
      p1.low_bid_creation_ind,  
      p1.high_asked_creation_ind,  
      p1.avg_closed_creation_ind,  
      /* the datediff() here will return 0 or a positive number */  
      datediff (day, p1.price_quote_date, convert(datetime, @my_before_quote_date))  
   from price p1,  
        #price_temp p2  
   where p1.commkt_key = p2.commkt_key and  
         p1.price_source_code = p2.price_source_code and  
         p1.trading_prd = p2.trading_prd and  
         p1.price_quote_date = p2.price_quote_date  
  
   drop table #price_temp  
   return  
  
reportusage:  
   print 'Usage: exec dbo.usp_price_rows @before_quote_date = ''mm/dd/yyyy'', [ @max_years_back = ? ]'  
   print '                               [ @commkt_key = ? ], [ @price_source_code = ''..'' ]'  
   return 
GO
GRANT EXECUTE ON  [dbo].[usp_price_rows] TO [next_usr]
GO
