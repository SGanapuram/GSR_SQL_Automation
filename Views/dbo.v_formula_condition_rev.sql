SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_formula_condition_rev]
(
   formula_num,
   formula_cond_num,
   formula_cond_type,
   formula_cond_date,
   formula_cond_quote_range,
   formula_cond_last_next_ind,
   src_commkt_key,
   src_trading_prd,
   src_price_source_code,
   src_val_type,
   basis_commkt_key,
   basis_trading_prd,
   basis_price_source_code,
   basis_val_type,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   formula_num,
   formula_cond_num,
   formula_cond_type,
   formula_cond_date,
   formula_cond_quote_range,
   formula_cond_last_next_ind,
   src_commkt_key,
   src_trading_prd,
   src_price_source_code,
   src_val_type,
   basis_commkt_key,
   basis_trading_prd,
   basis_price_source_code,
   basis_val_type,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_formula_condition
GO
GRANT SELECT ON  [dbo].[v_formula_condition_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_formula_condition_rev] TO [next_usr]
GO
