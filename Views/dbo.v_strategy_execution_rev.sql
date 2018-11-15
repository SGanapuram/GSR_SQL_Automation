SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                         
CREATE view [dbo].[v_strategy_execution_rev]                              
(                                                        
	oid,
	real_port_num,
	shipment_num,
	alloc_num,
	strategy_status,
	max_strategy_detail_num,
	trans_id,
	asof_trans_id,
	resp_trans_id
)                                                        
as                                                       
select                                                   
	oid,
	real_port_num,
	shipment_num,
	alloc_num,
	strategy_status,
	max_strategy_detail_num,
	trans_id,
	trans_id,
	resp_trans_id
from dbo.aud_strategy_execution                                 
GO
GRANT SELECT ON  [dbo].[v_strategy_execution_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_strategy_execution_rev] TO [next_usr]
GO
