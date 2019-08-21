SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                                 
CREATE proc [dbo].[fetchPhysInvWeightRevPK]
(                                      
   @asof_trans_id      bigint, 
   @exec_inv_num       int,
   @measure_date       datetime  
)   
as                                                               
set nocount on                                                   
declare @trans_id   bigint                                          
                                                                 
select @trans_id = trans_id                                      
from dbo.phys_inv_weight                                            
where exec_inv_num = @exec_inv_num and
      measure_date = @measure_date                             
                                                                 
if @trans_id <= @asof_trans_id                                   
begin                                                            
   select                                                        
	  asof_trans_id = @asof_trans_id,
	  exec_inv_num,
	  loc_code,
	  measure_date,
	  prim_qty,
	  prim_qty_uom_code,
	  resp_trans_id = null,
	  sec_qty,
	  sec_qty_uom_code,
	  short_comment,
	  trans_id,
	  use_in_pl_ind,
	  weight_detail_num,
      weight_type	  
   from dbo.phys_inv_weight                                         
   where exec_inv_num = @exec_inv_num and
         measure_date = @measure_date                         
end                                                              
else                                                             
begin                                                            
   set rowcount 1                                                
   select                                                        
	  asof_trans_id = @asof_trans_id,
	  exec_inv_num,
	  loc_code,
	  measure_date,
	  prim_qty,
	  prim_qty_uom_code,
	  resp_trans_id = null,
	  sec_qty,
	  sec_qty_uom_code,
	  short_comment,
	  trans_id,
	  use_in_pl_ind,
	  weight_detail_num,
      weight_type	  
   from dbo.aud_phys_inv_weight                                      
   where exec_inv_num = @exec_inv_num and
		 measure_date = @measure_date and                      
         trans_id <= @asof_trans_id and                          
         resp_trans_id > @asof_trans_id                          
   order by trans_id desc                                        
end                                                              
return                                                           
GO
GRANT EXECUTE ON  [dbo].[fetchPhysInvWeightRevPK] TO [next_usr]
GO
