SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchConcBrandRevPK]
(
   @asof_trans_id   bigint,
   @oid       		int
)
as
declare @trans_id   bigint

   select @trans_id = trans_id
   from dbo.conc_brand
   where oid = @oid

if @trans_id <= @asof_trans_id
begin
   select
		asof_trans_id = @asof_trans_id,
		brand_code,
		conc_contract_oid,
		conc_prior_ver_oid,
		oid,
		resp_trans_id = null,
		trans_id,
		version_num
	from dbo.conc_brand
	where oid = @oid
end
else
begin
   set rowcount 1
   select 
		asof_trans_id = @asof_trans_id,
		brand_code,
		conc_contract_oid,
		conc_prior_ver_oid,
		oid,
		resp_trans_id,
		trans_id,
		version_num
   from dbo.aud_conc_brand
   where oid = @oid and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchConcBrandRevPK] TO [next_usr]
GO
