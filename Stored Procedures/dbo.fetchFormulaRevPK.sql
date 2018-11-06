SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchFormulaRevPK]
(
   @asof_trans_id       int,
   @formula_num         int
)
as
set nocount on
declare @trans_id        int

select @trans_id = trans_id
from dbo.formula
where formula_num = @formula_num

if @trans_id <= @asof_trans_id
begin
   select 
       asof_trans_id=@asof_trans_id,
       cmnt_num,
       formula_curr_code,
       formula_name,
       formula_num,
       formula_precision,
       formula_rounding_level,
       formula_status,
       formula_type,
       formula_uom_code,
       formula_use,
	     max_qp_opt_end_date,
       modular_ind,
       monthly_pricing_inds,
       parent_formula_num,
       price_assay_final_ind,
       resp_trans_id = null,
       trans_id,
       use_alt_source_ind,
       use_exec_price_ind       
   from dbo.formula
   where formula_num = @formula_num
end
else
begin
   set rowcount 1
   select 
       asof_trans_id=@asof_trans_id,
       cmnt_num,
       formula_curr_code,
       formula_name,
       formula_num,
       formula_precision,
       formula_rounding_level,
       formula_status,
       formula_type,
       formula_uom_code,
       formula_use,
	     max_qp_opt_end_date,
       modular_ind,
       monthly_pricing_inds,
       parent_formula_num,
       price_assay_final_ind,
       resp_trans_id,
       trans_id,
       use_alt_source_ind,
       use_exec_price_ind
   from dbo.aud_formula
   where formula_num = @formula_num and
         trans_id <= @asof_trans_id and
	       resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchFormulaRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchFormulaRevPK', NULL, NULL
GO
