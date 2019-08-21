SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchConcAssayActivityRevPK]
(
   @asof_trans_id   bigint,
   @oid       	  	int
)
as
declare @trans_id   bigint

   select @trans_id = trans_id
   from dbo.conc_assay_activity
   where oid = @oid

if @trans_id <= @asof_trans_id
begin
   select
      activity_trigger,
      asof_trans_id = @asof_trans_id,
      assay_activity_code,
      conc_prior_ver_oid,
      conc_contract_oid,
      oid,
      resp_trans_id = null,
      target,
      time,
      trans_id,
      version_num
   from dbo.conc_assay_activity
   where oid = @oid
end
else
begin
   set rowcount 1
   select 
      activity_trigger,
      asof_trans_id = @asof_trans_id,
      assay_activity_code,
      conc_prior_ver_oid,
      conc_contract_oid,
      oid,
      resp_trans_id,
      target,
      time,
      trans_id,
      version_num
   from dbo.aud_conc_assay_activity
   where oid = @oid and
         trans_id <= @asof_trans_id and
	     resp_trans_id > @asof_trans_id
   order by trans_id desc
end

return
GO
GRANT EXECUTE ON  [dbo].[fetchConcAssayActivityRevPK] TO [next_usr]
GO
