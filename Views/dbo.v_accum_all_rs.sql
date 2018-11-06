SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_accum_all_rs]
(
   trade_num,
   order_num,
   item_num,
   accum_num,
   accum_start_date,
   accum_end_date,
   nominal_start_date,
   nominal_end_date,
   quote_start_date,
   quote_end_date,
   accum_qty,
   accum_qty_uom_code,
   total_price,
   price_curr_code,
   price_status,
   last_pricing_run_date,
   last_pricing_as_of_date,
   accum_creation_type,
   manual_override_ind,
   formula_precision,
   cmnt_num,
   formula_num,
   alloc_num,
   alloc_item_num,
   cost_num,
   idms_trig_bb_ref_num,
   exercised_by_init,
   max_qpp_num,
   trans_id,
   resp_trans_id,
   ai_est_actual_num,
   trans_type,
   trans_user_init,
   tran_date,
   app_name,
   workstation_id,
   sequence
)
as
select
   maintb.trade_num,
   maintb.order_num,
   maintb.item_num,
   maintb.accum_num,
   maintb.accum_start_date,
   maintb.accum_end_date,
   maintb.nominal_start_date,
   maintb.nominal_end_date,
   maintb.quote_start_date,
   maintb.quote_end_date,
   maintb.accum_qty,
   maintb.accum_qty_uom_code,
   maintb.total_price,
   maintb.price_curr_code,
   maintb.price_status,
   maintb.last_pricing_run_date,
   maintb.last_pricing_as_of_date,
   maintb.accum_creation_type,
   maintb.manual_override_ind,
   maintb.formula_precision,
   maintb.cmnt_num,
   maintb.formula_num,
   maintb.alloc_num,
   maintb.alloc_item_num,
   maintb.cost_num,
   maintb.idms_trig_bb_ref_num,
   maintb.exercised_by_init,
   maintb.max_qpp_num,
   maintb.trans_id,
   null,
   maintb.ai_est_actual_num,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.accumulation maintb
        left outer join dbo.icts_transaction it
           on maintb.trans_id = it.trans_id
union
select
   audtb.trade_num,
   audtb.order_num,
   audtb.item_num,
   audtb.accum_num,
   audtb.accum_start_date,
   audtb.accum_end_date,
   audtb.nominal_start_date,
   audtb.nominal_end_date,
   audtb.quote_start_date,
   audtb.quote_end_date,
   audtb.accum_qty,
   audtb.accum_qty_uom_code,
   audtb.total_price,
   audtb.price_curr_code,
   audtb.price_status,
   audtb.last_pricing_run_date,
   audtb.last_pricing_as_of_date,
   audtb.accum_creation_type,
   audtb.manual_override_ind,
   audtb.formula_precision,
   audtb.cmnt_num,
   audtb.formula_num,
   audtb.alloc_num,
   audtb.alloc_item_num,
   audtb.cost_num,
   audtb.idms_trig_bb_ref_num,
   audtb.exercised_by_init,
   audtb.max_qpp_num,
   audtb.trans_id,
   audtb.resp_trans_id,
   audtb.ai_est_actual_num,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.aud_accumulation audtb
        left outer join dbo.icts_transaction it
           on audtb.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_accum_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_accum_all_rs] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[v_accum_all_rs] TO [public]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_accum_all_rs', NULL, NULL
GO