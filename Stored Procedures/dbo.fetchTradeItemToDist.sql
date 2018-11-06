SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchTradeItemToDist]
(
   @asof_trans_id   int,
   @item_num        smallint,
   @order_num       smallint,
   @trade_num       int
)
as
set nocount on

select
   accum_num, 
   -- addl_cost_sum,
   alloc_qty,
   asof_trans_id = @asof_trans_id,
   bus_date,
   -- closed_pl,
   commkt_key,
   delivered_qty,
   discount_qty,
   dist_num,
   dist_qty,
   dist_type,
   estimate_qty,
   formula_body_num,
   formula_num,
   is_equiv_ind,
   item_num,
   -- open_pl,
   order_num,
   p_s_ind,
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
   resp_trans_id = NULL,                  
   sec_conversion_factor,
   sec_qty_uom_code,
   spread_pos_group_num, 
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
   asof_trans_id = @asof_trans_id,                   
   bus_date,                       
   -- closed_pl,                      
   commkt_key,
   delivered_qty,                  
   discount_qty,                   
   dist_num,                       
   dist_qty,                       
   dist_type, 
   estimate_qty,
   formula_body_num,
   formula_num, 
   is_equiv_ind,                   
   item_num,                       
   -- open_pl,                        
   order_num,                      
   p_s_ind,  
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
   spread_pos_group_num, 
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
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchTradeItemToDist', NULL, NULL
GO
