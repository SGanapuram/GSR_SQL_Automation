SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_portfolio_division_info]
(
   real_port_num,
   division_code,
   division_desc
)
as
select
   pt.port_num,
   pt.tag_value,
   pto.tag_option_desc
from dbo.portfolio_tag pt
        LEFT OUTER JOIN (select tag_option,
                                tag_option_desc
                         from dbo.portfolio_tag_option
                         where tag_name = 'DIVISION') as pto                    
           ON pt.tag_value = pto.tag_option
where pt.tag_name = 'DIVISION' and
      len(rtrim(pt.tag_value)) > 0
GO
GRANT SELECT ON  [dbo].[v_portfolio_division_info] TO [next_usr]
GO
