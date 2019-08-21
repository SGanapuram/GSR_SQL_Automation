SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchConcDelTermRevPK]
   @asof_trans_id   bigint,
   @oid       int
as
declare @trans_id   bigint

   select @trans_id = trans_id
   from dbo.conc_del_term
   where oid = @oid

if @trans_id <= @asof_trans_id
begin
   select
		asof_trans_id = @asof_trans_id,
		conc_prior_ver_oid,
		conc_contract_oid,
		del_term_code,
		loc_code,
		loc_country_code,
		loc_type,
		oid,
		resp_trans_id = null,
		term_type,
		trans_id,
		version_num
	from dbo.conc_del_term
	where oid = @oid
end
else
begin
   set rowcount 1
   select 
		asof_trans_id = @asof_trans_id,
		conc_prior_ver_oid,
		conc_contract_oid,
		del_term_code,
		loc_code,
		loc_country_code,
		loc_type,
		oid,
		resp_trans_id,
		term_type,
		trans_id,
		version_num
   from dbo.aud_conc_del_term
   where oid = @oid and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchConcDelTermRevPK] TO [next_usr]
GO
