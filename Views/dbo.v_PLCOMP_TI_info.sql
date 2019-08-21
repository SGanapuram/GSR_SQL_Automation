SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_PLCOMP_TI_info]
(
   trade_num,
   order_num,
   item_num,
   real_port_num,
   p_s_ind,
   contr_qty, 
   contr_qty_uom_code,
   price_curr_code,
   avg_price,
   contr_date,
   inhouse_ind,
   creator_init,
   trade_mod_date,
   port_num,
   trade_status_code,
   order_type_code,
   quote_start_date,
   quote_end_date,
   counterparty,
   clearing_brkr,
   trans_id
)
as
select
   ti.trade_num,
   ti.order_num,
   ti.item_num,
   ti.real_port_num,
   ti.p_s_ind,
   ti.contr_qty, 
   ti.contr_qty_uom_code,
   ti.price_curr_code,
   ti.avg_price,
   t.contr_date,
   t.inhouse_ind,
   t.creator_init,
   t.trade_mod_date,
   t.port_num,
   t.trade_status_code,
   tor.order_type_code,
   acc.quote_start_date,
   acc.quote_end_date,
   cpty.acct_short_name,
   clr.acct_short_name,
   t.trans_id
from dbo.trade_item ti WITH (NOLOCK) 
        inner join dbo.trade_order tor WITH (NOLOCK) 
           on ti.trade_num = tor.trade_num and 
              ti.order_num = tor.order_num                                            
        left outer join dbo.accumulation acc WITH (NOLOCK) 
           on ti.trade_num = acc.trade_num and 
              ti.order_num = acc.order_num and 
              ti.item_num = acc.item_num and 
              tor.order_type_code in ('SWAP', 'SWAPFLT')      
        inner join dbo.trade t 
           on ti.trade_num = t.trade_num                                                        
        left outer join dbo.account clr WITH (NOLOCK) 
           on ti.exch_brkr_num = clr.acct_num  
        left outer join dbo.account cpty WITH (NOLOCK) 
           on t.acct_num = cpty.acct_num                                                        
GO
GRANT SELECT ON  [dbo].[v_PLCOMP_TI_info] TO [next_usr]
GO
