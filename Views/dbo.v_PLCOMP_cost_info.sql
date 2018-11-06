SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_PLCOMP_cost_info]    
(    
   cost_num,    
   cost_owner_code,    
   cost_owner_key1,    
   cost_owner_key2,    
   cost_code,    
   cost_eff_date,    
   cost_price_curr_code,    
   cost_creation_date,    
   alloc_creation_date,    
   cost_prim_sec_ind,    
   creator_init,    
   cost_counterparty_name,    
   sch_init,    
   cost_trans_id,    
   alloc_trans_id    
)    
as    
select c.cost_num,    
       c.cost_owner_code,    
       c.cost_owner_key1,    
       c.cost_owner_key2,    
       c.cost_code,    
       c.cost_eff_date,    
       c.cost_price_curr_code,    
       c.creation_date,    
       alloc.creation_date,    
       c.cost_prim_sec_ind,    
       c.creator_init,    
       a1.acct_short_name,    
       alloc.sch_init,    
       c.trans_id,    
       alloc.trans_id    
from dbo.cost c WITH (NOLOCK)     
        left outer join dbo.allocation alloc WITH (NOLOCK)    
           on alloc.alloc_num = c.cost_owner_key1 and     
              c.cost_owner_code in ('A', 'AA', 'AI')                                                
        left outer join dbo.account a1 WITH (NOLOCK)     
           on c.acct_num = a1.acct_num                                                            
    

                                          
GO
GRANT SELECT ON  [dbo].[v_PLCOMP_cost_info] TO [next_usr]
GO
