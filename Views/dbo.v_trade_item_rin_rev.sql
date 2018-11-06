SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_trade_item_rin_rev]
(
   trade_num,
   order_num,
   item_num,
   rin_impact_type,
   rin_action_code,
   rin_port_num,
   rin_p_s_ind,
   rin_impact_date,	
   rin_cmdty_code,
   counterparty_qty,	
   manual_settled_ind,	
   settled_cur_y_sqty,		
   settled_pre_y_sqty,		
   rin_sep_status,	
   rin_pcent_year,		 
   py_rin_cmdty_code,	
   manual_epa_ind,	
   epa_imp_prod_qty,		 
   epa_exp_qty,			 
   manual_commit_ind,	
   committed_sqty,		 
   rin_qty_uom_code,	
   mf_cmdty_code,	
   manual_rvo_ind,	
   rvo_mf_qty,			 
   rvo_mf_qty_uom_code,	 
   rins_finalized,	
   impact_begin_year,
   impact_current_year,
   trans_id,		
   asof_trans_id,
   resp_trans_id
)
as
select
   trade_num,
   order_num,
   item_num,
   rin_impact_type,
   rin_action_code,
   rin_port_num,
   rin_p_s_ind,
   rin_impact_date,	
   rin_cmdty_code,
   counterparty_qty,	
   manual_settled_ind,	
   settled_cur_y_sqty,		
   settled_pre_y_sqty,		
   rin_sep_status,	
   rin_pcent_year,		 
   py_rin_cmdty_code,	
   manual_epa_ind,	
   epa_imp_prod_qty,		 
   epa_exp_qty,			 
   manual_commit_ind,	
   committed_sqty,		 
   rin_qty_uom_code,	
   mf_cmdty_code,	
   manual_rvo_ind,	
   rvo_mf_qty,			 
   rvo_mf_qty_uom_code,		
   rins_finalized,	
   impact_begin_year,
   impact_current_year,
   trans_id,		
   trans_id,
   resp_trans_id
from dbo.aud_trade_item_rin                                                                                                                                                                               
GO
GRANT SELECT ON  [dbo].[v_trade_item_rin_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_trade_item_rin_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_trade_item_rin_rev', NULL, NULL
GO