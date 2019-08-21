SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_MTM_pl_report]
(    
   @as_of_Date      	datetime = null,      
   @book           	  varchar(8000),    
   @port_num        	varchar(8000),    
   @pricing_from_date datetime = null,    
   @debugon          	bit = 0     
)    
as
set nocount on    
declare @rows_affected     	int,      
        @smsg              	varchar(255),      
        @status            	int,      
        @oid               	numeric(18, 0),      
        @stepid            	smallint,      
        @session_started   	varchar(30),      
        @session_ended     	varchar(30),      
        @my_as_of_Date     	datetime,      
        @my_book           	varchar(8000),    
        @my_port_num       	varchar(8000),    
        @my_pricing_from_date 	datetime    
    
   select @my_as_of_Date = @as_of_Date,      
        @my_book = @book,    
          @my_port_num = @port_num,    
        @my_pricing_from_date = @pricing_from_date    
    
  create table #output    
   (      
    toi          nvarchar(50),    
    mkt_code       nvarchar(50) null,    
    product        nvarchar(50) null,    
    pricing_period    varchar(20) null,    
    tradedate       varchar(20) null,    
    bblqty        decimal(20,8) null,    
    mtqty          decimal(20,8) null,    
    cp           varchar(150) null,    
    tradeprice      decimal(20,8) null,    
    trader        char(6) null,    
    book          varchar(50) null,    
    pricing_from      varchar(20) null,    
    pricing_to        varchar(20) null,    
    no_of_days      int null,    
    days_passed      int null,    
    realised_qty     int null,    
    realised_avg_price  decimal(20,8) null,    
    realised_pl      decimal(20,8) null,    
    evaluated_qty     int null,    
    evaluated_avg_price  decimal(20,8) null,    
    evaluated_pl     decimal(20,8) null,    
    total_pl       decimal(20,8) null,    
    due_date       varchar(20) null,    
    trading_prd_desc   varchar(40) null,  
    trading_prd   varchar(8) null,  
    order_type      char(10) null,    
    grp_type       char(10) null,    
    trade_num       int null,    
    order_num       int null,    
    item_num       int null,    
    bench_mark      varchar(50) null,    
    pricing_qty_per_day  decimal(20,8) null,    
    premium        nvarchar(50) null,    
    additional_cost    decimal(20,8) null,    
    add_cost_per_bbl   decimal(20,8) null,    
    freight        decimal(20,8) null,    
    freight_per_bbl    decimal(20,8) null,    
    bl_date        varchar(20) null,    
    mt_bbl        decimal(20,8) null,  
    port_num int null  
   )      
    
   CREATE TABLE #trade_item  
   (  
  trade_num INT,  
  order_num INT,  
  item_num INT,  
  real_port_num int  
   )  
  
   --SWAP Query Started-------------------------------------------------------------------  
 INSERT INTO #trade_item  
 SELECT distinct pl_secondary_owner_key1,  
   pl_secondary_owner_key2,  
   pl_secondary_owner_key3,  
   real_port_num  
 FROM dbo.pl_history plh  
 JOIN dbo.trade t ON t.trade_num=plh.pl_secondary_owner_key1  
     join dbo.accumulation acc     
        on plh.pl_secondary_owner_key1 = acc.trade_num and     
           plh.pl_secondary_owner_key2 = acc.order_num and     
           plh.pl_secondary_owner_key3 = acc.item_num      
     join dbo.quote_pricing_period qpp     
        on acc.trade_num = qpp.trade_num and     
           acc.order_num = qpp.order_num and     
           acc.item_num = qpp.item_num and     
           acc.accum_num = qpp.accum_num       
     WHERE ((pl_owner_code in ('C') AND pl_owner_sub_code in ('SWAP'))  
    OR  
    (pl_owner_code in ('T') AND pl_owner_sub_code in ('C'))) AND   
     pl_asof_date = @my_as_of_Date AND  
    qpp.quote_start_date >= @my_pricing_from_date AND  
   1 = (case when @my_book is NULL then 1  
      when '<NONE>' IN (select * from dbo.udf_split(@my_book, ',')) then 1  
        when t.trader_init IN (select * from dbo.udf_split(@my_book, ',')) then 1  
        else 0  
      end) AND  --Book Init    
   1 = (case when @my_port_num is NULL then 1  
      when '0' IN (select * from dbo.udf_split(@my_port_num, ',')) then 1  
      when plh.real_port_num IN (select * from dbo.udf_split(@my_port_num, ',')) then 1  
        else 0  
      end) --PortFolios  
 -- fill swaps    
 insert into #output     
 (      
  toi,    
  mkt_code,    
  product,    
  pricing_period,    
  tradedate,    
  bblqty,    
  mtqty,    
  cp,    
  tradeprice,    
  trader,    
  book,    
  pricing_from,    
  pricing_to,    
  no_of_days,    
  days_passed,    
  realised_qty,    
  realised_avg_price,    
  realised_pl,    
  evaluated_qty,    
  evaluated_avg_price,    
  evaluated_pl,    
  total_pl,    
  due_date,    
  trading_prd_desc,  
  trading_prd,    
  order_type,    
  grp_type,  
  port_num,  
  trade_num,  
  order_num,  
  item_num  
 )     
     
 select convert(varchar, ti.trade_num) + '/' +convert(varchar, ti.order_num)+ '/' + convert(varchar, ti.item_num) as 'toi',       
        ti.risk_mkt_code as 'mkt_code',     
        ti.cmdty_code as 'product',       
        null,  
        convert(varchar, t.contr_date, 101) as 'tradedate',       
  dtidmtm.dist_qty 'bblqty',      
        0 as mtqty,     
        cp.acct_full_name as 'cp',       
        case isnull(dtidmtm.dist_qty, 0)     
           when 0 then 0     
           else ABS(isnull(dtidmtm.trade_value, 0) / isnull(dtidmtm.dist_qty, 1))     
        end as 'tradeprice',      
        t.trader_init as 'trader',      
        bkcp.acct_short_name as 'book',      
        null,  
        null,       
        0,       
        0,  
        0,  
        case isnull(dtidmtm.dist_qty, 0)     
           when 0 then 0     
           else case tor.order_type_code   
     when 'SWAP' then ABS(isnull(dtidmtm.market_value,0)/ isnull(dtidmtm.dist_qty, 1))     
     when 'SWAPFLT' then ABS((isnull(dtidmtm.open_pl, 0) + isnull(dtidmtm.closed_pl,0))/ isnull(dtidmtm.dist_qty, 1))     
    end  
        end as 'realised_avg_price',     
        isnull(dtidmtm.open_pl, 0) + isnull(dtidmtm.closed_pl,0),    
        0,      
        case isnull(dtidmtm.dist_qty, 0)     
           when 0 then 0     
           else case tor.order_type_code   
     when 'SWAP' then ABS(isnull(dtidmtm.market_value,0)/ isnull(dtidmtm.dist_qty, 1))     
     when 'SWAPFLT' then ABS((isnull(dtidmtm.open_pl, 0) + isnull(dtidmtm.closed_pl,0))/ isnull(dtidmtm.dist_qty, 1))     
    end  
        end as 'evaluated_avg_price',    
       isnull(dtidmtm.open_pl, 0) + isnull(dtidmtm.closed_pl,0),     
       isnull(dtidmtm.open_pl, 0) + isnull(dtidmtm.closed_pl,0),    
       convert(varchar, c.cost_due_date,101) as 'DueDate',      
       null,--prd.trading_prd_desc,  
       null,--prd.trading_prd as 'trading_prd',     
       tor.order_type_code,    
       'PAPER',  
       ti.real_port_num 'Port_Num',  
    dtid.trade_num,  
       dtid.order_num,  
       dtid.item_num  
 from dbo.trade t       
         join dbo.trade_order tor     
            on t.trade_num = tor.trade_num       
         join dbo.trade_item ti     
            on tor.trade_num = ti.trade_num and     
               tor.order_num = ti.order_num       
         join dbo.accumulation acc     
            on ti.trade_num = acc.trade_num and     
               ti.order_num = acc.order_num and     
               ti.item_num = acc.item_num      
         join dbo.trade_item_dist dtid     
            on dtid.trade_num = ti.trade_num and     
               dtid.order_num = ti.order_num and     
               dtid.item_num = ti.item_num and     
               dtid.dist_type = 'D'      
         join #trade_item ti1   
              ON dtid.trade_num = ti1.trade_num and   
                 dtid.order_num = ti1.order_num and   
                 dtid.item_num = ti1.item_num and   
                 dtid.real_port_num = ti1.real_port_num  
         left outer join dbo.account cp     
            on t.acct_num = cp.acct_num      
         join dbo.account bkcp     
            on ti.booking_comp_num = bkcp.acct_num       
         left outer join dbo.cost c     
            on acc.cost_num = c.cost_num      
         left outer join dbo.tid_mark_to_market dtidmtm     
            on dtidmtm.dist_num = dtid.dist_num and     
               dtidmtm.mtm_pl_asof_date = @my_as_of_Date  
 order by ti.trade_num, ti.order_num, ti.item_num    
     
 --Updating Pricing Period,No if pricing days  
     update t1  
     set pricing_period = left(DATENAME(m, t2.price_end_date), 3),  
         pricing_from = convert(varchar, price_start_date, 101),  
  pricing_to = convert(varchar, price_end_date, 101),    
  no_of_days = num_of_pricing_days,  
  trading_prd_desc=upper(CONVERT(CHAR(3), price_end_date, 100)) + '-' + right(CONVERT(CHAR(4), price_end_date, 120),2),  
  trading_prd=CONVERT(CHAR(4),price_end_date, 120) +CONVERT(CHAR(2), price_end_date, 110)  
     
    from #output t1  
     join (select trade_num,order_num,item_num,min(price_quote_date) as  price_start_date,max(price_quote_date) as price_end_date,count(*) as num_of_pricing_days  
   from (select distinct qp.trade_num,qp.order_num,qp.item_num,price_quote_date   
      from dbo.quote_price qp  
      join #output op on qp.trade_num=op.trade_num and qp.order_num=op.order_num and qp.item_num=op.item_num) t3  
   group by trade_num,order_num,item_num) t2  
  on t1.trade_num=t2.trade_num and t1.order_num=t2.order_num and t1.item_num=t2.item_num  
  
 --Updating number of days priced  
     update t1  
     set days_passed = num_of_days_priced    
    from #output t1  
     join (select trade_num,order_num,item_num,count(*) as num_of_days_priced  
   from (select distinct qp.trade_num,qp.order_num,qp.item_num,price_quote_date   
      from dbo.quote_price qp  
      join #output op on qp.trade_num=op.trade_num and qp.order_num=op.order_num and qp.item_num=op.item_num and price_quote_date <= @my_as_of_Date) t3  
   group by trade_num,order_num,item_num) t2  
  on t1.trade_num=t2.trade_num and t1.order_num=t2.order_num and t1.item_num=t2.item_num  
  
 --Updating Qty,PL for Fixed swaps, where quantity trade is fully priced or fully unpriced   
     update t1  
  set realised_pl = case when days_passed = 0 then 0 else realised_pl end,  
   realised_avg_price = case when days_passed = 0 then 0 else realised_avg_price end,  
   realised_qty = bblqty * (convert(float,days_passed)/convert(float,no_of_days)),  
   evaluated_pl = case when (no_of_days - days_passed) = 0 then 0 else evaluated_pl end,  
   evaluated_avg_price = case when (no_of_days - days_passed) = 0 then 0 else evaluated_avg_price end,  
   evaluated_qty = bblqty * (convert(float,(no_of_days - days_passed))/convert(float,no_of_days))  
    from #output t1  
  --where order_type='SWAP'  
  
     --update prices, Pl for trades that are pricing for this asofdate for Fixed vs Float Trades  
  update t2  
  set realised_avg_price = t3.realised_avg_price,  
   evaluated_avg_price = t3.evaluated_avg_price,  
   realised_pl = realised_qty * (t3.realised_avg_price - tradeprice),  
   evaluated_pl = evaluated_qty * (t3.evaluated_avg_price - tradeprice)  
     from #output t2  
     join (select t1.trade_num,t1.order_num,t1.item_num,  
   case when sum(ABS(isnull(utidmtm.alloc_qty,0))) < 0.1 then 0   
else abs(sum(abs(dtidmtm.market_value) * abs(isnull(utidmtm.alloc_qty,0)))/  
(abs(isnull(dtidmtm.dist_qty,0))*abs(isnull(dtidmtm.dist_qty,0)))) end as 'realised_avg_price',   
   case when sum(ABS(isnull(utidmtm.dist_qty,0)) - ABS(isnull(utidmtm.alloc_qty,0))) < 0.1   
then 0 else ABS(sum(abs(dtidmtm.market_value)*(abs(isnull(utidmtm.dist_qty,0))-abs(isnull(utidmtm.alloc_qty,0))))  
/(abs(isnull(dtidmtm.dist_qty,0))*abs(isnull(dtidmtm.dist_qty,0)))) end as 'evaluated_avg_price'  
  from #output t1  
   join dbo.trade_item_dist utid on utid.trade_num=t1.trade_num and utid.order_num=t1.order_num and utid.item_num=t1.item_num   
and utid.dist_type='U'  
   join dbo.tid_mark_to_market utidmtm on utid.dist_num=utidmtm.dist_num and utidmtm.mtm_pl_asof_date= @my_as_of_Date  
   join dbo.trade_item_dist dtid on dtid.trade_num=t1.trade_num and dtid.order_num=t1.order_num and dtid.item_num=t1.item_num   
and dtid.dist_type='D'  
   join dbo.tid_mark_to_market dtidmtm on dtid.dist_num=dtidmtm.dist_num and dtidmtm.mtm_pl_asof_date= @my_as_of_Date  
     where order_type='SWAP' and not (days_passed = 0 or (no_of_days - days_passed) = 0)  
     group by t1.trade_num,t1.order_num,t1.item_num,dtidmtm.dist_qty,dtidmtm.market_value) t3  
      on t2.trade_num=t3.trade_num and t2.order_num=t3.order_num and t2.item_num=t3.item_num  
        
 --Handle Float vs Float swap  
 CREATE TABLE #swap_flt_data (  
  trade_num int,  
  order_num int,  
  item_num int,   
  cmdty_code CHAR(8),  
  float_diff decimal(20,8)  
 )  
  
 INSERT INTO #swap_flt_data  
 SELECT  DISTINCT ti.trade_num,  
   ti.order_num,   
   ti.item_num,  
   cm.cmdty_code,  
   differential_val  
 FROM #output ti  
    join dbo.accumulation acc   
    on ti.trade_num = acc.trade_num and   
    ti.order_num = acc.order_num and   
    ti.item_num = acc.item_num  
    join dbo.quote_pricing_period qpp   
    on acc.trade_num = qpp.trade_num and   
    acc.order_num = qpp.order_num and   
    acc.item_num = qpp.item_num and   
    acc.accum_num = qpp.accum_num  
    join dbo.formula f   
    on qpp.formula_num = f.formula_num  
    join dbo.formula_body fb  
    on fb.formula_num = qpp.formula_num and   
    fb.formula_body_num = qpp.formula_body_num and formula_body_type='Q'  
    join dbo.formula_component fc  
    on fc.formula_num = qpp.formula_num and   
    fc.formula_body_num = qpp.formula_body_num and   
    fc.formula_comp_num = qpp.formula_comp_num  
    join dbo.commodity_market cm   
    on cm.commkt_key = fc.commkt_key   
  where order_type in ('SWAP', 'SWAPFLT'  )
  
 UPDATE ta1  
 SET ta1.product=ta2.cmdty_code  
 FROM #output ta1  
 JOIN (SELECT t1.trade_num,  
     t1.order_num,  
     t1.item_num,  
     REPLACE((SELECT RTRIM(t2.cmdty_code) + '_' AS 'data()'   
     FROM #swap_flt_data t2   
     WHERE t1.trade_num=t2.trade_num and t1.order_num=t2.order_num and t1.item_num=t2.item_num FOR XML PATH(''))+'$','_$','') AS cmdty_code  
      FROM #swap_flt_data t1) AS ta2   
 ON ta1.trade_num=ta2.trade_num and ta1.order_num=ta2.order_num and ta1.item_num=ta2.item_num  
  
 --dirty hack to update premium/diff  
 UPDATE ta1  
 SET ta1.tradeprice=ta2.float_diff  
 FROM #output ta1  
 JOIN (SELECT t1.trade_num,  
     t1.order_num,  
     t1.item_num,  
     t1.float_diff  
      FROM #swap_flt_data t1 where ABS(t1.float_diff) > 0) AS ta2   
 ON ta1.trade_num=ta2.trade_num and ta1.order_num=ta2.order_num and ta1.item_num=ta2.item_num  
  
 --update pl and avg price  
  update t2  
  set realised_avg_price = case when ABS(isnull(realised_qty,0)) < 0.1 then 0 else case when ABS(isnull(bblqty,0)) < 0.1 then 0 else (isnull(total_pl,0)/isnull(bblqty,1)) end end +tradeprice,  
   evaluated_avg_price = case when ABS(isnull(evaluated_qty,0)) < 0.1 then 0 else case when ABS(isnull(bblqty,0)) < 0.1 then 0 else (isnull(total_pl,0)/isnull(bblqty,1)) end end +tradeprice,  
   realised_pl = case when ABS(isnull(bblqty,0)) < 0.1 then 0 else (isnull(total_pl,0) * realised_qty / isnull(bblqty,1)) end,  
   evaluated_pl = case when ABS(isnull(bblqty,0)) < 0.1 then 0 else (isnull(total_pl,0) * evaluated_qty / isnull(bblqty,1)) end  
     from #output t2  
  where order_type='SWAPFLT'  
     
  -- Futures    
 insert into #output     
 (      
  toi,    
  mkt_code,    
  product,    
  pricing_period,    
  tradedate,    
  bblqty,    
  mtqty,    
  cp,    
  tradeprice,    
  trader,    
  book,    
  pricing_from,    
  pricing_to,    
  no_of_days,    
  days_passed,    
  realised_qty,    
  realised_avg_price,    
  realised_pl,    
  evaluated_qty,    
  evaluated_avg_price,    
  evaluated_pl,    
  total_pl,    
  due_date,    
  trading_prd_desc,  
  trading_prd,    
  order_type,    
  grp_type,  
  port_num  
 )     
 select     
    convert(varchar, ti.trade_num) + '/' + convert(varchar, ti.order_num) + '/' + convert(varchar, ti.item_num) as 'toi',    
    ti.risk_mkt_code as 'mkt_code',    
    ti.cmdty_code as 'product',    
    substring(tp.trading_prd_desc, 0, 4) as 'pricing_period',    
    convert(varchar, t.contr_date, 101) as 'tradedate',     
 case when tif.fill_qty IS NULL then   
    0  
    else   
    ABS(tif.fill_qty * tid.qty_uom_conv_rate * dbo.udf_getUomConversion(tidmtm.qty_uom_code_conv_to, 'BBL', tidmtm.sec_conversion_factor, tidmtm.sec_qty_uom_code, ti.cmdty_code))   
    end as bblqty,  
    --ABS(tidmtm.dist_qty * tid.qty_uom_conv_rate * dbo.udf_getUomConversion(tidmtm.qty_uom_code_conv_to, 'BBL', tidmtm.sec_conversion_factor, tidmtm.sec_qty_uom_code, ti.cmdty_code)) as bblqty,    
    0 as mtqty,    
    case t.inhouse_ind when 'N' then cp.acct_short_name     
                       else ihp.port_short_name     
    end as 'cp',     
    ti.avg_price as 'tradeprice',    
    t.trader_init as 'trader',    
    bkcp.acct_short_name as 'book',     
    convert(varchar, tif.fill_date, 101) as 'pricing_from',    
    convert(varchar, tif.fill_date, 101) as 'pricing_to',    
    1 as 'no_of_days',    
    1 as 'days_passed',    
    case when tp.last_trade_date < @my_as_of_Date then ABS(tidmtm.dist_qty * tid.qty_uom_conv_rate * dbo.udf_getUomConversion(tidmtm.qty_uom_code_conv_to, 'BBL', tidmtm.sec_conversion_factor, tidmtm.sec_qty_uom_code, ti.cmdty_code)) end as 'realised_qty',
    
    case when tp.last_trade_date < @my_as_of_Date then ABS(tidmtm.market_value/(tidmtm.dist_qty * tid.qty_uom_conv_rate * dbo.udf_getUomConversion(tidmtm.qty_uom_code_conv_to, 'BBL', tidmtm.sec_conversion_factor, tidmtm.sec_qty_uom_code, ti.cmdty_code))) 
end as 'realised_avg_price',    
    case when tp.last_trade_date < @my_as_of_Date then (isnull(tidmtm.open_pl,0) + isnull(tidmtm.closed_pl,0) + isnull(tidmtm.addl_cost_sum,0)) end as 'realised_pl',    
    case when tp.last_trade_date >= @my_as_of_Date then ABS(tidmtm.dist_qty * tid.qty_uom_conv_rate * dbo.udf_getUomConversion(tidmtm.qty_uom_code_conv_to, 'BBL', tidmtm.sec_conversion_factor, tidmtm.sec_qty_uom_code, ti.cmdty_code)) end as 'evaluated_qty
',    
    case when tp.last_trade_date >= @my_as_of_Date then ABS(tidmtm.market_value/(tidmtm.dist_qty * tid.qty_uom_conv_rate * dbo.udf_getUomConversion(tidmtm.qty_uom_code_conv_to, 'BBL', tidmtm.sec_conversion_factor, tidmtm.sec_qty_uom_code, ti.cmdty_code)))
 end as 'evaluated_avg_price',    
    case when tp.last_trade_date >= @my_as_of_Date then (isnull(tidmtm.open_pl,0) + isnull(tidmtm.closed_pl,0) + isnull(tidmtm.addl_cost_sum,0)) end as 'evaluated_pl',    
    (isnull(tidmtm.open_pl,0) + isnull(tidmtm.closed_pl,0) + isnull(tidmtm.addl_cost_sum,0)) as 'total_pl',     
    null as due_date,    
    tp.trading_prd_desc as 'trading_prd_desc',   
    tp.trading_prd as 'trading_prd',    
    'FUTURE',    
    'PAPER',  
    pl.real_port_num  
 from dbo.pl_history pl    
         join dbo.trade t     
            on t.trade_num = pl.pl_secondary_owner_key1    
         join dbo.trade_item ti     
            on ti.trade_num = pl.pl_secondary_owner_key1 and     
               ti.order_num = pl.pl_secondary_owner_key2 and     
               ti.item_num = pl.pl_secondary_owner_key3    
         join dbo.trade_item_dist tid     
            on tid.trade_num = pl.pl_secondary_owner_key1 and     
               tid.order_num = pl.pl_secondary_owner_key2 and     
               tid.item_num = pl.pl_secondary_owner_key3 and     
               dist_type = 'D'    
         left outer join dbo.account cp     
            on t.acct_num = cp.acct_num    
         left outer join dbo.account bkcp     
            on ti.booking_comp_num = bkcp.acct_num    
         join dbo.portfolio rp     
            on ti.real_port_num = rp.port_num    
         left outer join dbo.portfolio ihp     
            on t.port_num = ihp.port_num    
         left outer join dbo.trading_period tp     
            on tid.commkt_key = tp.commkt_key and     
               tid.trading_prd = tp.trading_prd    
         left outer join dbo.tid_mark_to_market tidmtm     
            on tidmtm.dist_num = tid.dist_num and     
               tidmtm.mtm_pl_asof_date = @my_as_of_Date  
  left outer join dbo.trade_item_fill tif     
            on tif.trade_num = ti.trade_num  and       
               tif.order_num =  ti.order_num and     
               tif.item_num = ti.item_num   
 where pl.pl_asof_date = @my_as_of_Date and         
      pl_owner_code = 'T' and     
      pl_owner_sub_code = 'F' and     
      pl_type='U' and  
      1 = (case when @my_book is NULL then 1  
     when '<NONE>' IN (select * from dbo.udf_split(@my_book, ',')) then 1  
                   when t.trader_init IN (select * from dbo.udf_split(@my_book, ',')) then 1  
                   else 0  
              end) AND  --Book Init    
       1 = (case when @my_port_num is NULL then 1  
     when '0' IN (select * from dbo.udf_split(@my_port_num, ',')) then 1  
                 when ti.real_port_num IN (select * from dbo.udf_split(@my_port_num, ',')) then 1  
                   else 0  
              end) AND  --PortFolios  
      tp.last_trade_date >= @my_pricing_from_date    
    
  -- PHYSICAL    
 insert into #output     
 (      
  toi,    
  mkt_code,    
  product,    
  pricing_period,    
  tradedate,    
  bblqty,    
  mtqty,    
  cp,    
  tradeprice,    
  trader,    
  book,    
  pricing_from,    
  pricing_to,    
  no_of_days,    
  days_passed,    
  realised_qty,    
  realised_avg_price,    
  realised_pl,    
  evaluated_qty,    
  evaluated_avg_price,    
  evaluated_pl,    
  total_pl,    
  due_date,    
  trading_prd_desc,  
  trading_prd,    
  order_type,    
  grp_type,    
  trade_num,    
  order_num,  
  item_num,  
  bench_mark,    
  pricing_qty_per_day,    
  premium,    
  additional_cost,    
  add_cost_per_bbl,    
  freight,    
  freight_per_bbl,    
  bl_date,    
  mt_bbl,  
  port_num  
 )     
select     
    convert(varchar, ti.trade_num) + '/' + convert(varchar, ti.order_num) + '/' + convert(varchar, ti.item_num) as 'toi',    
    ti.risk_mkt_code as 'mkt_code',    
    ti.cmdty_code 'product',    
    substring(tp.trading_prd_desc, 0, 4) as 'pricing_period',    
    convert(varchar, t.contr_date, 101) as 'tradedate',    
    ABS(tidmtm.dist_qty * tid.qty_uom_conv_rate * dbo.udf_getUomConversion(tidmtm.qty_uom_code, 'BBL', tidmtm.sec_conversion_factor, tidmtm.sec_qty_uom_code, ti.cmdty_code)) as 'bblqty',    
    ABS(tidmtm.dist_qty * tid.qty_uom_conv_rate * dbo.udf_getUomConversion(tidmtm.qty_uom_code, 'MT', tidmtm.sec_conversion_factor, tidmtm.sec_qty_uom_code, ti.cmdty_code)) as 'mmqty',    
    case t.inhouse_ind     
       when 'N' then cp.acct_short_name     
       else ihp.port_short_name     
    end as 'cp',    
     null as 'traderprice',    
    t.trader_init as 'trader',    
    bkcp.acct_short_name as 'book',    
    case ti.formula_ind
    when 'Y' then convert(varchar, nomin_start_date, 101) 
    when 'N' then convert(varchar, t.contr_date, 101) end as 'pricing_from',
    case ti.formula_ind
    when 'Y' then convert(varchar, nomin_end_date, 101) 
    when 'N' then convert(varchar, t.contr_date, 101) end as 'pricing_to',
    case ti.formula_ind
    when 'Y' then num_of_pricing_days 
    when 'N' then 1 end as 'no_of_days',
    case ti.formula_ind
    when 'Y' then num_of_days_priced 
    when 'N' then 1 end as 'days_passed',    
    case when num_of_pricing_days > 0 then tidmtm.dist_qty * num_of_days_priced/num_of_pricing_days  
  else tidmtm.dist_qty  
  end as 'realised_qty',    
    case when ((tidmtm.dist_qty - tidmtm.alloc_qty) > 0) then tidmtm.trade_value / (tidmtm.dist_qty-tidmtm.alloc_qty)  
         else ti.avg_price  
         end as 'realised_avg_price',     
    (case when num_of_pricing_days > 0 then tidmtm.dist_qty * num_of_days_priced/num_of_pricing_days  
  else tidmtm.dist_qty  
  end) *  
    (case when ((tidmtm.dist_qty - tidmtm.alloc_qty) > 0) then tidmtm.trade_value / (tidmtm.dist_qty-tidmtm.alloc_qty)  
         else ti.avg_price  
         end) as 'realised_pl',     
    case when num_of_pricing_days > num_of_days_priced then tidmtm.dist_qty * (num_of_pricing_days - num_of_days_priced)/num_of_pricing_days  
  else 0  
  end   
  as 'evaluated_qty', --unpriced qty both in MT    
    case when qpp.total_qty > 0 then qpp.open_price  
  when ((tidmtm.dist_qty - tidmtm.alloc_qty) > 0) then tidmtm.trade_value / (tidmtm.dist_qty-tidmtm.alloc_qty)  
         else ti.avg_price  
         end   
         as 'evaluated_avg_price',      
    tidmtm.open_pl as 'evaluated_pl',     
    tidmtm.addl_cost_sum as 'total_pl',     
    null as 'due_date',        tp.trading_prd_desc as 'trading_prd_desc',  
    tp.trading_prd as 'trading_prd',    
    'PHYSICAL' as order_type,    
    'PHYSICAL',    
    ti.trade_num,     
    ti.order_num,     
    ti.item_num,     
    null,     
    ABS(tidmtm.dist_qty * tid.qty_uom_conv_rate * dbo.udf_getUomConversion(tidmtm.qty_uom_code, 'MT',  
   tidmtm.sec_conversion_factor, tidmtm.sec_qty_uom_code,ti.cmdty_code)) /  
  (Case num_of_pricing_days when 0 then 1 else num_of_pricing_days end) as 'pricing_qty_per_day',    
    null,

    null as 'additional_cost',    
    null as 'add_cost_per_bbl',    
    null as 'freight', 
    null as 'freight_per_bbl',    
    null as 'bl_date',    
    dbo.udf_getUomConversion('MT', 'BBL', tidmtm.sec_conversion_factor, tidmtm.sec_qty_uom_code, ti.cmdty_code) as 'mt_bbl',  
    pl.real_port_num  
 from dbo.pl_history pl    
         join dbo.trade t     
            on t.trade_num = pl.pl_secondary_owner_key1    
         join dbo.trade_item ti     
            on ti.trade_num = pl.pl_secondary_owner_key1 and     
               ti.order_num = pl.pl_secondary_owner_key2 and     
               ti.item_num = pl.pl_secondary_owner_key3    
         join dbo.trade_item_dist tid     
            on tid.trade_num = pl.pl_secondary_owner_key1 and     
               tid.order_num = pl.pl_secondary_owner_key2 and     
               tid.item_num = pl.pl_secondary_owner_key3 and     
               dist_type = 'D'  and tid.real_port_num=ti.real_port_num  
         left outer join dbo.account cp     
            on t.acct_num = cp.acct_num    
         left outer join dbo.account bkcp     
            on ti.booking_comp_num = bkcp.acct_num    
         join dbo.portfolio rp     
            on ti.real_port_num = rp.port_num    
         left outer join dbo.portfolio ihp     
            on t.port_num = ihp.port_num    
         left outer join dbo.trading_period tp     
            on tid.commkt_key = tp.commkt_key and     
               tid.trading_prd = tp.trading_prd    
         left outer join dbo.tid_mark_to_market tidmtm     
            on tidmtm.dist_num = tid.dist_num and     
               mtm_pl_asof_date = @my_as_of_Date  
         left outer join (select trade_num,     
                                 order_num,     
                                 item_num,min(nominal_start_date) as nomin_start_date,     
                                 max(nominal_end_date) as nomin_end_date,     
                                 sum(num_of_pricing_days) as num_of_pricing_days,     
                                 sum(num_of_days_priced) as num_of_days_priced,  
                                 sum(total_qty) as total_qty,  
         sum(isnull(priced_qty,0)) as priced_qty,  
                                 sum((isnull(priced_qty,0) * isnull(priced_price,0)))/sum(isnull(priced_qty,0.00001)) as priced_price,  
                                 sum((isnull(total_qty,0) - isnull(priced_qty,0))* isnull(open_price,0))/  
                                   sum(isnull(total_qty,0) - isnull(priced_qty,0) + 0.000000001) as open_price  
                      from dbo.quote_pricing_period qpp    
                      group by trade_num, order_num, item_num) qpp     
        on qpp.trade_num = ti.trade_num and     
           qpp.order_num = ti.order_num and     
           qpp.item_num = ti.item_num
	where pl.pl_asof_date = @my_as_of_Date and       
      pl_owner_code = 'T' and     
      pl_owner_sub_code = 'W' and  pl_type='U' and  pl.real_port_num=ti.real_port_num and   
        1 = (case when @my_book is NULL then 1  
     when '<NONE>' IN (select * from dbo.udf_split(@my_book, ',')) then 1  
                   when t.trader_init IN (select * from dbo.udf_split(@my_book, ',')) then 1  
                   else 0  
              end) AND  --Book Init    
       1 = (case when @my_port_num is NULL then 1  
     when '0' IN (select * from dbo.udf_split(@my_port_num, ',')) then 1  
                 when ti.real_port_num IN (select * from dbo.udf_split(@my_port_num, ',')) then 1  
                   else 0  
              end) AND  --PortFolios  
       ((nomin_start_date is null and t.contr_date > @my_pricing_from_date) or nomin_start_date >= @my_pricing_from_date    )
CREATE TABLE #freight 
  (  
  trade_num int,  
  order_num int,  
  item_num int,
  port_num   int,   
  cost_amt decimal(20,8)  
  )
INSERT INTO #freight 
 select c.cost_owner_key1,c.cost_owner_key2,c.cost_owner_key3,c.port_num,sum(c.cost_amt) 
from cost c inner join #output t1 on t1.trade_num = c.cost_owner_key1 and     
               t1.order_num = c.cost_owner_key2 and     
               t1.item_num = c.cost_owner_key3  and 
			   t1.port_num=c.port_num  and c.cost_type_code  not in ('WPP') and c.cost_code = 'FREIGHT'
group by c.cost_owner_key1,c.cost_owner_key2,c.cost_owner_key3,c.port_num
order by c.cost_owner_key1,c.cost_owner_key2,c.cost_owner_key3,c.port_num
--updating Freight
update t1  
  set t1.freight=fr.cost_amt 
from  #output t1 inner join #freight fr on t1.trade_num = fr.trade_num and     
               t1.order_num = fr.order_num and     
               t1.item_num = fr.item_num  and 
			   t1.port_num=fr.port_num 

 CREATE TABLE #additional_cost 
  (  
  trade_num int,  
  order_num int,  
  item_num int,
  port_num   int,   
  cost_amt decimal(20,8)  
  )
INSERT INTO #additional_cost
 select c.cost_owner_key1,c.cost_owner_key2,c.cost_owner_key3,c.port_num,sum(c.cost_amt) 
from dbo.cost c inner join #output t1 on t1.trade_num = c.cost_owner_key1 and     
               t1.order_num = c.cost_owner_key2 and     
               t1.item_num = c.cost_owner_key3  and 
			   t1.port_num=c.port_num  and c.cost_type_code  not in ('WPP') and c.cost_code <> 'FREIGHT'
group by c.cost_owner_key1,c.cost_owner_key2,c.cost_owner_key3,c.port_num
order by c.cost_owner_key1,c.cost_owner_key2,c.cost_owner_key3,c.port_num 
--updating additional_cost
update t1  
  set t1.additional_cost=ac.cost_amt 
from  #output t1 inner join  #additional_cost ac on t1.trade_num = ac.trade_num and     
              t1.order_num = ac.order_num and     
              t1.item_num = ac.item_num  and 
	      t1.port_num=ac.port_num

  
  --Updating bl_date  
  update t1  
  set bl_date=convert(varchar,t2.bl_date,101)  
  from #output t1  
  join (select convert(varchar, t3.trade_num) + '/' + convert(varchar, t3.order_num) + '/' + convert(varchar, t3.item_num) as 'toi',  
      max(ait.bl_date) as bl_date  
  from dbo.allocation_item_transport ait  
        join dbo.allocation_item ai on ai.alloc_num=ait.alloc_num  
  join #output t3 on t3.trade_num=ai.trade_num and t3.order_num=ai.order_num and t3.item_num=ai.item_num   
  group by t3.trade_num,t3.order_num,t3.item_num) t2 on t1.toi=t2.toi  
  
  
  CREATE TABLE #phy_premium_data 
  (  
  trade_num int,  
  order_num int,  
  item_num int,   
  diff_val decimal(20,8)  
  )  

  
 INSERT INTO #phy_premium_data  
 SELECT  DISTINCT ti.trade_num,  
   ti.order_num,   
   ti.item_num,  
   sum(differential_val)
 FROM dbo.trade_item ti 
    join dbo.trade_order tor on ti.trade_num=tor.trade_num and ti.order_num=tor.order_num 
    join dbo.trade_formula tf   
    on ti.trade_num = tf.trade_num and
    ti.order_num = tf.order_num and   
    ti.item_num = tf.item_num  
    join dbo.formula f   
    on tf.formula_num = f.formula_num  
    join dbo.formula_body fb  
    on fb.formula_num = f.formula_num and
    fb.complexity_ind = 'S' and 
    fb.differential_val <> 0
  where tor.order_type_code in ('PHYSICAL')
group by ti.trade_num,ti.order_num,ti.item_num
order by ti.trade_num,ti.order_num,ti.item_num

 -- update premium/diff  
 UPDATE ta1  
 SET ta1.premium=ta2.diff_val  
 FROM #output ta1  
 JOIN (SELECT t1.trade_num,  
     t1.order_num,  
     t1.item_num,  
     t1.diff_val  
      FROM #phy_premium_data t1 where ABS(t1.diff_val) > 0) AS ta2   
 ON ta1.trade_num=ta2.trade_num and ta1.order_num=ta2.order_num and ta1.item_num=ta2.item_num 

-- update realised and evaluated values.. these are NOT PL  
  -- Revised requirement: The premium should be included in both the realized and evaluated price columns. Please include this rework in the original issue number 108245 
  -- update t1 set realised_avg_price = realised_avg_price - premium, evaluated_avg_price = evaluated_avg_price - premium from #output t1 where order_type='PHYSICAL'


 -- update realised and evaluated values.. these are NOT PL  
  update t1 set realised_pl= isnull(realised_avg_price, 0) * isnull (realised_qty, 0), evaluated_pl = isnull(evaluated_avg_price, 0) * isnull (evaluated_qty, 0) from #output t1 where order_type='PHYSICAL'  
  
  -- update total value  
  update t1 set total_pl = isnull(realised_pl,0) + isnull(evaluated_pl, 0) + isnull(total_pl, 0) from #output t1 where order_type='PHYSICAL' 
    

  --Show output    
  select      
     toi as 'ICTS',    
   mkt_code,    
   product,    
   pricing_period,    
   tradedate,    
   bblqty,    
   mtqty,    
   cp,    
   tradeprice,    
   trader,    
   book,    
   pricing_from,    
   pricing_to,    
   no_of_days,    
   days_passed,    
   realised_qty,    
   realised_avg_price,    
   realised_pl,    
   evaluated_qty,    
   evaluated_avg_price,    
   evaluated_pl,    
   total_pl,    
   due_date,    
   trading_prd_desc,  
   trading_prd,  
   rtrim(order_type) as order_type,    
   grp_type,    
   trade_num,    
   bench_mark,    
   pricing_qty_per_day,    
   premium,    
   additional_cost,    
   add_cost_per_bbl,    
   freight,    
   freight_per_bbl,    
   bl_date,    
   mt_bbl,  
   port_num  
  from #output     
    
  DROP TABLE #output    
  drop table #trade_item  
  drop table #swap_flt_data
  drop table #phy_premium_data
  drop table #freight
  drop table #additional_cost
    
endofsp:      
return 0
GO
GRANT EXECUTE ON  [dbo].[usp_MTM_pl_report] TO [next_usr]
GO
