SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_compare_pos_mtm]    
  @resp_trans_id_NEW      int,    
  @resp_trans_id_OLD      int,    
  @portnum                int = null,    
  @digits_for_scale4      tinyint = 4,    
  @digits_for_scale7      tinyint = 7      
as    
set nocount on    
    
   print ' '    
   print '==================================================='    
   print ' DATA : position_mark_to_market'    
   print '==================================================='    
   print ' '    
    
   select resp_trans_id,    
         pos_num,     
         mtm_asof_date,     
          str(mtm_mkt_price, 38, @digits_for_scale4) as mtm_mkt_price,    
         mtm_mkt_price_curr_code,     
         mtm_mkt_price_uom_code,     
         mtm_mkt_price_source_code,           
          str(volatility, 38, @digits_for_scale7) as volatility,    
          str(interest_rate, 38, @digits_for_scale7) as interest_rate,    
          str(delta, 38, @digits_for_scale7) as delta,    
          str(gamma, 38, @digits_for_scale7) as gamma,    
          str(theta, 38, @digits_for_scale7) as theta,    
          str(vega, 38, @digits_for_scale7) as vega,    
         opt_eval_method,     
         otc_opt_code,     
         trans_id    
  into #posmtm    
  from dbo.aud_position_mark_to_market    
   where resp_trans_id in (@resp_trans_id_NEW, @resp_trans_id_OLD)     
       
  select     
     min(resp_trans_id) as resp_trans_id,     
     pos_num,     
     mtm_asof_date,     
     mtm_mkt_price,     
     mtm_mkt_price_curr_code,     
     mtm_mkt_price_uom_code,     
     mtm_mkt_price_source_code,     
     opt_eval_method,     
     otc_opt_code,     
     volatility,    
     interest_rate,     
     delta,     
     gamma,    
     theta,    
     vega,     
     min(trans_id) as trans_id1    
  into #posmtm1    
   from #posmtm    
  group by pos_num, mtm_asof_date, mtm_mkt_price, mtm_mkt_price_curr_code,     
              mtm_mkt_price_uom_code, mtm_mkt_price_source_code, opt_eval_method,     
              otc_opt_code, volatility, interest_rate, delta, gamma, theta, vega     
  having count(*) = 1    
  order by pos_num, mtm_asof_date, resp_trans_id        
  drop table #posmtm     
   -- write changed columns   
   select     
     'DIFFCOLS' as PASS,    
     b.resp_trans_id,    
     b.pos_num,    
     convert(varchar, b.mtm_asof_date, 101) as mtm_asof_date,     
     case when isnull(a.mtm_mkt_price, '@@@') <> isnull(b.mtm_mkt_price, '@@@')     
             then 'mtm_mkt_price'
          else ' ' end +
     case when isnull(a.volatility, '@@@') <> isnull(b.volatility, '@@@')     
             then ',volatility'    
          else ' ' end +    
     case when isnull(a.interest_rate, '@@@') <> isnull(b.interest_rate, '@@@')     
             then ',interest_rate'    
          else ' ' end +
     case when isnull(a.delta, '@@@') <> isnull(b.delta, '@@@')     
             then ',delta'   
          else ' ' end +
     case when isnull(a.gamma, '@@@') <> isnull(b.gamma, '@@@')     
             then ',gamma'   
          else ' ' end +
     case when isnull(a.theta, '@@@') <> isnull(b.theta, '@@@')     
             then ',theta'   
          else ' ' end +
     case when isnull(a.vega, '@@@') <> isnull(b.vega, '@@@')     
             then ',vega'   
          else ' ' end +
     case when isnull(a.mtm_mkt_price_curr_code, '@@@') <> isnull(b.mtm_mkt_price_curr_code, '@@@')     
             then ',mtm_mkt_price_curr_code'   
          else ' ' end +
     case when isnull(a.mtm_mkt_price_uom_code, '@@@') <> isnull(b.mtm_mkt_price_uom_code, '@@@')     
             then ',mtm_mkt_price_uom_code'    
          else ' ' end +
     case when isnull(a.mtm_mkt_price_source_code, '@@@') <> isnull(b.mtm_mkt_price_source_code, '@@@')     
             then ',mtm_mkt_price_source_code'
          else ' ' end +
     case when isnull(a.opt_eval_method, '@') <> isnull(b.opt_eval_method, '@')     
             then ',opt_eval_method'
          else ' ' end +
     case when isnull(a.otc_opt_code, '@@@') <> isnull(b.otc_opt_code, '@@@')     
             then ',otc_opt_code'
          else ' ' end as diffColList  
   into #diffColList     
  from (select *    
        from #posmtm1    
        where resp_trans_id = @resp_trans_id_NEW) a,    
       (select  *    
        from #posmtm1    
        where resp_trans_id = @resp_trans_id_OLD) b     
  where a.pos_num = b.pos_num and    
        a.mtm_asof_date = b.mtm_asof_date 
   -- finish write changed columns.     
  select     
     'NEW' as PASS,    
     po1.resp_trans_id,
	 diffColList,     
      po1.pos_num,    
      convert(varchar, po1.mtm_asof_date, 101) as mtm_asof_date,    
      mtm_mkt_price,    
      volatility,    
      interest_rate,    
      delta,    
      gamma,    
      theta,    
      vega,    
      mtm_mkt_price_curr_code,    
      mtm_mkt_price_uom_code,    
      mtm_mkt_price_source_code,    
      opt_eval_method,    
      otc_opt_code,    
     trans_id1    
   from #posmtm1 po1 left outer join #diffColList difc    
 on po1.pos_num = difc.pos_num and po1.mtm_asof_date= difc.mtm_asof_date  
   where po1.resp_trans_id = @resp_trans_id_NEW    
   union          
  select     
     'OLD' as PASS,    
     b.resp_trans_id,
	 diffColList,    
     b.pos_num,    
     convert(varchar, b.mtm_asof_date, 101) as mtm_asof_date,     
     case when isnull(a.mtm_mkt_price, '@@@') <> isnull(b.mtm_mkt_price, '@@@')     
             then b.mtm_mkt_price    
          else ' '    
     end as mtm_mkt_price,     
     case when isnull(a.volatility, '@@@') <> isnull(b.volatility, '@@@')     
             then b.volatility    
          else ' '    
     end as volatility,     
     case when isnull(a.interest_rate, '@@@') <> isnull(b.interest_rate, '@@@')     
             then b.interest_rate    
          else ' '    
     end as interest_rate,     
     case when isnull(a.delta, '@@@') <> isnull(b.delta, '@@@')     
             then b.delta    
          else ' '    
     end as delta,     
     case when isnull(a.gamma, '@@@') <> isnull(b.gamma, '@@@')     
             then b.gamma    
          else ' '    
     end as gamma,     
     case when isnull(a.theta, '@@@') <> isnull(b.theta, '@@@')     
             then b.theta    
          else ' '    
     end as theta,     
     case when isnull(a.vega, '@@@') <> isnull(b.vega, '@@@')     
             then b.vega    
          else ' '    
     end as vega,     
     case when isnull(a.mtm_mkt_price_curr_code, '@@@') <> isnull(b.mtm_mkt_price_curr_code, '@@@')     
             then b.mtm_mkt_price_curr_code    
          else ' '    
     end as mtm_mkt_price_curr_code,     
     case when isnull(a.mtm_mkt_price_uom_code, '@@@') <> isnull(b.mtm_mkt_price_uom_code, '@@@')     
             then b.mtm_mkt_price_uom_code    
          else ' '    
     end as mtm_mkt_price_uom_code,     
     case when isnull(a.mtm_mkt_price_source_code, '@@@') <> isnull(b.mtm_mkt_price_source_code, '@@@')     
             then b.mtm_mkt_price_source_code    
          else ' '    
     end as mtm_mkt_price_source_code,     
     case when isnull(a.opt_eval_method, '@') <> isnull(b.opt_eval_method, '@')     
             then b.opt_eval_method    
          else ' '    
     end as opt_eval_method,     
     case when isnull(a.otc_opt_code, '@@@') <> isnull(b.otc_opt_code, '@@@')     
             then b.otc_opt_code    
          else ' '    
     end as otc_opt_code,     
     b.trans_id1      
  from (select *    
        from #posmtm1    
        where resp_trans_id = @resp_trans_id_NEW) a,    
       (select  *    
        from #posmtm1    
        where resp_trans_id = @resp_trans_id_OLD) b left outer join #diffColList difc    
 on b.pos_num = difc.pos_num and b.mtm_asof_date= difc.mtm_asof_date    
  where a.pos_num = b.pos_num and    
        a.mtm_asof_date = b.mtm_asof_date    
  order by pos_num, mtm_asof_date, resp_trans_id         
    
   drop table #posmtm1    
GO
GRANT EXECUTE ON  [dbo].[usp_compare_pos_mtm] TO [next_usr]
GO
