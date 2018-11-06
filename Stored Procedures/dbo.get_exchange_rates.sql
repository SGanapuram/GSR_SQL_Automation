SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[get_exchange_rates]
(
   @by_commkt_key          int = null,
   @by_price_source_code   varchar(8) = null,
   @by_price_quote_date    datetime = null
)
as
begin
set nocount on

   if (@by_commkt_key is null) or 
      (@by_price_source_code is null) or 
      (@by_price_quote_date is null) 
      return 4

   create table #price_temp 
   (       
      commkt_key                 int             not null,
      price_source_code          varchar(8)      not null,
      trading_prd                varchar(8)      not null,
      trading_prd_desc           varchar(40)     null,
      trans_id                   int             null,
      today_price_quote_date     datetime        null,
      today_low_bid_price        float           null,
      today_high_asked_price     float           null,
      today_avg_closed_price     float           null,
      yest_price_quote_date      datetime        null,
      yest_low_bid_price         float           null,
      yest_high_asked_price      float           null,
      yest_avg_closed_price      float           null
   )
   create unique index price_temp_idx1
        on #price_temp (commkt_key, price_source_code, trading_prd)


   /* this insert should "fill in" the #price_temp table with
      "NULL" entries for those quotes that do not have a record 
      in the price table...for our purposes, we want to represent
      the absence of a price as a row in #price_temp
   */
   insert into #price_temp
   select @by_commkt_key,
          @by_price_source_code,
          trading_prd,
          trading_prd_desc,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL
   from dbo.trading_period
   where commkt_key = @by_commkt_key


   /* get interest rates for current quote date */
   update #price_temp  
   set trans_id = p.trans_id,
       today_price_quote_date = @by_price_quote_date,
       today_low_bid_price = p.low_bid_price,
       today_high_asked_price = p.high_asked_price,
       today_avg_closed_price = p.avg_closed_price
   from dbo.price p
   where p.commkt_key = #price_temp.commkt_key
         and p.price_source_code = #price_temp.price_source_code
         and p.trading_prd = #price_temp.trading_prd
         and p.price_quote_date = @by_price_quote_date


   /* get previous quote date */
   update #price_temp 
   set yest_price_quote_date =
	        (select p.price_quote_date 
	         from dbo.price p
		       where p.commkt_key = @by_commkt_key and 
		             p.price_source_code = @by_price_source_code and 
		             p.trading_prd = #price_temp.trading_prd and 
		             p.price_quote_date < @by_price_quote_date
		       group by p.commkt_key,p.trading_prd,p.price_source_code
		       having price_quote_date = max(price_quote_date) and
		              p.price_source_code = @by_price_source_code and
                  p.trading_prd = #price_temp.trading_prd and
                  p.price_quote_date < @by_price_quote_date)
        
   /* get interest rates for previous quote date */
   update #price_temp 
   set yest_low_bid_price = p.low_bid_price
   from dbo.price p
   where #price_temp.trading_prd = p.trading_prd and
         #price_temp.yest_price_quote_date = p.price_quote_date and
         p.commkt_key = @by_commkt_key and
         p.price_source_code = @by_price_source_code
        
   update #price_temp 
   set yest_high_asked_price = p.high_asked_price
   from dbo.price p
   where #price_temp.trading_prd = p.trading_prd and
         #price_temp.yest_price_quote_date = p.price_quote_date and
         p.commkt_key = @by_commkt_key and
         p.price_source_code = @by_price_source_code
        
   update #price_temp 
   set yest_avg_closed_price = p.avg_closed_price
   from dbo.price p
   where #price_temp.trading_prd = p.trading_prd and
         #price_temp.yest_price_quote_date = p.price_quote_date and
         p.commkt_key = @by_commkt_key and
         p.price_source_code = @by_price_source_code       

   select commkt_key,
          price_source_code,
          trading_prd,
          trading_prd_desc,
          trans_id,
          today_price_quote_date,
          today_low_bid_price,
          today_high_asked_price,
          today_avg_closed_price,
          yest_price_quote_date,
          yest_low_bid_price,
          yest_high_asked_price,
          yest_avg_closed_price
   from #price_temp
   order by trading_prd_desc

   drop table #price_temp
end
return
GO
GRANT EXECUTE ON  [dbo].[get_exchange_rates] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'get_exchange_rates', NULL, NULL
GO
