SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchConcContractPriorVersionRevPK]
(
   @asof_trans_id   int,
   @oid       	  	int
)
as
declare @trans_id        int

   select @trans_id = trans_id
   from dbo.conc_contract_prior_version
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
	  conc_contract_oid,
	  contract_status_code,
	  contract_year,
	  contractual_type,
	  custom_contract_id,
	  custom_contract_num,
	  external_reference,
	  formula_num,
	  oid,
	  orig_contr_qty,
	  p_s_ind,
	  real_port_num,
	  resp_trans_id = NULL,
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
	  workflow_status_code
   from dbo.conc_contract_prior_version
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
	  conc_contract_oid,
	  contract_status_code,
	  contract_year,
	  contractual_type,
	  custom_contract_id,
	  custom_contract_num,
	  external_reference,
	  formula_num,
	  oid,
	  orig_contr_qty,
	  p_s_ind,
	  real_port_num,
	  resp_trans_id,
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
	  workflow_status_code
   from dbo.aud_conc_contract_prior_version
   where oid = @oid and
         trans_id <= @asof_trans_id and
	     resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchConcContractPriorVersionRevPK] TO [next_usr]
GO
