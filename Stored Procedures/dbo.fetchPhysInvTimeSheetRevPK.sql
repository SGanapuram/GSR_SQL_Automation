SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                                 
CREATE proc [dbo].[fetchPhysInvTimeSheetRevPK]                                      
   @asof_trans_id      bigint,                                      
   @oid      int                                       
as                                                               
set nocount on                                                   
declare @trans_id   bigint                                          
                                                                 
select @trans_id = trans_id                                      
from dbo.phys_inv_time_sheet                                            
where oid = @oid                             
                                                                 
if @trans_id <= @asof_trans_id                                   
begin                                                            
   select                                                        
	asof_trans_id = @asof_trans_id,
	cmnt_num,
	document_id,
	event_from_date,
	event_to_date,
	exec_inv_num,
	from_date_actual_ind,
	loc_code,
	logistic_event,
	logistic_event_order_num,
	mot_code,
	oid,
	resp_trans_id = null,
	short_comment,
	spec_code,
	to_date_actual_ind,
	trans_id
   from dbo.phys_inv_time_sheet                                         
   where oid = @oid                          
end                                                              
else                                                             
begin                                                            
   set rowcount 1                                                
   select                                                        
	asof_trans_id = @asof_trans_id,
	cmnt_num,
	document_id,
	event_from_date,
	event_to_date,
	exec_inv_num,
	from_date_actual_ind,
	loc_code,
	logistic_event,
	logistic_event_order_num,
	mot_code,
	oid,
	resp_trans_id = null,
	short_comment,
	spec_code,
	to_date_actual_ind,
	trans_id
   from dbo.aud_phys_inv_time_sheet                                      
   where oid = @oid and                      
         trans_id <= @asof_trans_id and                          
         resp_trans_id > @asof_trans_id                          
   order by trans_id desc                                        
end                                                              
return                                                           
GO
GRANT EXECUTE ON  [dbo].[fetchPhysInvTimeSheetRevPK] TO [next_usr]
GO
