SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_MET_TS_trade_item_fut] 
( 
   trade_num, 
   order_num, 
   item_num,
   clr_brkr_num, 
   clearing_broker, 
   trans_id 
)
AS
SELECT 
   fut.trade_num,
   fut.order_num,
   fut.item_num,
   fut.clr_brkr_num,
   a.acct_short_name,
   fut.trans_id
FROM dbo.trade_item_fut fut
        LEFT OUTER JOIN dbo.account a WITH (nolock)
           ON a.acct_num = fut.clr_brkr_num  
GO
GRANT SELECT ON  [dbo].[v_MET_TS_trade_item_fut] TO [next_usr]
GO
