SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                                 
CREATE proc [dbo].[fetchStrategyExecutionDetailRevPK] 
(                                     
   @asof_trans_id      int,                                      
   @strategy_id        int,
   @strat_detail_num   int
)
as                                                               
set nocount on                                                   
declare @trans_id   int                                          
                                                                 
select @trans_id = trans_id                                      
from dbo.strategy_execution_detail                                            
where strategy_id = @strategy_id and
	  strat_detail_num = @strat_detail_num						
                                                                 
if @trans_id <= @asof_trans_id                                   
begin                                                            
   select                                                        
	  asof_trans_id = @asof_trans_id,
	  exec_id,
	  resp_trans_id = null,
	  strat_detail_num,
	  strategy_id,
	  trans_id
   from dbo.strategy_execution_detail                                         
   where strategy_id = @strategy_id and
		 strat_detail_num = @strat_detail_num
end                                                              
else                                                             
begin                                                            
   set rowcount 1                                                
   select                                                        
	  asof_trans_id = @asof_trans_id,
	  exec_id,
	  resp_trans_id = null,
	  strat_detail_num,
	  strategy_id,
	  trans_id
   from dbo.aud_strategy_execution_detail                                      
   where strategy_id = @strategy_id and 
		 strat_detail_num = @strat_detail_num and
         trans_id <= @asof_trans_id and                          
         resp_trans_id > @asof_trans_id                          
   order by trans_id desc                                        
end                                                              
return                                                           
GO
GRANT EXECUTE ON  [dbo].[fetchStrategyExecutionDetailRevPK] TO [next_usr]
GO
