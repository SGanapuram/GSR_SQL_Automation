SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_conc_delivery_schedule_rev]
(
	oid,
	conc_contract_oid,
	version_num,
	conc_prior_ver_oid,
	quantity,
	quantity_uom_code,
	additional_qty,
	additional_qty_uom_code,
	tolerance_qty,
	tolerance_qty_uom_code,
	dry_wet_ind,
    moisture_percent,
	moisture_precision,
	franchise_charge,
	tol_option,
	periodicity,
	num_of_deliveries,
	delivery_start_date,
	trade_num,
	prorated_flat_amt,
	flat_amt_curr_code,
	creation_date,
    custom_delivery_schedule_id,
	trans_id,
	resp_trans_id
)
as 
select
  	oid,
	conc_contract_oid,
	version_num,
	conc_prior_ver_oid,
	quantity,
	quantity_uom_code,
	additional_qty,
	additional_qty_uom_code,
	tolerance_qty,
	tolerance_qty_uom_code,
	dry_wet_ind,
    moisture_percent,
	moisture_precision,
	franchise_charge,
	tol_option,
	periodicity,
	num_of_deliveries,
	delivery_start_date,
	trade_num,
	prorated_flat_amt,
	flat_amt_curr_code,
	creation_date,
    custom_delivery_schedule_id,	
	trans_id,
	resp_trans_id
from dbo.aud_conc_delivery_schedule
GO
GRANT SELECT ON  [dbo].[v_conc_delivery_schedule_rev] TO [next_usr]
GO
