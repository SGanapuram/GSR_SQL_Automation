SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchTradeItemToAccum]
(
   @asof_trans_id      int,
   @item_num           smallint,
   @order_num          smallint,
   @trade_num          int
)
as
set nocount on
 
   select accum_creation_type,
          accum_end_date,
          accum_num,
          accum_qty,
          accum_qty_uom_code,
          accum_start_date,
          ai_est_actual_num,
          alloc_item_num,
          alloc_num,
          asof_trans_id = @asof_trans_id,
          cmnt_num,
          cost_num,
          exercised_by_init,
          formula_num,
          formula_precision,
          idms_trig_bb_ref_num,
          item_num,
          last_pricing_as_of_date,
          last_pricing_run_date,
          manual_override_ind,
          max_qpp_num,
          nominal_end_date,
          nominal_start_date,
          order_num,
          price_curr_code,
          price_status,
          quote_end_date,
          quote_start_date,
          resp_trans_id = NULL,
          total_price,
          trade_num,
          trans_id
   from dbo.accumulation
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num and
         trans_id <= @asof_trans_id
   union
   select accum_creation_type,
          accum_end_date,
          accum_num,
          accum_qty,
          accum_qty_uom_code,
          accum_start_date,
          ai_est_actual_num,
          alloc_item_num,
          alloc_num,
          asof_trans_id = @asof_trans_id,
          cmnt_num,
          cost_num,
          exercised_by_init,
          formula_num,
          formula_precision,
          idms_trig_bb_ref_num,
          item_num,
          last_pricing_as_of_date,
          last_pricing_run_date,
          manual_override_ind,
          max_qpp_num,
          nominal_end_date,
          nominal_start_date,
          order_num,
          price_curr_code,
          price_status,
          quote_end_date,
          quote_start_date,
          resp_trans_id,
          total_price,
          trade_num,
          trans_id
   from dbo.aud_accumulation
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num and
         (trans_id <= @asof_trans_id and
          resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchTradeItemToAccum] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchTradeItemToAccum', NULL, NULL
GO
