SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchConcAssayRevPK]
(
   @asof_trans_id   int,
   @oid       		int
)
as
declare @trans_id        int

   select @trans_id = trans_id
   from dbo.conc_trade
   where oid = @oid

if @trans_id <= @asof_trans_id
begin
   select
      analysis_basis,
      asof_trans_id = @asof_trans_id,
      conc_contract_oid,
      conc_prior_ver_oid,
      oid,
      per_spec_uom_code,
      primary_type,
      resp_trans_id = null,
      row_order_num,
      secondary_type,
      sl_applicable,
      spec_code,
      spec_max_value,
      spec_max_value_text,
      spec_min_value,
      spec_min_value_text,
      spec_regulatory_limit,
      spec_regulatory_limit_text,
      spec_typical_value,
      spec_typical_value_text,
      spec_uom_code,
      splitting_limit,
      trans_id,
      umpire_rule
   from dbo.conc_assay
   where oid = @oid
end
else
begin
   set rowcount 1
   select 
      analysis_basis,
      asof_trans_id = @asof_trans_id,
      conc_contract_oid,
      conc_prior_ver_oid,
      oid,
      per_spec_uom_code,
      primary_type,
      resp_trans_id,
      row_order_num,
      secondary_type,
      sl_applicable,
      spec_code,
      spec_max_value,
      spec_max_value_text,
      spec_min_value,
      spec_min_value_text,
      spec_regulatory_limit,
      spec_regulatory_limit_text,
      spec_typical_value,
      spec_typical_value_text,
      spec_uom_code,
      splitting_limit,
      trans_id,
      umpire_rule
   from dbo.aud_conc_assay
   where oid = @oid and
         trans_id <= @asof_trans_id and
	     resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchConcAssayRevPK] TO [next_usr]
GO
