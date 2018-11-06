SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_MET_TS_trade_item_exch_opt] 
( 
   trade_num, 
   order_num, 
   item_num,
   put_call_ind, 
   strike_price, 
   premium, 
   premium_uom_code, 
   premium_curr_code,
   clr_brkr_num, 
   clearing_broker, 
   exp_date 
)
as
select 
   tie.trade_num,
   tie.order_num,
   tie.item_num,
   tie.put_call_ind,
   tie.strike_price,
   tie.premium,
   tie.premium_uom_code,
   tie.premium_curr_code,
   tie.clr_brkr_num,
   clr.acct_short_name,
   tie.exp_date
from dbo.trade_item_exch_opt tie
        LEFT OUTER JOIN dbo.account clr WITH (nolock)
           ON tie.clr_brkr_num = clr.acct_num  
GO
GRANT SELECT ON  [dbo].[v_MET_TS_trade_item_exch_opt] TO [next_usr]
GO
