SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchExecLogisticsDetailsRevPK]
   @asof_trans_id   bigint,
   @oid       		int
as
declare @trans_id   bigint

   select @trans_id = trans_id
   from dbo.conc_exec_assay
   where oid = @oid

if @trans_id <= @asof_trans_id
begin
   select
		asof_trans_id = @asof_trans_id,
		conc_exec_weight_oid,
		conc_ref_result_type_oid,
		contract_exec_oid
		from_date,
		from_date_actual_ind,
		group_num,
		line_num,
		mot_desc,
		oid,
		resp_trans_id = NULL,
		title_date_actual_ind,
		title_passage_date,
		to_date,
		to_date_actual_ind,
		trans_id,
		transporter_name
	from dbo.exec_logistics_details
	where oid = @oid
end
else
begin
   set rowcount 1
   select 
		asof_trans_id = @asof_trans_id,
		conc_exec_weight_oid,
		conc_ref_result_type_oid,
		contract_exec_oid
		from_date,
		from_date_actual_ind,
		group_num,
		line_num,
		mot_desc,
		oid,
		resp_trans_id,
		title_date_actual_ind,
		title_passage_date,
		to_date,
		to_date_actual_ind,
		trans_id,
		transporter_name
	from dbo.aud_exec_logistics_details
   where oid = @oid and
         trans_id <= @asof_trans_id and
	       resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchExecLogisticsDetailsRevPK] TO [next_usr]
GO
