SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


create function [dbo].[udf_currency_exch_rate]
(
   @asof_date            datetime = null,    
   @curr_code_from       char(8) = null,
   @curr_code_to         char(8) = null,
   @eff_date             datetime = null,
   @est_final_ind        char(1) = null,
   @trading_prd          char(8) = 'SPOT'
)
returns @rtnvalue table 
(
   conv_rate     numeric(20, 8) null, 
   calc_oper     char(1) null,
   errmsg        varchar(255) null
) 
as
begin
declare @smsg                varchar(255),
        @qdate1              datetime,
        @qdate2              datetime,
        @qdate4              datetime,
        @dt                  datetime,
        @dt1                 datetime,
        @dt2                 datetime,
        @exch_rate           numeric(20, 8),
        @avg_closed_price1   numeric(20, 8),
        @avg_closed_price2   numeric(20, 8),
        @commkt_key          int,
        @price_source_code   char(8),
        @currtime            varchar(30),
        @cmdty_code          char(8),
        @mkt_code            char(8),
        @my_asof_date        datetime,    
        @my_curr_code_from   char(8),
        @my_curr_code_to     char(8),
        @my_eff_date         datetime,
        @my_trading_prd      char(8),
        @calc_oper           char(1)

declare @temp1               table
(
   trading_prd       char(8) null,
   price_quote_date  datetime null,
   real_quote_date   datetime null,
   avg_closed_price  float null
)

   if @curr_code_from is null or
      @curr_code_to is null or
      @asof_date is null or
      @est_final_ind is null
   begin
      insert into @rtnvalue values(null, null, 'NULL argument value provided')
      return
   end

   if UPPER(@est_final_ind) not in ('E', 'F')
   begin
      insert into @rtnvalue values (null, null, 'Invalid argument value for the argument @est_final_ind')
      return
   end

   select @exch_rate = null,
          @calc_oper = null

   if @curr_code_from = @curr_code_to 
   begin
      insert into @rtnvalue values (1.0, 'M', null)
      return
   end

   select @commkt_key = null,
          @price_source_code = null,
          @my_asof_date = @asof_date,    
          @my_curr_code_from = @curr_code_from,
          @my_curr_code_to = @curr_code_to,
          @my_eff_date = @eff_date
    
   if @trading_prd is null
      select @my_trading_prd = 'SPOT'
   else
      select @my_trading_prd = @trading_prd
                   
   if exists (select 1
              from dbo.commodity_market cm, 
                   dbo.commkt_physical_attr cpa
              where cm.cmdty_code = @my_curr_code_from and
                    cm.mkt_code = @my_curr_code_to and 
                    cpa.commkt_key = cm.commkt_key and 
                    cpa.commkt_phy_attr_status = 'A')
      select @commkt_key = commkt_key,
             @cmdty_code = cmdty_code,
             @mkt_code = mkt_code,
             @price_source_code = mtm_price_source_code
      from dbo.commodity_market
      where cmdty_code = @my_curr_code_from and
            mkt_code = @my_curr_code_to
   else
   begin
      if exists (select 1
                 from dbo.commodity_market cm, 
                      dbo.commkt_physical_attr cpa
                 where cm.cmdty_code = @my_curr_code_to and
                       cm.mkt_code = @my_curr_code_from and 
                       cpa.commkt_key = cm.commkt_key and 
                       cpa.commkt_phy_attr_status = 'A')
         select @commkt_key = commkt_key,
                @cmdty_code = cmdty_code,
                @mkt_code = mkt_code,
                @price_source_code = mtm_price_source_code
         from dbo.commodity_market
         where cmdty_code = @my_curr_code_to and
               mkt_code = @my_curr_code_from
   end
 
   if @commkt_key is null
   begin
      insert into @rtnvalue values (null, null, 'Could not find a commkt_key')
      return
   end

   if @price_source_code is null
   begin
      insert into @rtnvalue values (null, null, 'Could not get a price_source_code')
      return
   end
   
