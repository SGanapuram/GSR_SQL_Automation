SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[get_option_price_rows]
(
   @by_commkt_key          int = null,
   @by_price_source_code   varchar(8) = null,
   @by_price_quote_date    datetime = null,
   @by_earliest_period     varchar(30) = null
)
as
begin
set nocount on
declare @opt_strike_price   float

   if (@by_commkt_key is null) or 
      (@by_price_source_code is null) or 
      (@by_price_quote_date is null) or
      (@by_earliest_period is null) 
      return 4

   create table #price_temp 
   (       
      trading_prd                varchar(8)      not null,
      trading_prd_desc           varchar(40)     null,
      put_call_ind               char(1)         null,
      opt_strike_price           float           null,
      price                      float           null,
      seqnum                     int             null,
      pccode                     char(1)         null
   )
   create unique index price_temp_idx1
        on #price_temp (trading_prd, pccode, opt_strike_price)

   select @opt_strike_price = min(opt_strike_price)
   from dbo.option_strike
   where commkt_key = @by_commkt_key and
         trading_prd LIKE 'SPOT%'

   while @opt_strike_price is not null
   begin    
      insert into #price_temp
      select trading_prd,
          trading_prd_desc,
          'C',
          @opt_strike_price,
          NULL,
          case 
             when trading_prd = 'SPOT' then 0
             else convert(int, substring(trading_prd, 5, 2))
          end,
          'B'
      from dbo.trading_period
      where commkt_key = @by_commkt_key and
            trading_prd LIKE 'SPOT%'


      /* add PUT records for the SPOT periods */
      insert into #price_temp
      select trading_prd,
             trading_prd_desc,
             'P',
             @opt_strike_price,
             NULL,
             case 
                when trading_prd = 'SPOT' then 0
                else convert(int, substring(trading_prd, 5, 2))
             end,
             'A'
      from dbo.trading_period
      where commkt_key = @by_commkt_key and
            trading_prd LIKE 'SPOT%'

      select @opt_strike_price = min(opt_strike_price)
      from dbo.option_strike
      where commkt_key = @by_commkt_key and
            trading_prd LIKE 'SPOT%' and
            opt_strike_price > @opt_strike_price
   end  /* while */
 
   select @opt_strike_price = min(opt_strike_price)
   from dbo.option_strike
   where commkt_key = @by_commkt_key and
         (NOT trading_prd LIKE 'SPOT%' and 
          convert(int, substring(trading_prd, 1, 6)) >= convert(int, @by_earliest_period))

   while @opt_strike_price is not null
   begin    
      /* add CALL records for the FUTURE periods */
      insert into #price_temp
      select trading_prd,
             trading_prd_desc,
             'C',
             @opt_strike_price,
             NULL,
             case
                when substring(trading_prd, 7, 1) = 'W' 
                   then convert(int, (substring(trading_prd, 1, 6) + substring(trading_prd, 8, 1)))
                else convert(int, trading_prd)
             end,
             'B' 
      from dbo.trading_period
      where commkt_key = @by_commkt_key and
            (NOT trading_prd LIKE 'SPOT%' and 
             convert(int, substring(trading_prd, 1, 6)) >= convert(int, @by_earliest_period))


      /* add PUT records for the FUTURE periods */
      insert into #price_temp
      select trading_prd,
             trading_prd_desc,
             'P',
             @opt_strike_price,
             NULL,
             case
                when substring(trading_prd, 7, 1) = 'W' 
                   then convert(int, (substring(trading_prd, 1, 6) + substring(trading_prd, 8, 1)))
                else convert(int, trading_prd)
             end,
             'A' 
      from dbo.trading_period
      where commkt_key = @by_commkt_key and
            (NOT trading_prd LIKE 'SPOT%' and 
             convert(int, substring(trading_prd, 1, 6)) >= convert(int, @by_earliest_period))


      select @opt_strike_price = min(opt_strike_price)
      from dbo.option_strike
      where commkt_key = @by_commkt_key and
            (NOT trading_prd LIKE 'SPOT%' and 
             convert(int, substring(trading_prd, 1, 6)) >= convert(int, @by_earliest_period)) and
            opt_strike_price > @opt_strike_price
   End  /* while */
    

   update #price_temp  
   set price = p.avg_closed_price
   from dbo.option_price p
   where p.commkt_key = @by_commkt_key and
         p.price_source_code = @by_price_source_code and
         p.trading_prd = #price_temp.trading_prd and
         p.opt_strike_price = #price_temp.opt_strike_price and
         p.put_call_ind = #price_temp.put_call_ind and
         p.opt_price_quote_date = @by_price_quote_date

   select trading_prd,
          trading_prd_desc,
          put_call_ind,
          opt_strike_price,
          price
   from #price_temp
   order by seqnum, pccode, opt_strike_price

   drop table #price_temp
end
return
GO
GRANT EXECUTE ON  [dbo].[get_option_price_rows] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'get_option_price_rows', NULL, NULL
GO
