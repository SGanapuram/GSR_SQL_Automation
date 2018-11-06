SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[get_posted_price_rows]
(
   @by_posting_source_code varchar(8) = null,
   @by_price_eff_date      datetime = null
)
as
begin
set nocount on

   if (@by_posting_source_code is null) or
      (@by_price_eff_date is null) 
      return 4   /* bad arguments */

   create table #price_temp 
   (  
      commkt_key              int          NOT NULL,
      cmdty_code              char(8)      NULL,
      mkt_code                char(8)      NULL,
      price                   float        NULL,
      posted_gravity          float        NULL,
      gravity_source_code     char(8)      NULL,
      gravity_table_name      char(8)      NULL,
      price_quote_date        datetime     NULL
    )

   insert into #price_temp
   select commkt_key,
          NULL,
          NULL,
          avg_closed_price,
          NULL,
          NULL,
          NULL,
          price_quote_date
   from dbo.price
   where trading_prd = 'SPOT' and
         price_source_code =  @by_posting_source_code and
         convert(varchar(30), price_quote_date, 101) = convert(varchar(30), @by_price_eff_date, 101)

   /* if there is not current price, then we should use the previous
      price_quote_date as base */
   if not exists (select * from #price_temp)
   begin
      insert into #price_temp
      select commkt_key,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             price_quote_date
      from dbo.price p1
      where p1.trading_prd = 'SPOT' and
            p1.price_source_code =  @by_posting_source_code and
            p1.price_quote_date = (select max(p2.price_quote_date)
                                   from dbo.price p2
                                   where p1.commkt_key = p2.commkt_key and
                                         p1.price_source_code =  p2.price_source_code and
                                         p1.trading_prd = p2.trading_prd and
                                         convert(varchar(30), p2.price_quote_date, 101) < convert(varchar(30), @by_price_eff_date, 101))
      if exists (select * from #price_temp)
      begin
         update #price_temp
         set posted_gravity = price_gravity_adj.posted_gravity,
             gravity_source_code = price_gravity_adj.gravity_source_code,
             gravity_table_name = price_gravity_adj.gravity_table_name
         from dbo.price_gravity_adj
         where #price_temp.commkt_key = price_gravity_adj.commkt_key and
               price_gravity_adj.price_source_code = @by_posting_source_code and
               convert(varchar(30), price_gravity_adj.price_quote_date, 101) = convert(varchar(30), #price_temp.price_quote_date, 101)
      end
   end
   else
   begin
      update #price_temp
      set posted_gravity = price_gravity_adj.posted_gravity,
          gravity_source_code = price_gravity_adj.gravity_source_code,
          gravity_table_name = price_gravity_adj.gravity_table_name
      from dbo.price_gravity_adj
      where #price_temp.commkt_key = price_gravity_adj.commkt_key and
            price_gravity_adj.price_source_code = @by_posting_source_code and
            convert(varchar(30), price_gravity_adj.price_quote_date, 101) = convert(varchar(30), #price_temp.price_quote_date, 101)
   end

   update #price_temp
   set cmdty_code = cm.cmdty_code,
       mkt_code = cm.mkt_code
   from dbo.commodity_market cm
   where #price_temp.commkt_key = cm.commkt_key

   select commkt_key,
          cmdty_code,
          mkt_code,
          price,
          posted_gravity,
          gravity_source_code,
          gravity_table_name     
   from #price_temp
   order by cmdty_code, mkt_code

end
return
GO
GRANT EXECUTE ON  [dbo].[get_posted_price_rows] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'get_posted_price_rows', NULL, NULL
GO
