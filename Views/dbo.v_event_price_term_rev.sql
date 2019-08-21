SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_event_price_term_rev]
(
   formula_num,
   price_term_num,
   event_name,
   event_oper,
   event_pricing_days,
   event_start_end_days,
   quote_type,
   event_include_ind,
   event_dflt_ind,
   event_trig_ind,
   parent_price_term_num,
   deemed_event_date,
   event_date_saturdays,
   event_date_sundays,
   event_date_holidays,
   adj_pricing_date_ind,
   trans_id,
   asof_trans_id,
   resp_trans_id,
   date_deemed,
   adj_days,
   adj_pricing_prd_type
)
as
select
   formula_num,
   price_term_num,
   event_name,
   event_oper,
   event_pricing_days,
   event_start_end_days,
   quote_type,
   event_include_ind,
   event_dflt_ind,
   event_trig_ind,
   parent_price_term_num,
   deemed_event_date,
   event_date_saturdays,
   event_date_sundays,
   event_date_holidays,
   adj_pricing_date_ind,
   trans_id,
   trans_id,
   resp_trans_id,
   date_deemed,
   adj_days,
   adj_pricing_prd_type
from dbo.aud_event_price_term
GO
GRANT SELECT ON  [dbo].[v_event_price_term_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_event_price_term_rev] TO [next_usr]
GO
