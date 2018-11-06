SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_TS_portfolio_booking_company]
(
   bookingcomp,
   port_num
)
as
select 
   bc.acct_short_name, 
   pt.port_num   
from dbo.portfolio_tag pt with (nolock), 
     dbo.account bc with (nolock)
where pt.tag_name = 'BOOKCOMP' and   
      cast(bc.acct_num as varchar) = pt.tag_value
GO
GRANT SELECT ON  [dbo].[v_TS_portfolio_booking_company] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_TS_portfolio_booking_company] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_TS_portfolio_booking_company', NULL, NULL
GO
