SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[cost_book_comp_view]
(
	 acct_num,
	 acct_short_name,
	 acct_full_name,
	 acct_status,
	 acct_type_code,    
	 acct_parent_ind,
	 acct_sub_ind,
   trans_id
)
as
select 
	 a.acct_num,
	 a.acct_short_name,
	 a.acct_full_name,
	 a.acct_status,
	 a.acct_type_code,    
	 a.acct_parent_ind,
	 a.acct_sub_ind,
   a.trans_id
from dbo.account a, 
     dbo.cost c
where a.acct_num = c.cost_book_comp_num
GO
GRANT SELECT ON  [dbo].[cost_book_comp_view] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[cost_book_comp_view] TO [next_usr]
GO
