SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
create view [dbo].[v_MDS_portfolio_profit_loss]  
(  
real_port_num ,  
pl_asof_date ,  
summary_pl_amt ,  
total_pl_no_sec_cost ,  
trans_id  
)  
AS  
select port_num 'real_port_num',pl_asof_date,(isnull(open_phys_pl,0) +  
  isnull(open_hedge_pl,0) +  
  isnull(closed_phys_pl,0)+  
  isnull(closed_hedge_pl,0)+  
  isnull(other_pl ,0) +  
  isnull(liq_open_phys_pl,0)+   
  isnull(liq_open_hedge_pl,0)+   
  isnull(liq_closed_phys_pl,0)+   
  isnull(liq_closed_hedge_pl,0)) as summary_pl_amt , total_pl_no_sec_cost, trans_id  
from portfolio_profit_loss ppl   
where exists (select 1 from portfolio p where p.port_num=ppl.port_num and port_type='R')  
GO
GRANT SELECT ON  [dbo].[v_MDS_portfolio_profit_loss] TO [next_usr]
GO
