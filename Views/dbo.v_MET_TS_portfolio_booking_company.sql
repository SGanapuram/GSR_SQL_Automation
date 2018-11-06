SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_MET_TS_portfolio_booking_company] 
( 
   bookingcomp, 
   port_num 
)
as
select bc.acct_short_name,
       pt.port_num
from dbo.portfolio_tag pt WITH (nolock),
     dbo.account bc WITH (nolock)
where pt.tag_name = 'BOOKCOMP' and
      cast(bc.acct_num as varchar) = pt.tag_value  
GO
GRANT SELECT ON  [dbo].[v_MET_TS_portfolio_booking_company] TO [next_usr]
GO
