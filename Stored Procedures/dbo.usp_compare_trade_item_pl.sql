SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[usp_compare_trade_item_pl] 
  @resp_trans_id_NEW     int,    
  @resp_trans_id_OLD       int,    
  @portnum                int = null,    
  @digits_for_scale4      tinyint = 4,    
  @digits_for_scale7      tinyint = 7      
as    
set nocount on    
    
   print ' '    
   print '==================================================='    
   print ' DATA : trade_item_pl'    
   print '==================================================='    
   print ' '    
    
   select a.resp_trans_id,     
         real_port_num,    
         a.trade_num,    
         a.order_num,     
         a.item_num,     
          str(a.mtm_pl, 38, @digits_for_scale4) as mtm_pl,    
         a.mtm_pl_curr_code,     
         a.pl_asof_date,     
          str(a.contr_mtm_pl, 38, @digits_for_scale4) as contr_mtm_pl,    
          str(a.addl_cost_sum, 38, @digits_for_scale4) as addl_cost_sum,    
          str(a.price_fx_rate, 38, @digits_for_scale4) as price_fx_rate,    
         a.trans_id    
  into #tipl    
  from dbo.aud_trade_item_pl a,     
       dbo.trade_item b    
  where a.trade_num = b.trade_num and     
        a.order_num = b.order_num and     
        a.item_num = b.item_num and    
        resp_trans_id in (@resp_trans_id_NEW, @resp_trans_id_OLD) and     
        1 = case when @portnum is null then 1    
                 when real_port_num = @portnum then 1    
                 else 0    
            end    
                
  select     
     min(resp_trans_id) as resp_trans_id,     
     min(real_port_num) as real_port_num,    
     trade_num,    
     order_num,     
     item_num,     
     mtm_pl,     
     mtm_pl_curr_code,     
     pl_asof_date,     
     contr_mtm_pl,    
     addl_cost_sum,    
     price_fx_rate,            
     min(trans_id) as trans_id1    
  into #tipl1    
   from #tipl    
  group by trade_num, order_num, item_num, mtm_pl,     
              mtm_pl_curr_code, pl_asof_date, contr_mtm_pl,    
              addl_cost_sum, price_fx_rate    
  having count(*) = 1    
  order by trade_num, order_num, item_num, pl_asof_date, resp_trans_id    
  drop table #tipl  
  
 -- write changed columns  
 select     
     'DIFFCOLS' as PASS,    
     b.resp_trans_id,    
     b.trade_num,     
      b.order_num,    
      b.item_num,    
     convert(varchar, b.pl_asof_date, 101) as pl_asof_date,     
     case when isnull(a.mtm_pl, '@@@') <> isnull(b.mtm_pl, '@@@')     
             then 'mtm_pl'   
          else ' ' end +
     case when isnull(a.contr_mtm_pl, '@@@') <> isnull(b.contr_mtm_pl, '@@@')     
             then ',contr_mtm_pl'   
          else ' ' end +
     case when isnull(a.addl_cost_sum, '@@@') <> isnull(b.addl_cost_sum, '@@@')     
             then ',addl_cost_sum'    
          else ' ' end +
     case when isnull(a.price_fx_rate, '@@@') <> isnull(b.price_fx_rate, '@@@')     
             then ',price_fx_rate'   
          else ' ' end +
     case when isnull(a.mtm_pl_curr_code, '@@@') <> isnull(b.mtm_pl_curr_code, '@@@')     
             then ',mtm_pl_curr_code'    
          else ' ' end as diffColList    
 into #diffColList       
  from (select *    
        from #tipl1    
        where resp_trans_id = @resp_trans_id_NEW) a,    
       (select  *    
        from #tipl1    
        where resp_trans_id = @resp_trans_id_OLD) b     
  where a.trade_num = b.trade_num and    
        a.order_num = b.order_num and    
        a.item_num = b.item_num and    
        a.pl_asof_date = b.pl_asof_date 
 -- finish write changed columns.    
  select     
     'NEW' as PASS,    
     tip.resp_trans_id,  
	 diffColList,   
     tip.trade_num,     
     tip.order_num,    
     tip.item_num,    
     convert(varchar, tip.pl_asof_date, 101) as pl_asof_date,     
      mtm_pl,    
      contr_mtm_pl,    
      addl_cost_sum,    
      price_fx_rate,    
      mtm_pl_curr_code,    
     trans_id1    
   from #tipl1 tip left outer join #diffColList difc    
 on tip.trade_num = difc.trade_num and tip.order_num= difc.order_num and tip.item_num=difc.item_num
 and tip.pl_asof_date = difc.pl_asof_date
   where tip.resp_trans_id = @resp_trans_id_NEW    
   union          
  select     
     'OLD' as PASS,    
     b.resp_trans_id,    
	 diffColList,  
     b.trade_num,     
      b.order_num,    
      b.item_num,    
     convert(varchar, b.pl_asof_date, 101) as pl_asof_date,     
     case when isnull(a.mtm_pl, '@@@') <> isnull(b.mtm_pl, '@@@')     
             then b.mtm_pl    
          else ' '    
     end as mtm_pl,     
     case when isnull(a.contr_mtm_pl, '@@@') <> isnull(b.contr_mtm_pl, '@@@')     
             then b.contr_mtm_pl    
          else ' '    
     end as contr_mtm_pl,  
     case when isnull(a.addl_cost_sum, '@@@') <> isnull(b.addl_cost_sum, '@@@')     
             then b.addl_cost_sum    
          else ' '    
     end as addl_cost_sum,     
     case when isnull(a.price_fx_rate, '@@@') <> isnull(b.price_fx_rate, '@@@')     
             then b.price_fx_rate    
          else ' '    
     end as price_fx_rate,     
     case when isnull(a.mtm_pl_curr_code, '@@@') <> isnull(b.mtm_pl_curr_code, '@@@')     
             then b.mtm_pl_curr_code    
          else ' '    
     end as mtm_pl_curr_code,     
     b.trans_id1      
  from (select *    
        from #tipl1    
        where resp_trans_id = @resp_trans_id_NEW) a,    
       (select  *    
        from #tipl1    
        where resp_trans_id = @resp_trans_id_OLD) b left outer join #diffColList difc    
 on b.trade_num = difc.trade_num and b.order_num= difc.order_num and b.item_num=difc.item_num
 and b.pl_asof_date = difc.pl_asof_date    
  where a.trade_num = b.trade_num and    
        a.order_num = b.order_num and    
        a.item_num = b.item_num and    
        a.pl_asof_date = b.pl_asof_date    
  order by trade_num, order_num, item_num, pl_asof_date, resp_trans_id    
    
   drop table #tipl1    
GO
GRANT EXECUTE ON  [dbo].[usp_compare_trade_item_pl] TO [next_usr]
GO
