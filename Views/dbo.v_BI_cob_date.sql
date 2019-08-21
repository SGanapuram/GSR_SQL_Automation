SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_BI_cob_date]      
(      
   port_num,
   pl_asof_date       
)      
AS      
select port_num, 
       max(pl_asof_date) 
from dbo.portfolio_profit_loss 
where port_num in (select cast(F2.data as int)
                   from dbo.dashboard_configuration F1
                          CROSS APPLY dbo.udf_split(F1.config_value, ',') F2
                   where F1.config_name = 'PortfolioListForRollingCOBDate')
group by port_num          
GO
GRANT SELECT ON  [dbo].[v_BI_cob_date] TO [next_usr]
GO
