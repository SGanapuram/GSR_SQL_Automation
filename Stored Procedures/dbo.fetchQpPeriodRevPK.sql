SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                                                         
CREATE proc [dbo].[fetchQpPeriodRevPK]                                                  
   @asof_trans_id      bigint,                                                              
   @oid      int                                                                         
as                                                                                       
set nocount on                                                                           
declare @trans_id   bigint                                                                  
select @trans_id = trans_id                                                              
from dbo.qp_period                                                                       
where oid = @oid                                                                         
if @trans_id <= @asof_trans_id                                                           
begin                                                                                    
   select
	  app_cond,
	  asof_trans_id = @asof_trans_id,
	  avg_time_frame,
	  avg_time_unit,
	  default_ind,
	  description,
	  oid,
	  qp_option_oid,
	  resp_trans_id = null,
	  time_frame,
	  time_unit,
	  trans_id,
	  trigger_desc,
	  trigger_event,
	  trigger_event_desc
   from dbo.qp_period                                                                    
   where oid = @oid                                                                      
end                                                                                      
else                                                                                     
begin                                                                                    
   set rowcount 1                                                                        
   select
	  app_cond,
	  asof_trans_id = @asof_trans_id,
	  avg_time_frame,
	  avg_time_unit,
	  default_ind,
	  description,
	  oid,
	  qp_option_oid,
	  resp_trans_id,
	  time_frame,
	  time_unit,
	  trans_id,
	  trigger_desc,
	  trigger_event,
	  trigger_event_desc
   from dbo.aud_qp_period                                                                
   where oid = @oid and                                                                  
         trans_id <= @asof_trans_id and                                                  
         resp_trans_id > @asof_trans_id                                                  
   order by trans_id desc                                                                
end                                                                                      
return                                                                                   
GO
GRANT EXECUTE ON  [dbo].[fetchQpPeriodRevPK] TO [next_usr]
GO
