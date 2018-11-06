SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_CUBE_cob_date]      
(      
port_num,pl_asof_date       
)      
AS      
--select port_num,max (pl_asof_date) from portfolio_profit_loss where port_num in (36972,13119,102835,13113) group by port_num      
select port_num,max (pl_asof_date) 
from portfolio_profit_loss 
where port_num in (17,18,52421,5587,103111,102836,318076,13121,144507,47048,93612) 
group by port_num      
GO
GRANT SELECT ON  [dbo].[v_CUBE_cob_date] TO [next_usr]
GO
