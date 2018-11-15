SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchConcCommentRevPK]
(
   @asof_trans_id   int,
   @oid             int
)
as
declare @trans_id        int

   select @trans_id = trans_id
   from dbo.conc_comment
   where oid = @oid

if @trans_id <= @asof_trans_id
begin
   select
		asof_trans_id = @asof_trans_id,
		cmnt_creation_date,
		cmnt_creator_init,
		cmnt_last_mod_date,
		cmnt_mod_init,
		cmnt_num,
		conc_prior_ver_oid,
		conc_contract_oid,
		oid,
		resp_trans_id = null,
		trans_id,
		version_num
	from dbo.conc_comment
	where oid = @oid
end
else
begin
   set rowcount 1
   select 
		asof_trans_id = @asof_trans_id,
		cmnt_creation_date,
		cmnt_creator_init,
		cmnt_last_mod_date,
		cmnt_mod_init,
		cmnt_num,
		conc_prior_ver_oid,
		conc_contract_oid,
		oid,
		resp_trans_id,
		trans_id,
		version_num
   from dbo.aud_conc_comment
   where oid = @oid and
         trans_id <= @asof_trans_id and
	     resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchConcCommentRevPK] TO [next_usr]
GO
