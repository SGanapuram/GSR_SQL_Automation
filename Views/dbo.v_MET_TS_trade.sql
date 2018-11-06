SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_MET_TS_trade]   
(   
   trade_num,  
   trader_init,   
   trade_status_code,  
   inhouse_ind,   
   acct_num,   
   acct_short_name,   
   acct_ref_num,   
   contr_date,   
   trade_mod_date,   
   creation_date,   
   port_num,   
   inter_company_ind,   
   conclusion_type,  
   contract_anly_user,   
   contr_status_code,   
   contr_anly_init,   
   trans_id   
)  
as  
select   
   t.trade_num,  
   t.trader_init,  
   t.trade_status_code,  
   t.inhouse_ind,  
   t.acct_num,  
   a.acct_short_name,  
   t.acct_ref_num,  
   t.contr_date,  
   t.trade_mod_date,  
   t.creation_date,  
   t.port_num,  
   case when aa1.acct_alias_name IS NULL then 'N'  
        else aa1.acct_alias_name  
   end,  
   conclusion_type,  
   u.user_last_name + ', ' + u.user_first_name,  
   t.contr_status_code,  
   t.contr_anly_init,  
   t.trans_id  
from dbo.trade t  
        LEFT OUTER JOIN dbo.account a WITH (nolock)  
           ON t.acct_num = a.acct_num  
        LEFT OUTER JOIN dbo.account_alias aa1 WITH (nolock)  
           ON aa1.alias_source_code = 'INTERCOS' and  
              aa1.acct_num = t.acct_num  
        LEFT JOIN dbo.icts_user u WITH (nolock)  
           ON t.contr_anly_init = u.user_init    
GO
GRANT SELECT ON  [dbo].[v_MET_TS_trade] TO [next_usr]
GO
