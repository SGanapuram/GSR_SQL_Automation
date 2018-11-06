SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_PLCOMP_trade_info]
(
   trade_num,
   contr_date,
   creation_date,
   inhouse_ind,
   creator_init,
   trade_mod_date,
   port_num,
   trade_status_code,
   trade_counterparty_name,
   trader_name,
   trans_id
)
as
select tr.trade_num,
       tr.contr_date,
       tr.creation_date,
       tr.inhouse_ind,
       tr.creator_init,
       tr.trade_mod_date,
       tr.port_num,
       tr.trade_status_code,
       cpty.acct_short_name,
       case when u.user_last_name is null then null
            else u.user_last_name + ', ' + u.user_first_name
       end as trader_name,
       tr.trans_id
from dbo.trade tr WITH (NOLOCK)
        left join dbo.icts_user u WITH (NOLOCK)
           on tr.trader_init = u.user_init                                                     
        left outer join dbo.account cpty WITH (NOLOCK) 
           on tr.acct_num = cpty.acct_num
GO
GRANT SELECT ON  [dbo].[v_PLCOMP_trade_info] TO [next_usr]
GO
