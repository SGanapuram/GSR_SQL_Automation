SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_qp_pricing_all_rs] 
(
	oid,
	qp_option_oid,
	pricing_option_ind,
	min_qty,
	min_qty_uom_code,
	trans_id,
	resp_trans_id, 
	trans_type, 
	trans_user_init, 
	tran_date, 
	app_name, 
	workstation_id, 
	sequence 
) 
as 
select 
	qp.oid,
	qp.qp_option_oid,
	qp.pricing_option_ind,
	qp.min_qty,
	qp.min_qty_uom_code,
	qp.trans_id,
	null, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.qp_pricing qp 
         left outer join dbo.icts_transaction it 
            on qp.trans_id = it.trans_id 
union 
select 
	qp.oid,
	qp.qp_option_oid,
	qp.pricing_option_ind,
	qp.min_qty,
	qp.min_qty_uom_code,
	qp.trans_id,
	qp.resp_trans_id, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.aud_qp_pricing qp 
        left outer join dbo.icts_transaction it 
          on qp.trans_id = it.trans_id 
GO
GRANT SELECT ON  [dbo].[v_qp_pricing_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_qp_pricing_all_rs] TO [next_usr]
GO
