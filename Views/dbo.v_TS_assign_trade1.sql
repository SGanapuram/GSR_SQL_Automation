SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_TS_assign_trade1] 
( 
   trade_num, 
   order_num, 
   item_num, 
   lc_comment
)
as
select trade_num,
       order_num,
       item_num,
       COUNT(*)
from dbo.v_TS_assign_trade
group by trade_num,
         order_num,
         item_num
having COUNT(*) > 1  
GO
GRANT SELECT ON  [dbo].[v_TS_assign_trade1] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_TS_assign_trade1] TO [next_usr]
GO
