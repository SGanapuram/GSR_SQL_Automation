SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                                                         
CREATE proc [dbo].[fetchQpPricingRevPK] 
(                                                 
   @asof_trans_id      bigint,                                                              
   @oid                int    
)   
as                                                                                       
set nocount on                                                                           
declare @trans_id   bigint                                                                  
                                                                                         
select @trans_id = trans_id                                                              
from dbo.qp_pricing                                                                       
where oid = @oid                                                                         
                                                                                         
if @trans_id <= @asof_trans_id                                                           
begin                                                                                    
   select
	  asof_trans_id = @asof_trans_id,
	  min_qty,
	  min_qty_uom_code,
	  oid,
	  pricing_option_ind,
	  qp_option_oid,
	  resp_trans_id = null,
	  trans_id
   from dbo.qp_pricing                                                                    
   where oid = @oid                                                                      
end                                                                                      
else                                                                                     
begin                                                                                    
   set rowcount 1                                                                        
   select
	  asof_trans_id = @asof_trans_id,
	  min_qty,
	  min_qty_uom_code,
	  oid,
	  pricing_option_ind,
	  qp_option_oid,
	  resp_trans_id = null,
	  trans_id
   from dbo.aud_qp_pricing                                                                
   where oid = @oid and                                                                  
         trans_id <= @asof_trans_id and                                                  
         resp_trans_id > @asof_trans_id                                                  
   order by trans_id desc                                                                
end                                                                                      
return                                                                                   
GO
GRANT EXECUTE ON  [dbo].[fetchQpPricingRevPK] TO [next_usr]
GO
