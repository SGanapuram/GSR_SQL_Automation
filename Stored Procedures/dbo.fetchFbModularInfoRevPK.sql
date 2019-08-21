SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[fetchFbModularInfoRevPK] 
   @asof_trans_id       bigint,  
   @formula_body_num    int,  
   @formula_num         int    
as    
declare @trans_id  bigint    
   select @trans_id = trans_id    
   from dbo.fb_modular_info    
   where formula_num = @formula_num and  
         formula_body_num = @formula_body_num   
if @trans_id <= @asof_trans_id  
begin  
   select  
      asof_trans_id = @asof_trans_id,  
      basis_cmdty_code,  
      cross_ref_ind,  
      formula_body_num,  
      formula_num,
      last_computed_value,
      last_computed_asof_date,
	  lib_formula_name,
      line_item_contr_desc,
      line_item_invoice_desc,
      pay_deduct_ind,  
      price_pcnt_string,  
      price_pcnt_value,  
      price_quote_string,
	  price_rule_oid,
	  prorated_flat_amt,
	  qp_desc,
	  qp_elected,
	  qp_election_date,
	  qp_election_opt,
	  qp_end_date,
	  qp_end_date_addl_days,
	  qp_start_date,
	  qp_start_date_addl_days,
	  qp_type,
      ref_cmdty_code, 
      resp_trans_id = null,	  
      risk_mkt_code,  
      risk_trading_prd,  
      trans_id  
   from dbo.fb_modular_info  
   where formula_num = @formula_num and  
         formula_body_num = @formula_body_num  
end    
else    
begin    
   set rowcount 1    
   select     
      asof_trans_id = @asof_trans_id,  
      basis_cmdty_code,  
      cross_ref_ind,  
      formula_body_num,  
      formula_num,
      last_computed_value,
      last_computed_asof_date,
	  lib_formula_name,
      line_item_contr_desc,
      line_item_invoice_desc,
      pay_deduct_ind,  
      price_pcnt_string,  
      price_pcnt_value,  
      price_quote_string,
	  price_rule_oid,	
	  prorated_flat_amt,
	  qp_desc,
	  qp_elected,
	  qp_election_date,
	  qp_election_opt,
	  qp_end_date,
	  qp_end_date_addl_days,
	  qp_start_date,
	  qp_start_date_addl_days,
	  qp_type,
      ref_cmdty_code, 
      resp_trans_id,   
      risk_mkt_code,  
      risk_trading_prd,     
      trans_id    
   from dbo.aud_fb_modular_info  
   where formula_num = @formula_num and  
         formula_body_num = @formula_body_num and  
         trans_id <= @asof_trans_id and  
         resp_trans_id > @asof_trans_id  
   order by trans_id desc    
end    
return 
GO
GRANT EXECUTE ON  [dbo].[fetchFbModularInfoRevPK] TO [next_usr]
GO
