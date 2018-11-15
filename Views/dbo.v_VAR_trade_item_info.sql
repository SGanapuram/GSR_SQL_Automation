SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[v_VAR_trade_item_info]     
(  
   trade_num,   
   order_num,  
   item_num,  
   item_type,  
   order_type_code,  
   contr_date,  
   trader_init,  
   inhouse_ind,  
   counterparty,  
   trade_mod_date,           
   creation_date,   
   contr_qty_uom_code,   
   contract_p_s_ind,   
   contr_qty,  
   product,  
   creator_init,  
   del_date_to,  
   formula_ind,  
   cmdty_code,  
   risk_mkt_code,  
   booking_comp_num,  
   real_port_num,   
   price_status,  
   quote_end_date   
)  
as  
select ti.trade_num,   
       ti.order_num,  
       ti.item_num,  
       ti.item_type,  
       trdord.order_type_code,  
       trd.contr_date,  
       trd.trader_init,  
       trd.inhouse_ind,  
       case when trd.inhouse_ind = 'Y'   
               then null  
            else a1.acct_num   
       end,           
       trd.trade_mod_date,           
       trd.creation_date,   
       ti.contr_qty_uom_code,   
       ti.p_s_ind,   
       case when ti.p_s_ind = 'S' then ti.contr_qty * -1   
            else ti.contr_qty    
       end,           
       case when trdord.order_type_code in ('SWAP', 'SWAPFLT')   
               then isnull(ti.idms_acct_alloc, cmnt.tiny_cmnt)   
            else NULL   
       end,  
       trd.creator_init,  
       tiwp.del_date_to,  
       ti.formula_ind,    
       ti.cmdty_code,  
       ti.risk_mkt_code,  
       ti.booking_comp_num,  
       ti.real_port_num,   
       isnull(acc.price_status, ' '),  
       acc.quote_end_date   
from dbo.trade_item ti      
        LEFT OUTER JOIN dbo.trade_item_wet_phy tiwp  
           ON ti.trade_num = tiwp.trade_num and  
              ti.order_num = tiwp.order_num and  
              ti.item_num = tiwp.item_num  
        LEFT OUTER JOIN dbo.comment cmnt WITH (NOLOCK)  
           ON ti.cmnt_num = cmnt.cmnt_num   
        INNER JOIN dbo.trade_order trdord  
           ON ti.trade_num = trdord.trade_num and  
              ti.order_num = trdord.order_num  
        INNER JOIN dbo.trade trd    
           ON ti.trade_num = trd.trade_num  
        LEFT OUTER JOIN dbo.account a1 WITH (NOLOCK)  
           ON a1.acct_num = trd.acct_num  
        LEFT OUTER JOIN dbo.accumulation acc  
           ON ti.trade_num = acc.trade_num and  
              ti.order_num = acc.order_num and  
              ti.item_num = acc.item_num  
where trdord.strip_summary_ind <> 'Y' and  
      trd.conclusion_type = 'C'  
GO
GRANT SELECT ON  [dbo].[v_VAR_trade_item_info] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_VAR_trade_item_info] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_VAR_trade_item_info', NULL, NULL
GO
