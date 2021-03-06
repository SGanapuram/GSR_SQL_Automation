SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[fetchAllocItemToAIEstActual]
   @alloc_item_num      smallint,
   @alloc_num           int,
   @asof_trans_id       bigint
as
declare @trans_id bigint

select
   accum_num,
   actual_tax_m315_qty,
   actual_tax_mt_qty,
   actual_timezone,
   ai_est_actual_date,             
   ai_est_actual_gross_qty,        
   ai_est_actual_ind,              
   ai_est_actual_net_qty,          
   ai_est_actual_num,              
   ai_est_actual_short_cmnt,       
   ai_gross_qty_uom_code,          
   ai_net_qty_uom_code,            
   alloc_item_num,                 
   alloc_num,                      
   asof_trans_id=@asof_trans_id, 
   assay_final_ind,
   bol_code,                       
   date_specs_recieved_from_al,
   del_loc_code,                   
   dest_trade_num,                 
   fixed_swing_qty_ind,
   insert_sequence,
   lease_num, 
   manual_input_sec_ind,
   mot_code,
   owner_code,                     
   resp_trans_id=NULL,
   sap_position_num,
   scac_carrier_code,              
   secondary_actual_gross_qty,
   secondary_actual_net_qty,
   secondary_qty_uom_code,
   start_load_date,
   stop_load_date,
   tertiary_gross_qty,
   tertiary_net_qty,
   tertiary_uom_code,
   ticket_num,                     
   trans_id,                       
   transporter_code,
   unique_id   
from dbo.ai_est_actual
where alloc_num = @alloc_num and 
      alloc_item_num = @alloc_item_num and 
      trans_id <= @asof_trans_id
union
select
   accum_num,
   actual_tax_m315_qty,
   actual_tax_mt_qty,
   actual_timezone,
   ai_est_actual_date,             
   ai_est_actual_gross_qty,        
   ai_est_actual_ind,              
   ai_est_actual_net_qty,          
   ai_est_actual_num,              
   ai_est_actual_short_cmnt,       
   ai_gross_qty_uom_code,          
   ai_net_qty_uom_code,            
   alloc_item_num,                 
   alloc_num,                      
   asof_trans_id=@asof_trans_id,  
   assay_final_ind,
   bol_code,
   date_specs_recieved_from_al,
   del_loc_code,                   
   dest_trade_num,                 
   fixed_swing_qty_ind,
   insert_sequence,
   lease_num, 
   manual_input_sec_ind,
   mot_code,
   owner_code,                     
   resp_trans_id,  
   sap_position_num,
   scac_carrier_code,              
   secondary_actual_gross_qty,
   secondary_actual_net_qty,
   secondary_qty_uom_code,
   start_load_date,
   stop_load_date,
   tertiary_gross_qty,
   tertiary_net_qty,
   tertiary_uom_code,
   ticket_num,                     
   trans_id,                       
   transporter_code,
   unique_id   
from dbo.aud_ai_est_actual
where alloc_num = @alloc_num and 
      alloc_item_num = @alloc_item_num and 
      (trans_id <= @asof_trans_id and 
       resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchAllocItemToAIEstActual] TO [next_usr]
GO
