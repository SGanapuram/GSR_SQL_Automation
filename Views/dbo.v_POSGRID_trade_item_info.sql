SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_POSGRID_trade_item_info]
(
   trader_init, 
   contr_date, 
   inhouse_ind,   
   trade_mod_date,                         
   creation_date, 
   acct_num,
   port_num,                        
   order_type_code,                         
   trade_num,
   order_num,
   item_num,                         
   p_s_ind,                                                       
   contr_qty_uom_code, 
   contr_qty,
   product 
)
as
select
   trd.trader_init, 
   trd.contr_date, 
   trd.inhouse_ind,   
   trd.trade_mod_date,                         
   trd.creation_date, 
   trd.acct_num,
   trd.port_num,                        
   trdord.order_type_code,                         
   ti.trade_num,
   ti.order_num,
   ti.item_num,                         
   ti.p_s_ind,                                                       
   ti.contr_qty_uom_code, 
   case when ti.p_s_ind = 'S' then ti.contr_qty * -1 
        else ti.contr_qty  
   end,
   case when trdord.order_type_code in ('SWAP', 'SWAPFLT') 
           then isnull(ti.idms_acct_alloc, cmnt.tiny_cmnt) 
        else NULL 
   end                                                                                   
from dbo.trade_item ti with (nolock)                    
        LEFT OUTER JOIN dbo.comment cmnt with (nolock) 
           ON ti.cmnt_num = cmnt.cmnt_num 
        INNER JOIN dbo.trade_order trdord
           ON ti.trade_num = trdord.trade_num and
              ti.order_num = trdord.order_num
        INNER JOIN dbo.trade trd  
           ON trd.trade_num = ti.trade_num                      
GO
GRANT SELECT ON  [dbo].[v_POSGRID_trade_item_info] TO [next_usr]
GO
