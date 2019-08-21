SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[usp_compare_tid_mtm]        
  @resp_trans_id_NEW     int,        
  @resp_trans_id_OLD       int,        
  @portnum                int = null,        
  @digits_for_scale4      tinyint = 4,        
  @digits_for_scale7      tinyint = 7          
as        
set nocount on        
        
   print ' '        
   print '==================================================='        
   print ' DATA : tid_mark_to_market'        
   print '==================================================='        
   print ' '        
        
   select resp_trans_id,         
         real_port_num,        
         dist_num,         
         mtm_pl_asof_date,         
          str(open_pl, 38, @digits_for_scale4) as open_pl,        
          str(closed_pl, 38, @digits_for_scale4) as closed_pl,        
          str(addl_cost_sum, 38, @digits_for_scale4) as addl_cost_sum,        
          str(delta, 38, @digits_for_scale7) as delta,        
         trans_id,         
          str(vega, 38, @digits_for_scale7) as vega,        
          str(volatility, 38, @digits_for_scale7) as volatility,        
          str(theta, 38, @digits_for_scale7) as theta,        
          str(curr_conv_rate, 38, @digits_for_scale7) as curr_conv_rate,        
         curr_code_conv_from,         
         curr_code_conv_to,         
          str(interest_rate, 38, @digits_for_scale7) as interest_rate,        
          str(isnull(price_diff_value, 0.0), 38, @digits_for_scale7) as price_diff_value,        
          str(dist_qty, 38, @digits_for_scale4) as dist_qty,        
          str(alloc_qty, 38, @digits_for_scale4) as alloc_qty,        
          str(trade_value, 38, @digits_for_scale4) as trade_value,        
          str(market_value, 38, @digits_for_scale4) as market_value,        
         curr_code,         
         qty_uom_code,         
          str(gamma, 38, @digits_for_scale7) as gamma,        
          str(discount_factor, 38, @digits_for_scale7) as discount_factor,        
          str(rho, 38, @digits_for_scale7) as rho,        
          str(drift, 38, @digits_for_scale7) as drift,        
         trade_modified_ind,         
         commkt_key,         
         pos_num,         
         trade_num,         
         order_num,         
         item_num,         
         qty_uom_code_conv_to,         
         sec_qty_uom_code,         
          str(sec_conversion_factor, 38, @digits_for_scale7) as sec_conversion_factor,        
         trading_prd,         
         last_trade_date,         
         dist_type,         
         p_s_ind,         
         opt_model_type,         
         leg_total_days,         
         opt_priced_days,         
          str(opt_priced_price, 38, @digits_for_scale4) as opt_priced_price,        
          str(opt_avg_correlation, 38, @digits_for_scale7) as opt_avg_correlation,        
          str(priced_qty, 38, @digits_for_scale4) as priced_qty,        
          str(qty_uom_conv_rate, 38, @digits_for_scale4) as qty_uom_conv_rate,        
          str(avg_price, 38, @digits_for_scale4) as avg_price        
   into #tidmtm        
  from dbo.aud_tid_mark_to_market a,         
      (select dist_num as distnum,         
               real_port_num         
       from dbo.trade_item_dist) b        
   where a.dist_num = b.distnum and        
        resp_trans_id in (@resp_trans_id_NEW, @resp_trans_id_OLD) and         
        1 = case when @portnum is null then 1        
                 when real_port_num = @portnum then 1        
                 else 0        
            end        
        
  select         
     min(resp_trans_id) as resp_trans_id,         
     min(real_port_num) as real_port_num,        
     dist_num,         
     mtm_pl_asof_date,         
     open_pl,         
     closed_pl,        
     addl_cost_sum,         
     delta,         
     min(trans_id) as trans_id1,         
     vega,         
     volatility,         
     theta,         
     curr_conv_rate,         
     curr_code_conv_from,         
     curr_code_conv_to,         
     interest_rate,         
     price_diff_value,        
     dist_qty,        
     alloc_qty,         
     trade_value,         
     market_value,         
     curr_code,       
     qty_uom_code,         
     gamma,         
     discount_factor,         
     rho,         
     drift,         
     trade_modified_ind,         
     commkt_key,         
     pos_num,         
     trade_num,         
     order_num,         
     item_num,         
     qty_uom_code_conv_to,         
     sec_qty_uom_code,         
     sec_conversion_factor,          
     trading_prd,         
     last_trade_date,         
     dist_type,         
     p_s_ind,         
     opt_model_type,         
     leg_total_days,         
     opt_priced_days,         
     opt_priced_price,        
     opt_avg_correlation,        
     priced_qty,        
     qty_uom_conv_rate,        
     avg_price        
  into #tidmtm1        
  from #tidmtm        
   group by dist_num, mtm_pl_asof_date, open_pl, closed_pl,addl_cost_sum, delta,         
              vega, volatility, theta, curr_conv_rate, curr_code_conv_from,         
              curr_code_conv_to, interest_rate, price_diff_value, dist_qty,alloc_qty,         
              trade_value, market_value, curr_code, qty_uom_code, gamma,         
              discount_factor, rho, drift, trade_modified_ind, commkt_key, pos_num,         
              trade_num, order_num, item_num, qty_uom_code_conv_to, sec_qty_uom_code,         
              sec_conversion_factor, trading_prd, last_trade_date, dist_type, p_s_ind,         
              opt_model_type, leg_total_days, opt_priced_days, opt_priced_price,        
              opt_avg_correlation, priced_qty, qty_uom_conv_rate, avg_price        
  having count(*) = 1        
  order by real_port_num, dist_num, mtm_pl_asof_date, resp_trans_id        
  drop table #tidmtm        
      
  -- write changed columns    
  select         
     'DIFFCOLS' as PASS,        
     b.resp_trans_id,        
     b.real_port_num,        
     b.dist_num,         
     convert(varchar, b.mtm_pl_asof_date, 101) as mtm_pl_asof_date,         
     case when isnull(a.open_pl, '@@@') <> isnull(b.open_pl, '@@@')         
             then 'open_pl'       
          else ''  end +         
     case when isnull(a.closed_pl, '@@@') <> isnull(b.closed_pl, '@@@')         
             then ',closed_pl'      
          else '' end +         
     case when isnull(a.addl_cost_sum, '@@@') <> isnull(b.addl_cost_sum, '@@@')         
             then ',addl_cost_sum '    
          else ''    end +         
     case when isnull(a.delta, '@@@') <> isnull(b.delta, '@@@')         
             then ',delta'       
          else '' end +         
     case when isnull(a.vega, '@@@') <> isnull(b.vega, '@@@')         
             then ',vega'    
          else ''  end +        
     case when isnull(a.volatility, '@@@') <> isnull(b.volatility, '@@@')         
             then ',volatility'     
          else ''    end +    
     case when isnull(a.theta, '@@@') <> isnull(b.theta, '@@@')         
             then ',theta'    
          else '' end +         
     case when isnull(a.curr_conv_rate, '@@@') <> isnull(b.curr_conv_rate, '@@@')         
             then ',curr_conv_rate'        
          else ''    end +       
     case when isnull(a.curr_code_conv_from, '@@@') <> isnull(b.curr_code_conv_from, '@@@')         
             then ',curr_code_conv_from'        
          else ''    end +         
     case when isnull(a.curr_code_conv_to, '@@@') <> isnull(b.curr_code_conv_to, '@@@')         
    then ',curr_code_conv_to'        
          else ''    end +        
     case when isnull(a.interest_rate, '@@@') <> isnull(b.interest_rate, '@@@')         
             then ',interest_rate'      
          else ''    end +        
     case when isnull(a.price_diff_value, '@@@') <> isnull(b.price_diff_value, '@@@')         
             then ',price_diff_value'      
    else ''    end +    
     case when isnull(a.dist_qty, '@@@') <> isnull(b.dist_qty, '@@@')         
             then ',dist_qty'      
          else ''    end +        
     case when isnull(a.alloc_qty, '@@@') <> isnull(b.alloc_qty, '@@@')         
             then ',alloc_qty'    
          else ''    end +         
     case when isnull(a.trade_value, '@@@') <> isnull(b.trade_value, '@@@')         
             then ',trade_value'        
          else ''    end +         
     case when isnull(a.market_value, '@@@') <> isnull(b.market_value, '@@@')         
             then ',market_value'      
          else ''    end +       
     case when isnull(a.curr_code, '@@@') <> isnull(b.curr_code, '@@@')         
             then ',curr_code'       
          else ''    end +         
     case when isnull(a.qty_uom_code, '@@@') <> isnull(b.qty_uom_code, '@@@')         
             then ',qty_uom_code'        
          else ''    end +        
     case when isnull(a.gamma, '@@@') <> isnull(b.gamma, '@@@')         
             then ',gamma'        
          else ''   end +       
     case when isnull(a.discount_factor, '@@@') <> isnull(b.discount_factor, '@@@')         
             then ',discount_factor'       
          else ''    end +         
     case when isnull(a.rho, '@@@') <> isnull(b.rho, '@@@')         
             then ',rho'       
          else '' end +       
     case when isnull(a.drift, '@@@') <> isnull(b.drift, '@@@')         
             then ',drift'        
          else ''  end +         
     case when isnull(a.trade_modified_ind, '@@@') <> isnull(b.trade_modified_ind, '@@@')         
             then ',trade_modified_ind'      
          else ''    end +         
     case when isnull(a.commkt_key, -1) <> isnull(b.commkt_key, -1)         
             then ',commkt_key'        
          else ''    end +        
     case when isnull(a.pos_num, -1) <> isnull(b.pos_num, -1)         
             then ',pos_num'      
          else ''    end +         
     case when isnull(a.trade_num, -1) <> isnull(b.trade_num, -1)         
             then ',trade_num'        
          else ''    end +        
     case when isnull(a.order_num, -1) <> isnull(b.order_num, -1)         
             then ',order_num'        
          else ''    end +        
     case when isnull(a.item_num, -1) <> isnull(b.item_num, -1)         
             then ',item_num'       
          else ''    end +        
     case when isnull(a.qty_uom_code_conv_to, '@@@') <> isnull(b.qty_uom_code_conv_to, '@@@')         
             then ',qty_uom_code_conv_to'     
    else '' end  +        
     case when isnull(a.sec_qty_uom_code, '@@@') <> isnull(b.sec_qty_uom_code, '@@@')         
             then ',sec_qty_uom_code'        
          else ''    end +         
     case when isnull(a.sec_conversion_factor, '@@@') <> isnull(b.sec_conversion_factor, '@@@')         
             then ',sec_conversion_factor'        
          else ''    end +         
     case when isnull(a.trading_prd, '@@@') <> isnull(b.trading_prd, '@@@')         
             then ',trading_prd'        
          else ''    end +        
     case when isnull(a.last_trade_date, '01/01/1990') <> isnull(b.last_trade_date, '01/01/1990')         
             then ',last_trade_date'        
          else ''    end +         
     case when isnull(a.dist_type, '@@@') <> isnull(b.dist_type, '@@@')         
             then ',dist_type'      
          else ''    end +         
     case when isnull(a.p_s_ind, '@@@') <> isnull(b.p_s_ind, '@@@')         
             then ',p_s_ind'      
          else ''   end +         
     case when isnull(a.opt_model_type, '@@@') <> isnull(b.opt_model_type, '@@@')         
             then ',opt_model_type'       
          else ''    end +        
     case when isnull(a.leg_total_days, -1) <> isnull(b.leg_total_days, -1)         
             then ',leg_total_days'       
          else ''    end +      
     case when isnull(a.opt_priced_days, -1) <> isnull(b.opt_priced_days, -1)         
             then ',opt_priced_days'       
          else ''    end +         
     case when isnull(a.opt_priced_price, '@@@') <> isnull(b.opt_priced_price, '@@@')         
             then ',opt_priced_price'        
          else ''    end +        
     case when isnull(a.opt_avg_correlation, '@@@') <> isnull(b.opt_avg_correlation, '@@@')         
             then ',opt_avg_correlation'        
          else ''    end +         
     case when isnull(a.priced_qty, '@@@') <> isnull(b.priced_qty, '@@@')         
             then ',priced_qty'       
          else ''    end +        
     case when isnull(a.qty_uom_conv_rate, '@@@') <> isnull(b.qty_uom_conv_rate, '@@@')         
             then ',qty_uom_conv_rate'     
          else ''    end +         
     case when isnull(a.avg_price, '@@@') <> isnull(b.avg_price, '@@@')         
             then ',avg_price '       
          else ''  end as diffColList    
 into #diffColList        
  from (select *        
        from #tidmtm1        
        where resp_trans_id = @resp_trans_id_NEW) a,        
       (select  *        
        from #tidmtm1        
        where resp_trans_id = @resp_trans_id_OLD) b         
  where a.dist_num = b.dist_num and        
        a.mtm_pl_asof_date = b.mtm_pl_asof_date and         
        a.real_port_num = b.real_port_num        
      
  --- finish write changed columns.    
      
      
        
  select         
     'NEW' as PASS,        
     tidm.resp_trans_id,       
