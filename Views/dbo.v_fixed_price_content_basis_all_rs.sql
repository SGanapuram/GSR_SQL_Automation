SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_fixed_price_content_basis_all_rs] 
( 
	oid,
	cp_formula_oid,
	price_rule_oid,
	spec_from_value,
	spec_to_value,
	inc_dec_ind,
	inc_dec_value,
	floor_or_ceiling_value,
	app_ind,
	price,
	fixed_pricing_basis,
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
	fi.oid,
	fi.cp_formula_oid,
	fi.price_rule_oid,
	fi.spec_from_value,
	fi.spec_to_value,
	fi.inc_dec_ind,
	fi.inc_dec_value,
	fi.floor_or_ceiling_value,
	fi.app_ind,
	fi.price,
	fi.fixed_pricing_basis,
	fi.trans_id,
	null, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.fixed_price_content_basis fi 
        left outer join dbo.icts_transaction it 
           on fi.trans_id = it.trans_id 
union 
select
	fi.oid,
	fi.cp_formula_oid,
	fi.price_rule_oid,
	fi.spec_from_value,
	fi.spec_to_value,
	fi.inc_dec_ind,
	fi.inc_dec_value,
	fi.floor_or_ceiling_value,
	fi.app_ind,
	fi.price,
	fi.fixed_pricing_basis,
	fi.trans_id,
	fi.resp_trans_id, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.aud_fixed_price_content_basis fi 
        left outer join dbo.icts_transaction it 
           on fi.trans_id = it.trans_id 
GO
GRANT SELECT ON  [dbo].[v_fixed_price_content_basis_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_fixed_price_content_basis_all_rs] TO [next_usr]
GO