getexchrate:
   if UPPER(@est_final_ind) = 'F'
   begin
      /* ******************************************************************* 
          finding a price record which meets the following conditions:
             commkt_key = <commodity_market.commkt_key>
             price_source_code = <commodity_market.mtm_price_source_code>
             trading_prd = <a trading period>
             price_quote_date = @asofdate
         ******************************************************************* */
      select @exch_rate = avg_closed_price
      from dbo.price
      where commkt_key = @commkt_key and
            price_source_code = @price_source_code and
            trading_prd = @my_trading_prd and
            price_quote_date = @my_asof_date

      if @exch_rate is not null
         goto endoffunc

      select @qdate1 = max(price_quote_date)
      from dbo.price
      where commkt_key = @commkt_key and
            price_source_code = @price_source_code and
            trading_prd = @my_trading_prd and
            price_quote_date < @my_asof_date

      if @qdate1 is not null
      begin
         select @exch_rate = avg_closed_price
         from dbo.price
         where commkt_key = @commkt_key and
               price_source_code = @price_source_code and
               trading_prd = @my_trading_prd and
               price_quote_date = @qdate1
      end

      if @exch_rate is not null
         goto endoffunc
         
      if @my_trading_prd <> 'SPOT'
      begin
         -- We could not find an exchange rate for a non-SPOT trading_prd, let's try SPOT
         select @my_trading_prd = 'SPOT'
         goto getexchrate
      end
   end
 
   /* For estimate, we want to locate 2 DAYxxx records which cover the @asof_date
      so that we can use 2 avg_closed_prices to calculate an exchange rate for the
      given @eff_date.
   */       

   if @my_trading_prd = 'SPOT' 
   begin
      select @qdate4 = max(price_quote_date)
      from dbo.price
      where commkt_key = @commkt_key and
            price_source_code = @price_source_code and
            (trading_prd = 'SPOT' or trading_prd like 'DAY%') and
             price_quote_date <= @my_asof_date
   end
   else
   begin
      select @qdate4 = max(price_quote_date)
      from dbo.price
      where commkt_key = @commkt_key and
            price_source_code = @price_source_code and
            trading_prd = @my_trading_prd and
            price_quote_date <= @my_asof_date
   end
   
   if @qdate4 is not null
   begin
      if @my_trading_prd = 'SPOT' 
      begin
         insert into @temp1
            (trading_prd, price_quote_date, real_quote_date, avg_closed_price)
         select trading_prd,
                price_quote_date,
                case when trading_prd = 'SPOT'
                        then price_quote_date
                     else
                        dateadd(day, convert(int, rtrim(substring(trading_prd, 4, 5))), price_quote_date)
                end,
                avg_closed_price
         from dbo.price
         where commkt_key = @commkt_key and
               price_source_code = @price_source_code and
               (trading_prd = 'SPOT' or trading_prd like 'DAY%') and
                price_quote_date = @qdate4
      end
      else
      begin
         insert into @temp1
            (trading_prd, price_quote_date, real_quote_date, avg_closed_price)
         select trading_prd,
                price_quote_date,
                price_quote_date,
                avg_closed_price
         from dbo.price
         where commkt_key = @commkt_key and
               price_source_code = @price_source_code and
               trading_prd = @my_trading_prd and
               price_quote_date = @qdate4
      end
          
      select @dt1 = null,
             @dt2 = null

      -- Scan the temporary table to find an date which is later than @eff_date
      -- If we can find a date which is later than @eff_date, then we can do
      -- interpolation to get an exchange rate for @eff_date, otherwise, we need
      -- to use 2 earlier price records which are closest to @eff_date to do
      -- extrapolation in order to get an exchange rate
      select @dt = min(real_quote_date)
      from @temp1

      while @dt is not null
      begin
         if @dt1 is null
            select @dt1 = @dt

         if @dt > @eff_date   -- Yes, we do find a date which is later than @eff_date, so exit here
         begin
            select @dt1 = @dt2     
            select @dt2 = @dt
            break
         end
 
         select @dt1 = @dt2     
         select @dt2 = @dt
         select @dt = min(real_quote_date)
         from @temp1
         where real_quote_date > @dt    
      end

      if @dt1 is not null
      begin
         select @qdate1 = real_quote_date,
                @avg_closed_price1 = avg_closed_price
         from @temp1
         where real_quote_date = @dt1
      end

      if @dt2 is not null
      begin
         select @qdate2 = real_quote_date,
                @avg_closed_price2 = avg_closed_price
         from @temp1
         where real_quote_date = @dt2
      end
      delete @temp1
      
      /* If we can not find 2 price records whose price_quote_dates
         cover the @eff_date, then check to see if we can find a price
         record for an earlier price_quote_date for the given trading period
      */
      if @dt1 is null or @dt2 is null   -- here, we could not find 2 date points
      begin
         select @exch_rate = avg_closed_price
         from dbo.price
         where commkt_key = @commkt_key and
               price_source_code = @price_source_code and
               trading_prd = @my_trading_prd and
               price_quote_date = @qdate4
         goto endoffunc
      end        
    
      -- Yes, we found 2 date points. So, let's calcuate conversion rate for the effective date using
      -- these 2 date points
      if @qdate1 is not null and
         @qdate2 is not null
         goto calc_exch_rate
   end
   goto endoffunc

