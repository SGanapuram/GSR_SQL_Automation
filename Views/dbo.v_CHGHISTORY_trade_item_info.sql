SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_CHGHISTORY_trade_item_info]
(
   trade_num,
   order_num,
   item_num,
   real_port_num,
   p_s_ind,
   price_curr_code,
   cmdty_code,
	 risk_mkt_code,
	 trading_prd,
   order_type_code,
   creation_date,
   counterparty_name
)
as
select
   ti.trade_num,
   ti.order_num,
   ti.item_num,
   ti.real_port_num,
   ti.p_s_ind,
   ti.price_curr_code,
   ti.cmdty_code,
	 ti.risk_mkt_code,
	 ti.trading_prd,
   tor.order_type_code,
   t.creation_date,
   cpty.acct_short_name
from dbo.trade_item ti WITH (NOLOCK) 
        inner join dbo.trade_order tor WITH (NOLOCK) 
           on ti.trade_num = tor.trade_num and 
              ti.order_num = tor.order_num                                            
        inner join dbo.trade t WITH (NOLOCK) 
           on ti.trade_num = t.trade_num 
        left outer join dbo.account cpty WITH (NOLOCK) 
           on t.acct_num = cpty.acct_num
GO
GRANT SELECT ON  [dbo].[v_CHGHISTORY_trade_item_info] TO [next_usr]
GO
