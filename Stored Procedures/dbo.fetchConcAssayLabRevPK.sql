SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchConcAssayLabRevPK]
(
   @asof_trans_id   bigint,
   @oid             int
)
as
declare @trans_id   bigint

   select @trans_id = trans_id
   from dbo.conc_assay_lab
   where oid = @oid

if @trans_id <= @asof_trans_id
begin
   select
		asof_trans_id = @asof_trans_id,
		assay_lab_code,
		conc_prior_ver_oid,
		conc_contract_oid,
		final_binding_ind,
		oid,
		resp_trans_id = null,
		trans_id,
		umpire_ind,
		version_num
	from dbo.conc_assay_lab
	where oid = @oid
end
else
begin
   set rowcount 1
   select 
		asof_trans_id = @asof_trans_id,
		assay_lab_code,
		conc_prior_ver_oid,
		conc_contract_oid,
		final_binding_ind,
		oid,
		resp_trans_id,
		trans_id,
		umpire_ind,
		version_num
   from dbo.aud_conc_assay_lab
   where oid = @oid and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchConcAssayLabRevPK] TO [next_usr]
GO
