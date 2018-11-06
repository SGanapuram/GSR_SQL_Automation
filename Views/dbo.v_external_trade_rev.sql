SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_external_trade_rev]
(
   oid,
   entry_date,
   external_trade_system_oid,
   external_trade_status_oid,
   external_trade_source_oid,
   port_num,
   trade_num,
   sequence,
   external_comment_oid,
   inhouse_port_num,
   external_trade_state_oid,
   order_num,   
   item_num,  
   ext_pos_num, 
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   oid,
   entry_date,
   external_trade_system_oid,
   external_trade_status_oid,
   external_trade_source_oid,
   port_num,
   trade_num,
   sequence,
   external_comment_oid,
   inhouse_port_num,
   external_trade_state_oid,
   order_num,   
   item_num,
   ext_pos_num,   
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_external_trade
GO
GRANT SELECT ON  [dbo].[v_external_trade_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_external_trade_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_external_trade_rev', NULL, NULL
GO
