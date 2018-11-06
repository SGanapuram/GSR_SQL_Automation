SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_TS_rc_assign_trade]
(
   trade_num,  
   order_num,  
   item_num,
   rc_multi_ind
)
as
select 
   trade_num,  
   order_num,  
   item_num,  
   count(*)
from dbo.rc_assign_trade with (nolock)
group by trade_num, order_num, item_num  
having count(*) > 1
GO
GRANT SELECT ON  [dbo].[v_TS_rc_assign_trade] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_TS_rc_assign_trade] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_TS_rc_assign_trade', NULL, NULL
GO