/* ***************************************************************** */
calc_exch_rate:
/* ***************************************************************** */
   select @exch_rate = null
   if @qdate1 = @my_eff_date
   begin
      select @exch_rate = @avg_closed_price1
      goto endoffunc
   end
   if @qdate2 = @my_eff_date
   begin
      select @exch_rate = @avg_closed_price2
      goto endoffunc
   end

   declare @delta       numeric(20, 8),
           @numdays1    float,
           @numdays2    float

   if @qdate2 < @my_eff_date  -- extrapolate
   begin     
      select @numdays1 = datediff(Day, @qdate1, @qdate2) * 1.0
      select @numdays2 = datediff(Day, @qdate1, @my_eff_date) * 1.0
      select @delta = (@avg_closed_price2 - @avg_closed_price1) * (@numdays2 / @numdays1)

      select @exch_rate = @avg_closed_price1 + @delta
      goto endoffunc
   end

   if @qdate1 > @my_eff_date  -- extrapolate
   begin     
      select @numdays1 = datediff(Day, @qdate1, @qdate2) * 1.0
      select @numdays2 = datediff(Day, @my_eff_date, @qdate2) * 1.0
      select @delta = (@avg_closed_price2 - @avg_closed_price1) * (@numdays2 / @numdays1)

      select @exch_rate = @avg_closed_price2 - @delta
      goto endoffunc
   end

   select @numdays2 = datediff(Day, @qdate1, @qdate2) * 1.0
   select @numdays1 = datediff(Day, @qdate1, @eff_date) * 1.0
   select @delta = (@avg_closed_price2 - @avg_closed_price1) * (@numdays1 / @numdays2)
   select @exch_rate = @avg_closed_price1 + @delta
   
endoffunc:
   -- ********************************************************
   -- Output Example:
   --   @curr_code_from = 'USD', 
   --   @curr_code_to = 'EUR'
   --
   --     Rate                   divide_multiply_ind 
   --     ---------------------- ------------------- 
   --                 0.82720000  M
   --
   --       It means  1 USD = 0.8272 * EUR
   -- ********************************************************

   if @exch_rate is not null
   begin
      select @calc_oper = case when @my_curr_code_from = @mkt_code and
                                    @my_curr_code_to = @cmdty_code
                                  then 'D'
                               else 'M'
                          end
      insert into @rtnvalue values (@exch_rate, @calc_oper, null)
   end
   else
   begin
      if @my_trading_prd <> 'SPOT'
      begin
         select @my_trading_prd = 'SPOT'
         goto getexchrate
      end 
      insert into @rtnvalue values (null, null, null)
   end
   return
END
GO
GRANT SELECT ON  [dbo].[udf_currency_exch_rate] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[udf_currency_exch_rate] TO [next_usr]
GO
