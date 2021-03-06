SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                                 
CREATE proc [dbo].[fetchContractExecutionToExecPhysInv]                                      
(
   @asof_trans_id      bigint,
   @exec_inv_num       int
)
as
set nocount on
declare @trans_id   bigint
   select asof_trans_id = @asof_trans_id,
          brand_id,
          cmdty_code,
          conc_del_item_oid,
          contract_execution_oid,
          del_loc_code,
          del_term_code,
          exec_inv_num,
          inv_actual_qty,
          inv_adj_qty,
          inv_matched_qty,
          inv_matched_qty_uom_code,
          inv_price_curr_code,
          inv_price_uom_code,
          inv_proj_qty,
          inv_qty_uom_code,
          inv_sec_actual_qty,
          inv_sec_adj_qty,
          inv_sec_proj_qty,
          inv_sec_qty_uom_code,
          inv_unit_price,
          item_num,
          order_num,
          p_s_ind,
          pos_num,
          real_port_num,
          resp_trans_id = NULL,
          trade_num,
          trans_id,
          version_num,
          wsmd_loc_code
   from dbo.exec_phys_inv
   where exec_inv_num = @exec_inv_num and
         trans_id <= @asof_trans_id
   union
   select asof_trans_id = @asof_trans_id,
          brand_id,
          cmdty_code,
          conc_del_item_oid,
          contract_execution_oid,
          del_loc_code,
          del_term_code,
          exec_inv_num,
          inv_actual_qty,
          inv_adj_qty,
          inv_matched_qty,
          inv_matched_qty_uom_code,
          inv_price_curr_code,
          inv_price_uom_code,
          inv_proj_qty,
          inv_qty_uom_code,
          inv_sec_actual_qty,
          inv_sec_adj_qty,
          inv_sec_proj_qty,
          inv_sec_qty_uom_code,
          inv_unit_price,
          item_num,
          order_num,
          p_s_ind,
          pos_num,
          real_port_num,
          resp_trans_id,
          trade_num,
          trans_id,
          version_num,
          wsmd_loc_code
   from dbo.aud_exec_phys_inv
   where exec_inv_num = @exec_inv_num and
         (trans_id <= @asof_trans_id and
          resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchContractExecutionToExecPhysInv] TO [next_usr]
GO
