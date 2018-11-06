SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_compare_inventory_history]
(    
   @resp_trans_id_NEW      int,    
   @resp_trans_id_OLD      int,    
   @portnum                int = null,    
   @digits_for_scale4      tinyint = 4,    
   @digits_for_scale7      tinyint = 7 
)     
as    
set nocount on    
    
   print ' '    
   print '==================================================='    
   print ' DATA : inventory_history'    
   print '==================================================='    
   print ' '    
    
   select resp_trans_id,  
          asof_date,  
          real_port_num,  
          inv_num,  
          cost_num,  
          cost_due_date,  
          inv_balance_period,  
          cost_trade_num,  
          cost_order_num,  
          cost_item_num,  
          rcpt_alloc_num,  
          rcpt_alloc_item_num,  
          cost_type_code,  
          cost_acct_num,  
          str(r_cost_amt, 38, @digits_for_scale4) as r_cost_amt,  
          str(unr_cost_amt, 38, @digits_for_scale4) as unr_cost_amt,  
          str(cost_amt_ratio, 38, @digits_for_scale4) as cost_amt_ratio,  
          trans_id      
      into #invhis   
   from dbo.aud_inventory_history   
   where resp_trans_id in (@resp_trans_id_NEW, @resp_trans_id_OLD) and     
         1 = case when @portnum is null then 1    
                  when real_port_num = @portnum then 1    
                  else 0    
             end    
                
   select     
      min(resp_trans_id) as resp_trans_id,       
      asof_date,  
      real_port_num,  
      inv_num,  
      cost_num,  
      cost_due_date,  
      inv_balance_period,  
      cost_trade_num,  
      cost_order_num,  
      cost_item_num,  
      rcpt_alloc_num,  
      rcpt_alloc_item_num,  
      cost_type_code,  
      cost_acct_num,  
      r_cost_amt,  
      unr_cost_amt,  
      cost_amt_ratio,  
      min(trans_id) as trans_id1  
       into #invhis1    
   from #invhis    
   group by asof_date,real_port_num,inv_num,cost_num,cost_due_date,  
            inv_balance_period,cost_trade_num,cost_order_num,  
            cost_item_num,rcpt_alloc_num,rcpt_alloc_item_num,  
            cost_type_code,cost_acct_num,r_cost_amt,unr_cost_amt,cost_amt_ratio
   having count(*) = 1    
   order by asof_date, real_port_num, inv_num, cost_num, rcpt_alloc_num  
    
   drop table #invhis    
    
   select     
      'NEW' as PASS,    
      resp_trans_id,     
      asof_date,  
      real_port_num,  
      inv_num,  
      cost_num,  
      cost_due_date,  
      inv_balance_period,  
      cost_trade_num,  
      cost_order_num,  
      cost_item_num,  
      rcpt_alloc_num,  
      rcpt_alloc_item_num,  
      cost_type_code,  
      cost_acct_num,  
      r_cost_amt,  
      unr_cost_amt,  
      cost_amt_ratio,  
      trans_id1    
   from #invhis1    
   where resp_trans_id = @resp_trans_id_NEW    
   union  
   select        
      'OLD' as PASS,    
      b.resp_trans_id,    
      b.asof_date,     
      b.real_port_num,    
      b.inv_num,    
      b.cost_num,  
      b.cost_due_date,  
      b.inv_balance_period,  
      b.cost_trade_num,  
      b.cost_order_num,  
      b.cost_item_num,  
      b.rcpt_alloc_num,  
      b.rcpt_alloc_item_num,  
      case when isnull(a.cost_type_code, '@@@')  <>  isnull(b.cost_type_code, '@@@')  
              then b.cost_type_code  
           else  '  '  
      end as cost_type_code,  
      b.cost_acct_num,  
      case when isnull(a.r_cost_amt, '@@@') <> isnull(b.r_cost_amt, '@@@')  
              then b.r_cost_amt  
           else '  '  
      end as r_cost_amt,  
      case when isnull(a.unr_cost_amt, '@@@') <> isnull(b.unr_cost_amt, '@@@')  
              then b.unr_cost_amt  
           else '  '  
      end as unr_cost_amt,  
      b.cost_amt_ratio,  
      b.trans_id1    
   from (select *    
         from #invhis1    
         where resp_trans_id = @resp_trans_id_NEW) a,  
        (select *    
         from #invhis1    
         where resp_trans_id = @resp_trans_id_OLD) b     
   where a.asof_date = b.asof_date and    
         a.real_port_num = b.real_port_num and    
         a.inv_num = b.inv_num and    
         a.cost_num = b.cost_num and  
         a.rcpt_alloc_num = b.rcpt_alloc_num  
   order by asof_date, real_port_num, inv_num, cost_num, rcpt_alloc_num   
    
   drop table #invhis1    
GO
GRANT EXECUTE ON  [dbo].[usp_compare_inventory_history] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_compare_inventory_history', NULL, NULL
GO
