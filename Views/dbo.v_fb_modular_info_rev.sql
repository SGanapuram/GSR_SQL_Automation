SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_fb_modular_info_rev]
(
   formula_num,
   formula_body_num,
   basis_cmdty_code,
   risk_mkt_code,
   risk_trading_prd,
   pay_deduct_ind,
   cross_ref_ind,
   ref_cmdty_code,
   price_pcnt_string,
   price_pcnt_value,
   price_quote_string,
   last_computed_value,
   last_computed_asof_date,
   line_item_contr_desc,
   line_item_invoice_desc,
   qp_start_date,
   qp_end_date,
   qp_election_date,
   qp_desc,
   qp_election_opt,
   qp_elected,		
   trans_id,
   asof_trans_id,   
   resp_trans_id 
)
as  
select
   formula_num,
   formula_body_num,
   basis_cmdty_code,
   risk_mkt_code,
   risk_trading_prd,
   pay_deduct_ind,
   cross_ref_ind,
   ref_cmdty_code,
   price_pcnt_string,
   price_pcnt_value,
   price_quote_string,
   line_item_contr_desc,
   line_item_invoice_desc,
   last_computed_value,
   last_computed_asof_date,
   qp_start_date,
   qp_end_date,
   qp_election_date,
   qp_desc,
   qp_election_opt,
   qp_elected,		
   trans_id,
   trans_id,   
   resp_trans_id 
from dbo.aud_fb_modular_info
GO
GRANT SELECT ON  [dbo].[v_fb_modular_info_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_fb_modular_info_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_fb_modular_info_rev', NULL, NULL
GO
