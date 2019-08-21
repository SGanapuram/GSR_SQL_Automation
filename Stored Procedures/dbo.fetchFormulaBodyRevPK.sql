SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchFormulaBodyRevPK]
(
   @asof_trans_id         bigint,
   @formula_body_num      tinyint,
   @formula_num           int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.formula_body
where formula_num = @formula_num and
      formula_body_num = @formula_body_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      avg_price_end_date,
      avg_price_start_date,
      char_value,
      complexity_ind,
      differential_val,
      fb_trigger_num,
      float_value,
      formula_body_num,
      formula_body_string,
      formula_body_text,
      formula_body_type,
      formula_num,
      formula_parse_string,
      formula_parse_text,
      formula_qty_pcnt_val,
      formula_qty_uom_code,
      holiday_pricing_rule,
      parent_fb_num,
      range_type,
      resp_trans_id = null,
      saturday_pricing_rule,
      sunday_pricing_rule,
      trans_id
   from dbo.formula_body
   where formula_num = @formula_num and
         formula_body_num = @formula_body_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      avg_price_end_date,
      avg_price_start_date,
      char_value,
      complexity_ind,
      differential_val,
      fb_trigger_num,
      float_value,
      formula_body_num,
      formula_body_string,
      formula_body_text,
      formula_body_type,
      formula_num,
      formula_parse_string,
      formula_parse_text,
      formula_qty_pcnt_val,
      formula_qty_uom_code,
      holiday_pricing_rule,
      parent_fb_num,
      range_type,
      resp_trans_id,
      saturday_pricing_rule,
      sunday_pricing_rule,
      trans_id
   from dbo.aud_formula_body
   where formula_num = @formula_num and
         formula_body_num = @formula_body_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchFormulaBodyRevPK] TO [next_usr]
GO
