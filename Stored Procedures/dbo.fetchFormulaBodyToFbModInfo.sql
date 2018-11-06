SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchFormulaBodyToFbModInfo] 
( 
   @asof_trans_id       int,    
   @formula_body_num    tinyint,    
   @formula_num         int 
)   
as 
set nocount on   
    
   select    
      asof_trans_id = @asof_trans_id,  
      basis_cmdty_code,  
      cross_ref_ind,  
      formula_body_num,  
      formula_num,  
      last_computed_value,
      last_computed_asof_date,
      line_item_contr_desc,
      line_item_invoice_desc,
      pay_deduct_ind,  
      price_pcnt_string,  
      price_pcnt_value,  
      price_quote_string, 
	    qp_desc,
	    qp_elected,
	    qp_election_date,
	    qp_election_opt,
	    qp_end_date,
	    qp_start_date,	
      ref_cmdty_code,  
      resp_trans_id=NULL,
      risk_mkt_code,  
      risk_trading_prd,  
      trans_id                           
   from dbo.fb_modular_info  
   where formula_num = @formula_num and  
         formula_body_num = @formula_body_num and   
         trans_id <= @asof_trans_id    
   union all    
   select    
      asof_trans_id = @asof_trans_id,  
      basis_cmdty_code,  
      cross_ref_ind,  
      formula_body_num,  
      formula_num,  
      last_computed_value,
      last_computed_asof_date,
      line_item_contr_desc,
      line_item_invoice_desc,
      pay_deduct_ind,  
      price_pcnt_string,  
      price_pcnt_value,  
      price_quote_string,  
	    qp_desc,
	    qp_elected,
	    qp_election_date,
	    qp_election_opt,
	    qp_end_date,
	    qp_start_date,	
      ref_cmdty_code, 
      resp_trans_id, 
      risk_mkt_code,  
      risk_trading_prd,  
      trans_id                           
   from dbo.aud_fb_modular_info  
   where formula_num = @formula_num and  
         formula_body_num = @formula_body_num and     
         (trans_id <= @asof_trans_id and     
          resp_trans_id > @asof_trans_id)    
return 
GO
GRANT EXECUTE ON  [dbo].[fetchFormulaBodyToFbModInfo] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchFormulaBodyToFbModInfo', NULL, NULL
GO
