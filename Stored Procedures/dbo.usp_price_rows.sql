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
        @my_price_source_code    char(8)  
  
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
         datediff (day, p1.price_quote_date, @my_before_quote_date)
      from price p1,
           (select commkt_key,
                   price_source_code,
                   trading_prd,
                   max(price_quote_date) as price_quote_date
            from price
            where price_quote_date between @after_quote_date and @my_before_quote_date
            group by commkt_key, price_source_code, trading_prd) p2
      where p1.price_quote_date between @after_quote_date and @my_before_quote_date and
                     p2.commkt_key = p1.commkt_key and 
                     p2.price_source_code = p1.price_source_code and 
                     p2.trading_prd = p1.trading_prd and 
                    p2.price_quote_date = p1.price_quote_date 
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
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_price_rows', NULL, NULL
GO
