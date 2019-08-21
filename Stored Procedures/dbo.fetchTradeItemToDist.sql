SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[fetchTradeItemToDist]
(
   @asof_trans_id   bigint,
   @item_num        smallint,
   @order_num       smallint,
   @trade_num       int
)
as
declare @trans_id bigint

select
   accum_num, 
   -- addl_cost_sum,
   alloc_qty,
   asof_trans_id=@asof_trans_id,
   bus_date,
   -- closed_pl,
   commkt_key,
   delivered_qty,
   discount_qty,
   dist_num,
   dist_qty,
   dist_type,
   equiv_source_ind,
   estimate_qty,
   exec_inv_num,
   float_value,
   formula_body_num,
   formula_num,
   int_value,
   is_equiv_ind,
   item_num,
   -- open_pl,
   order_num,
   p_s_ind,
   parcel_num,
   parent_dist_num,   
   -- pl_asof_date,
   pos_num,
   price_curr_code_conv_to,
   price_curr_conv_rate,
   price_uom_code_conv_to,
   price_uom_conv_rate,
   priced_qty,
   qpp_num,
   qty_uom_code,                   
   qty_uom_code_conv_to,           
   qty_uom_conv_rate,              
   real_port_num,                  
   real_synth_ind,                 
   resp_trans_id=NULL,                  
   sec_conversion_factor,
   sec_qty_uom_code,
   spec_code,
   spread_pos_group_num, 
   string_value,          
   trade_num,                      
   trading_prd,
   trans_id,                       
   what_if_ind                    
from dbo.trade_item_dist
where trade_num = @trade_num and 
      order_num = @order_num and
      item_num = @item_num and 
      trans_id <= @asof_trans_id
union
select
   accum_num,                      
   -- addl_cost_sum,                  
   alloc_qty,                      
   asof_trans_id=@asof_trans_id,                   
   bus_date,                       
   -- closed_pl,                      
   commkt_key,
   delivered_qty,                  
   discount_qty,                   
   dist_num,                       
   dist_qty,                       
   dist_type, 
   equiv_source_ind,
   estimate_qty,
   exec_inv_num,
   float_value ,
   formula_body_num,
   formula_num, 
   int_value,
   is_equiv_ind,                   
   item_num,                       
   -- open_pl,                        
   order_num,                      
   p_s_ind,  
   parcel_num,
   parent_dist_num,                      
   -- pl_asof_date,                   
   pos_num,                        
   price_curr_code_conv_to,        
   price_curr_conv_rate,           
   price_uom_code_conv_to,         
   price_uom_conv_rate,            
   priced_qty,                     
   qpp_num,                        
   qty_uom_code,                   
   qty_uom_code_conv_to,           
   qty_uom_conv_rate,              
   real_port_num,                  
   real_synth_ind,                 
   resp_trans_id,                 
   sec_conversion_factor,
   sec_qty_uom_code,
   spec_code,
   spread_pos_group_num, 
   string_value,          
   trade_num,                      
   trading_prd,
   trans_id,                       
   what_if_ind                    
from dbo.aud_trade_item_dist
where trade_num = @trade_num and 
      order_num = @order_num and 
      item_num = @item_num and 
      (trans_id <= @asof_trans_id and 
       resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchTradeItemToDist] TO [next_usr]
GO
