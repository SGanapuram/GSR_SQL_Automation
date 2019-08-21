SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
  
CREATE view [dbo].[v_collateral]                    
(                    
   lc_num,                    
   lc_type_code,                    
   lc_type_desc,                    
   lc_status_code,                    
   lc_status_desc,                    
   lc_usage_code,                    
   lc_usage_desc,                    
   lc_exp_imp_ind,                    
   lc_transact_or_blanket,                    
   lc_start_date,                    
   lc_expiry_date,                    
   currency,                    
   lc_amt,                    
   lc_max_amt,                    
   lc_utilized_amt,                       
   lc_available_amt,                    
   applicant_acct_num,                    
   applicant,                    
   applicant_full_name,             
   applicant_bank_ref_num,            
   beneficiary_acct_num,              
   beneficiary,                 
   beneficiary_full_name,             
   beneficiary_ref_num,            
   issuing_acct_num,            
   issuing_bank,                  
   issuing_bank_full_name  ,                   
   issuing_bank_ref_num,                
   advising_acct_num,                    
   advising_bank    ,            
   advising_bank_full_name,             
   advising_bank_ref_num,            
   confirming_bank_ref_num,            
            
lc_final_ind,            
lc_evergreen_status,            
lc_evergreen_roll_days,            
lc_evergreen_ext_days,            
lc_stale_doc_allow_ind,            
lc_stale_doc_days,            
lc_loi_presented_ind,            
lc_negotiate_clause,            
lc_confirm_reqd_ind,            
lc_confirm_date,            
lc_request_date,            
lc_exp_event,            
lc_exp_days,            
lc_exp_days_oper,            
lc_office_loc_code,            
lc_short_cmnt,            
lc_cr_analyst_init,            
lc_negotiating_bank_num,            
negotiating_bank,            
negotiating_bank_full_name,            
lc_confirming_bank_num,            
confirming_bank,            
confirming_bank_full_name,            
guarantor_acct_num,            
other_lcs_rel_ind,            
lc_netting_ind,            
collateral_type_code,            
pcg_type_code,            
external_ref_key,            
lc_dispute_ind,            
lc_dispute_status,            
lc_priority,            
lc_custom_column1,            
lc_custom_column2   ,    
red_flag,    
auto_escalation_ind,    
place_of_payment,    
place_of_expiry,    
pay_term_code,    
last_ship_date,    
lc_rate,    
latest_present_term         
            
)                    
as                    
                    
                    
select l.lc_num,  l.lc_type_code,                    
   lc_type_desc,l.lc_status_code,lc_status_desc,l.lc_usage_code,lc_usage_desc,lc_exp_imp_ind,  lc_transact_or_blanket,                    
   l.lc_issue_date,                       
   l.lc_exp_date,                       
   la.lc_alloc_amt_curr_code,                      
   la.lc_alloc_amt_cap 'lc_amt',                       
   case when isnull(lc_alloc_max_amt,0)/100>1 then isnull(lc_alloc_max_amt,0)                  
  else la.lc_alloc_amt_cap+(isnull(la.lc_alloc_amt_cap,0)*isnull(lc_alloc_max_amt,0)/100) end 'lc_max_amt',                    
   abs(isnull(util.UtilizedAmt,0)) 'UtilizedAmt',                    
   case when isnull(lc_alloc_max_amt,0)/100>1 and isnull(lc_alloc_max_amt,0) - abs(isnull(util.UtilizedAmt,0))<0                   
   then 0                  
  when isnull(lc_alloc_max_amt,0)/100>1 and isnull(lc_alloc_max_amt,0) - abs(isnull(util.UtilizedAmt,0))>0                   
   then isnull(lc_alloc_max_amt,0) - abs(isnull(util.UtilizedAmt,0))                  
  when (isnull(la.lc_alloc_amt_cap,0)+(isnull(la.lc_alloc_amt_cap,0)*isnull(lc_alloc_max_amt,0)/100))- abs(isnull(util.UtilizedAmt,0))<0                   
   then 0                   
  else  (isnull(la.lc_alloc_amt_cap,0)+(isnull(la.lc_alloc_amt_cap,0)*isnull(lc_alloc_max_amt,0)/100))- abs(isnull(util.UtilizedAmt,0)) end 'lc_amt_available',                    
   appl.acct_num ,            
   appl.acct_short_name,                  
   appl.acct_full_name ,            
   appc_ref.lc_acct_ref,                        
   ben.acct_num,                    
   ben.acct_short_name,             
   ben.acct_full_name  ,                      
   ben_ref.lc_acct_ref ,                        
   iss.acct_num,                  
   iss.acct_short_name,               
   iss.acct_full_name ,                  
   lau.lc_acct_ref ,                    
   adv.acct_num,                  
   adv.acct_short_name,               
   adv.acct_full_name   ,               
   adv_ref.lc_acct_ref ,            
   cnfb_ref.lc_acct_ref,            
