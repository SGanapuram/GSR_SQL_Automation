SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_merge_trade_defaults]
as
set nocount on
declare @errcode    int

   select @errcode = 0
   
   update #cons_trade_default
   set acct_num = isnull(td.acct_num, ctd.acct_num),
       cmdty_code = isnull(td.cmdty_code, ctd.cmdty_code),
       order_type_code = isnull(td.order_type_code, ctd.order_type_code),
       risk_mkt_code = isnull(td.risk_mkt_code, ctd.risk_mkt_code),
       title_mkt_code = isnull(td.title_mkt_code, ctd.title_mkt_code),
       contr_qty = isnull(td.contr_qty, ctd.contr_qty),
       contr_qty_uom_code = isnull(td.contr_qty_uom_code, ctd.contr_qty_uom_code),
       price_curr_code = isnull(td.price_curr_code, ctd.price_curr_code),
       price_uom_code = isnull(td.price_uom_code, ctd.price_uom_code),
       booking_comp_num = isnull(td.booking_comp_num, ctd.booking_comp_num),
       gtc_code = isnull(td.gtc_code, ctd.gtc_code),
       pay_term_code = isnull(td.pay_term_code, ctd.pay_term_code),
       del_term_code = isnull(td.del_term_code, ctd.del_term_code),
       mot_code = isnull(td.mot_code, ctd.mot_code),
       del_loc_code = isnull(td.del_loc_code, ctd.del_loc_code),
       min_qty = isnull(td.min_qty, ctd.min_qty),
       min_qty_uom_code = isnull(td.min_qty_uom_code, ctd.min_qty_uom_code),
       max_qty = isnull(td.max_qty, ctd.max_qty),
       max_qty_uom_code = isnull(td.max_qty_uom_code, ctd.max_qty_uom_code),
       tol_qty = isnull(td.tol_qty, ctd.tol_qty),
       tol_qty_uom_code = isnull(td.tol_qty_uom_code, ctd.tol_qty_uom_code),
       tol_sign = isnull(td.tol_sign, ctd.tol_sign),
       tol_opt = isnull(td.tol_opt, ctd.tol_opt),
       formula_precision = isnull(td.formula_precision, ctd.formula_precision),
       brkr_num = isnull(td.brkr_num, ctd.brkr_num),
       brkr_cont_num = isnull(td.brkr_cont_num, ctd.brkr_cont_num),
       brkr_comm_amt = isnull(td.brkr_comm_amt, ctd.brkr_comm_amt),
       brkr_comm_curr_code = isnull(td.brkr_comm_curr_code, ctd.brkr_comm_curr_code),
       brkr_comm_uom_code = isnull(td.brkr_comm_uom_code, ctd.brkr_comm_uom_code),
       brkr_ref_num = isnull(td.brkr_ref_num, ctd.brkr_ref_num)
    from #cons_trade_default ctd,
         #buf_trade_default td
    select @errcode = @@error
    delete from #buf_trade_default
    if @errcode > 0
       return 1

    return 0
GO
GRANT EXECUTE ON  [dbo].[usp_merge_trade_defaults] TO [next_usr]
GO
