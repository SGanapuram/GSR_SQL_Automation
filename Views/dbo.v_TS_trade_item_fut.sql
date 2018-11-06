SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_TS_trade_item_fut]  
(
   trade_num,
   order_num,
   item_num,
   clr_brkr_num,
   clearing_broker,
   trans_id
)
as
select
   fut.trade_num,
   fut.order_num,
   fut.item_num,
   fut.clr_brkr_num,
   a.acct_short_name,
   fut.trans_id
from dbo.trade_item_fut fut
        LEFT OUTER JOIN dbo.account a with (nolock)
           ON a.acct_num = fut.clr_brkr_num
GO
GRANT SELECT ON  [dbo].[v_TS_trade_item_fut] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_TS_trade_item_fut] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_TS_trade_item_fut', NULL, NULL
GO
