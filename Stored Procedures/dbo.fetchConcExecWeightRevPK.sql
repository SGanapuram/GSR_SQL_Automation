SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchConcExecWeightRevPK]
   @asof_trans_id   bigint,
   @oid       		int
as
declare @trans_id   bigint

   select @trans_id = trans_id
   from dbo.conc_exec_weight
   where oid = @oid

if @trans_id <= @asof_trans_id
begin
   select
	asof_trans_id = @asof_trans_id,
	cargo_condition_code,
	conc_ref_document_oid,
	conc_ref_result_type_oid,
	contract_execution_oid,
	final_ind,
	franchise_percent,
	group_num,
	insp_acct_num,
	line_num,
	loc_code,
	loc_country_code,
	loc_type_code,
	measure_date,
	moisture_percent,
	oid,
	prim_qty,
	prim_qty_uom_code,
	resp_trans_id = NULL,
	result_date,	
	sec_qty,
	sec_qty_uom_code,
	short_comment,
	title_ind,
	trans_id,
	use_in_pl_ind,
	weight_detail_num,
	weight_type	
	from dbo.conc_exec_weight
	where oid = @oid
end
else
begin
   set rowcount 1
   select 
	asof_trans_id = @asof_trans_id,
	cargo_condition_code,
	conc_ref_document_oid,
	conc_ref_result_type_oid,
	contract_execution_oid,
	final_ind,
	franchise_percent,
	group_num,
	insp_acct_num,
	line_num,
	loc_code,
	loc_country_code,
	loc_type_code,
	measure_date,
	moisture_percent,
	oid,
	prim_qty,
	prim_qty_uom_code,
	resp_trans_id,
	result_date,	
	sec_qty,
	sec_qty_uom_code,
	short_comment,
	title_ind,
	trans_id,
	use_in_pl_ind,
	weight_detail_num,
	weight_type	
	from dbo.aud_conc_exec_weight
   where oid = @oid and
         trans_id <= @asof_trans_id and
	       resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchConcExecWeightRevPK] TO [next_usr]
GO
