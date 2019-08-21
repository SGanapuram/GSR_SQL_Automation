SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchInventoryRevPK]  
(
   @asof_trans_id    bigint,  
   @inv_num          int 
) 
as  
set nocount on
declare @trans_id   bigint  
  
select @trans_id = trans_id  
from dbo.inventory  
where inv_num = @inv_num  
  
if @trans_id <= @asof_trans_id  
begin  
   select   
	    asof_trans_id=@asof_trans_id,  
	    balance_period,    
	    cmdty_code,    
	    cmnt_num,    
	    del_loc_code,   
	    fifo_open_qty_uom_code,
      fifo_open_qty, 
	    inv_adj_qty,    
	    inv_adj_sec_qty,    
	    inv_avg_cost,    
	    inv_bal_from_date,    
	    inv_bal_qty,    
	    inv_bal_sec_qty,    
	    inv_bal_to_date,    
	    inv_capacity,    
	    inv_cnfrmd_qty,    
	    inv_cnfrmd_sec_qty,    
	    inv_cost_curr_code,    
	    inv_cost_uom_code,    
	    inv_credit_exposure_oid,    
	    inv_curr_actual_qty,      
	    inv_curr_actual_sec_qty,    
	    inv_curr_proj_qty,    
	    inv_curr_proj_sec_qty,    
	    inv_dlvry_actual_qty,    
	    inv_dlvry_actual_sec_qty,    
	    inv_dlvry_proj_qty,    
	    inv_dlvry_proj_sec_qty,    
	    inv_fifo_cost,  
	    inv_fifo_num,  
	    inv_heel,    
	    inv_loop_num,    
	    inv_mac_cost,    
	    inv_mac_insert_cost,     
	    inv_min_op_req_qty,          
	    inv_num,    
	    inv_open_prd_actual_qty,    
	    inv_open_prd_actual_sec_qty,    
	    inv_open_prd_proj_qty,    
	    inv_open_prd_proj_sec_qty, 
	    inv_pricing_type,   
	    inv_qty_uom_code,    
	    inv_rcpt_actual_qty,    
	    inv_rcpt_actual_sec_qty,    
	    inv_rcpt_proj_qty,    
	    inv_rcpt_proj_sec_qty,    
	    inv_safe_fill,    
	    inv_sec_qty_uom_code,    
	    inv_target_max_qty,    
	    inv_target_min_qty,     
	    inv_type,    
	    inv_wacog_cost,    
	    line_fill_qty,    
	    long_cmdty_code,    
	    long_risk_mkt,    
	    mac_inv_amt,    
	    needs_repricing,    
	    next_inv_num,    
	    open_close_ind,    
	    order_num,    
	    port_num,    
	    pos_num,    
	    prev_inv_num,    
	    r_inv_avg_cost_amt,    
	    resp_trans_id=null,    
	    roll_at_mkt_price_ind,    
	    sale_item_num,   
	    sec_fifo_open_qty_uom_code,
      sec_fifo_open_qty, 
	    short_cmdty_code,    
	    short_risk_mkt,    
	    storage_subloc_name,    
	    trade_num,    
	    trans_id,    
	    unr_inv_avg_cost_amt,
	    use_mtm
   from dbo.inventory  
   where inv_num = @inv_num  
end  
else  
begin  
   select top 1  
	    asof_trans_id=@asof_trans_id,  
	    balance_period,    
	    cmdty_code,    
	    cmnt_num,    
	    del_loc_code, 
	    fifo_open_qty_uom_code,
      fifo_open_qty,   
	    inv_adj_qty,    
	    inv_adj_sec_qty,    
	    inv_avg_cost,    
	    inv_bal_from_date,    
	    inv_bal_qty,    
	    inv_bal_sec_qty,    
	    inv_bal_to_date,    
	    inv_capacity,    
	    inv_cnfrmd_qty,    
	    inv_cnfrmd_sec_qty,    
	    inv_cost_curr_code,    
	    inv_cost_uom_code,    
	    inv_credit_exposure_oid,    
	    inv_curr_actual_qty,      
	    inv_curr_actual_sec_qty,    
	    inv_curr_proj_qty,    
	    inv_curr_proj_sec_qty,    
	    inv_dlvry_actual_qty,    
	    inv_dlvry_actual_sec_qty,    
	    inv_dlvry_proj_qty,    
	    inv_dlvry_proj_sec_qty,    
	    inv_fifo_cost,  
	    inv_fifo_num,  
	    inv_heel,    
	    inv_loop_num,    
	    inv_mac_cost,    
	    inv_mac_insert_cost,     
	    inv_min_op_req_qty,          
	    inv_num,    
	    inv_open_prd_actual_qty,    
	    inv_open_prd_actual_sec_qty,    
	    inv_open_prd_proj_qty,    
	    inv_open_prd_proj_sec_qty, 
	    inv_pricing_type,   
	    inv_qty_uom_code,    
	    inv_rcpt_actual_qty,    
	    inv_rcpt_actual_sec_qty,    
	    inv_rcpt_proj_qty,    
	    inv_rcpt_proj_sec_qty,    
	    inv_safe_fill,    
	    inv_sec_qty_uom_code,    
	    inv_target_max_qty,    
	    inv_target_min_qty,     
	    inv_type,    
	    inv_wacog_cost,    
	    line_fill_qty,    
	    long_cmdty_code,    
	    long_risk_mkt,    
	    mac_inv_amt,    
	    needs_repricing,    
	    next_inv_num,    
	    open_close_ind,    
	    order_num,    
	    port_num,    
	    pos_num,    
	    prev_inv_num,    
	    r_inv_avg_cost_amt,    
	    resp_trans_id,    
	    roll_at_mkt_price_ind,    
	    sale_item_num,  
	    sec_fifo_open_qty_uom_code,
      sec_fifo_open_qty,  
	    short_cmdty_code,    
	    short_risk_mkt,    
	    storage_subloc_name,    
	    trade_num,    
	    trans_id,    
	    unr_inv_avg_cost_amt,
	    use_mtm
   from dbo.aud_inventory  
   where inv_num = @inv_num and  
         trans_id <= @asof_trans_id and  
         resp_trans_id > @asof_trans_id  
   order by trans_id desc  
end  
return  
GO
GRANT EXECUTE ON  [dbo].[fetchInventoryRevPK] TO [next_usr]
GO
