SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[cost_pay_rec_view] 
(
	 cost_pay_rec_ind,	
   trans_id
)
as 
select
	 cost_pay_rec_ind, 
   trans_id
from dbo.cost 
where cost_pay_rec_ind in ('P', 'R') 
GO
GRANT SELECT ON  [dbo].[cost_pay_rec_view] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[cost_pay_rec_view] TO [next_usr]
GO
