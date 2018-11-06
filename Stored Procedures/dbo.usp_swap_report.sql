SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_swap_report]
(  
   @port_nums    varchar(8000),  
   @trades       varchar(8000),           
   @from_date    datetime,  
   @to_date      datetime  
)  
as  
set nocount on  
declare @rows_affected          int,   
        @smsg                   varchar(255),   
        @status                 int,   
        @oid                    numeric(18, 0),   
        @stepid                 smallint,   
        @session_started        varchar(30),   
        @session_ended          varchar(30),   
        @my_port_nums           varchar(8000),  
        @my_trades              varchar(8000),          
        @my_from_date           datetime,  
        @my_to_date             datetime  
  
select    @my_port_nums = @port_nums,   
          @my_trades = @trades,  
          @my_from_date = @from_date,   
          @my_to_date = @to_date  
  
create table #temp_fixed_swap   
  (   
     p_ty            VARCHAR(10),   
     p_com           VARCHAR(255),   
     p_riskmkt       VARCHAR(255),   
     s_ty            VARCHAR(10),   
     s_com           VARCHAR(255),   
     s_riskmkt       VARCHAR(255),   
     quantity        FLOAT,   
     fix_price       VARCHAR(20),   
     float_p         VARCHAR(255),   
     float_s         VARCHAR(255),   
     uml_p           CHAR(8),   
     uml_s           CHAR(8),   
     real_commodity  VARCHAR(500),   
     signed_quantity FLOAT,   
     trade_num       INT,   
     order_num       INT,   
     item_num        INT,  
     acct_short_name VARCHAR(255),  
     port_num        INT,  
     contr_date      DATETIME,  
     effect_date     DATETIME,  
     formula_desc    VARCHAR(500)  
  )    

  insert into #temp_fixed_swap  
  select case ti.p_s_ind when 'P' then 'FIXED' else 'FLOAT' end,  
       null,  
       null,  
       case ti.p_s_ind when 'P' then 'FLOAT' else 'FIXED' end,  
       null,   
       null,  
       dtid.dist_qty,  
       convert(varchar,abs(convert(float,formula_body_string))),  
       'FIXED',  
       'FIXED',  
       case ti.p_s_ind when 'P' then '' else dtid.qty_uom_code end,  
       case ti.p_s_ind when 'S' then '' else dtid.qty_uom_code end,  
       null,   
       case ti.p_s_ind when 'P' then dtid.dist_qty else dtid.dist_qty * -1 end,  
       ti.trade_num,  
       ti.order_num,  
       ti.item_num,  
       a.acct_short_name,  
       dtid.real_port_num,  
       convert(varchar(10),t.contr_date,101) as contr_date,  
       convert(varchar(10),c.cost_eff_date,101) as cost_eff_date,  
       cmnt.cmnt_text  
  from dbo.trade t  
  join dbo.trade_order tor 
       on tor.trade_num=t.trade_num  
  join dbo.trade_item ti 
       on tor.trade_num=ti.trade_num and 
          tor.order_num=ti.order_num  
  join dbo.trade_formula tf 
       on ti.trade_num=tf.trade_num and 
          ti.order_num=tf.order_num and 
	  ti.item_num=tf.item_num  
  left outer join dbo.formula_body fb 
       on tf.formula_num=fb.formula_num and 
          formula_body_type ='M'  
  join dbo.trade_item_dist dtid 
       on ti.trade_num=dtid.trade_num and 
          ti.order_num=dtid.order_num and 
	  ti.item_num=dtid.item_num and 
	  dist_type='D'  
  left outer join dbo.cost c 
       on c.cost_owner_key6 = ti.trade_num and 
          c.cost_owner_key7=ti.order_num and 
	  c.cost_owner_key8=ti.item_num and 
	  cost_type_code='SWAP'  
  left outer join dbo.account a 
       on a.acct_num = t.acct_num  
  left outer join dbo.comment cmnt 
       on cmnt.cmnt_num = ti.cmnt_num  
  where order_type_code ='SWAP' and 
        conclusion_type='C'and 
        a.acct_num is not null and 
        t.contr_date>=@my_from_date and 
	t.contr_date<=@my_to_date and  
        1 = (case when @my_trades is null then 1     
                  when t.trader_init in (Select * from dbo.udf_split(@my_trades,',')) then 1    
             else 0    
             end) and  
        1 = (case when @my_port_nums is null then 1     
                  when dtid.real_port_num in (Select * from dbo.udf_split(@my_port_nums,',')) then 1    
             else 0    
             end)  
  
  create table #cmdty_mkt_data   
  (   
     trade_num        INT,   
     order_num        INT,   
     item_num         INT,   
     cmdty_short_name VARCHAR(15),   
     mkt_code         CHAR(8),   
     trading_prd_desc VARCHAR(40),   
     p_s_ind          CHAR(1),   
     float_qty        FLOAT,   
     float_diff       VARCHAR(20)   
  )    
  
  insert into #cmdty_mkt_data  
  select distinct ti.trade_num,   
                  ti.order_num,   
                  ti.item_num,   
                  c.cmdty_short_name,   
                  cm.mkt_code,   
                  prd.trading_prd_desc,   
                  NULL,   
                  NULL,   
                  NULL   
  from #temp_fixed_swap ti   
  join dbo.accumulation acc   
       on ti.trade_num = acc.trade_num and  
          ti.order_num = acc.order_num and  
          ti.item_num = acc.item_num   
  join dbo.quote_pricing_period qpp   
       on acc.trade_num = qpp.trade_num and  
       acc.order_num = qpp.order_num and  
       acc.item_num = qpp.item_num and  
       acc.accum_num = qpp.accum_num  
  join dbo.formula_component fc   
       on fc.formula_num = qpp.formula_num and  
          fc.formula_body_num = qpp.formula_body_num and  
          fc.formula_comp_num = qpp.formula_comp_num   
  join dbo.commodity_market cm   
       on cm.commkt_key = fc.commkt_key          
  join dbo.commodity c
       on c.cmdty_code = cm.cmdty_code 
  join dbo.trading_period prd   
       on prd.commkt_key = fc.commkt_key and  
          prd.trading_prd = fc.trading_prd    
  
  
  update ta1  
  set ta1.p_com=ta2.cmdty_short_name,  
      ta1.s_com=ta2.cmdty_short_name,  
      ta1.real_commodity=ta2.cmdty_short_name,  
      ta1.p_riskmkt=ta2.mkt_code,  
      ta1.s_riskmkt=ta2.mkt_code  
 from #temp_fixed_swap ta1  
 join (select t1.trade_num,  
              t1.order_num,  
              t1.item_num,  
              t1.p_s_ind,  
              replace((select rtrim(t2.cmdty_short_name) + ' Vs ' as 'data()'   
       from #cmdty_mkt_data t2   
       where t1.trade_num=t2.trade_num and 
             t1.order_num=t2.order_num and 
	     t1.item_num=t2.item_num FOR XML PATH(''))+'$','Vs $','') as cmdty_short_name,  
       replace((select rtrim(t3.mkt_code) + ' Vs ' as 'data()'   
       from #cmdty_mkt_data t3   
       where t1.trade_num=t3.trade_num and 
             t1.order_num=t3.order_num and 
	     t1.item_num=t3.item_num FOR XML PATH(''))+'$','Vs $','') as mkt_code,  
       replace((select rtrim(t4.cmdty_short_name)+'_'+rtrim(t4.mkt_code)+'_'+rtrim(t4.trading_prd_desc)+ ' Vs ' as 'data()'   
       from #cmdty_mkt_data t4   
       where t1.trade_num=t4.trade_num and 
             t1.order_num=t4.order_num and 
	     t1.item_num=t4.item_num FOR XML PATH(''))+'$','Vs $','') as real_cmdty  
       from #cmdty_mkt_data t1) as ta2 
 on ta1.trade_num=ta2.trade_num and 
    ta1.order_num=ta2.order_num and 
    ta1.item_num=ta2.item_num  
  
  
delete #cmdty_mkt_data  
  
CREATE TABLE #temp_float_swap   
  (   
     p_ty            VARCHAR(10),   
     p_com           VARCHAR(255),   
     p_riskmkt       VARCHAR(255),   
     s_ty            VARCHAR(10),   
     s_com           VARCHAR(255),   
     s_riskmkt       VARCHAR(255),   
     quantity        FLOAT,   
     fix_price       VARCHAR(20),   
     float_p         VARCHAR(255),   
     float_s         VARCHAR(255),   
     uml_p           CHAR(8),   
     uml_s           CHAR(8),   
     real_commodity  VARCHAR(500),   
     signed_quantity FLOAT,   
     trade_num       INT,   
     order_num       INT,   
     item_num        INT,  
     acct_short_name VARCHAR(255),  
     port_num         INT,  
     contr_date       DATETIME,  
     effect_date      DATETIME,  
     formula_desc     VARCHAR(500)   
  )    
INSERT INTO #temp_float_swap  
select 'FLOAT',  
  null,  
  null,  
  'FLOAT',  
  null,  
  null,   
  null,  
  'FLOAT',  
  null,  
  null,  
  ti.contr_qty_uom_code,  
  ti.contr_qty_uom_code,  
  null,  
  null,  
  ti.trade_num,  
  ti.order_num,  
  ti.item_num,  
  a.acct_short_name,  
                dtid.real_port_num,  
                convert(varchar(10),t.contr_date,101) as contr_date,  
                convert(varchar(10),c.cost_eff_date,101) as cost_eff_date,  
                cmnt.cmnt_text  
  from dbo.trade t  
  join dbo.trade_order tor 
       on tor.trade_num = t.trade_num  
  join dbo.trade_item ti 
       on tor.trade_num = ti.trade_num and 
          tor.order_num=ti.order_num  
  join dbo.trade_formula tf 
       on ti.trade_num = tf.trade_num and 
          ti.order_num=tf.order_num and 
	  ti.item_num=tf.item_num  
  left outer join dbo.formula_body fb 
       on tf.formula_num = fb.formula_num and 
          formula_body_type = 'M'  
  join dbo.trade_item_dist dtid 
       on ti.trade_num = dtid.trade_num and 
          ti.order_num = dtid.order_num and 
	  ti.item_num = dtid.item_num and 
	  dist_type = 'D'  
  left outer join dbo.cost c 
       on c.cost_owner_key6 = ti.trade_num and 
          c.cost_owner_key7 = ti.order_num and 
	  c.cost_owner_key8 = ti.item_num and 
	  cost_type_code = 'SWAP'  
  left outer join dbo.account a 
       on a.acct_num = t.acct_num  
  left outer join dbo.comment cmnt 
       on cmnt.cmnt_num = ti.cmnt_num  
  where order_type_code = 'SWAPFLT' and 
        conclusion_type='C' and 
	a.acct_num is not null and 
	t.contr_date >= @my_from_date and 
	t.contr_date <= @my_to_date and  
        1 = (case when @my_trades is null then 1     
                  when t.trader_init in (Select * from dbo.udf_split(@my_trades,',')) then 1    
                  else 0    
              end) and  
        1 = (case when @my_port_nums is null then 1     
                  when ti.real_port_num in (Select * from dbo.udf_split(@my_port_nums,',')) then 1    
                  else 0    
              end)  
  
  insert into #cmdty_mkt_data  
  select distinct ti.trade_num,   
                  ti.order_num,   
                  ti.item_num,   
                  c.cmdty_short_name,   
                  cm.mkt_code,   
                  prd.trading_prd_desc,   
                  case formula_name when 'SwapBuyFloat' then 'P'   
                                    when 'SwapSellFloat' then 'S'   
                       else null   
                  end,   
                 accum_qty,   
                 case when charindex('-', formula_body_string) > 0 then    
                           substring(formula_body_string, charindex('-', formula_body_string), len(formula_body_string))   
                      when charindex('+', formula_body_string) > 0 then   
                      substring(formula_body_string, charindex('+', formula_body_string), len(formula_body_string))   
                 else null   
                 end substring   
  from #temp_float_swap ti   
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
            fb.formula_body_num = qpp.formula_body_num and  
            formula_body_type = 'Q'   
    join dbo.formula_component fc   
         on fc.formula_num = qpp.formula_num and  
            fc.formula_body_num = qpp.formula_body_num and  
            fc.formula_comp_num = qpp.formula_comp_num          
    join dbo.commodity_market cm   
         on cm.commkt_key = fc.commkt_key   
    join dbo.commodity c
         on c.cmdty_code = cm.cmdty_code 
    join dbo.trading_period prd   
         on prd.commkt_key = fc.commkt_key and  
            prd.trading_prd = fc.trading_prd    
  
 update ta1  
 set ta1.p_com = ta2.p_cmdty_short_name,  
     ta1.s_com = ta2.s_cmdty_short_name,  
     ta1.real_commodity = ta2.cmdty_short_name,  
     ta1.p_riskmkt = ta2.p_mkt_code,  
     ta1.s_riskmkt = ta2.s_mkt_code,  
     ta1.quantity = float_qty,  
     ta1.signed_quantity = float_qty,  
     ta1.float_p = p_float_diff,  
     ta1.float_s = s_float_diff  
 from #temp_float_swap ta1  
 join (SELECT t1.trade_num,  
              t1.order_num,  
              t1.item_num,  
              t1.p_s_ind,  
              t1.float_qty,  
     replace((select rtrim(t2.cmdty_short_name) + ' Vs ' as 'data()' 
              from #cmdty_mkt_data t2   
              where t1.trade_num = t2.trade_num and 
	            t1.order_num = t2.order_num and 
		    t1.item_num = t2.item_num and 
		    t2.p_s_ind = 'P' FOR XML PATH(''))+'$','Vs $','') as p_cmdty_short_name,  
     replace((select rtrim(t3.mkt_code) + ' Vs ' as 'data()'   
              from #cmdty_mkt_data t3   
              where t1.trade_num = t3.trade_num and 
	            t1.order_num = t3.order_num and 
		    t1.item_num = t3.item_num and 
		    t3.p_s_ind = 'P' FOR XML PATH(''))+'$','Vs $','') as p_mkt_code,  
     replace((select rtrim(t4.cmdty_short_name) + ' Vs ' as 'data()'   
              from #cmdty_mkt_data t4   
              where t1.trade_num = t4.trade_num and 
	            t1.order_num = t4.order_num and 
		    t1.item_num = t4.item_num and
		    t4.p_s_ind = 'S' FOR XML PATH(''))+'$','Vs $','') as s_cmdty_short_name,  
     replace((select rtrim(t5.mkt_code) + ' Vs ' as 'data()'   
              from #cmdty_mkt_data t5   
              where t1.trade_num = t5.trade_num and 
	            t1.order_num = t5.order_num and 
		    t1.item_num = t5.item_num and 
		    t5.p_s_ind = 'S' FOR XML PATH(''))+'$','Vs $','') as s_mkt_code,  
     replace((select rtrim(t6.cmdty_short_name)+'_'+rtrim(t6.mkt_code)+'_'+rtrim(t6.trading_prd_desc)+ ' Vs ' as 'data()'   
              from #cmdty_mkt_data t6   
              where t1.trade_num = t6.trade_num and 
	            t1.order_num=t6.order_num and 
		    t1.item_num=t6.item_num FOR XML PATH(''))+'$','Vs $','') AS cmdty_short_name,  
     replace((select rtrim(t7.float_diff) + ',' as 'data()'   
              from #cmdty_mkt_data t7   
              where t1.trade_num = t7.trade_num and 
	            t1.order_num = t7.order_num and 
		    t1.item_num = t7.item_num and 
		    t7.p_s_ind = 'P' and 
		    float_diff is not null FOR XML PATH(''))+'$',',$','') AS p_float_diff,  
     replace((select rtrim(t8.float_diff) + ',' as 'data()'   
              from #cmdty_mkt_data t8   
              where t1.trade_num = t8.trade_num and 
	            t1.order_num = t8.order_num and 
		    t1.item_num = t8.item_num and 
		    t8.p_s_ind = 'S' and 
		    float_diff is not null FOR XML PATH(''))+'$',',$','') AS s_float_diff  
     from #cmdty_mkt_data t1) as ta2 
     on ta1.trade_num = ta2.trade_num and 
        ta1.order_num = ta2.order_num and 
	ta1.item_num=ta2.item_num 
	
select * from  #temp_float_swap   
union
select * from  #temp_fixed_swap    
  
drop table #temp_float_swap  
drop table #temp_fixed_swap  
drop table #cmdty_mkt_data  
  
endofsp:   
return 0
GO
GRANT EXECUTE ON  [dbo].[usp_swap_report] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_swap_report', NULL, NULL
GO
