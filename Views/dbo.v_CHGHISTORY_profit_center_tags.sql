SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_CHGHISTORY_profit_center_tags]
(
   real_port_num,
   profit_center
)
as
select port_num,
       tag_value
from dbo.portfolio_tag with (nolock)
where tag_name = 'PRFTCNTR'
GO
GRANT SELECT ON  [dbo].[v_CHGHISTORY_profit_center_tags] TO [next_usr]
GO
