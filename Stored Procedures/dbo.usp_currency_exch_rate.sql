SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_currency_exch_rate]
(
   @asof_date            datetime = null,    
   @curr_code_from       char(8) = null,
   @curr_code_to         char(8) = null,
   @eff_date             datetime = null,
   @est_final_ind        char(1) = null,
   @trading_prd          char(8) = 'SPOT',
   @use_out_args_flag    bit = 0,
   @conv_rate            numeric(20, 8) = null OUTPUT,
   @calc_oper            char(1) = null OUTPUT,
   @debugonoff           bit = 0
)
as
set nocount on
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
        @my_trading_prd      char(8)

   set @exch_rate = null
   if @curr_code_from is null or
      @curr_code_to is null or
      @asof_date is null or
      @est_final_ind is null
   begin
      print 'Usage: exec usp_currency_exch_rate @asof_date = ''?'','
      print '                                   @curr_code_from = ''?'','
      print '                                   @curr_code_to = ''?'','
      print '                                   @eff_date = ''?'','
      print '                                   @est_final_ind = ''?'''
      print '                                   [, trading_prd = ''?'']'
      print '                                   [, @use_out_args_flag = ? ]'
      print '                                   [, @conv_rate OUTPUT ]'
      print '                                   [, @calc_oper OUTPUT ]'
      print '                                   [, @debugonoff = ? ]'
      print '==> You must provide values for the first 4 arguments!'
      return 1
   end

   if UPPER(@est_final_ind) not in ('E', 'F')
   begin
      if @debugonoff = 1
      begin
         print 'The value for @est_final_ind must be either ''E'' or ''F''!'
      end
      goto endofsp1
   end

   select @conv_rate = null,
          @calc_oper = null

   if @debugonoff = 1
   begin
      print 'DEBUG (0): The argument values you gave are:'
      select @smsg = '             @curr_code_from = ''' + rtrim(@curr_code_from) + ''', '
      select @smsg = @smsg + '@curr_code_to = ''' + rtrim(@curr_code_to) + ''''
      print @smsg
      select @smsg = '             @asof_date      = ''' + convert(varchar, @asof_date, 101) + ''', '
      print @smsg
      select @smsg = '             @est_final_ind  = ''' + @est_final_ind + ''','
      print @smsg
      select @smsg = '             @eff_date       = ''' + convert(varchar, @eff_date, 101) + ''''
      print @smsg
      if @trading_prd is not null
      begin
         select @smsg = '             @trading_prd    = ''' + rtrim(@trading_prd) + ''''
         print @smsg
      end
      print ' '
   end

   if @curr_code_from = @curr_code_to 
   begin
      select @exch_rate = 1.0
      goto endofsp1
   end

   if @debugonoff = 1
   begin
      select @smsg = 'DEBUG (1): Getting commkt_key and mtm_price_source_code ...'
      select @smsg = @smsg + convert(varchar, getdate(), 109)
      print @smsg 
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
              from dbo.commodity_market cm with (nolock), 
                   dbo.commkt_physical_attr cpa with (nolock)
              where cm.cmdty_code = @my_curr_code_from and
                    cm.mkt_code = @my_curr_code_to and 
                    cpa.commkt_key = cm.commkt_key and 
                    cpa.commkt_phy_attr_status = 'A')
      select @commkt_key = commkt_key,
             @cmdty_code = cmdty_code,
             @mkt_code = mkt_code,
             @price_source_code = mtm_price_source_code
      from dbo.commodity_market with (nolock)
      where cmdty_code = @my_curr_code_from and
            mkt_code = @my_curr_code_to
   else
   begin
      if exists (select 1
                 from dbo.commodity_market cm with (nolock), 
                      dbo.commkt_physical_attr cpa with (nolock)
                 where cm.cmdty_code = @my_curr_code_to and
                       cm.mkt_code = @my_curr_code_from and 
                       cpa.commkt_key = cm.commkt_key and 
                       cpa.commkt_phy_attr_status = 'A')
         select @commkt_key = commkt_key,
                @cmdty_code = cmdty_code,
                @mkt_code = mkt_code,
                @price_source_code = mtm_price_source_code
         from dbo.commodity_market with (nolock)
         where cmdty_code = @my_curr_code_to and
               mkt_code = @my_curr_code_from
   end

   if @debugonoff = 1
   begin
      select @smsg = 'DEBUG (1): Done ... ' + convert(varchar, getdate(), 109)
      print @smsg
   end
 
   if @commkt_key is null
   begin
      if @debugonoff = 1
      begin
         select @smsg = 'DEBUG (1): Could not locate a commodity_market record for '
         select @smsg = @smsg + rtrim(@curr_code_from) + '/' + rtrim(@curr_code_to) + ' pair!'
         print @smsg
      end
      goto endofsp1
   end

   if @price_source_code is null
   begin
      if @debugonoff = 1
      begin
         print 'DEBUG (1): The mtm_price_source_code in the commodity_market record is NULL!'
      end
      goto endofsp1
   end
   
   if @debugonoff = 1
   begin
      print ' '
      select @smsg = 'DEBUG (2): START getting exchange rate for converting from '''
      select @smsg = @smsg + rtrim(@curr_code_from) + ''' to ''' + rtrim(@curr_code_to) + ''''
      print @smsg
      print ' '
   end

   create table #temp1
   (
      trading_prd       char(8) null,
      price_quote_date  datetime null,
      real_quote_date   datetime null,
      avg_closed_price  float null
   )
   create nonclustered index xx_temp1_idx999
      on #temp1 (real_quote_date)

   if @debugonoff = 1
   begin
      select @smsg = '              commkt_key = ' + convert(varchar, @commkt_key) + ','
      print @smsg
      select @smsg = '              price_source_code = ''' + rtrim(@price_source_code) + ''','
      print @smsg
      select @smsg = '              trading_prd = ''' + rtrim(@my_trading_prd) + ''','
      print @smsg
      select @smsg = '              price_quote_date = ''' + convert(varchar, @my_asof_date, 101) 
      print @smsg
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
      if @debugonoff = 1
      begin
         select @smsg = 'DEBUG (3): Getting a price record for ...'
         select @smsg = @smsg + convert(varchar, getdate(), 109)      
         print @smsg
      end

      select @exch_rate = avg_closed_price
      from dbo.price
      where commkt_key = @commkt_key and
            price_source_code = @price_source_code and
            trading_prd = @my_trading_prd and
            price_quote_date = @my_asof_date

      if @exch_rate is not null
      begin
         if @debugonoff = 1
         begin
            select @smsg = 'DEBUG (3): => YES, an conversion rate ' + convert(varchar, convert(numeric(20, 8), @exch_rate))
            select @smsg = @smsg + '(' + convert(varchar, @my_asof_date, 101) + ') was found!'
            print @smsg
         end
         goto endofsp
      end

      if @debugonoff = 1
      begin
         print 'DEBUG (3): Unable to find a price record!'         
         select @smsg = 'DEBUG (3): Trying to find a price record for a date prior to ''' + convert(varchar, @my_asof_date, 101) + ''' ...' 
         select @smsg = @smsg + convert(varchar, getdate(), 109)      
         print @smsg
      end
      select @qdate1 = max(price_quote_date)
      from dbo.price
      where commkt_key = @commkt_key and
            price_source_code = @price_source_code and
            trading_prd = @my_trading_prd and
            price_quote_date < @my_asof_date

      if @qdate1 is not null
      begin
         if @debugonoff = 1
         begin
            select @smsg = 'DEBUG (3): Found a price record for a date before ''' + convert(varchar, @my_asof_date, 101) + ''' '
            select @smsg = @smsg + 'and trading period is ''' + rtrim(@my_trading_prd) + '''!'
            print @smsg
            select @smsg = '           => The price_quote_date found is ''' + convert(varchar, @qdate1, 101) + '''.'    
            print @smsg
         end
         select @exch_rate = avg_closed_price
         from dbo.price
         where commkt_key = @commkt_key and
               price_source_code = @price_source_code and
               trading_prd = @my_trading_prd and
               price_quote_date = @qdate1

         if @exch_rate is not null
         begin
            if @debugonoff = 1
            begin
               select @smsg = 'DEBUG (3): => YES, an conversion rate ' + convert(varchar, convert(numeric(20, 8), @exch_rate))
               select @smsg = @smsg + '(' + convert(varchar, @qdate1, 101) + ') was found!'
               print @smsg
            end
         end
      end
      else
      begin
         if @debugonoff = 1
         begin
            select @smsg = 'DEBUG (3): Could not find a price record for a date prior to ''' + convert(varchar, @my_asof_date, 101) + '''!' 
            print @smsg
         end
      end
      if @exch_rate is not null
         goto endofsp
      else
      begin
         if @my_trading_prd <> 'SPOT'
         begin
            -- We could not find an exchange rate for a non-SPOT trading_prd, let's try SPOT
            if @debugonoff = 1
            begin
               select @smsg = 'DEBUG (3): Could not find a conversion rate for the trading_prd ''' + rtrim(@my_trading_prd) + '''!'
               print @smsg
               print 'DEBUG (3): Let''s try SPOT ...'
            end
            select @my_trading_prd = 'SPOT'
            goto getexchrate
         end
      end
   end
 
   /* For estimate, we want to locate 2 DAYxxx records which cover the @asof_date
      so that we can use 2 avg_closed_prices to calculate an exchange rate for the
      given @eff_date.
   */       

   if @debugonoff = 1
   begin
      if @my_trading_prd = 'SPOT' 
      begin
         select @smsg = 'DEBUG (3): Getting a price_quote_date closest to ''' + convert(varchar, @my_asof_date, 101) + ''' for SPOT and/or DAYxxx records  ...'
         print @smsg
      end
      else
      begin
         select @smsg = 'DEBUG (3): Getting a price_quote_date closest to ''' + convert(varchar, @my_asof_date, 101) + ''' '
         select @smsg = @smsg + ' for a price record whose trading_prd is ''' + rtrim(@my_trading_prd) + ''' ...'
         print @smsg
      end
   end

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
      if @debugonoff = 1
      begin
         select @smsg = 'DEBUG (3): An earlier price_quote_date ''' + convert(varchar, @qdate4, 101) + ''' was found!'
         print @smsg
         print 'DEBUG (3): Copying all records for the price_quote_date being found to a temporary table ...'
      end
      if @my_trading_prd = 'SPOT' 
      begin
         insert into #temp1
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
         insert into #temp1
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
      
      if @debugonoff = 1
      begin
         print ' '
         select convert(char(15), real_quote_date, 101) 'REAL quote date',
                trading_prd,
                convert(char(15), price_quote_date, 101) 'price_quote_date',
                avg_closed_price
         from #temp1
         order by real_quote_date
         print ' '
      end

      if @debugonoff = 1
      begin
         print 'DEBUG (3): Scanning the temporary table to find 2 date points which'
         print 'DEBUG (3): cover the @eff_date ...'
      end

      select @dt = min(real_quote_date)
      from #temp1
    
      select @dt1 = null,
             @dt2 = null

      -- Scan the temporary table to find an date which is later than @eff_date
      -- If we can find a date which is later than @eff_date, then we can do
      -- interpolation to get an exchange rate for @eff_date, otherwise, we need
      -- to use 2 earlier price records which are closest to @eff_date to do
      -- extrapolation in order to get an exchange rate
      select @dt = min(real_quote_date)
      from #temp1

      while @dt is not null
      begin
         if @dt1 is null
            select @dt1 = @dt

         if @dt > @eff_date   -- Yes, we do find a date which is later than @eff_date, so exit here
         begin
            select @dt1 = @dt2     
            select @dt2 = @dt
            if @debugonoff = 1
            begin
               select @smsg = 'DEBUG (3): dt1 = ' + convert(varchar, @dt1, 101) + ', dt2 = ' + convert(varchar, @dt2, 101)
               print @smsg
            end     
            break
         end
 
         select @dt1 = @dt2     
         select @dt2 = @dt

         if @debugonoff = 1
         begin
            select @smsg = 'DEBUG (3): dt1 = ' + convert(varchar, @dt1, 101) + ', dt2 = ' + convert(varchar, @dt2, 101)
            print @smsg
         end     

         select @dt = min(real_quote_date)
         from #temp1
         where real_quote_date > @dt    
      end

      if @dt1 is not null
      begin
         select @qdate1 = real_quote_date,
                @avg_closed_price1 = avg_closed_price
         from #temp1
         where real_quote_date = @dt1
      end

      if @dt2 is not null
      begin
         select @qdate2 = real_quote_date,
                @avg_closed_price2 = avg_closed_price
         from #temp1
         where real_quote_date = @dt2
      end
      truncate table #temp1
      
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
         goto endofsp
      end        
    
      -- Yes, we found 2 date points. So, let's calcuate conversion rate for the effective date using
      -- these 2 date points
      if @qdate1 is not null and
         @qdate2 is not null
         goto calc_exch_rate
   end
   else
   begin
      if @debugonoff = 1
      begin
         select @smsg = 'DEBUG (3): Could not locate a price record with an earlier price_quote_date ...'
         select @smsg = @smsg + '(' + convert(varchar, @my_asof_date, 101) + ')!'
         print @smsg
         select @smsg = '              commkt_key = ' + convert(varchar, @commkt_key) + ','
         print @smsg
         select @smsg = '              price_source_code = ''' + rtrim(@price_source_code) + ''','
         print @smsg
         if @my_trading_prd = 'SPOT'
            select @smsg = '              trading_prd = ''SPOT'' or ''DAY%'','
         else
            select @smsg = '              trading_prd = ''' + rtrim(@my_trading_prd) + ''','
         print @smsg
         select @smsg = '              price_quote_date <= ''' + convert(varchar, @my_asof_date, 101) + ''''
         print @smsg
      end
   end
   goto endofsp

/* ***************************************************************** */
calc_exch_rate:
/* ***************************************************************** */
   select @exch_rate = null
   if @debugonoff = 1
   begin
      select @smsg = 'DEBUG (4): Calculating an exchange rate using the following 2 date points:'
      print @smsg
      select @smsg = 'DEBUG (4):   (' + convert(varchar, @qdate1, 101) + ') '
      select @smsg = @smsg + convert(varchar, convert(numeric(20, 8), @avg_closed_price1))
      print @smsg
      select @smsg = 'DEBUG (4):   (' + convert(varchar, @qdate2, 101) + ') '
      select @smsg = @smsg + convert(varchar, convert(numeric(20, 8), @avg_closed_price2))
      print @smsg
      print ' '
   end

   if @qdate1 = @my_eff_date
   begin
      if @debugonoff = 1
      begin
         print 'DEBUG (4): The @eff_date is the same as the FIRST date point'
         print 'DEBUG (4): so use the avg_closed_price of the FIRST date point!'
      end
      select @exch_rate = @avg_closed_price1
      goto endofsp
   end
   if @qdate2 = @my_eff_date
   begin
      if @debugonoff = 1
      begin
         print 'DEBUG (4): The @eff_date is the same as the SECOND date point'
         print 'DEBUG (4): so use the avg_closed_price of the SECOND date point!'
      end
      select @exch_rate = @avg_closed_price2
      goto endofsp
   end

   declare @delta       numeric(20, 8),
           @numdays1    float,
           @numdays2    float

   if @qdate2 < @my_eff_date  -- extrapolate
   begin     

      select @numdays1 = datediff(Day, @qdate1, @qdate2) * 1.0
      select @numdays2 = datediff(Day, @qdate1, @my_eff_date) * 1.0
      if @debugonoff = 1
      begin
         print 'DEBUG (4): Performing extrapolation when the eff_date is after the SECOND date point ...'
         select @smsg = 'DEBUG (4): @numdays2  = ' + convert(varchar, convert(numeric(10, 0), @numdays2))
         print @smsg
         select @smsg = 'DEBUG (4): @numdays1  = ' + convert(varchar, convert(numeric(10, 0), @numdays1))
         print @smsg
      end
      select @delta = (@avg_closed_price2 - @avg_closed_price1) * (@numdays2 / @numdays1)

      select @exch_rate = @avg_closed_price1 + @delta
      goto endofsp
   end

   if @qdate1 > @my_eff_date  -- extrapolate
   begin     

      select @numdays1 = datediff(Day, @qdate1, @qdate2) * 1.0
      select @numdays2 = datediff(Day, @my_eff_date, @qdate2) * 1.0
      if @debugonoff = 1
      begin
         print 'DEBUG (4): Performing extrapolation when the eff_date is before the FIRST date point ...'
         select @smsg = 'DEBUG (4): @numdays2  = ' + convert(varchar, convert(numeric(10, 0), @numdays2))
         print @smsg
         select @smsg = 'DEBUG (4): @numdays1  = ' + convert(varchar, convert(numeric(10, 0), @numdays1))
         print @smsg
      end
      select @delta = (@avg_closed_price2 - @avg_closed_price1) * (@numdays2 / @numdays1)

      select @exch_rate = @avg_closed_price2 - @delta
      goto endofsp
   end

   select @numdays2 = datediff(Day, @qdate1, @qdate2) * 1.0
   select @numdays1 = datediff(Day, @qdate1, @eff_date) * 1.0
   if @debugonoff = 1
   begin
      print 'DEBUG (4): Interpolating an exchange rate using two obtained avg_closed_prices  ...'
      select @smsg = 'DEBUG (4): @numdays2  = ' + convert(varchar, convert(numeric(10, 0), @numdays2))
      print @smsg
      select @smsg = 'DEBUG (4): @numdays1  = ' + convert(varchar, convert(numeric(10, 0), @numdays1))
      print @smsg
   end
   select @delta = (@avg_closed_price2 - @avg_closed_price1) * (@numdays1 / @numdays2)
   select @exch_rate = @avg_closed_price1 + @delta
endofsp:
   drop table #temp1

endofsp1:
   if @debugonoff = 1
   begin
      if @exch_rate is not null
      begin
         select @smsg = 'DEBUG (4): @exch_rate = ' + convert(varchar, convert(numeric(20, 8), @exch_rate))
         print @smsg
         print ' '
      end
   end
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
      if @use_out_args_flag = 1
      begin
         select @conv_rate = @exch_rate,
                @calc_oper = case when @my_curr_code_from = @mkt_code and
                                       @my_curr_code_to = @cmdty_code
                                     then 'D'
                                  else 'M'
                             end
      end
      else
      begin
         select @exch_rate 'Rate',
                case when @my_curr_code_from = @mkt_code and
                          @my_curr_code_to = @cmdty_code
                        then 'D'
                     else 'M'
                end 'divide_multiply_ind'
      end
   end
   else
   begin
      if @my_trading_prd <> 'SPOT'
      begin
         select @my_trading_prd = 'SPOT'
         goto getexchrate
      end 
      if @debugonoff = 1
      begin
         select @smsg = 'DEBUG (5): Unable to find a conversion rate!!'
         print @smsg
         print ' '
      end
      if @use_out_args_flag = 0
      begin
         select NULL 'Rate', 
                NULL 'divide_multiply_ind'
      end
   end

return 0
GO
GRANT EXECUTE ON  [dbo].[usp_currency_exch_rate] TO [next_usr]
GO
