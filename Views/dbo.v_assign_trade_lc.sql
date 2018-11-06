SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_assign_trade_lc]
(
	 trade_num,
	 order_num,
	 item_num,
	 AllocNum,
	 AllocItemNum,
	 lc_covered_amt,
	 lc_num,
	 lc_beneficiary,
	 lc_exp_imp_ind,
	 lc_applicant,
	 ct_doc_num
)
as  
select     
	 a.trade_num, 
	 a.order_num as order_num, 
	 a.item_num AS item_num,
	 ISNULL(a.alloc_num, a.trade_num) as AllocNum, 
	 ISNULL(a.alloc_item_num, a.order_num) as AllocItemNum, 
	 SUM(ISNULL(a.covered_amt, 0)) as lc_covered_amt, 
	 b.lc_num,
	 b.lc_beneficiary, 
	 b.lc_exp_imp_ind, 
	 b.lc_applicant, 
	 a.ct_doc_num  
from dbo.assign_trade a 
        inner join dbo.lc b
           on a.ct_doc_num = b.lc_num  
group by a.trade_num, 
         a.order_num, 
         a.item_num, 
         a.alloc_num,   
         a.alloc_item_num, 
         b.lc_num, 
         b.lc_beneficiary, 
         b.lc_exp_imp_ind, 
         b.lc_applicant, 
         a.ct_doc_num
GO
GRANT SELECT ON  [dbo].[v_assign_trade_lc] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_assign_trade_lc] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_assign_trade_lc', NULL, NULL
GO
