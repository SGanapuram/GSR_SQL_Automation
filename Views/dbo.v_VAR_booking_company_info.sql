SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[v_VAR_booking_company_info]     
(  
   bookingcomp_name,  
   booking_company_num,   
   port_num   
)  
as  
select a.acct_short_name,  
       pt.booking_company_num,   
       pt.port_num   
from (select convert(int, tag_value) as booking_company_num,  
             port_num  
      from dbo.portfolio_tag WITH (NOLOCK)  
      where tag_name = 'BOOKCOMP') pt  
         INNER JOIN dbo.account a WITH (NOLOCK)  
            ON a.acct_num = pt.booking_company_num  
GO
GRANT SELECT ON  [dbo].[v_VAR_booking_company_info] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_VAR_booking_company_info] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_VAR_booking_company_info', NULL, NULL
GO
