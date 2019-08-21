SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_formula_body_rev]
(
   formula_num,
   formula_body_num,
   formula_body_string,
   formula_parse_string,
   formula_body_type,
   formula_qty_pcnt_val,
   formula_qty_uom_code,
   formula_body_text,
   formula_parse_text,
   avg_price_start_date,
   avg_price_end_date,
   range_type,
   complexity_ind,
   differential_val,
   holiday_pricing_rule,
   saturday_pricing_rule,
   sunday_pricing_rule,
   parent_fb_num, 
   fb_trigger_num,
   float_value,
   char_value,
   trans_id,
   asof_trans_id, 
   resp_trans_id
)
as
select
   formula_num,
   formula_body_num,
   formula_body_string,
   formula_parse_string,
   formula_body_type,
   formula_qty_pcnt_val,
   formula_qty_uom_code,
   formula_body_text,
   formula_parse_text,
   avg_price_start_date,
   avg_price_end_date,
   range_type,
   complexity_ind,
   differential_val,
   holiday_pricing_rule,
   saturday_pricing_rule,
   sunday_pricing_rule,
   parent_fb_num, 
   fb_trigger_num,
   float_value,
   char_value,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_formula_body                                                                                                                                                                                     
GO
GRANT SELECT ON  [dbo].[v_formula_body_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_formula_body_rev] TO [next_usr]
GO
