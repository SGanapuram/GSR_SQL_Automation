SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_cost_ext_info_rev]
(
   cost_num,
   pr_cost_num,
   prepayment_ind,
   voyage_code,
   trans_id,
   asof_trans_id,
   resp_trans_id,
   qty_adj_rule_num,
   qty_adj_factor,
   orig_voucher_num,
   pay_term_override_ind,
   vat_rate,
   discount_rate,
   cost_pl_contribution_ind,
   material_code,
   related_cost_num,
   fx_exp_num,
   creation_fx_rate,
   creation_rate_m_d_ind,
   fx_link_oid,
   fx_locking_status,
   fx_compute_ind,
   fx_real_port_num,
   reserve_cost_amt,
   pl_contrib_mod_transid,
   manual_input_pl_contrib_ind,
   cost_desc,
   risk_cover_num,
   prelim_type_override_ind,
   lc_num
)
as
select
   cost_num,
   pr_cost_num,
   prepayment_ind,
   voyage_code,
   trans_id,
   trans_id,
   resp_trans_id,
   qty_adj_rule_num,
   qty_adj_factor,
   orig_voucher_num,
   pay_term_override_ind,
   vat_rate,
   discount_rate,
   cost_pl_contribution_ind,
   material_code,
   related_cost_num,
   fx_exp_num,
   creation_fx_rate,
   creation_rate_m_d_ind,
   fx_link_oid,
   fx_locking_status,
   fx_compute_ind,
   fx_real_port_num,
   reserve_cost_amt,
   pl_contrib_mod_transid,
   manual_input_pl_contrib_ind,
   cost_desc,
   risk_cover_num,
   prelim_type_override_ind,
   lc_num
from dbo.aud_cost_ext_info
GO
GRANT SELECT ON  [dbo].[v_cost_ext_info_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_cost_ext_info_rev] TO [next_usr]
GO
