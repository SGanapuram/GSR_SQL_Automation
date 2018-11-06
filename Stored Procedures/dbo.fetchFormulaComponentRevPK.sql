SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchFormulaComponentRevPK]
(
   @asof_trans_id         int,
   @formula_body_num      tinyint,
   @formula_comp_num      smallint,
   @formula_num           int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.formula_component
where formula_num = @formula_num and
      formula_body_num = @formula_body_num and
      formula_comp_num = @formula_comp_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      commkt_key,
      formula_body_num,
      formula_comp_cmnt,
      formula_comp_curr_code,
      formula_comp_label,
      formula_comp_name,
      formula_comp_num,
      formula_comp_pos_num,
      formula_comp_ref,
      formula_comp_type,
      formula_comp_uom_code,
      formula_comp_val,
      formula_comp_val_type,
      formula_num,
      is_type_weight_ind,
      linear_factor,
      price_source_code,
      resp_trans_id = null,
      trading_prd,
      trans_id
   from dbo.formula_component
   where formula_num = @formula_num and
         formula_body_num = @formula_body_num and
         formula_comp_num = @formula_comp_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      commkt_key,
      formula_body_num,
      formula_comp_cmnt,
      formula_comp_curr_code,
      formula_comp_label,
      formula_comp_name,
      formula_comp_num,
      formula_comp_pos_num,
      formula_comp_ref,
      formula_comp_type,
      formula_comp_uom_code,
      formula_comp_val,
      formula_comp_val_type,
      formula_num,
      is_type_weight_ind,
      linear_factor,
      price_source_code,
      resp_trans_id,
      trading_prd,
      trans_id
   from dbo.aud_formula_component
   where formula_num = @formula_num and
         formula_body_num = @formula_body_num and
         formula_comp_num = @formula_comp_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchFormulaComponentRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchFormulaComponentRevPK', NULL, NULL
GO
