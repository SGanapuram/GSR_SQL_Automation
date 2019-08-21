SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                                 
CREATE procedure [dbo].[fetchStrategyExecutionToDetail] 
(   
   @asof_trans_id   bigint,    
   @strategy_id     smallint
)   
as    
declare @trans_id bigint    
    
select    
   asof_trans_id=@asof_trans_id,   
   exec_id,  
   resp_trans_id = NULL,  
   strat_detail_num,  
   strategy_id,  
   trans_id                    
from dbo.strategy_execution_detail    
where strategy_id = @strategy_id and     
      trans_id <= @asof_trans_id    
union    
select    
   asof_trans_id=@asof_trans_id,   
   exec_id,  
   resp_trans_id,  
   strat_detail_num,  
   strategy_id,  
   trans_id                    
from dbo.aud_strategy_execution_detail    
where strategy_id = @strategy_id and     
      (trans_id <= @asof_trans_id and     
       resp_trans_id > @asof_trans_id)    
return                                                            
GO
GRANT EXECUTE ON  [dbo].[fetchStrategyExecutionToDetail] TO [next_usr]
GO
