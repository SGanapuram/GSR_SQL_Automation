SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchConcDeliveryItemRevPK]
   @asof_trans_id   int,
   @oid       		int
as
declare @trans_id        int

   select @trans_id = trans_id
   from dbo.conc_delivery_item
   where oid = @oid

if @trans_id <= @asof_trans_id
begin
   select
		actual_qty,
		actual_qty_uom_code,
		asof_trans_id = @asof_trans_id,
		cmnt_num,
		conc_prior_ver_oid,
		conc_contract_oid,
		conc_delivery_schedule_oid,
		contract_execution_oid,
		custom_delivery_lot_id,
		del_date_from,
		del_date_to,
		del_qty,
		del_qty_uom_code,
		del_status_ind,
		flat_amt_curr_code,
		item_num,		
		max_qty,
		max_qty_uom_code,
		min_qty,
		min_qty_uom_code,
		oid,
		order_num,
		prorated_flat_amt,
		resp_trans_id = null,
		title_document_num,
		total_exec_qty,
		total_exec_qty_uom_code,
		trade_num,
		trans_id,
		version_num
	from dbo.conc_delivery_item
	where oid = @oid
end
else
begin
   set rowcount 1
   select 
		actual_qty,
		actual_qty_uom_code,
		asof_trans_id = @asof_trans_id,
		cmnt_num,
		conc_prior_ver_oid,
		conc_contract_oid,
		conc_delivery_schedule_oid,		
		contract_execution_oid,
		custom_delivery_lot_id,
		del_date_from,
		del_date_to,
		del_qty,
		del_qty_uom_code,
		del_status_ind,
		flat_amt_curr_code,
		item_num,		
		max_qty,
		max_qty_uom_code,
		min_qty,
		min_qty_uom_code,
		oid,
		order_num,
		prorated_flat_amt,
		resp_trans_id,
		title_document_num,
		total_exec_qty,
		total_exec_qty_uom_code,		
		trade_num,
		trans_id,
		version_num
   from dbo.aud_conc_delivery_item
   where oid = @oid and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchConcDeliveryItemRevPK] TO [next_usr]
GO
