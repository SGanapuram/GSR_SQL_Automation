SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[tax_license_view] 
(
   license_num,                    
   license_covers_num,             
   tax_code,                       
   issuing_tax_authority_num,       
   license_id,                     
   acct_num,     					                 
   license_eff_date,               
   license_exp_date,               
   license_short_cmnt,             
   cmnt_num,                        
   cmdty_code,                    
   tax_exempt_ind,                  
   tax_rate_discount,              
   product_usage_code,              
   trans_id
)
as 
select
   l.license_num,                    
   lc.license_covers_num,             
   lt.tax_code,                       
   l.issuing_tax_authority_num,       
   l.license_id,                     
   l.acct_num,                      
   l.license_eff_date,               
   l.license_exp_date,               
   l.license_short_cmnt,             
   l.cmnt_num,                        
   lc.cmdty_code,                    
   lt.tax_exempt_ind,                  
   lt.tax_rate_discount,              
   lt.product_usage_code,              
   l.trans_id
from dbo.license l
        inner join dbo.license_covers lc
           on l.license_num = lc.license_num
        left outer join dbo.lic_tax_implication lt
           on lc.license_num = lt.license_num and 
              lc.license_covers_num = lt.license_covers_num
GO
GRANT SELECT ON  [dbo].[tax_license_view] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[tax_license_view] TO [next_usr]
GO
