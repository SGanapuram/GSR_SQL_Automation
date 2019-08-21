SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_conc_delivery_schedule_all_rs]
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
    cq.oid,
	cq.conc_contract_oid,
	cq.version_num,
	cq.conc_prior_ver_oid,
	cq.quantity,
	cq.quantity_uom_code,
	cq.additional_qty,
	cq.additional_qty_uom_code,
	cq.tolerance_qty,
	cq.tolerance_qty_uom_code,
	cq.dry_wet_ind,
	cq.periodicity,
	cq.num_of_deliveries,
	cq.delivery_start_date,
	cq.trade_num,
	cq.prorated_flat_amt,
	cq.flat_amt_curr_code,
	cq.creation_date,
	cq.custom_delivery_schedule_id,
	cq.trans_id,
	null
from dbo.conc_delivery_schedule cq
        left outer join dbo.icts_transaction it
           on cq.trans_id = it.trans_id
union
select
	cq.oid,
	cq.conc_contract_oid,
	cq.version_num,
	cq.conc_prior_ver_oid,
	cq.quantity,
	cq.quantity_uom_code,
	cq.additional_qty,
	cq.additional_qty_uom_code,
	cq.tolerance_qty,
	cq.tolerance_qty_uom_code,
	cq.dry_wet_ind,
	cq.periodicity,
	cq.num_of_deliveries,
	cq.delivery_start_date,
	cq.trade_num,
	cq.prorated_flat_amt,
	cq.flat_amt_curr_code,
	cq.creation_date,
    cq.custom_delivery_schedule_id,	
	cq.trans_id,
    cq.resp_trans_id
from dbo.aud_conc_delivery_schedule cq
        left outer join dbo.icts_transaction it
           on cq.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_conc_delivery_schedule_all_rs] TO [next_usr]
GO
