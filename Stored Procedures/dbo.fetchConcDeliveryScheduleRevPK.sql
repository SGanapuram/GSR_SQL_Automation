SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchConcDeliveryScheduleRevPK]
   @asof_trans_id   bigint,
   @oid       		int
as
declare @trans_id   bigint

   select @trans_id = trans_id
   from dbo.conc_quantity
   where oid = @oid

if @trans_id <= @asof_trans_id
begin
   select
		additional_qty,
		additional_qty_uom_code,
		asof_trans_id = @asof_trans_id,
		conc_prior_ver_oid,
		conc_contract_oid,
		creation_date,
		custom_delivery_schedule_id,
		delivery_start_date,
		dry_wet_ind,
		flat_amt_curr_code,
		num_of_deliveries,
		oid,
		periodicity,
		prorated_flat_amt,
		quantity,
		quantity_uom_code,
		resp_trans_id = null,
		tolerance_qty,
		tolerance_qty_uom_code,
		trade_num,
		trans_id,
		version_num
	from dbo.conc_delivery_schedule
	where oid = @oid
end
else
begin
   set rowcount 1
   select 
		additional_qty,
		additional_qty_uom_code,
		asof_trans_id = @asof_trans_id,
		conc_prior_ver_oid,
		conc_contract_oid,
		creation_date,
        custom_delivery_schedule_id,
		delivery_start_date,
		dry_wet_ind,
		flat_amt_curr_code,
		num_of_deliveries,
		oid,
		periodicity,
		prorated_flat_amt,
		quantity,
		quantity_uom_code,
		resp_trans_id,
		tolerance_qty,
		tolerance_qty_uom_code,
		trade_num,
		trans_id,
		version_num
   from dbo.aud_conc_delivery_schedule
   where oid = @oid and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchConcDeliveryScheduleRevPK] TO [next_usr]
GO
