SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[udf_portfolio_list] 
(	
   @root_port_num           int
)
RETURNS TABLE 
AS
RETURN 
(
   WITH ChildPortfolioListCTE(port_num)
   AS
   ( 
      -- Anchor Member 
      SELECT pg.port_num
      FROM dbo.portfolio_group pg
      WHERE pg.parent_port_num = @root_port_num
      UNION ALL  
      -- Recursive Member 
      SELECT pg.port_num
      FROM dbo.portfolio_group pg
              INNER JOIN ChildPortfolioListCTE cte 
                 ON pg.parent_port_num = cte.port_num
   )
   SELECT cte.port_num, p.port_type, p.trading_entity_num, p.port_locked
   FROM ChildPortfolioListCTE cte,
        dbo.portfolio p
   WHERE cte.port_num = p.port_num
   union all
   select @root_port_num,  p.port_type, p.trading_entity_num, p.port_locked
   from dbo.portfolio p
   where port_num = @root_port_num
)
GO
GRANT SELECT ON  [dbo].[udf_portfolio_list] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[udf_portfolio_list] TO [next_usr]
GO