lc_final_ind,            
lc_evergreen_status,            
lc_evergreen_roll_days,            
lc_evergreen_ext_days,            
lc_stale_doc_allow_ind,            
lc_stale_doc_days,            
lc_loi_presented_ind,            
lc_negotiate_clause,            
lc_confirm_reqd_ind,            
lc_confirm_date,            
lc_request_date,            
lc_exp_event,            
lc_exp_days,            
lc_exp_days_oper,            
lc_office_loc_code,            
lc_short_cmnt,            
lc_cr_analyst_init,            
lc_negotiating_bank,            
neg.acct_short_name ,          
neg.acct_full_name 'negotiating_bank',            
lc_confirming_bank,            
cnfb.acct_short_name,          
cnfb.acct_full_name 'confirming_bank',            
guarantor_acct_num,            
other_lcs_rel_ind,            
lc_netting_ind,            
collateral_type_code,            
pcg_type_code,            
external_ref_key,            
lc_dispute_ind,            
lc_dispute_status,            
lc_priority,            
lc_custom_column1,            
lc_custom_column2     ,    
red_flag,    
auto_escalation_ind,    
place_of_payment,    
place_of_expiry,    
pay_term_code,    
last_ship_date,    
lc_rate,    
latest_present_term       
from  dbo.lc l                       
        left outer join dbo.lc_type lt                       
    on l.lc_type_code=lt.lc_type_code                      
        left outer join dbo.lc_status ls                       
    on l.lc_status_code=ls.lc_status_code                       
        left outer join dbo.lc_usage lu                       
    on l.lc_usage_code=lu.lc_usage_code                       
        left outer join dbo.account appl                      
    on l.lc_applicant=appl.acct_num                      
        left outer join dbo.account ben                      
    on l.lc_beneficiary=ben.acct_num                      
        left outer join dbo.account iss                      
    on l.lc_issuing_bank=iss.acct_num                      
        left outer join dbo.account adv                      
    on l.lc_advising_bank=adv.acct_num                      
        left outer join dbo.account neg            
    on l.lc_negotiating_bank=neg.acct_num                      
        left outer join dbo.account cnfb                      
    on l.lc_confirming_bank=cnfb.acct_num                      
        left outer join dbo.lc_allocation la                       
           on l.lc_num = la.lc_num                  
        left outer join dbo.lc_account_usage lau              
           on l.lc_num = lau.lc_num                 
           and lc_acct_usage='ISSB'                      
        left outer join dbo.lc_account_usage adv_ref              
           on l.lc_num = adv_ref.lc_num                 
           and adv_ref.lc_acct_usage='ADVB'                  
        left outer join dbo.lc_account_usage ben_ref              
           on l.lc_num = ben_ref.lc_num                 
           and ben_ref.lc_acct_usage='BENF'                  
        left outer join dbo.lc_account_usage cnfb_ref              
           on l.lc_num = cnfb_ref.lc_num                 
           and cnfb_ref.lc_acct_usage='CNFB'                
        left outer join dbo.lc_account_usage appc_ref              
           on l.lc_num = appc_ref.lc_num                 
           and appc_ref.lc_acct_usage='APPC'     
  left outer join lc_ext_info lei    
           on lei.lc_num=l.lc_num    
 left outer join                     
  (select ct_doc_num ,sum(case when cost_pay_rec_ind='P' then -cost_amt else cost_amt end) 'UtilizedAmt'                     
  From cost c , (select distinct trade_num, order_num, item_num, ct_doc_num from assign_trade ) at1                    
  where cost_type_code in ('WPP','PR','PO') and cost_status='PAID' and finance_bank_num is not null                     
  and at1.trade_num=cost_owner_key6 and at1.order_num=cost_owner_key7 and at1.item_num=cost_owner_key8                      
  group by ct_doc_num                     
  ) util                     
    on util.ct_doc_num=la.lc_num                    
where lt.lc_type_code=l.lc_type_code                      
GO
GRANT SELECT ON  [dbo].[v_collateral] TO [next_usr]
GO
