SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_CHGHISTORY_portfolio_info]
(
   port_num,
   port_short_name,
   port_full_name,
   port_type,
   trading_entity_name
)
as
select port_num,
       port_short_name,
       port_full_name,
       port_type,
       a.acct_short_name
from dbo.portfolio p with (nolock)
        left outer join dbo.account a with (nolock)
           on p.trading_entity_num = a.acct_num and
              a.acct_type_code = 'TRDNGNTT'
where port_locked = 0
GO
GRANT SELECT ON  [dbo].[v_CHGHISTORY_portfolio_info] TO [next_usr]
GO
