SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_TS_trade_item_dist]  
(
   dist_num,
   trade_num,
   order_num,
   item_num,
   accum_num,
   qpp_num,
   real_port_num,
   profit_center,
   lifetime_qty,
   group_code
) 
as
select
   tid.dist_num,
   tid.trade_num,
   tid.order_num,
   tid.item_num,
   tid.accum_num,
   tid.qpp_num,
   tid.real_port_num,
   jm.profit_center_code,
   case when tid.p_s_ind = 'S' 
           then tid.dist_qty * -1 
        else tid.dist_qty  
   end,
   jm.group_code
from dbo.trade_item_dist tid
        LEFT OUTER JOIN dbo.jms_reports jm
           on jm.port_num = tid.real_port_num
where tid.dist_type = 'D' and 
      tid.real_synth_ind = 'R'
GO
GRANT SELECT ON  [dbo].[v_TS_trade_item_dist] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_TS_trade_item_dist] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_TS_trade_item_dist', NULL, NULL
GO
