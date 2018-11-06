SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_get_tiMTMPlAsofDate]
(
   @pl_asof_date  varchar(20) = null
)
as
set nocount on
declare @my_pl_asof_date  varchar(20)

   select @my_pl_asof_date = @pl_asof_date
   if @my_pl_asof_date is null
   begin
      print 'Usage: exec usp_get_tiMTMPlAsofDate @pl_asof_date = ''?'''
      print '=> Please provide a valid date to the argument @pl_asof_date!'
      return 1
   end
  
   select distinct 
      timtm.acct_num,
      qppmtm.accum_num,
      tidmtm.addl_cost_sum,
      tidmtm.alloc_qty,
      timtm.booking_comp_num,
      tidmtm.closed_pl,	
      timtm.cmdty_code,
      timtm.contr_date,
      timtm.contr_qty,	
      timtm.contr_qty_periodicity,
      timtm.contr_qty_uom_code,
      timtm.creation_date,
      tidmtm.curr_code,
      tidmtm.curr_conv_rate,
      tidmtm.delta,
      tidmtm.discount_factor,
      tidmtm.dist_num,
      tidmtm.dist_qty,
      tidmtm.dist_type,
      tidmtm.drift,
      tidmtm.gamma,
      tidmtm.interest_rate,
      timtm.item_num, 
      timtm.last_trade_date,
      tidmtm.market_value,
      qppmtm.num_of_days_priced,
      qppmtm.num_of_pricing_days,
      tidmtm.open_pl,
      qppmtm.open_price,
      timtm.open_qty,	
      timtm.order_num, 
      timtm.order_type_code,
      timtm.p_s_ind,
      timtm.mtm_pl_asof_date as pl_asof_date,
      tidmtm.pos_num,
      qppmtm.price_curr_code,
      tidmtm.price_diff_value,
      qppmtm.price_uom_code,
      qppmtm.priced_price,
      qppmtm.qpp_num,
      qppmtm.trans_id as qpp_trans_id,
      tidmtm.qty_uom_code,
      tidmtm.qty_uom_code_conv_to,
      qppmtm.quote_end_date,
      qppmtm.quote_start_date,
      timtm.real_port_num,
      tidmtm.rho,
      timtm.risk_mkt_code,	
      tidmtm.sec_conversion_factor,
      tidmtm.sec_qty_uom_code,
      tidmtm.theta,
      timtm.trading_prd as ti_last_trade_date,
      timtm.trans_id as ti_trans_id,	
      tidmtm.commkt_key as tid_commkt_key,
      tidmtm.last_trade_date as tid_last_trade_date,
      tidmtm.p_s_ind as tid_p_s_ind,
      tidmtm.trans_id as tid_trans_id,
      tidmtm.trade_modified_ind,
      timtm.trade_num, 
      tidmtm.trade_value,	
      timtm.trader_init,
      tidmtm.trading_prd,
      tidmtm.vega,	
      tidmtm.volatility
/********************************************************************************      
   from ti_mark_to_market timtm, 
        tid_mark_to_market tidmtm,
        qpp_mark_to_market qppmtm
   where tidmtm.trade_num = timtm.trade_num and
         tidmtm.order_num = timtm.order_num and
         tidmtm.item_num = timtm.item_num and
         tidmtm.mtm_pl_asof_date = timtm.mtm_pl_asof_date and
         timtm.trade_num *= qppmtm.trade_num and
         timtm.order_num *= qppmtm.order_num and
         timtm.item_num *= qppmtm.item_num and
         timtm.mtm_pl_asof_date *= qppmtm.mtm_pl_asof_date and 
         timtm.mtm_pl_asof_date = @my_pl_asof_date
*********************************************************************************/  
    from ti_mark_to_market timtm
        inner join tid_mark_to_market tidmtm
            on tidmtm.trade_num = timtm.trade_num
            and tidmtm.order_num = timtm.order_num
            and tidmtm.item_num = timtm.item_num
            and tidmtm.mtm_pl_asof_date = timtm.mtm_pl_asof_date
            and timtm.mtm_pl_asof_date = @my_pl_asof_date
        left outer join qpp_mark_to_market qppmtm
            on timtm.trade_num = qppmtm.trade_num
            and timtm.order_num = qppmtm.order_num
            and timtm.item_num = qppmtm.item_num
            and timtm.mtm_pl_asof_date = qppmtm.mtm_pl_asof_date
            
return 0
GO
GRANT EXECUTE ON  [dbo].[usp_get_tiMTMPlAsofDate] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_get_tiMTMPlAsofDate', NULL, NULL
GO
