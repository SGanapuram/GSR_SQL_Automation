SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                         
CREATE view [dbo].[v_strategy_execution_detail_rev]                              
(                                                        
	strategy_id,
	strat_detail_num,
	exec_id,
	trans_id,
	asof_trans_id,
	resp_trans_id
)                                                        
as                                                       
select                                                   
	strategy_id,
	strat_detail_num,
	exec_id,
	trans_id,
	trans_id,
	resp_trans_id
from dbo.aud_strategy_execution_detail                                 
GO
GRANT SELECT ON  [dbo].[v_strategy_execution_detail_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_strategy_execution_detail_rev] TO [next_usr]
GO
