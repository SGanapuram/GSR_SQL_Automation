SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_trade_item_ext_info_rev]
(
   trade_num,
   order_num,
   item_num,
   custom_field1,
   custom_field2,
   custom_field3,
   custom_field4,
   custom_field5,
   custom_field6,
   custom_field7,
   custom_field8,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   trade_num,
   order_num,
   item_num,
   custom_field1,
   custom_field2,
   custom_field3,
   custom_field4,
   custom_field5,
   custom_field6,
   custom_field7,
   custom_field8,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_trade_item_ext_info
GO
GRANT SELECT ON  [dbo].[v_trade_item_ext_info_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_trade_item_ext_info_rev] TO [next_usr]
GO
