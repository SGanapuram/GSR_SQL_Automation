SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_MET_TS_lc_allocation] 
( 
   lc_num, 
   lc_issue_date, 
   lc_exp_date,
   lc_issuing_bank_num, 
   lc_issuing_bank_name, 
   bank_lc_num, 
   lc_cap_amount,
   lc_type_code 
)
as
select 
   lc.lc_num,
   lc.lc_issue_date,
   lc.lc_exp_date,
   lc.lc_issuing_bank,
   a.acct_short_name,
   lau.lc_acct_ref,
   lc_alloc_amt_cap * (case when lc_alloc_max_amt IS NULL then 1.0
                            else ((lc_alloc_max_amt + 100.0) / 100.0)
                       end),
   lc.lc_type_code
from dbo.lc_allocation lca
        INNER JOIN dbo.lc
           ON lc.lc_num = lca.lc_num
        LEFT OUTER JOIN dbo.lc_account_usage lau
           ON lca.lc_num = lau.lc_num and
              lau.lc_acct_usage = 'ISSB'
        LEFT OUTER JOIN dbo.account a WITH (nolock)
           ON a.acct_num = lc.lc_issuing_bank  
GO
GRANT SELECT ON  [dbo].[v_MET_TS_lc_allocation] TO [next_usr]
GO
