SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[v_VAR_swap_trades_v24]  
(  
   trade_num,  
   order_num,  
   item_num,  
   accum_num,  
   cmdty_code,  
   risk_mkt_code,  
   inhouse_ind,  
   commkt_key,   
   real_port_num,   
   trader_init,   
   acct_num,   
   creator_init,   
   booking_comp_num,   
   order_type_code,  
   contr_date,   
   brkr_num,  
   exch_brkr_num  
)  
as  
select   
   trditm.trade_num,  
   trditm.order_num,  
   trditm.item_num,  
   trditm.accum_num,  
   trditm.cmdty_code,  
   trditm.risk_mkt_code,  
   trd.inhouse_ind,  
   trditm.commkt_key,   
   trditm.real_port_num,   
   trd.trader_init,   
   trd.acct_num,   
   trd.creator_init,   
   trditm.booking_comp_num,   
   trdord.order_type_code,  
   trd.contr_date,  
   trditm.brkr_num,  
   trditm.exch_brkr_num  
from (select ti.trade_num,  
             ti.order_num,  
             ti.item_num,  
             ti.cmdty_code,  
             acc.accum_num,  
             ti.risk_mkt_code,  
             ti.real_port_num,  
             cm.commkt_key,  
             ti.booking_comp_num,  
             ti.brkr_num,  
             ti.exch_brkr_num  
      from dbo.trade_item ti  
              LEFT OUTER JOIN dbo.commodity_market cm  
                 ON ti.cmdty_code = cm.cmdty_code and  
                    ti.risk_mkt_code = cm.mkt_code  
              INNER JOIN dbo.accumulation acc  
                 ON ti.trade_num = acc.trade_num and  
                    ti.order_num = acc.order_num and  
                    ti.item_num = acc.item_num  
      where ti.item_type = 'C' and   
            ti.formula_ind = 'Y' and  
            acc.price_status <> 'F') trditm  
         INNER JOIN (select trade_num,  
                            order_num,  
                            order_type_code  
                     from dbo.trade_order  
                     where strip_summary_ind <> 'Y' and  
                           order_type_code in ('SWAP', 'SWAPFLT')) trdord  
            ON trditm.trade_num = trdord.trade_num and  
               trditm.order_num = trdord.order_num  
         INNER JOIN (select trade_num,  
                            inhouse_ind,  
                            trader_init,   
                            acct_num,   
                            creator_init,  
                            contr_date   
                     from dbo.trade  
                     where conclusion_type = 'C') trd  
             ON trditm.trade_num = trd.trade_num  
GO
GRANT SELECT ON  [dbo].[v_VAR_swap_trades_v24] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_VAR_swap_trades_v24] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_VAR_swap_trades_v24', NULL, NULL
GO
