SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchConcDocumentRevPK]
(
   @asof_trans_id   int,
   @oid       	  	int
)
as
declare @trans_id        int

   select @trans_id = trans_id
   from dbo.conc_document
   where oid = @oid

if @trans_id <= @asof_trans_id
begin
   select
		asof_trans_id = @asof_trans_id,
		conc_prior_ver_oid,
		conc_contract_oid,
		doc_creation_date,
		doc_creator_init,
		doc_description,
		doc_last_mod_date,
		doc_mod_init,
		doc_name,
		doc_url,
		oid,
		resp_trans_id = null,
		trans_id,
		version_num
	from dbo.conc_document
	where oid = @oid
end
else
begin
   set rowcount 1
   select 
		asof_trans_id = @asof_trans_id,
		conc_prior_ver_oid,
		conc_contract_oid,
		doc_creation_date,
		doc_creator_init,
		doc_description,
		doc_last_mod_date,
		doc_mod_init,
		doc_name,
		doc_url,
		oid,
		resp_trans_id,
		trans_id,
		version_num
   from dbo.aud_conc_document
   where oid = @oid and
         trans_id <= @asof_trans_id and
	     resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchConcDocumentRevPK] TO [next_usr]
GO
