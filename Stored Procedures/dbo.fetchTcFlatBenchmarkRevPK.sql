SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                                                         
CREATE proc [dbo].[fetchTcFlatBenchmarkRevPK]                                                  
   @asof_trans_id      bigint,                                                              
   @oid      int                                                                         
as                                                                                       
set nocount on                                                                           
declare @trans_id   bigint                                                                  
                                                                                         
select @trans_id = trans_id                                                              
from dbo.tc_flat_benchmark                                                                       
where oid = @oid                                                                         
                                                                                         
if @trans_id <= @asof_trans_id                                                           
begin                                                                                    
   select
	  app_to_benchmark,
	  app_to_flat,
	  asof_trans_id = @asof_trans_id,
	  benchmark_detail_oid,
	  benchmark_percentage,
	  benchmark_value,
	  cp_formula_oid,
	  flat_amt,
	  flat_percentage,
	  from_value,
	  oid,
	  price_rule_oid,
	  resp_trans_id = null,
	  tc_value,
	  to_value,
	  trans_id
   from dbo.tc_flat_benchmark                                                                    
   where oid = @oid                                                                      
end                                                                                      
else                                                                                     
begin                                                                                    
   set rowcount 1                                                                        
   select
	  app_to_benchmark,
	  app_to_flat,
	  asof_trans_id = @asof_trans_id,
	  benchmark_detail_oid,
	  benchmark_percentage,
	  benchmark_value,
	  cp_formula_oid,
	  flat_amt,
	  flat_percentage,
	  from_value,
	  oid,
	  price_rule_oid,
	  resp_trans_id = null,
	  tc_value,
	  to_value,
	  trans_id
   from dbo.aud_tc_flat_benchmark                                                                
   where oid = @oid and                                                                  
         trans_id <= @asof_trans_id and                                                  
         resp_trans_id > @asof_trans_id                                                  
   order by trans_id desc                                                                
end                                                                                      
return                                                                                   
GO
GRANT EXECUTE ON  [dbo].[fetchTcFlatBenchmarkRevPK] TO [next_usr]
GO
