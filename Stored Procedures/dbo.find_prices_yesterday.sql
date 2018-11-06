SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[find_prices_yesterday]
(
   @by_commkt_key          int = null,
   @by_price_source_code   varchar(8) = null,
   @by_price_quote_date    datetime = null
)
as
begin
set nocount on

   create table #price_temp 
   (
      commkt_key                 int             not null,
      price_source_code          varchar(8)      not null,
      trading_prd                varchar(8)      not null,
      open_interest              float           null,
      vol_traded                 float           null,
      creation_type              varchar(1)      null,
      trans_id                   int             null,
      low_bid_creation_ind       char(1)         null,
      high_asked_creation_ind    char(1)         null,
      avg_closed_creation_ind    char(1)         null,
      today_price_quote_date     datetime        null,
      today_low_bid_price        float           null,
      today_high_asked_price     float           null,
      today_avg_closed_price     float           null,
      yest_price_quote_date      datetime        null,
      yest_low_bid_price         float           null,
      yest_high_asked_price      float           null,
      yest_avg_closed_price      float           null
    )
        
   create unique index price_temp_idx1 on #price_temp 
        (commkt_key, price_source_code, trading_prd)

   if (@by_commkt_key is not null) and 
      (@by_price_source_code is not null) and 
      (@by_price_quote_date is not null)
   begin
      /* 
         This insert should 'fill in' the #price_temp table with
         'NULL' entries for those quotes that do not have a record 
         in the price table...for our purposes, we want to represent
         the absence of a price as a row in #price_temp
      */
      insert into #price_temp
      select
         @by_commkt_key,
         @by_price_source_code,
         t.trading_prd,
         NULL,
         NULL,
         NULL,
         NULL, 
         NULL,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL
      from dbo.trading_period t
      where t.commkt_key = @by_commkt_key

      /* 
          for each record in price table (for given keys), copy
          that record in to #price_temp table
      */
      update ptemp  
      set open_interest = p.open_interest,
          vol_traded = p.vol_traded,
          creation_type = p.creation_type,
          trans_id = p.trans_id,
          low_bid_creation_ind = p.low_bid_creation_ind,
          high_asked_creation_ind = p.high_asked_creation_ind,
          avg_closed_creation_ind = p.avg_closed_creation_ind,
          today_price_quote_date = @by_price_quote_date,
          today_low_bid_price = p.low_bid_price,
          today_high_asked_price = p.high_asked_price,
          today_avg_closed_price = p.avg_closed_price
      from dbo.price p,
           #price_temp ptemp 
      where p.commkt_key = ptemp.commkt_key and 
            p.price_source_code = ptemp.price_source_code and 
            p.trading_prd = ptemp.trading_prd and 
            p.price_quote_date = @by_price_quote_date

      update ptemp 
      set yest_price_quote_date = (select p.price_quote_date 
                                   from dbo.price p
                                   where p.commkt_key = @by_commkt_key and 
                                         p.price_source_code = @by_price_source_code and 
                                         p.trading_prd = ptemp.trading_prd and 
                                         p.price_quote_date < @by_price_quote_date
		                               group by p.commkt_key,
                                            p.trading_prd,
                                            p.price_source_code
                                   having price_quote_date = max(price_quote_date) and
		                                      p.price_source_code = @by_price_source_code and 
                                          p.trading_prd = ptemp.trading_prd and 
                                          p.price_quote_date < @by_price_quote_date)
      from #price_temp ptemp
        
      update ptemp 
      set yest_low_bid_price = p.low_bid_price
      from dbo.price p,
           #price_temp ptemp
      where ptemp.trading_prd = p.trading_prd and 
            ptemp.yest_price_quote_date = p.price_quote_date and 
            p.commkt_key = @by_commkt_key and 
            p.price_source_code = @by_price_source_code
        
      update ptemp 
      set yest_high_asked_price = p.high_asked_price
      from dbo.price p,
           #price_temp ptemp
      where ptemp.trading_prd = p.trading_prd and 
            ptemp.yest_price_quote_date = p.price_quote_date and 
            p.commkt_key = @by_commkt_key and 
            p.price_source_code = @by_price_source_code
        
      update ptemp 
      set yest_avg_closed_price = p.avg_closed_price
      from dbo.price p,
           #price_temp ptemp
      where ptemp.trading_prd = p.trading_prd and 
            ptemp.yest_price_quote_date = p.price_quote_date and 
            p.commkt_key = @by_commkt_key and 
            p.price_source_code = @by_price_source_code        
   end
   else    /* bad arguments */
      return 4

   select
      commkt_key,
      price_source_code,
      trading_prd,
      open_interest,
      vol_traded,
      creation_type,
      trans_id,
      low_bid_creation_ind,
      high_asked_creation_ind,
      avg_closed_creation_ind,
      today_price_quote_date,
      today_low_bid_price,
      today_high_asked_price,
      today_avg_closed_price,
      yest_price_quote_date,
      yest_low_bid_price,
      yest_high_asked_price,
      yest_avg_closed_price
   from #price_temp
   order by trading_prd
end
return
GO
GRANT EXECUTE ON  [dbo].[find_prices_yesterday] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'find_prices_yesterday', NULL, NULL
GO
