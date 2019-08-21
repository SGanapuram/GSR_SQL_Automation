SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[usp_get_fx_data]  

(                                                                                        

   @port_num    int = NULL,                                                                      

   @profit_cntr varchar(100) = NULL,                                                                              

   @debugon     bit = 0                                                                                        

)                                                                                        

as                                                                                         

set nocount on                                                                                        

declare @my_top_port_num   int                                                                                        

declare @smsg              varchar(255)                                                                                        

declare @status            int                                                                                        

declare @errcode           int                                                                                        

declare @asofdate          datetime                                                                                        

declare @pl_asof_date      datetime                                                                  

declare @start_time        varchar(30)      

declare @finish_time       varchar(30)      

declare @rows_affected     int = 0      

                                                                                                                    

   set @my_top_port_num = @port_num                                                                                                                                                                         

   set @status = 0                                                                                        

   set @errcode = 0                                                                                        

   if @my_top_port_num is null                                                                                        

      set @my_top_port_num = 0                                                                                        

                                                                                                                                                                                                                                                  

   create table #children                                                                                        

   (                                                                                        

      port_num int PRIMARY KEY,                                                                                        

      port_type char(2),                                                                                        

   )                                                                                        

                                                                                        

   create table #active_fx_ids                                                                                         

   (                                                                                        

     fx_exp_num int           primary key                                                                             

   )                                                                                        

                                                                             

   create table #fx_dump                                                                                        

  (                                                               

      trader_init          char(3) NULL,                                       

      contr_date     datetime NULL,                                       

      trade_number         varchar(40) null,                           

      trade_num            int NULL,                                                                  

      order_num            int NULL,                                                                   

      item_num             int NULL,                                                    

      trade_key            varchar(50) NULL,                                                                    

      counterparty         varchar(255) NULL,                                                                    

      inhouse_ind          char(1),                                                     

      fx_exp_num           int null,                                                   

      real_port_num        int null,                                                                           

      fx_type              varchar(45) null,                                                                                         

      fx_sub_type          varchar(45) null,                                                                                        

      fx_currency          char(8) null,                                                                                        

      pl_currency          char(8) null,                                                                                        

      trading_prd          varchar(15) null,                                                                       

      exp_date             varchar(15) null,                                                                                        

      year                 char(4) null,                                                                                        

      quarter              char(4) null,                                                                                        

      month                char(4) null,                                                                                        

      day                  char(4) null,                                                  

      total_exp_by_id      decimal(20,8) null,                                                                                        

      fx_amount            decimal(20,8) null,                                                                        

      fx_source            varchar(15) null,                                                                                        

      cost_num             int null,                                                                 

      cost_status          char(8) null,                                                                                    

      cost_type_code       char(8) null,                                                      

      cost_code            char(8) null,                                                                                    

      cost_prim_sec_ind    char(1),                                                                                    

      cost_est_final_ind   char(1),                                                                                    

      conv_rate1           float null,                                                                                    

      calc_oper1           char(1) null,                                                                        

      pl_incl_ind          char(1) NULL,                   

      due_date             datetime null                                                                    

   )        

      

   create nonclustered index xx9181_fx_dump_idx1      

      on #fx_dump (fx_type, fx_source, trade_num, order_num, item_num)      

       include (trade_key,      

       cost_num,       

       real_port_num,       

       fx_amount)      

      

   create nonclustered index xx9181_fx_dump_idx2      

      on #fx_dump (cost_num)      

         

