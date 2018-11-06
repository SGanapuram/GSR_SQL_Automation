SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchFormulaToFormBody]
(
   @asof_trans_id      int,
   @formula_num        int
)
as
set nocount on

   /* Sep-11-2002   return NULL for the TEXT columns because the UNION operator
                     can not be used while they exists in SELECT column list.
   */
 
   select asof_trans_id = @asof_trans_id,
          avg_price_end_date,
          avg_price_start_date,
          char_value,
          complexity_ind,
          differential_val,
          fb_trigger_num,
          float_value,
          formula_body_num,
          formula_body_string,
          formula_body_text = NULL,
          formula_body_type,
          formula_num,
          formula_parse_string,
          formula_parse_text = NULL,
          formula_qty_pcnt_val,
          formula_qty_uom_code,
          holiday_pricing_rule,
          parent_fb_num,
          range_type,
          resp_trans_id = NULL,
          saturday_pricing_rule,
          sunday_pricing_rule,
          trans_id
   from dbo.formula_body
   where formula_num = @formula_num and
         trans_id <= @asof_trans_id
   union
   select asof_trans_id = @asof_trans_id,
          avg_price_end_date,
          avg_price_start_date,
          char_value,
          complexity_ind,
          differential_val,
          fb_trigger_num,
          float_value,
          formula_body_num,
          formula_body_string,
          formula_body_text = NULL,
          formula_body_type,
          formula_num,
          formula_parse_string,
          formula_parse_text = NULL,
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
         (trans_id <= @asof_trans_id and
          resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchFormulaToFormBody] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchFormulaToFormBody', NULL, NULL
GO
