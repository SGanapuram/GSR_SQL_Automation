SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_VAR_exchange_options_v24]  
(  
   trade_num,  
   order_num,  
   item_num,  
   cmdty_code,  
   risk_mkt_code,  
   trading_prd,  
   opt_exp_date,  
   last_trade_date,   
   opt_type,  
   put_call_ind,  
   strike_price,  
   strike_price_curr_code,   
   strike_price_uom_code,   
   commkt_curr_code,  
   commkt_price_uom_code,  
   commkt_key,  
   mtm_price_source_code,  
   mkt_type,  
   sec_price_source_code,  
   inhouse_ind,  
   real_port_num,  
   first_del_date,  
   last_del_date,  
   contr_date,  
   trader_init,  
   acct_num,  
   creator_init,  
   booking_comp_num,  
   order_type_code,  
   brkr_num,   
   clr_brkr_num   
)  
as  
select   
   trditm.trade_num,   
   trditm.order_num,   
   trditm.item_num,   
   trditm.cmdty_code,   
   trditm.risk_mkt_code,   
   trditm.trading_prd,   
   trditm.opt_exp_date,  
   trditm.last_trade_date,   
   trditm.opt_type,   
   trditm.put_call_ind,   
   trditm.strike_price,  
   trditm.strike_price_curr_code,   
   trditm.strike_price_uom_code,   
   trditm.fut_commkt_curr_code,   
   trditm.fut_commkt_price_uom_code,   
   trditm.commkt_key,   
   trditm.mtm_price_source_code,   
   trditm.mkt_type,   
   trditm.fut_sec_price_source_code,   
   trd.inhouse_ind,  
   trditm.real_port_num,   
   trditm.first_del_date,   
   trditm.last_del_date,  
   trd.contr_date,   
   trd.trader_init,  
   trd.acct_num,  
   trd.creator_init,  
   trditm.booking_comp_num,   
   trdord.order_type_code,  
   trditm.brkr_num,  
   trditm.clr_brkr_num  
from (select ti.trade_num,  
             ti.order_num,  
             ti.item_num,  
             ti.cmdty_code,  
             ti.risk_mkt_code,  
             ti.trading_prd,  
             ti.real_port_num,  
             cm.commkt_key,  
             cm.mtm_price_source_code,  
             cm.mkt_type,  
             ti.booking_comp_num,  
             isnull(trdprd.opt_exp_date, '01/01/1900') as opt_exp_date,  
             trdprd.last_trade_date,  
             trdprd.first_del_date,  
             trdprd.last_del_date,  
             tieo.opt_type,   
             tieo.put_call_ind,   
             tieo.strike_price,  
             tieo.strike_price_curr_code,   
             tieo.strike_price_uom_code,                
             cm.fut_commkt_curr_code,   
             cm.fut_commkt_price_uom_code,   
             cm.fut_sec_price_source_code,  
             ti.brkr_num,  
             tieo.clr_brkr_num  
      from dbo.trade_item ti  
              LEFT OUTER JOIN dbo.v_VAR_commkt_info cm  
                 ON ti.cmdty_code = cm.cmdty_code and  
                    ti.risk_mkt_code = cm.mkt_code  
              LEFT OUTER JOIN dbo.trading_period trdprd  
                 ON cm.commkt_key = trdprd.commkt_key and  
                    ti.trading_prd = trdprd.trading_prd   
              INNER JOIN dbo.trade_item_exch_opt tieo   
                 ON ti.trade_num = tieo.trade_num AND   
                    ti.order_num = tieo.order_num AND   
                    ti.item_num = tieo.item_num   
      where ti.item_type = 'E') trditm  
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
GRANT SELECT ON  [dbo].[v_VAR_exchange_options_v24] TO [next_usr]
GO
