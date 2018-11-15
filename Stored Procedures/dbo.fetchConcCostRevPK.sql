SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchConcCostRevPK]
   @asof_trans_id   int,
   @oid       		int
as
declare @trans_id        int

   select @trans_id = trans_id
   from dbo.conc_exec_assay
   where oid = @oid

if @trans_id <= @asof_trans_id
begin
   select
	asof_trans_id = @asof_trans_id,
	comment,
	conc_contract_oid,
	conc_ref_cost_item_oid,
	contract_exec_detail_oid,
	contract_execution_oid,
	cost_basis,
	cost_cmnt_num,
	cost_price_curr_code,
	cost_unit_price,
	exp_rev_ind,
	oid,
	owner_code,
	resp_trans_id = NULL,
	strategy_execution_detail_oid,
	strategy_execution_oid,
	trans_id
	from dbo.conc_cost
	where oid = @oid
end
else
begin
   set rowcount 1
   select 
	asof_trans_id = @asof_trans_id,
	comment,
	conc_contract_oid,
	conc_ref_cost_item_oid,
	contract_exec_detail_oid,
	contract_execution_oid,
	cost_basis,
	cost_cmnt_num,
	cost_price_curr_code,
	cost_unit_price,
	exp_rev_ind,
	oid,
	owner_code,
	resp_trans_id,
	strategy_execution_detail_oid,
	strategy_execution_oid,
	trans_id
	from dbo.aud_conc_cost
   where oid = @oid and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchConcCostRevPK] TO [next_usr]
GO
