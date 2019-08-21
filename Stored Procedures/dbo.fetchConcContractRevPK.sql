SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchConcContractRevPK]
   @asof_trans_id   bigint,
   @oid       		int
as
declare @trans_id   bigint

   select @trans_id = trans_id
   from dbo.conc_contract
   where oid = @oid

if @trans_id <= @asof_trans_id
begin
   select
	  acct_num,
	  asof_trans_id = @asof_trans_id,
	  book_comp_num,
	  cargo_conditioning,
	  cmdty_code,
	  conc_brand_id,
	  contract_curr_code,
	  contract_fixed_curr_code,
	  contract_fixed_price,
	  contract_fixed_price_uom,
	  contract_status_code,
	  contract_year,
	  contractual_type,
	  creation_date,
	  custom_contract_id,
	  custom_contract_num,
	  external_reference,
	  fixed_price_ind,
	  main_formula_num,
	  market_formula_num,
	  oid,
	  orig_contr_qty,
	  origin_country_code,
	  p_s_ind,
	  real_port_num,
	  resp_trans_id = NULL,
	  risk_mkt_code,
	  sample_lot_size,
	  sample_lot_uom_code,
	  total_contr_max,
	  total_contr_min,
	  total_contr_qty,
	  total_execution_qty,
	  totoal_open_contr_qty,
	  trader_init,
	  traffic_operator,
	  trans_id,
	  version_num,
	  weighing_method_code,
	  workflow_status_code,
	  wsmd_insp_acct_num,
	  wsmd_settlement_basis
   from dbo.conc_contract
   where oid = @oid
end
else
begin
   set rowcount 1
   select 
	  acct_num,
	  asof_trans_id = @asof_trans_id,
	  book_comp_num,
	  cargo_conditioning,
	  cmdty_code,
	  conc_brand_id,
	  contract_curr_code,	
	  contract_fixed_curr_code,
	  contract_fixed_price,
	  contract_fixed_price_uom,
	  contract_status_code,
	  contract_year,
	  contractual_type,
	  creation_date,	
	  custom_contract_id,
	  custom_contract_num,
	  external_reference,
	  fixed_price_ind,
	  main_formula_num,
	  market_formula_num,
	  oid,
	  orig_contr_qty,
	  origin_country_code,
	  p_s_ind,	
	  real_port_num,
	  resp_trans_id,
	  risk_mkt_code,
	  sample_lot_size,
	  sample_lot_uom_code,	
	  total_contr_max,
	  total_contr_min,
	  total_contr_qty,
	  total_execution_qty,
	  totoal_open_contr_qty,
	  trader_init,
	  traffic_operator,
	  trans_id,
	  version_num,
	  weighing_method_code,
	  workflow_status_code,
	  wsmd_insp_acct_num,
	  wsmd_settlement_basis
   from dbo.aud_conc_contract
   where oid = @oid and
         trans_id <= @asof_trans_id and
	     resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchConcContractRevPK] TO [next_usr]
GO
