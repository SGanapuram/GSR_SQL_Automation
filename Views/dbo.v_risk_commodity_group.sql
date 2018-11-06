SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_risk_commodity_group]
(
	 parent_cmdty_code,
	 parent_cmdty_short_name,
	 cmdty_code,
	 cmdty_short_name
)
as
select
	 cg.parent_cmdty_code,
	 c1.cmdty_short_name,
	 cg.cmdty_code,
	 c2.cmdty_short_name
from dbo.commodity_group cg with (nolock)
        INNER JOIN dbo.commodity c1
           ON cg.parent_cmdty_code = c1.cmdty_code
        INNER JOIN dbo.commodity c2
           ON cg.cmdty_code = c2.cmdty_code
where cmdty_group_type_code = 'POSITION'
GO
GRANT SELECT ON  [dbo].[v_risk_commodity_group] TO [next_usr]
GO