--To store final Query and the apply conv        

   create table #fx_dump_final                                                          

   (                                                               

      Trader            char(3) NULL,                                   

      ContractDate      datetime NULL,                                       

      TradeNum          varchar(40) null,                                                                         

      TradeKey          varchar(50) NULL,                     

      CostNum           int null,                                                           

      Counterparty      varchar(255) NULL,        

      TradeType         char(16) null,                                                                 

      InhouseInd        char(1),          

      FXRiskType        varchar(45) null,                                                                                             

      TradingEntity     varchar(510) null,         

      Book              varchar(16) null,        

      ProfitCntr        varchar(16) null,        

      BookingCompany    varchar(30) null,                 

      PortNum           int null,             

      FXAmount          decimal(20,8) null,                                                                               

      Currency          char(8) null,                                                                                        

      BookCurrencyEquiv decimal(30,8) null,        

      BookCurrency      char(8) null,         

      Month             varchar(30) null,       

      Qtr               varchar(32) null,         

      YEAR              varchar(30) null,         

      ExpDate           varchar(30) null,                                                                                              

      TradingPrd        varchar(15) null,                                                                                                              

      ExpId             decimal(20,8) null,                                                                                                                                                            

      FxSource          varchar(15) null,                                                                                                                                                     

      CostStatus        char(8) null,                                                                                    

      CostType          char(8) null,                                                      

      cost_code         char(8) null,                                                                                                     

      OrignalDueDate    datetime null                                                                                                                                                         

   )         

        

   --Temp table to store priceCmdtyCode, primaryCuryCode and conv rate from priceCmdtyCode to primaryCuryCode        

   create table #cmdtyCurrToPrimaryCurrConvTable         

   (        

      ID1                 int IDENTITY(1,1) PRIMARY KEY,        

      cmdty_code          char(8),        

      prim_curr_code      char(8),        

      prim_curr_conv_rate float(8)        

   )                

      

   create table #allExpDatesQuoteAsTradeCurr      

   (      

   trade_num           int null,      

   order_num           int null,      

   item_num            int null,      

   accum_num           int null,      

   price_curr_code     char(8) null,      

   price_quote_date    datetime null,      

   real_port_num       int null,      

   amtSign             int null      

   )      

                                                     

   create nonclustered index xx0189_allExpDatesQuoteAsTradeCurr_idx1      

      on #allExpDatesQuoteAsTradeCurr (trade_num, order_num, item_num, accum_num, price_curr_code)      

      

   create nonclustered index xx0189_allExpDatesQuoteAsTradeCurr_idx2      

      on #allExpDatesQuoteAsTradeCurr (real_port_num)      

        include (trade_num, order_num, item_num, accum_num, price_curr_code)      

         

   if @my_top_port_num > 0                                                            

   begin                                                                                                                         

      begin try                                              

        exec dbo.usp_get_child_port_nums @my_top_port_num, 1                                                                                        

      end try                             

      begin catch                                                                                        

        set @smsg = ERROR_MESSAGE()                                                                               

        set @errcode = ERROR_NUMBER()                                                                                        

        RAISERROR('=> Failed to execute the ''usp_get_child_port_nums'' sp due to the following error:', 0, 1) with nowait                                                                                       

        RAISERROR('==> ERROR %d: %s', 0, 1, @errcode, @smsg) with nowait                                                          

        goto errexit                                                                                

      end catch                                                                                        

   end                                          

                                                            

   if @debugon = 1      

   begin      

      declare @portfolio_hierarchy_size   int = 0      

      

      set @portfolio_hierarchy_size = (select count(*) from #children)      

   RAISERROR('There are %d portfolioes in portfolio hierarchy leading by %d', 0, 1, @portfolio_hierarchy_size, @my_top_port_num) with nowait      

   select * from #children order by port_num      

   end      

                                                               

   if @my_top_port_num = 0 and       

      @profit_cntr is not null                                         

   begin                                                                                                                    

      begin try                                                                                                                        

        insert into #children                                                            

          select port_num, 'R'       

    from dbo.portfolio_tag with (nolock)      

    where tag_name = 'PRFTCNTR' and       

          tag_value = @profit_cntr and       

       port_num in (select port_num       

                 from dbo.portfolio with (nolock)       

        where port_type = 'R')       

        set @rows_affected = @@rowcount              

      end try                                                                                        

      begin catch                                

        set @smsg = ERROR_MESSAGE()                                                                               

        set @errcode = ERROR_NUMBER()                                                                                        

     RAISERROR('=> Failed to get real-level portfolioes from the portfolio_tag view for the given profit center ''%s'' due to the following error:', 0, 1, @profit_cntr) with nowait                                                                          


  

    

              

        RAISERROR('==> ERROR %d: %s', 0, 1, @errcode, @smsg) with nowait      

        goto errexit                                   

      end catch                                                                                        

   end                                                        

                                

   if @debugon = 1           

      set @start_time = convert(varchar, getdate(), 109)      

   begin try                                                                          

     insert into #active_fx_ids                                            

       select fe.oid                                                                                       

       from dbo.fx_exposure fe                                                                                        

       where exists (select 1      

                  from #children t1       

            where fe.real_port_num = t1.port_num) and      

 isnull(status, 'N') <> 'N'                                                                                        

       set @rows_affected = @@rowcount              

   end try                                                                          

   begin catch                                                                                        

     set @smsg = ERROR_MESSAGE()                                                                               

     set @errcode = ERROR_NUMBER()                                                                                        

  RAISERROR('=> Failed to get list of active fx oids due to the following error:', 0, 1) with nowait                                                                                        

     RAISERROR('==> ERROR %d: %s', 0, 1, @errcode, @smsg) with nowait      

     goto errexit                                                                                        

   end catch                                                                             

            

   if @debugon = 1           

   begin            

      set @finish_time = convert(varchar, getdate(), 109)      

      RAISERROR('Fetching active OIDs from the fx_exposure table ...', 0, 1) with nowait      

      RAISERROR('          Start  Time : %s', 0, 1, @start_time) with nowait      

      RAISERROR('          Finish Time : %s', 0, 1, @finish_time) with nowait      

      RAISERROR('          Rows Fetched: %d', 0, 1, @rows_affected) with nowait      

   end      

         

   if @rows_affected = 0      

   begin      

      if @my_top_port_num > 0      

         RAISERROR('No active fx_exposure records found for the given portfolio #%d', 0, 1, @my_top_port_num) with nowait      

   else      

   begin      

      if @profit_cntr is not null      

            RAISERROR('No active fx_exposure records found for the give profit center ''%s''', 0, 1, @profit_cntr) with nowait         

   end      

   set @errcode = 0      

   goto exit1      

   end      

         

   begin try                                                                                            

     if @debugon = 1           

        set @start_time = convert(varchar, getdate(), 109)      

     insert into #fx_dump                                                                          

     select                                     

        t.trader_init,                                                                

        contr_date,                                                                    

        convert(varchar, fed.trade_num),                                                                   

        fed.trade_num,                                                                  

        fed.order_num,                                                                  

        fed.item_num,                                    

        convert(varchar, fed.trade_num) + '-' +       

      convert(varchar, fed.order_num) + '-' +       

      convert(varchar, fed.item_num) 'trade_key',                                                                          

        acc.acct_short_name,                                                                    

        inhouse_ind,                                                                    

        fe.oid,           

        fe.real_port_num,                                              

        case fx_exposure_type                                                                                       

           when 'P' then 'Primary'                                                                                       

           when 'SW' then 'Swap Curr Hedge' --Swap should be in primary                                                       

           when 'C' then 'Forex'                                                                                      

           when 'F' then 'Future Curr Exp'                                                                                      

           when 'PP' then 'PricingP'                                                                      

           when 'PR' then 'Premium'                                              

           when 'FD' then 'Premium'                                                                                      

           when 'S' then 'Other'                                                                                   

           else 'GasPower'                          

        end as fx_type,                                                                  

        case fx_exposure_type                                                                                       

           when 'P' then 'Primary'                                                                                       

           when 'SW' then 'Swap Curr Exp' --Swap should be in primary                                                                                      

           when 'C' then 'Forex'                                                                                      

           when 'F' then 'Future Curr Exp'                                                                            

           when 'PP' then 'PricingP'                                                                                      

           when 'PR' then 'Premium'                                                                                      

           when 'FD' then 'Premium'                                                  

           when 'S' then 'Other'                                                                                      

           else 'INVALID'                                                                       

        end as fx_sub_type,                                                                                      

        price_curr_code,                                                                                        

        pl_curr_code,                                                                                        

        fx_trading_prd,                                                 

        case when fx_drop_date is not null       

          then fx_drop_date                                                                         

             when fx_drop_date is null and       

         fx_trading_prd = 'SPOT'       

    then convert(char,getdate(),101)                                                                                      

             else       

       convert(varchar, convert(datetime, substring(fx_trading_prd, 13, len(fx_trading_prd) - 12) + ' ' +      

       substring(fx_trading_prd, 9, 3) + ' ' + substring(fx_trading_prd, 1, 4), 106), 101)                                                                                 

        end 'exp_date',                                                                                  

 null,                                                                                 

        null,                                                                                        

        null,                                                                                        

        null,                                                                                        

     open_rate_amt,                                                                                        

        isnull(fx_amt, 0) - isnull(fx_priced_amt, 0),                                                                                        

        'FXEXPDIST',                                                                                        

        fx_owner_key4,                                                     

        null,                           

       null,                                                                                    

        null,                                                                                    

        null,                                                                                    

        'E',                                              

        null,                                                                                    

        null,                                                                        

      'Y',           

  NULL                

     from dbo.fx_exposure fe                                      

             join dbo.fx_exposure_dist fed       

       on fed.fx_exp_num = fe.oid and fed.fx_owner_code<>'QP'                                                                                      

             join dbo.fx_exposure_currency fec       

       on fec.oid = fx_exp_curr_oid                                                                       

             left outer join dbo.trade t       

       on t.trade_num = fed.trade_num                                                                    

             left outer join dbo.account acc       

       on acc.acct_num = t.acct_num       

  where exists (select 1      

                from #active_fx_ids t1      

       where fe.oid = t1.fx_exp_num)      

     set @rows_affected = @@rowcount                                                                   

     if @debugon = 1           

     begin            

        set @finish_time = convert(varchar, getdate(), 109)      

        RAISERROR('Filling the #fx_dump table (1) ...', 0, 1) with nowait      

        RAISERROR('          Start  Time : %s', 0, 1, @start_time) with nowait      

        RAISERROR('          Finish Time : %s', 0, 1, @finish_time) with nowait      

        RAISERROR('          Rows Fetched: %d', 0, 1, @rows_affected) with nowait      

     end             

      

     if @debugon = 1           

        set @start_time = convert(varchar, getdate(), 109)      

     insert into #fx_dump                                                                                            

     select                                                                      

        c.creator_init,                                                              

        c.creation_date,                                                                    

        convert(varchar, isnull(cost_owner_key6, c.cost_num)),                                      

        cost_owner_key6,                                                                  

        cost_owner_key7,                                                                  

        cost_owner_key8,                                                                  

        convert(varchar, isnull(cost_owner_key6, c.cost_num)) + '-' +      

     convert(varchar, cost_owner_key7) + '-' + convert(varchar, cost_owner_key8),                                                                            

        acc.acct_short_name,                                                                    

        'N',                                                                    

        fe.oid,                                                                                        

        fe.real_port_num,                                                                    

        case fx_exposure_type                                                                          

           when 'P' then 'Primary'                                                                              

           when 'SW' then 'Swap Curr Hedge' --Swap should be in primary                                                                                      

           when 'C' then 'Forex'                                                                                      

           when 'F' then 'Future Curr Exp'                                                                                      

           when 'PP' then 'PricingP'                              

           when 'PR' then 'Premium'                                  

           when 'FD' then 'Premium'                                                                                      

           when 'S' then 'Other'                                                                                   

           else 'GasPower'                                                                                      

        end as fx_type,                                                                                      

        case fx_exposure_type                                     

           when 'P' then 'Primary'                                                                                       

           when 'SW' then 'Swap Curr Exp' --Swap should be in primary                                                                                      

           when 'C' then 'Forex'                                                                                      

           when 'F' then 'Future Curr Exp'                                                                                      

           when 'PP' then 'PricingP'               

           when 'PR' then 'Premium'                                                                                      

           when 'FD' then 'Premium'                                                                                      

           when 'S' then 'Other'                                    

           else 'INVALID'                                            

        end as fx_sub_type,                                                                                      

        price_curr_code,                                                                                        

        pl_curr_code,                                                           

        fx_trading_prd,                                                                                        

        case       

     when fx_trading_prd = 'SPOT'         

        then convert(char,getdate(),101)                                                                                      

           else convert(varchar, convert(datetime, substring(fx_trading_prd, 13, len(fx_trading_prd) - 12) + ' ' +      

         substring(fx_trading_prd, 9, 3) + ' ' + substring(fx_trading_prd, 1, 4), 106), 101)                                                 

        end 'exp_date',                                                    

        null,                                                                                        

        null,                                                                                        

        null,                                                                                        

        null,                                                                                        

  open_rate_amt,                                                                                  

        (isnull(cost_amt, 0) * (case cost_pay_rec_ind when 'P' then -1 else 1 end)),          

        'COST',                                                                                        

        c.cost_num,                                                                                    

        c.cost_status,                                                                                    

        c.cost_type_code,                                                     

        c.cost_code,                                          

        c.cost_prim_sec_ind,                                                                                    

        c.cost_est_final_ind,                                                                                    

        null,                                                                                    

        null,                                                                        

        'Y',       

  cost_due_date                             

     from dbo.fx_exposure fe                                                                                        

             join dbo.cost_ext_info cei       

       on cei.fx_exp_num = fe.oid and       

       cei.cost_pl_contribution_ind = 'Y'                                                                                          

             join dbo.cost c       

       on cei.cost_num = c.cost_num                                                                                        

             join dbo.fx_exposure_currency fec       

       on fec.oid = fx_exp_curr_oid                                       

             left outer join dbo.account acc       

       on acc.acct_num = c.acct_num                                                                    

     where exists (select 1      

                from #active_fx_ids t1      

       where fe.oid = t1.fx_exp_num) and      

        abs(c.cost_amt) >= 0.001 and       

        c.cost_status not in ('PAID', 'HELD', 'CLOSED') and       

     cost_type_code not in ('INVROLL') and       

     not exists (select 1       

                 from dbo.pdfx_detail pdfx       

        where pdfx.cost_num = c.cost_num)                                                    

     set @rows_affected = @@rowcount                                                                   

     if @debugon = 1           

     begin            

        set @finish_time = convert(varchar, getdate(), 109)      

        RAISERROR('Filling the #fx_dump table (2) ...', 0, 1) with nowait      

        RAISERROR('          Start  Time : %s', 0, 1, @start_time) with nowait      

        RAISERROR('          Finish Time : %s', 0, 1, @finish_time) with nowait      

        RAISERROR('          Rows Fetched: %d', 0, 1, @rows_affected) with nowait      

     end           

            

     ----- add #fx_dump for PricingP where primary is in the #fx_dump but no PricingP      

     if @debugon = 1           

        set @start_time = convert(varchar, getdate(), 109)      

     insert into #allExpDatesQuoteAsTradeCurr      

     select  distinct       

     qp1.trade_num,      

  qp1.order_num,      

  qp1.item_num,      

  qp1.accum_num,       

  qp1.price_curr_code,       

  qp1.price_quote_date,       

  fd.real_port_num,       

  -1 * fd.fx_amount / abs(fx_amount)            

     from (select distinct       

           trade_key,      

     cost_num,       

     trade_num,       

     order_num,       

     item_num,       

     fx_type,       

     real_port_num,       

     fx_source,       

     fx_amount       

     from #fx_dump       

     where fx_type = 'Primary' and       

           fx_source = 'COST'  and cost_type_code not in ('PR','PO')) fd       

             inner join dbo.trade_item ti       

       on ti.trade_num = fd.trade_num and       

       ti.order_num = fd.order_num and       

       ti.item_num = fd.item_num      

    inner join dbo.portfolio p       

       on p.port_num = ti.real_port_num      

    inner join dbo.accumulation acc       

       on acc.trade_num = ti.trade_num and       

       acc.order_num = ti.order_num and       

       acc.item_num = ti.item_num   and acc.accum_creation_type not in ('M','e','a')      

    inner join dbo.quote_pricing_period qpp1       

       on qpp1.trade_num = ti.trade_num and       

       qpp1.order_num = ti.order_num and       

       qpp1.item_num = ti.item_num and       

       qpp1.accum_num = acc.accum_num and       

       qpp1.price_curr_code != p.desired_pl_curr_code and qpp1.price_curr_code=ti.price_curr_code      

   inner join dbo.quote_price qp1       

      on qp1.trade_num = qpp1.trade_num and       

         qp1.order_num = qpp1.order_num and       

      qp1.item_num = qpp1.item_num and       

      qp1.accum_num = qpp1.accum_num and qp1.price_curr_code = qpp1.price_curr_code       

     where fd.fx_type = 'Primary'       

        

     set @rows_affected = @@rowcount                                                                   

     if @debugon = 1           

     begin            

        set @finish_time = convert(varchar, getdate(), 109)      

        RAISERROR('Filling the #allExpDatesQuoteAsTradeCurr table ...', 0, 1) with nowait      

        RAISERROR('          Start  Time : %s', 0, 1, @start_time) with nowait      

        RAISERROR('          Finish Time : %s', 0, 1, @finish_time) with nowait      

        RAISERROR('          Rows Fetched: %d', 0, 1, @rows_affected) with nowait      

     end          

      

     if @debugon = 1           

        set @start_time = convert(varchar, getdate(), 109)      

     insert into #fx_dump      

     select       

     t.trader_init,       

  t.contr_date,       

  convert(varchar, ti.trade_num),                                                                   

        ti.trade_num,       

  ti.order_num,       

  ti.item_num,                                    

        convert(varchar, ti.trade_num) + '-' +       

     convert(varchar, ti.order_num) + '-' +      

        convert(varchar, ti.item_num) 'trade_key',                                                                          

        acc.acct_short_name,       

  t.inhouse_ind,       

  null,                                                             

        ti.real_port_num,        

  'PricingP',       

  'PricingP',      

     qppC.price_curr_code as fx_currency,      

     p.desired_pl_curr_code as pl_currency,               

     convert(varchar, datepart(year, qppC.price_quote_date)) + '|' +       

       case when datepart(month, qppC.price_quote_date) in (1,2,3) then 'Q1'      

         when datepart(month, qppC.price_quote_date) in (4,5,6) then 'Q2'      

         when datepart(month, qppC.price_quote_date) in (7,8,9) then 'Q3'      

         else 'Q4'       

    end +'|' +      

       case when datepart(month, qppC.price_quote_date) = 1 then 'Jan'      

            when datepart(month, qppC.price_quote_date) = 2 then 'Feb'      

            when datepart(month, qppC.price_quote_date) = 3 then 'Mar'      

            when datepart(month, qppC.price_quote_date) = 4 then 'Apr'      

            when datepart(month, qppC.price_quote_date) = 5 then 'May'      

            when datepart(month, qppC.price_quote_date) = 6 then 'Jun'      

            when datepart(month, qppC.price_quote_date) = 7 then 'Jul'      

            when datepart(month, qppC.price_quote_date) = 8 then 'Aug'      

            when datepart(month, qppC.price_quote_date) = 9 then 'Sep'      

            when datepart(month, qppC.price_quote_date) = 10 then 'Oct'      

            when datepart(month, qppC.price_quote_date) = 11 then 'Nov'      

            else 'Dec'       

    end + '|' + convert(varchar, datepart(day, qppC.price_quote_date)) as trading_prd,       

     convert(varchar(15), qppC.price_quote_date,101) as  exp_date,      

     null,                                                                                 

        null,                                                                                        

        null,                                                                                        

        null,                                                                                        

        qppC.total_price / isnull((qppNum.numQuotes), 1),                                                                                        

        qppC.total_price / isnull((qppNum.numQuotes), 1),                    

        'TEMPFXDIST',                                                                                        

        1,                                                      

        null,                           

        null,                                                                                    

        null,                                                                                    

        null,                                                                                    

        'E',                                              

        null,                                                                                    

        null,                                                                        

        'Y',           

  NULL                   

     from (select distinct       

   trade_key,       

     trade_num,       

     order_num,       

     item_num,       

     fx_type       

     from #fx_dump       

     where fx_type = 'Primary' and       

           fx_source = 'COST' and cost_type_code not in ('PR','PO')) fd       

             inner join dbo.trade_item ti       

       on ti.trade_num = fd.trade_num and       

       ti.order_num = fd.order_num and       

       ti.item_num = fd.item_num      

             inner join dbo.portfolio p       

       on p.port_num = ti.real_port_num      

             inner join (select distinct       

                   qpp1.trade_num,      

       qpp1.order_num,      

       qpp1.item_num,      

       qpp1.accum_num,       

       qp1.price_quote_date,       

       qp1.price_curr_code,       

       acc.total_price * ti.amtSign as total_price      

                from #allExpDatesQuoteAsTradeCurr ti      

                        inner join dbo.portfolio p       

            on p.port_num = ti.real_port_num      

                        inner join accumulation acc       

            on acc.trade_num = ti.trade_num and       

            acc.order_num = ti.order_num and       

            acc.item_num = ti.item_num and acc.item_num = ti.item_num    and acc.accum_creation_type not in ('M','e','a')      

                        inner join dbo.quote_pricing_period qpp1       

            on qpp1.trade_num = ti.trade_num and       

            qpp1.order_num = ti.order_num and       

            qpp1.item_num = ti.item_num and       

                           qpp1.accum_num = acc.accum_num and       

            qpp1.price_curr_code != p.desired_pl_curr_code and       

            qpp1.price_curr_code = ti.price_curr_code      

                        inner join dbo.quote_price qp1       

            on qp1.trade_num = qpp1.trade_num and       

            qp1.order_num = qpp1.order_num and       

            qp1.item_num = qpp1.item_num and       

            qp1.accum_num = qpp1.accum_num and       

            qp1.qpp_num = qpp1.qpp_num  and       

            qp1.price_curr_code=qpp1.price_curr_code      

                where qp1.price_quote_date >  convert(varchar(15),isnull(acc.last_pricing_as_of_date,dateadd(dd,-1,getdate())),101)) qppC       

       on qppC.trade_num = ti.trade_num and       

             qppC.order_num = ti.order_num and       

          qppC.item_num = ti.item_num       

             inner join (select       

                         trade_num,      

             order_num,      

             item_num,       

             accum_num,      

             price_curr_code,       

             count(1) as numQuotes       

                         from #allExpDatesQuoteAsTradeCurr       

             group by trade_num, order_num, item_num, accum_num, price_curr_code) qppNum       

           on qppNum.trade_num = ti.trade_num and       

              qppNum.order_num = ti.order_num and       

           qppNum.item_num = ti.item_num and       

     qppC.accum_num = qppNum.accum_num      

             left outer join dbo.trade t       

             on t.trade_num = ti.trade_num                                                                    

             left outer join dbo.account acc       

             on acc.acct_num = t.acct_num      

     where fd.fx_type = 'Primary'        

                 

     set @rows_affected = @@rowcount                                                                   

     if @debugon = 1           

     begin            

        set @finish_time = convert(varchar, getdate(), 109)      

        RAISERROR('Filling the #fx_dump table (3) ...', 0, 1) with nowait      

        RAISERROR('          Start  Time : %s', 0, 1, @start_time) with nowait      

        RAISERROR('          Finish Time : %s', 0, 1, @finish_time) with nowait      

        RAISERROR('          Rows Fetched: %d', 0, 1, @rows_affected) with nowait      

     end           

            

      

   ----- end add #fx_dump for PricingP where primary is in #fx_dump but no PricingP           

     if @debugon = 1           

        set @start_time = convert(varchar, getdate(), 109)      

     insert into #fx_dump            

     select       

        creator_init,                                                  

        creation_date,                                                                    

        c.cost_num,                                                                    

        cost_owner_key6,                                                                  

        cost_owner_key7,                                                                   

        cost_owner_key8,                                                                  

        convert(varchar, isnull(cost_owner_key6, c.cost_num)) + '-' +      

        convert(varchar, cost_owner_key7) + '-' +      

        convert(varchar, cost_owner_key8),                                                                      

        cpty.acct_short_name,                                                                    

        'N',                                                                    

        c.cost_num,                                                                    

        c.port_num,                                                                    

        'Forex',                  

        'Forex',                             

        cost_price_curr_code,                                                                    

        isnull(cost_book_curr_code, 'USD'),                                                                    

        case when isnull(cost_paid_date, cost_due_date)>= convert(char,getdate(), 101)       

       then       

       convert(varchar, datepart(yyyy, isnull(cost_paid_date, cost_due_date)))                                                      

                     + '|' + 'Q' + convert(varchar, datepart(qq,isnull(cost_paid_date, cost_due_date)))                       

                     + '|' + convert(varchar(3), datename(mm,isnull(cost_paid_date, cost_due_date)))                                                      

                     + '|' + convert(varchar(2), datepart(dd,isnull(cost_paid_date, cost_due_date)))                                      

             else 'SPOT'                                                       

        end 'trading_prd',                                                                    

        convert(char, isnull(cost_paid_date, cost_due_date), 101),                                                       

        'PAID',                                                                                 

        'PAID',                                                                                        

        'PAID',                                                                                        

        'PAID',                                                                                        

        NULL,                                                                      

        case when cost_pay_rec_ind = 'P' then -1       

          else 1       

     end * cost_amt,                                                                      

     'COST',                                                  

        c.cost_num,                                                                                    

        c.cost_status,                                                                                    

        c.cost_type_code,                                                                                    

        c.cost_code,                                                                                    

        c.cost_prim_sec_ind,                                                               

        c.cost_est_final_ind,                                                                  

        null,                                                                                    

        null,                                                                        

        'Y',             

     cost_due_date                                                         

     from dbo.cost c with (NOLOCK)                                             

       inner join dbo.portfolio port        

          ON port.port_num = c.port_num and       

          c.cost_price_curr_code <> desired_pl_curr_code                                           

             inner join dbo.cost_ext_info cei       

          ON cei.cost_num = c.cost_num and       

          cei.cost_pl_contribution_ind = 'Y'                                                

             left outer join dbo.commodity cmdty       

          ON cmdty.cmdty_code = c.cost_price_curr_code                                                                    

             left outer join dbo.account cpty       

         ON cpty.acct_num = c.acct_num                                                                    

     where cost_amt != 0 and       

           cost_type_code in ('CPR', 'CPP') and       

     cost_status in ('VOUCHED', 'OPEN') and       

     c.port_num in (select port_num       

                    from #children) and       

           exists (select 1       

             from dbo.cost_ext_info cei       

       where isnull(fx_exp_num, 0) = 0 and       

             cei.cost_num = c.cost_num)                                                              

     set @rows_affected = @@rowcount            

     if @debugon = 1           

     begin            

        set @finish_time = convert(varchar, getdate(), 109)      

        RAISERROR('Filling the #fx_dump table (4) ...', 0, 1) with nowait      

        RAISERROR('          Start  Time : %s', 0, 1, @start_time) with nowait      

        RAISERROR('          Finish Time : %s', 0, 1, @finish_time) with nowait      

        RAISERROR('          Rows Fetched: %d', 0, 1, @rows_affected) with nowait      

     end          

                               

     --Logic to include PAID costs that are not part of PDFX                          

     if @debugon = 1           

        set @start_time = convert(varchar, getdate(), 109)      

     insert into #fx_dump                                                                      

     select       

        creator_init,                                                                    

        creation_date,                                                                    

        c.cost_num,                                                   

        cost_owner_key6,                                                                  

        cost_owner_key7,                                                                   

        cost_owner_key8,                                                                  

        convert(varchar, isnull(cost_owner_key6, c.cost_num)) + '-' +      

       convert(varchar, cost_owner_key7) + '-' +       

        convert(varchar, cost_owner_key8),                                                                      

        cpty.acct_short_name,                                                                    

        'N',                                                                    

c.cost_num,                                         

        c.port_num,                                                                    

        case when cost_prim_sec_ind = 'S' then 'Secondary'                                                                 

             when cost_type_code in ('CPR','CPP') then 'Forex'                                                                

             else 'Primary'       

        end,                                                                    

        case when cost_prim_sec_ind='S' then 'Secondary'                                                                 

             when cost_type_code in ('CPR','CPP') then 'Forex'                                                                

             else 'Primary'       

     end,                                                                    

        cost_price_curr_code,                                                                    

        isnull(cost_book_curr_code, 'USD'),           

     case when cost_paid_date >= convert(char, getdate(), 101)       

             then       

       convert(varchar, datepart(yyyy, cost_paid_date))                                                      

                      + '|' + 'Q' + convert(varchar,datepart(qq, cost_paid_date))                                                       

                      + '|' + convert(varchar(3), datename(mm, cost_paid_date))                                                      

                      + '|' + convert(varchar(2), datepart(dd, cost_paid_date))                                                       

            else 'SPOT'                                                       

        end 'trading_prd',                                                                    

        convert(char, cost_paid_date, 101),                                                                      

        'PAID',                                                                                   

        'PAID',                             

        'PAID',                                                                                     

        'PAID',                                                                                        

        NULL,                                                                      

        case when cost_pay_rec_ind = 'P' then -1       

          else 1       

     end * cost_amt,                      

        'COST',                                                                   

        c.cost_num,                                                                                    

        c.cost_status,                                                                                    

        c.cost_type_code,                               

        c.cost_code,                              

        c.cost_prim_sec_ind,                                                    

        c.cost_est_final_ind,                                                                                    

        null,                                                                                    

        null,                                                                        

        'Y',      

     c.cost_due_date                  

     from dbo.cost c with (NOLOCK)                                               

             inner join dbo.voucher_cost vc       

          on vc.cost_num = c.cost_num                                

             inner join dbo.voucher v       

          on v.voucher_num = vc.voucher_num                                

             inner join dbo.portfolio port        

          on port.port_num = c.port_num and       

          c.cost_price_curr_code <> desired_pl_curr_code                                            

             inner join dbo.cost_ext_info cei       

          on cei.cost_num = c.cost_num and       

          cei.cost_pl_contribution_ind = 'Y'                                                               

             left outer join dbo.commodity cmdty       

          on cmdty.cmdty_code = c.cost_price_curr_code                                 

       left outer join dbo.account cpty       

          on cpty.acct_num = c.acct_num                                                                    

     where cost_amt <> 0 and       

           exists (select 1       

             from #children ch      

       where c.port_num = ch.port_num) and       

     (cost_status = 'PAID') and       

     not exists (select 1       

                 from dbo.pdfx_detail pdfx       

        where pdfx.cost_num = c.cost_num) and       

     not exists (select 1       

                 from #fx_dump f       

        where c.cost_num = f.cost_num) and       

     exists (select 1       

             from dbo.voucher_payment vp       

       where vp.voucher_num = v.voucher_num and       

             voucher_pay_amt <> 0 and       

          processed_date >= '08/06/2013')                

     set @rows_affected = @@rowcount                                                                   

     if @debugon = 1           

     begin            

        set @finish_time = convert(varchar, getdate(), 109)      

        RAISERROR('Filling the #fx_dump table (5) ...', 0, 1) with nowait      

        RAISERROR('          Start  Time : %s', 0, 1, @start_time) with nowait      

        RAISERROR('          Finish Time : %s', 0, 1, @finish_time) with nowait      

        RAISERROR('          Rows Fetched: %d', 0, 1, @rows_affected) with nowait      

     end          

      

                                                   

     --Logic to include VOUCHED costs that are not part of PDFX                     

     if @debugon = 1           

        set @start_time = convert(varchar, getdate(), 109)      

     insert into #fx_dump                                                                      

     select       

        creator_init,                                                                    

        creation_date,                                                                    

        c.cost_num,                                                   

        cost_owner_key6,                                                                  

        cost_owner_key7,                                                                   

        cost_owner_key8,                                                                  

        convert(varchar, isnull(cost_owner_key6, c.cost_num)) + '-' +      

       convert(varchar, cost_owner_key7) + '-' +      

       convert(varchar, cost_owner_key8),                  

        cpty.acct_short_name,                                                                    

        'N',                                                                    

        c.cost_num,                

        c.port_num,                                                   

        case when cost_prim_sec_ind = 'S' then 'Secondary'                                                                 

             when cost_type_code in ('CPR','CPP') then 'Forex'                                                                

             else 'Primary'       

     end,                                                                    

        case when cost_prim_sec_ind='S' then 'Secondary'                                                                 

             when cost_type_code in ('CPR','CPP') then 'Forex'                                                                

             else 'Primary'       

     end,                                                                    

        cost_price_curr_code,                                                                    

        isnull(cost_book_curr_code, 'USD'),                       

        case when isnull(cost_paid_date, cost_due_date)>= convert(char, getdate(), 101)       

       then       

       convert(varchar, datepart(yyyy, isnull(cost_paid_date, cost_due_date)))                                                      

                    + '|' + 'Q' + convert(varchar, datepart(qq, isnull(cost_paid_date, cost_due_date)))                                                       

                    + '|' + convert(varchar(3), datename(mm, isnull(cost_paid_date, cost_due_date)))                                                      

                    + '|' + convert(varchar(2), datepart(dd, isnull(cost_paid_date, cost_due_date)))                                                       

             else 'SPOT'                                                       

        end 'trading_prd',                                                                    

        convert(char, isnull(cost_paid_date, cost_due_date), 101),                                                                      

        'PAID',                                                                                        

        'PAID',                                                                                        

        'PAID',                                                                                     

        'PAID',                                                                                        

        NULL,                        

        case when cost_pay_rec_ind = 'P' then -1       

          else 1       

     end * cost_amt,                      

        'COST',                                                                    

        c.cost_num,                                                                                    

        c.cost_status,                                                                                    

        c.cost_type_code,                                                                                    

        c.cost_code,                                                                                    

        c.cost_prim_sec_ind,                                                    

        c.cost_est_final_ind,                                                                                    

        null,                                                                                    

        null,                                                                        

        'Y',             

     c.cost_due_date                 

     from dbo.cost c with (NOLOCK)                                               

             inner join dbo.portfolio port        

          on port.port_num = c.port_num and       

          c.cost_price_curr_code <> desired_pl_curr_code                                           

             inner join dbo.cost_ext_info cei       

          on cei.cost_num = c.cost_num and       

          cei.cost_pl_contribution_ind = 'Y'                     

             left outer join dbo.commodity cmdty       

          on cmdty.cmdty_code = c.cost_price_curr_code                                 

       left outer join dbo.account cpty       

          on cpty.acct_num = c.acct_num                                         

     where cost_amt != 0 and       

           exists (select 1       

             from #children ch      

       where c.port_num = ch.port_num) and       

     (cost_status = 'VOUCHED' and       

     isnull(c.cost_paid_date, cost_due_date) >= dateadd(mm, -12, getdate()) ) and       

     not exists (select 1       

                 from dbo.pdfx_detail pdfx       

        where pdfx.cost_num = c.cost_num) and       

     not exists (select 1       

                 from #fx_dump f       

        where c.cost_num = f.cost_num)                                      

     set @rows_affected = @@rowcount                                                                   

     if @debugon = 1           

     begin            

        set @finish_time = convert(varchar, getdate(), 109)      

        RAISERROR('Filling the #fx_dump table (6) ...', 0, 1) with nowait      

        RAISERROR('          Start  Time : %s', 0, 1, @start_time) with nowait      

        RAISERROR('          Finish Time : %s', 0, 1, @finish_time) with nowait      

        RAISERROR('          Rows Fetched: %d', 0, 1, @rows_affected) with nowait      

     end           

                          

     --Logic to include Partially Paid VOUCHED costs.                          

     if @debugon = 1           

        set @start_time = convert(varchar, getdate(), 109)      

     insert into #fx_dump                                                                      

     select       

        creator_init,                                                                    

        creation_date,                                                                    

        c.cost_num,                                                   

        cost_owner_key6,                                                                  

        cost_owner_key7,                                                                   

        cost_owner_key8,                                                                  

        convert(varchar, isnull(cost_owner_key6, c.cost_num)) + '-' +      

       convert(varchar, cost_owner_key7) + '-' +      

        convert(varchar, cost_owner_key8),                                                                      

        cpty.acct_short_name,                                                                    

        'N',                                                              

        c.cost_num,                             

        c.port_num,                                                                    

        case when cost_prim_sec_ind = 'S' then 'Secondary'                                                                 

             when cost_type_code in ('CPR','CPP') then 'Forex'                                                                

             else 'Primary'       

     end,                                                                    

        case when cost_prim_sec_ind = 'S' then 'Secondary'                                                                 

             when cost_type_code in ('CPR', 'CPP') then 'Forex'                                                                

             else 'Primary'       

     end,                                                                    

        cost_price_curr_code,                                                                    

        isnull(cost_book_curr_code, 'USD'),                                                            

        case when isnull(cost_paid_date, cost_due_date)>= convert(char, getdate(), 101)       

       then convert(varchar, datepart(yyyy, isnull(cost_paid_date, cost_due_date)))                                                      

                     + '|' + 'Q'+convert(varchar, datepart(qq, isnull(cost_paid_date, cost_due_date)))                                                       

                     + '|' + convert(varchar(3), datename(mm, isnull(cost_paid_date, cost_due_date)))                                            

                     + '|' + convert(varchar(2), datepart(dd, isnull(cost_paid_date, cost_due_date)))                                                       

             else 'SPOT'                                                       

        end 'trading_prd',                                                                    

        convert(char, isnull(cost_paid_date, cost_due_date), 101),                                                                      

        'PAID',                                                                                       

        'PAID',                                                                                        

        'PAID',                                                                                     

        'PAID',                                                                                        

        NULL,                                                

        case when cost_pay_rec_ind = 'P' then -1       

          else 1       

     end * cost_amt - isnull(pdfx.paid_amt, 0),                          

        'COST',                          

        c.cost_num,          

        c.cost_status,                                                                                    

        c.cost_type_code,                                                                                    

        c.cost_code,                                                                                    

        c.cost_prim_sec_ind,                                                    

        c.cost_est_final_ind,                                                                                    

        null,                        

        null,                                                                        

        'Y',       

     c.cost_due_date                  

     from dbo.cost c with (NOLOCK)                              

             inner join dbo.pdfx_detail pdfx       

          ON pdfx.cost_num = c.cost_num and       

          abs(round(case when cost_pay_rec_ind = 'P' then -1       

                      else 1       

           end * c.cost_amt - isnull(pdfx.paid_amt, 0), 0)) > 1                          

             inner join dbo.portfolio port        

          on port.port_num = c.port_num and       

          c.cost_price_curr_code <> desired_pl_curr_code                                            

             inner join dbo.cost_ext_info cei       

          on cei.cost_num = c.cost_num and       

          cei.cost_pl_contribution_ind = 'Y'                                                                    

             left outer join dbo.commodity cmdty       

          on cmdty.cmdty_code = c.cost_price_curr_code                                               

             left outer join dbo.account cpty       

          on cpty.acct_num = c.acct_num                                                                    

     where isnull(c.cost_paid_date, cost_due_date) >= dateadd(mm, -12, getdate()) and       

           cost_amt != 0 and       

     exists (select 1       

             from #children ch      

          where c.port_num = ch.port_num) and       

     cost_status in ('VOUCHED', 'PAID') and       

     not exists (select 1       

                 from #fx_dump f       

     where c.cost_num = f.cost_num)                                      

     set @rows_affected = @@rowcount                                                                   

     if @debugon = 1           

     begin            

        set @finish_time = convert(varchar, getdate(), 109)      

        RAISERROR('Filling the #fx_dump table (7) ...', 0, 1) with nowait      

        RAISERROR('          Start  Time : %s', 0, 1, @start_time) with nowait      

        RAISERROR('          Finish Time : %s', 0, 1, @finish_time) with nowait      

        RAISERROR('          Rows Fetched: %d', 0, 1, @rows_affected) with nowait      

     end           

   end try                                                                                        

   begin catch                                                                                        

     print '=> Failed to get fx dump data from fx_exposure_dist, costs for the active fx_oids due to the following error:'                                    

     print '==> ERROR: ' + ERROR_MESSAGE()                                                                                        

     set @errcode = ERROR_NUMBER()                                                                                        

     goto errexit                                                                                        

   end catch                                                                                 

                                                                 

   --Delete premiums offset records where Costs doesn't have forex exposure                                                                                        

   if @debugon = 1           

      set @start_time = convert(varchar, getdate(), 109)      

   begin try                                                                                            

     delete t1                           

     from #fx_dump t1                                                                                        

     where fx_sub_type = 'PRIMARY' and       

        fx_source = 'FXEXPDIST' and       

     exists (select 1       

             from dbo.cost_ext_info cei       

       where t1.cost_num = cei.cost_num and       

             fx_exp_num is null)                                                                              

     set @rows_affected = @@rowcount                                                                   

   end try                                                                                        

   begin catch                                                                                        

     print '=> Failed to delete premium offset records where costs dont have forex exposure due to the following error:'                                                                                        

     print '==> ERROR: ' + ERROR_MESSAGE()                                                                              

     set @errcode = ERROR_NUMBER()         

     goto errexit                                                                                        

   end catch                                                                                        

   if @debugon = 1           

   begin            

      set @finish_time = convert(varchar, getdate(), 109)      

      RAISERROR('Deleting records from the #fx_dump table (1) ...', 0, 1) with nowait      

      RAISERROR('          Start  Time : %s', 0, 1, @start_time) with nowait      

      RAISERROR('          Finish Time : %s', 0, 1, @finish_time) with nowait      

      RAISERROR('          Rows Fetched: %d', 0, 1, @rows_affected) with nowait      

   end           

                                                         

   -----START- Added per lionel/JM requirement to remove SPOT FX Risk shown on Premium for a USD Pricing deal.   

   if @debugon = 1           

      set @start_time = convert(varchar, getdate(), 109)      

   delete fx                                          

   from #fx_dump fx                                          

   where exists (select 1       

                 from dbo.trade_item ti,       

          dbo.portfolio p                                          

                 where ti.trade_num = fx.trade_num and       

           ti.order_num = fx.order_num and       

        ti.item_num = fx.item_num and       

        ti.real_port_num = p.port_num and       

        ti.price_curr_code = pl_currency and       

        fx.trading_prd = 'SPOT' and       

        fx.fx_sub_type = 'Premium')                                       

   set @rows_affected = @@rowcount                                                                   

   if @debugon = 1           

   begin            

      set @finish_time = convert(varchar, getdate(), 109)      

      RAISERROR('Deleting records from the #fx_dump table (2) ...', 0, 1) with nowait      

      RAISERROR('          Start  Time : %s', 0, 1, @start_time) with nowait      

      RAISERROR('          Finish Time : %s', 0, 1, @finish_time) with nowait      

      RAISERROR('          Rows Fetched: %d', 0, 1, @rows_affected) with nowait      

   end          

                                      

   if @debugon = 1           

      set @start_time = convert(varchar, getdate(), 109)      

   delete fx                                          

   from #fx_dump fx                                          

   where exists (select 1       

                 from dbo.trade_item ti,       

          dbo.portfolio p,       

       dbo.cost c                                         

                 where ti.trade_num = fx.trade_num and                    

                       ti.order_num = fx.order_num and                                          

                       ti.item_num = fx.item_num and                                      

                       ti.real_port_num = p.port_num and                                         

                       ti.price_curr_code = pl_currency and                                         

                       fx.fx_sub_type = 'Premium' and                                        

                       c.cost_num = fx.cost_num and                                   

                       c.cost_type_code in ('PO', 'PR') )       

   set @rows_affected = @@rowcount                                                                   

   if @debugon = 1           

   begin            

      set @finish_time = convert(varchar, getdate(), 109)      

      RAISERROR('Deleting records from the #fx_dump table (3) ...', 0, 1) with nowait      

      RAISERROR('          Start  Time : %s', 0, 1, @start_time) with nowait      

      RAISERROR('          Finish Time : %s', 0, 1, @finish_time) with nowait      

      RAISERROR('          Rows Fetched: %d', 0, 1, @rows_affected) with nowait      

   end                                                  

   ----- END- Added per lionel/JM requirement to remove SPOT FX Risk shown on Premium for a USD Pricing deal.        

                                                                  

   if @debugon = 1           

      set @start_time = convert(varchar, getdate(), 109)      

   begin try                                                   

     update #fx_dump       

  set year = 'SPOT',      

      exp_date = 'SPOT',       

   quarter = 'SPOT',      

   month = 'SPOT',      

   day = 'SPOT'       

  where trading_prd = 'SPOT'                                                                                       

     set @rows_affected = @@rowcount                                                                   

   end try                                                                                     

   begin catch                    

     print '=> Failed to set SPOT trading period due to the following error:'                               

     print '==> ERROR: ' + ERROR_MESSAGE()                                                                                        

     set @errcode = ERROR_NUMBER()                                                              

     goto errexit                                                       

   end catch                                                                                        

   if @debugon = 1           

   begin            

      set @finish_time = convert(varchar, getdate(), 109)      

      RAISERROR('Updating #fx_dump records (1) ...', 0, 1) with nowait      

      RAISERROR('          Start  Time : %s', 0, 1, @start_time) with nowait      

      RAISERROR('          Finish Time : %s', 0, 1, @finish_time) with nowait      

      RAISERROR('          Rows Fetched: %d', 0, 1, @rows_affected) with nowait      

   end          

                                       

   if @debugon = 1           

      set @start_time = convert(varchar, getdate(), 109)      

   begin try                                                                                        

     update #fx_dump       

     set exp_date = convert(varchar, convert(datetime, substring(trading_prd, 13, len(trading_prd) -12) + ' ' +      

                      substring(trading_prd, 9, 3) + ' ' +      

           substring(trading_prd, 1, 4), 106), 101),                                                                              

         year = substring(trading_prd, 1, 4),                         

         quarter = substring(trading_prd, 7, 1),                                                                            

         month = substring(trading_prd, 9, 3),                                                                                        

         day = substring(trading_prd, 13, len(trading_prd) - 12)       

  where trading_prd != 'SPOT'                                                                                        

     set @rows_affected = @@rowcount                                                                   

   end try                                                 

   begin catch                                                                                        

     print '=> Failed to derive exposure date, year, quarter,month and day from fx_exposure.trading_prd due to the following error:'                                                                                        

     print '==> ERROR: ' + ERROR_MESSAGE()                                                                                        

     set @errcode = ERROR_NUMBER()                                                                                        

     goto errexit                                                            

   end catch                                                                                       

   if @debugon = 1           

   begin            

      set @finish_time = convert(varchar, getdate(), 109)      

      RAISERROR('Updating #fx_dump records (2) ...', 0, 1) with nowait      

      RAISERROR('          Start  Time : %s', 0, 1, @start_time) with nowait      

      RAISERROR('          Finish Time : %s', 0, 1, @finish_time) with nowait      

      RAISERROR('          Rows Fetched: %d', 0, 1, @rows_affected) with nowait      

   end         

         

   if @debugon = 1           

      set @start_time = convert(varchar, getdate(), 109)                                                                                                                                

   update #fx_dump       

   set fx_type = 'Secondary'       

   where (cost_prim_sec_ind = 'S' or       

          cost_type_code in ('WAP', 'SPP')) and          

   fx_type in ('OTHER', 'INVALID')             

   set @rows_affected = @@rowcount                                                             

   if @debugon = 1           

   begin            

      set @finish_time = convert(varchar, getdate(), 109)      

      RAISERROR('Updating #fx_dump records (3) ...', 0, 1) with nowait      

      RAISERROR('          Start  Time : %s', 0, 1, @start_time) with nowait      

      RAISERROR('          Finish Time : %s', 0, 1, @finish_time) with nowait      

      RAISERROR('          Rows Fetched: %d', 0, 1, @rows_affected) with nowait      

   end         

           

   if @debugon = 1           

      set @start_time = convert(varchar, getdate(), 109)                                                                                                                                

   update #fx_dump       

   set fx_type = 'CashBalance'       

   where cost_code = 'CASHBLNC'        

   set @rows_affected = @@rowcount                                                                   

   if @debugon = 1           

   begin            

      set @finish_time = convert(varchar, getdate(), 109)      

      RAISERROR('Updating #fx_dump records (4) ...', 0, 1) with nowait      

      RAISERROR('          Start  Time : %s', 0, 1, @start_time) with nowait      

      RAISERROR('          Finish Time : %s', 0, 1, @finish_time) with nowait      

      RAISERROR('          Rows Fetched: %d', 0, 1, @rows_affected) with nowait      

   end         

           

   if @debugon = 1           

      set @start_time = convert(varchar, getdate(), 109)                                      

   update #fx_dump       

   set fx_type = 'GasPower'       

   where cost_type_code like 'POM%'                                                                                    

   set @rows_affected = @@rowcount                                      

   if @debugon = 1           

   begin            

      set @finish_time = convert(varchar, getdate(), 109)      

      RAISERROR('Updating #fx_dump records (5) ...', 0, 1) with nowait      

      RAISERROR('          Start  Time : %s', 0, 1, @start_time) with nowait      

      RAISERROR('          Finish Time : %s', 0, 1, @finish_time) with nowait      

      RAISERROR('          Rows Fetched: %d', 0, 1, @rows_affected) with nowait      

   end           

                    

                                                                            

   set @asofdate = (select max(price_quote_date)       

                    from dbo.price       

                    where commkt_key in (select commkt_key       

                                         from dbo.commodity_market cm      

                       where exists (select 1      

                                     from #fx_dump fx      

                            where cm.cmdty_code = fx.fx_currency and       

                                           cm.mkt_code = fx.pl_currency)) )                                                                                 

       

   if @debugon = 1      

   begin      

      declare @s    varchar(30)      

      

   if @asofdate is not null      

      set @s = convert(varchar, @asofdate, 101)      

   else      

      set @s = 'NULL'      

      RAISERROR('The @asofdate obtained from the price table is ''%s''', 0, 1, @s) with nowait      

   end      

                       

   --Added by Subu on Jul 30th 2012 to reflect the correct expected       

   --payment date incase Due Date is different from expected pay date.       

   -- Applies only for Physicals/secondary                                                                            

   if @debugon = 1           

      set @start_time = convert(varchar, getdate(), 109)                                                                                                                                

   update #fx_dump       

   set exp_date = convert(char, voucher_expected_pay_date, 101)                                  

   from #fx_dump fx,       

        dbo.voucher v,       

  dbo.voucher_cost vc                                                                            

   where fx.cost_num = vc.cost_num and                                                                    

         vc.voucher_num = v.voucher_num and                                                                            

         voucher_expected_pay_date <> voucher_due_date and                                                                           

         cost_type_code not in ('CPP', 'CPR') and                                                                            

         cost_type_code is not null and                                                                   

         cost_status = 'VOUCHED' and                                                         

         isnull(exp_date, 'SPOT') <>'SPOT'           

   set @rows_affected = @@rowcount                                                                   

   if @debugon = 1           

   begin            

      set @finish_time = convert(varchar, getdate(), 109)      

      RAISERROR('Updating #fx_dump records (6) ...', 0, 1) with nowait      

      RAISERROR('          Start  Time : %s', 0, 1, @start_time) with nowait      

      RAISERROR('          Finish Time : %s', 0, 1, @finish_time) with nowait      

      RAISERROR('          Rows Fetched: %d', 0, 1, @rows_affected) with nowait      

   end           

                                             

   -- Added by Subu on Jul 30th 2012 to reflect the correct expected payment       

   -- date incase Due Date is different from expected pay date.       

   -- Applies only for Physicals/secondary                                                                            

                                                                             

set @pl_asof_date = (select max(pl_asof_date)       

                     from dbo.portfolio_profit_loss)                                                                           

      

   if @debugon = 1      

   begin      

      declare @s1    varchar(30)      

      

   if @pl_asof_date is not null      

      set @s1 = convert(varchar, @pl_asof_date, 101)      

   else      

      set @s1 = 'NULL'      

      RAISERROR('The @pl_asof_date obtained from the dbo.portfolio_profit_loss table is ''%s''', 0, 1, @s1) with nowait      

   end      

                                

   ----Added temporariliy to fix a bug.       

   if @debugon = 1           

      set @start_time = convert(varchar, getdate(), 109)                                                                                                                                

   update fx       

   set fx_amount = fut.fx_amount,       

       conv_rate1 = currency_fx_rate,       

    calc_oper1 = 'M'                                                          

   from #fx_dump fx,                                                                    

        (select trade_number,      

          pl.real_port_num,      

    sum(isnull(pl_amt, 0) / currency_fx_rate) fx_amount,      

    currency_fx_rate                                                                              

         from #fx_dump fx,       

        dbo.pl_history pl                                                                              

         where pl.real_port_num = fx.real_port_num and                                                                

               fx.fx_type = 'FUT' and                                                                             

               fx.trade_num = pl_secondary_owner_key1 and                                                                 

               fx.order_num = pl_secondary_owner_key2 and                                                      

               fx.item_num = pl_secondary_owner_key3 and                                                                 

               currency_fx_rate is not null and                                                                             

               pl_type not in ('I', 'W') and                                                                             

               pl_asof_date = @pl_asof_date                                             

         group by trade_number, pl.real_port_num, currency_fx_rate) fut                         

   where fx.trade_number = fut.trade_number                                                                              

   set @rows_affected = @@rowcount                                                                   

   if @debugon = 1           

   begin            

      set @finish_time = convert(varchar, getdate(), 109)      

      RAISERROR('Updating #fx_dump records (7) ...', 0, 1) with nowait      

      RAISERROR('          Start  Time : %s', 0, 1, @start_time) with nowait      

      RAISERROR('          Finish Time : %s', 0, 1, @finish_time) with nowait      

      RAISERROR('          Rows Fetched: %d', 0, 1, @rows_affected) with nowait      

   end           

                                

   ----Added temporariliy to fix a bug. 
--added by teju
create table #tempdata                                                                                

(                                                                                

   max_price_quote_date datetime,                                                                                

   fx_currency_code varchar(50),
   pl_currency_code varchar(50)

)   
insert into  #tempdata
select distinct max_price_quote_date,fx.fx_currency,fx.pl_currency
         from #fx_dump fx  
         join 
		 (select   max(p.price_quote_date) as max_price_quote_date,cm.mkt_code,cm.cmdty_code from commodity_market cm   
         join price p on p.commkt_key=cm.commkt_key group by cm.mkt_code,cm.cmdty_code ) mp 
		 on (mp.mkt_code=fx.fx_currency and mp.cmdty_code=fx.pl_currency) OR (mp.mkt_code=fx.pl_currency and mp.cmdty_code=fx.fx_currency)
		  WHERE fx.conv_rate1 is null  

--added by teju         

   if @debugon = 1           

      set @start_time = convert(varchar, getdate(), 109)                                                                                                                                

   update #fx_dump                                                                                    

   set conv_rate1 = conv_rate,                                                                                     

       calc_oper1 = calc_oper                                                                                    

   from #fx_dump fx  
   join #tempdata td	on 	 fx.fx_currency=td.fx_currency_code and fx.pl_currency=td.pl_currency_code

          CROSS APPLY dbo.udf_currency_exch_rate(                       

                                
									td.max_price_quote_date, --@asofdate, /*@asof_date*/                          

                                   fx.fx_currency,  /* @curr_code_from */                                                                                    

                                   fx.pl_currency,  /* @curr_code_to */                                                                                    

                                   case when exp_date = 'SPOT' then getdate()       

                else exp_date       

           end,             /* @eff_date */                                                                          

									case when datediff(dd,td.max_price_quote_date,(case when exp_date='SPOT' then td.max_price_quote_date else exp_date end))>0 then 'E' else 'F' end ,  /* @est_final_ind */                                                                        

                                   case when exp_date = 'SPOT' then exp_date       

                else convert(char(6), exp_date, 112)       

           end              /* @trading_prd */                                                                                    

     )                                                                                    

   where fx.conv_rate1 is null                                                                                    

   set @rows_affected = @@rowcount                                                                   

   if @debugon = 1           

   begin            

      set @finish_time = convert(varchar, getdate(), 109)      

      RAISERROR('Updating #fx_dump records (8) ...', 0, 1) with nowait      

      RAISERROR('          Start  Time : %s', 0, 1, @start_time) with nowait      

      RAISERROR('        Finish Time : %s', 0, 1, @finish_time) with nowait      

      RAISERROR('          Rows Fetched: %d', 0, 1, @rows_affected) with nowait      

   end         

         

   if @debugon = 1           

      set @start_time = convert(varchar, getdate(), 109)                                                                                                                                                                                                    

   update #fx_dump       

   set pl_incl_ind = cost_pl_contribution_ind                                                

   from #fx_dump f,       

        dbo.cost_ext_info cei                                                                        

   where f.cost_num = cei.cost_num and       

         f.fx_source = 'COST' and       

   cost_pl_contribution_ind = 'N'                                                                        

   set @rows_affected = @@rowcount                                                                   

   if @debugon = 1           

   begin            

      set @finish_time = convert(varchar, getdate(), 109)      

      RAISERROR('Updating #fx_dump records (9) ...', 0, 1) with nowait      

      RAISERROR('          Start  Time : %s', 0, 1, @start_time) with nowait      

      RAISERROR('          Finish Time : %s', 0, 1, @finish_time) with nowait      

      RAISERROR('          Rows Fetched: %d', 0, 1, @rows_affected) with nowait      

   end        

                                                                     

   if @debugon = 1           

      set @start_time = convert(varchar, getdate(), 109)                                                                                                                                                                                                    

   update #fx_dump       

   set exp_date = '.SPOT-PDFX'       

   where cost_code = 'PDFX'         

   set @rows_affected = @@rowcount                              

   if @debugon = 1           

   begin            

      set @finish_time = convert(varchar, getdate(), 109)      

      RAISERROR('Updating #fx_dump records (10) ...', 0, 1) with nowait      

      RAISERROR('          Start  Time : %s', 0, 1, @start_time) with nowait      

      RAISERROR('          Finish Time : %s', 0, 1, @finish_time) with nowait      

      RAISERROR('          Rows Fetched: %d', 0, 1, @rows_affected) with nowait      

   end        

            

   if @debugon = 1           

      set @start_time = convert(varchar, getdate(), 109)                                                                                                                                                                                                    

   insert into #fx_dump_final                                                                                  

   select                                                                     

      fd.trader_init 'Trader' ,                                                                    

      contr_date ContractDate,                                                                    

      trade_number 'TradeNum',                                                                    

      trade_key 'TradeKey',                                                                  

      cost_num 'CostNum',                                                                                    

      counterparty 'Counterparty',                                                                    

      case when item_type = 'W' then 'PHYSICAL'        

           when item_type = 'C' then 'SWAP'        

           when item_type = 'F' then 'FUTURE'        

           when item_type = 'U' then 'CURRENCY'        

           when item_type = 'S' then 'STORAGE'        

           when item_type = 'E' then 'LST OPTION'        

           when item_type = 'O' then 'OTC'        

           when item_type = 'D' then 'CONCENTRATE'        

           when item_type = 'T' then 'TRANSPORTATION'        

           when item_type = 'B' then 'BUNKER'        

      end 'TradeType',                                              

      inhouse_ind 'InhouseInd',                                                                    

      fx_sub_type 'FXRiskType',                                                                       

      acc.acct_full_name as 'TradingEntity',                                                                    

      group_code as Book,                                                                    

      profit_center_code 'ProfitCntr',                                                                 

      bcomp.acct_short_name 'BookingCompany',                                                             

      fd.real_port_num 'PortNum',                                                                     

      fx_amount 'FXAmount',                                                                                        

      fx_currency 'Currency',                                                                                        

      case when calc_oper1 = 'M' then fd.conv_rate1 * fx_amount       

        else fx_amount / fd.conv_rate1       

   end 'BookCurrencyEquiv',                                         

      pl_currency 'BookCurrency',                                                                                                                                                   

      case when exp_date = 'SPOT' then '.SPOT'                                             

           when exp_date = '.SPOT-PDFX' then '.SPOT-PDFX'                                            

           else       

        substring(datename(mm, exp_date), 1, 3)       

   end 'Month',                                                                                          

      case when exp_date = 'SPOT' then '.SPOT'                                             

           when exp_date = '.SPOT-PDFX' then '.SPOT-PDFX'                                            

           else 'Q' + convert(char, datename(q, exp_date))       

   end 'Qtr',                                        

      case when exp_date = 'SPOT' then '.SPOT'                                             

           when exp_date = '.SPOT-PDFX'                                             

           then '.SPOT-PDFX'                                            

           else       

        datename(yyyy, exp_date)       

  end 'YEAR',                                     

      case when exp_date = 'SPOT' then '.SPOT'                                             

           when exp_date = '.SPOT-PDFX' then '.SPOT-PDFX'                                            

           else exp_date       

   end 'ExpDate',                                                                                        

      fd.trading_prd 'TradingPrd',                         

      total_exp_by_id 'ExpId',                                                                                        

      fx_source 'FxSource',                                 

      cost_status 'CostStatus',                                                                                   

      cost_type_code 'CostType',                                                                                    

      fd.cost_code,             

   due_date 'OrignalDueDate'                                

   from #fx_dump fd            

 inner join portfolio pt on pt.port_num=fd.real_port_num                                                          

 LEFT outer join account acc ON acc.acct_num=pt.trading_entity_num        

         LEFT OUTER JOIN jms_reports j         

           ON j.port_num = pt.port_num        

         LEFT OUTER JOIN entity_tag_option eto         

           ON eto.entity_tag_id = dbo.udf_portfolio_tag_id('PRFTCNTR') and         

              eto.tag_option = j.profit_center_code              

        LEFT OUTER JOIN entity_tag_option grp         

           ON grp.entity_tag_id = dbo.udf_portfolio_tag_id('GROUP') and         

              grp.tag_option = j.group_code        

            LEFT OUTER JOIN portfolio_tag pt1         

           on pt1.port_num = pt.port_num and         

pt1.tag_name = 'BOOKCOMP'                  

        LEFT OUTER JOIN account bcomp         

           ON bcomp.acct_num = pt1.tag_value       

 /*        

           join dbo.v_BI_portfolio pt       

        on fd.real_port_num = pt.port_num                                                                

           left outer join dbo.account acc      

          on acc.acct_num = pt.trading_entity_num        

     */      

           left outer join dbo.trade_item ti       

        on fd.trade_num = ti.trade_num and       

        fd.order_num = ti.order_num and       

     fd.item_num = ti.item_num                                                                                     

   order by fd.real_port_num, trade_number, exp_date                                         

   set @rows_affected = @@rowcount                                                                   

   if @debugon = 1           

   begin            

      set @finish_time = convert(varchar, getdate(), 109)      

      RAISERROR('Filling the #fx_dump_final table ...', 0, 1) with nowait      

      RAISERROR('          Start  Time : %s', 0, 1, @start_time) with nowait      

      RAISERROR('          Finish Time : %s', 0, 1, @finish_time) with nowait      

      RAISERROR('          Rows Fetched: %d', 0, 1, @rows_affected) with nowait      

   end        


   if @debugon = 1           

      set @start_time = convert(varchar, getdate(), 109)                                                                                                                                                                                                    

   insert into #cmdtyCurrToPrimaryCurrConvTable      

       (cmdty_code, prim_curr_code, prim_curr_conv_rate)         

   select distinct       

      cmdty_code,        

      prim_curr_code,       

      prim_curr_conv_rate       

   from dbo.commodity       

   where cmdty_code in (select distinct       

                           Currency       

         from #fx_dump_final) and       

      cmdty_code != prim_curr_code        

   set @rows_affected = @@rowcount                                                                   

   if @debugon = 1           

   begin            

      set @finish_time = convert(varchar, getdate(), 109)      

      RAISERROR('Filling the #cmdtyCurrToPrimaryCurrConvTable table ...', 0, 1) with nowait      

      RAISERROR('          Start  Time : %s', 0, 1, @start_time) with nowait      

      RAISERROR('          Finish Time : %s', 0, 1, @finish_time) with nowait      

      RAISERROR('          Rows Fetched: %d', 0, 1, @rows_affected) with nowait      

   end        


declare @z int = (select MAX(ID1)       

                  from #cmdtyCurrToPrimaryCurrConvTable)        

declare @priceCmdtyCode char(8) = null        

declare @primCurrCode   char(8) = null        

declare @rate           float(8)        


while @z > 0        

begin        

   select @priceCmdtyCode = cmdty_code,      

          @primCurrCode = prim_curr_code,       

    @rate = prim_curr_conv_rate        

   from #cmdtyCurrToPrimaryCurrConvTable t       

   where t.ID1 = @z       

   if ISNULL(@rate,0) > 0         

   begin        

      update #fx_dump_final       

   set Currency = @primCurrCode,       

       FXAmount = FXAmount * @rate       

   where Currency = @priceCmdtyCode        

   end        

   set @z = @z - 1        

end        

exit1:       

select *   

from #fx_dump_final        

errexit:                                                                                        

   if @errcode > 0                                                                                        

      set @status = 2                                                                            

endofsp:                                                                                        

if object_id('tempdb..#children', 'U') is not null      

   drop table #children      

if object_id('tempdb..#active_fx_ids', 'U') is not null      

   drop table #active_fx_ids      

if object_id('tempdb..#fx_dump', 'U') is not null      

   drop table #fx_dump      

if object_id('tempdb..#fx_dump_final', 'U') is not null      

   drop table #fx_dump_final      

if object_id('tempdb..#cmdtyCurrToPrimaryCurrConvTable', 'U') is not null      

   drop table #cmdtyCurrToPrimaryCurrConvTable      

if object_id('tempdb..#allExpDatesQuoteAsTradeCurr', 'U') is not null      

   drop table #allExpDatesQuoteAsTradeCurr      

return @status            

GO
GRANT EXECUTE ON  [dbo].[usp_get_fx_data] TO [next_usr]
GO
