SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_CHGHISTORY_cost_info]
(
   cost_num,
   port_num,
   cost_code,
   trade_num,
   order_num,
   item_num,
   cost_type_code,
	 cost_pl_code,
   cost_short_cmnt,
   cost_price_curr_code,
	 cost_price_mod_date,
	 cost_price_mod_init,
	 cost_pay_rec_ind,
   creation_date,
   counterparty_name
)
as
select
   c.cost_num,
   c.port_num,
   c.cost_code,
   c.cost_owner_key6,
   c.cost_owner_key7,
   c.cost_owner_key8,
   c.cost_type_code,
	 c.cost_pl_code,
   c.cost_short_cmnt,
   c.cost_price_curr_code,
	 c.cost_price_mod_date,
	 c.cost_price_mod_init,
	 c.cost_pay_rec_ind,
   c.creation_date,
   cpty.acct_short_name
from dbo.cost c WITH (NOLOCK) 
        left outer join dbo.account cpty WITH (NOLOCK) 
           on c.acct_num = cpty.acct_num
GO
GRANT SELECT ON  [dbo].[v_CHGHISTORY_cost_info] TO [next_usr]
GO