diffColList,      
     tidm.real_port_num,         
     tidm.dist_num,         
     convert(varchar, tidm.mtm_pl_asof_date, 101) as mtm_pl_asof_date,        
      open_pl,        
      closed_pl,        
      addl_cost_sum,        
      delta,        
      vega,        
      volatility,        
      theta,        
      curr_conv_rate,        
      curr_code_conv_from,        
      curr_code_conv_to,        
      interest_rate,        
      price_diff_value,        
      dist_qty,        
      alloc_qty,        
      trade_value,        
      market_value,        
      curr_code,        
      qty_uom_code,        
      gamma,        
      discount_factor,        
      rho,        
      drift,        
      trade_modified_ind,         
      str(commkt_key) as commkt_key,         
      str(pos_num) as pos_num,        
      str(trade_num) as trade_num,        
      str(order_num) as order_num,        
      str(item_num) as item_num,        
      qty_uom_code_conv_to,        
      sec_qty_uom_code,        
      sec_conversion_factor,        
      trading_prd,        
      convert(varchar, last_trade_date, 101) as last_trade_date,        
      dist_type,        
      p_s_ind,        
      opt_model_type,        
      str(leg_total_days) as leg_total_days,        
      str(opt_priced_days) as opt_priced_days,        
      opt_priced_price,        
      opt_avg_correlation,        
      priced_qty,        
      qty_uom_conv_rate,        
      avg_price,        
     trans_id1        
   from #tidmtm1 tidm  left outer join #diffColList difc    
 on tidm.dist_num = difc.dist_num and tidm.mtm_pl_asof_date= difc.mtm_pl_asof_date and tidm.real_port_num=difc.real_port_num    
   where tidm.resp_trans_id = @resp_trans_id_NEW        
   union              
  select         
     'OLD' as PASS,        
     b.resp_trans_id,       
    diffColList,   
     b.real_port_num,        
     b.dist_num,         
     convert(varchar, b.mtm_pl_asof_date, 101) as mtm_pl_asof_date,         
     case when isnull(a.open_pl, '@@@') <> isnull(b.open_pl, '@@@')         
             then b.open_pl        
          else ' '        
     end as open_pl,         
     case when isnull(a.closed_pl, '@@@') <> isnull(b.closed_pl, '@@@')         
             then b.closed_pl        
          else ' '        
     end as closed_pl,         
     case when isnull(a.addl_cost_sum, '@@@') <> isnull(b.addl_cost_sum, '@@@')         
             then b.addl_cost_sum        
          else ' '        
     end as addl_cost_sum,         
     case when isnull(a.delta, '@@@') <> isnull(b.delta, '@@@')         
             then b.delta        
          else ' '        
     end as delta,         
     case when isnull(a.vega, '@@@') <> isnull(b.vega, '@@@')         
             then b.vega        
          else ' '        
     end as vega,         
     case when isnull(a.volatility, '@@@') <> isnull(b.volatility, '@@@')         
             then b.volatility        
          else ' '        
     end as volatility,         
     case when isnull(a.theta, '@@@') <> isnull(b.theta, '@@@')         
             then b.theta        
          else ' '        
     end as theta,         
     case when isnull(a.curr_conv_rate, '@@@') <> isnull(b.curr_conv_rate, '@@@')         
             then b.curr_conv_rate        
          else ' '        
     end as curr_conv_rate,         
     case when isnull(a.curr_code_conv_from, '@@@') <> isnull(b.curr_code_conv_from, '@@@')         
             then b.curr_code_conv_from        
          else ' '        
     end as curr_code_conv_from,         
     case when isnull(a.curr_code_conv_to, '@@@') <> isnull(b.curr_code_conv_to, '@@@')         
    then b.curr_code_conv_to        
          else ' '        
     end as curr_code_conv_to,         
     case when isnull(a.interest_rate, '@@@') <> isnull(b.interest_rate, '@@@')         
             then b.interest_rate        
          else ' '        
     end as interest_rate,         
     case when isnull(a.price_diff_value, '@@@') <> isnull(b.price_diff_value, '@@@')         
             then b.price_diff_value        
          else ' '        
     end as price_diff_value,         
     case when isnull(a.dist_qty, '@@@') <> isnull(b.dist_qty, '@@@')         
             then b.dist_qty        
          else ' '        
     end as dist_qty,         
     case when isnull(a.alloc_qty, '@@@') <> isnull(b.alloc_qty, '@@@')         
             then b.alloc_qty        
          else ' '        
     end as alloc_qty,         
     case when isnull(a.trade_value, '@@@') <> isnull(b.trade_value, '@@@')         
             then b.trade_value        
          else ' '        
     end as trade_value,         
     case when isnull(a.market_value, '@@@') <> isnull(b.market_value, '@@@')         
             then b.market_value        
          else ' '        
     end as market_value,         
     case when isnull(a.curr_code, '@@@') <> isnull(b.curr_code, '@@@')         
             then b.curr_code        
          else ' '        
     end as curr_code,         
     case when isnull(a.qty_uom_code, '@@@') <> isnull(b.qty_uom_code, '@@@')         
             then b.qty_uom_code        
          else ' '        
     end as qty_uom_code,         
     case when isnull(a.gamma, '@@@') <> isnull(b.gamma, '@@@')         
             then b.gamma        
          else ' '        
     end as gamma,         
     case when isnull(a.discount_factor, '@@@') <> isnull(b.discount_factor, '@@@')         
             then b.discount_factor        
          else ' '        
     end as discount_factor,         
     case when isnull(a.rho, '@@@') <> isnull(b.rho, '@@@')         
             then b.rho        
          else ' '        
     end as rho,         
     case when isnull(a.drift, '@@@') <> isnull(b.drift, '@@@')         
             then b.drift        
          else ' '        
     end as drift,         
     case when isnull(a.trade_modified_ind, '@@@') <> isnull(b.trade_modified_ind, '@@@')         
             then b.trade_modified_ind        
          else ' '        
     end as trade_modified_ind,         
     case when isnull(a.commkt_key, -1) <> isnull(b.commkt_key, -1)         
             then str(b.commkt_key)        
          else ' '        
     end as commkt_key,         
     case when isnull(a.pos_num, -1) <> isnull(b.pos_num, -1)         
             then str(b.pos_num)        
          else ' '        
     end as pos_num,         
     case when isnull(a.trade_num, -1) <> isnull(b.trade_num, -1)         
            then str(b.trade_num)        
          else ' '        
     end as trade_num,         
     case when isnull(a.order_num, -1) <> isnull(b.order_num, -1)         
             then str(b.order_num)        
          else ' '        
     end as order_num,         
     case when isnull(a.item_num, -1) <> isnull(b.item_num, -1)         
             then str(b.item_num)        
          else ' '        
     end as item_num,         
     case when isnull(a.qty_uom_code_conv_to, '@@@') <> isnull(b.qty_uom_code_conv_to, '@@@')         
             then b.qty_uom_code_conv_to        
          else ' '        
     end as qty_uom_code_conv_to,         
     case when isnull(a.sec_qty_uom_code, '@@@') <> isnull(b.sec_qty_uom_code, '@@@')         
             then b.sec_qty_uom_code        
          else ' '        
     end as sec_qty_uom_code,         
     case when isnull(a.sec_conversion_factor, '@@@') <> isnull(b.sec_conversion_factor, '@@@')         
             then b.sec_conversion_factor        
          else ' '        
     end as sec_conversion_factor,         
     case when isnull(a.trading_prd, '@@@') <> isnull(b.trading_prd, '@@@')         
             then b.trading_prd        
          else ' '        
     end as trading_prd,         
     case when isnull(a.last_trade_date, '01/01/1990') <> isnull(b.last_trade_date, '01/01/1990')         
             then convert(varchar, b.last_trade_date, 101)        
          else ' '        
     end as last_trade_date,         
     case when isnull(a.dist_type, '@@@') <> isnull(b.dist_type, '@@@')         
             then b.dist_type        
          else ' '        
     end as dist_type,         
     case when isnull(a.p_s_ind, '@@@') <> isnull(b.p_s_ind, '@@@')         
             then b.p_s_ind        
          else ' '        
     end as p_s_ind,         
     case when isnull(a.opt_model_type, '@@@') <> isnull(b.opt_model_type, '@@@')         
             then b.opt_model_type        
          else ' '        
     end as opt_model_type,         
     case when isnull(a.leg_total_days, -1) <> isnull(b.leg_total_days, -1)         
             then str(b.leg_total_days)        
          else ' '        
     end as leg_total_days,         
     case when isnull(a.opt_priced_days, -1) <> isnull(b.opt_priced_days, -1)         
             then str(b.opt_priced_days)        
          else ' '        
     end as opt_priced_days,         
     case when isnull(a.opt_priced_price, '@@@') <> isnull(b.opt_priced_price, '@@@')         
             then b.opt_priced_price        
          else ' '        
     end as opt_priced_price,         
     case when isnull(a.opt_avg_correlation, '@@@') <> isnull(b.opt_avg_correlation, '@@@')         
             then b.opt_avg_correlation        
          else ' '        
     end as opt_avg_correlation,         
     case when isnull(a.priced_qty, '@@@') <> isnull(b.priced_qty, '@@@')         
             then b.priced_qty        
          else ' '        
     end as priced_qty,         
     case when isnull(a.qty_uom_conv_rate, '@@@') <> isnull(b.qty_uom_conv_rate, '@@@')         
             then b.qty_uom_conv_rate        
          else ' '        
     end as qty_uom_conv_rate,         
     case when isnull(a.avg_price, '@@@') <> isnull(b.avg_price, '@@@')         
             then b.avg_price        
          else ' '        
     end as avg_price,         
     b.trans_id1          
  from (select *        
        from #tidmtm1        
        where resp_trans_id = @resp_trans_id_NEW) a,        
       (select  *        
        from #tidmtm1        
        where resp_trans_id = @resp_trans_id_OLD) b      left outer join #diffColList difc    
 on b.dist_num = difc.dist_num and b.mtm_pl_asof_date= difc.mtm_pl_asof_date and b.real_port_num=difc.real_port_num      
  where a.dist_num = b.dist_num and        
        a.mtm_pl_asof_date = b.mtm_pl_asof_date and         
        a.real_port_num = b.real_port_num        
  order by real_port_num, dist_num, mtm_pl_asof_date, resp_trans_id        
        
   drop table #tidmtm1        
GO
GRANT EXECUTE ON  [dbo].[usp_compare_tid_mtm] TO [next_usr]
GO
