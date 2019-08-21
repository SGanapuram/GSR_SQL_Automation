SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_VAR_physical_float_trades]
(
   trade_num,
   order_num,
   item_num,
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
   contr_date 
)
as
select 
   trditm.trade_num,
   trditm.order_num,
   trditm.item_num,
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
   trd.contr_date
from (select ti.trade_num,
             ti.order_num,
             ti.item_num,
             ti.cmdty_code,
             ti.risk_mkt_code,
             ti.real_port_num,
             cm.commkt_key,
             ti.booking_comp_num
      from dbo.trade_item ti
              LEFT OUTER JOIN dbo.commodity_market cm with (nolock)
                 ON ti.cmdty_code = cm.cmdty_code and
                    ti.risk_mkt_code = cm.mkt_code
      where item_type in ('W', 'B') and 
            formula_ind = 'Y' and 
            exists (select 1
                    from dbo.accumulation as acc 
                    where acc.trade_num = ti.trade_num and 
                          acc.order_num = ti.order_num and 
                          acc.item_num = ti.item_num and 
                          acc.price_status <> 'F')) trditm
         INNER JOIN (select trade_num,
                            order_num,
                            order_type_code
                     from dbo.trade_order
                     where strip_summary_ind <> 'Y') trdord
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
GRANT SELECT ON  [dbo].[v_VAR_physical_float_trades] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_VAR_physical_float_trades] TO [next_usr]
GO
