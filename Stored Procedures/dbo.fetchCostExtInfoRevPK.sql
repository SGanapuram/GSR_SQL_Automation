SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchCostExtInfoRevPK]
(
   @asof_trans_id      int,
   @cost_num           int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.cost_ext_info
where cost_num = @cost_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      cost_desc,
      cost_num,
      cost_pl_contribution_ind,
      creation_fx_rate,
      creation_rate_m_d_ind,
      discount_rate,
      fx_compute_ind,
      fx_exp_num,
      fx_link_oid,
      fx_locking_status,
      fx_real_port_num,
      lc_num,
      manual_input_pl_contrib_ind,
      material_code,
      orig_voucher_num,
      pay_term_override_ind,
      pl_contrib_mod_transid,
      pr_cost_num,
      prelim_type_override_ind,
      prepayment_ind,
      qty_adj_factor,
      qty_adj_rule_num,
      related_cost_num,
      reserve_cost_amt,
      resp_trans_id = null,
      risk_cover_num,
      trans_id,
      vat_rate,
      voyage_code
   from dbo.cost_ext_info
   where cost_num = @cost_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      cost_desc,
      cost_num,
      cost_pl_contribution_ind,
      creation_fx_rate,
      creation_rate_m_d_ind,
      discount_rate,
      fx_compute_ind,
      fx_exp_num,
      fx_link_oid,
      fx_locking_status,
      fx_real_port_num,
      lc_num,
      manual_input_pl_contrib_ind,
      material_code,
      orig_voucher_num,
      pay_term_override_ind,
      pl_contrib_mod_transid,
      pr_cost_num,
      prelim_type_override_ind,
      prepayment_ind,
      qty_adj_factor,
      qty_adj_rule_num,
      related_cost_num,
      reserve_cost_amt,
      resp_trans_id,
      risk_cover_num,
      trans_id,
      vat_rate,
      voyage_code
   from dbo.aud_cost_ext_info
   where cost_num = @cost_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchCostExtInfoRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchCostExtInfoRevPK', NULL, NULL
GO
