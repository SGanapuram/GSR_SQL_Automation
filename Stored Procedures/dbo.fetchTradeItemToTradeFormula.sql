SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
   
CREATE procedure [dbo].[fetchTradeItemToTradeFormula]  
(  
   @asof_trans_id      bigint,  
   @item_num           smallint,  
   @order_num          smallint,  
   @trade_num          int  
)  
as  
set nocount on  
   
   select asof_trans_id = @asof_trans_id,
		  conc_del_item_oid,
		  cp_formula_oid,   
          fall_back_ind,  
          fall_back_to_formula_num,  
          formula_num,  
          formula_qty_opt,  
          item_num,  
		  modified_default_ind,
          order_num,  
          resp_trans_id = NULL,  
          trade_num,  
          trans_id  
   from dbo.trade_formula  
   where trade_num = @trade_num and  
         order_num = @order_num and  
         item_num = @item_num and  
         trans_id <= @asof_trans_id  
   union  
   select asof_trans_id = @asof_trans_id,
		  conc_del_item_oid,
		  cp_formula_oid,      
          fall_back_ind,  
          fall_back_to_formula_num,  
          formula_num,  
          formula_qty_opt,  
          item_num, 
		  modified_default_ind,		  
          order_num,  
          resp_trans_id,  
          trade_num,  
          trans_id  
   from dbo.aud_trade_formula  
   where trade_num = @trade_num and  
         order_num = @order_num and  
         item_num = @item_num and  
         (trans_id <= @asof_trans_id and  
          resp_trans_id > @asof_trans_id)  
return  
GO
GRANT EXECUTE ON  [dbo].[fetchTradeItemToTradeFormula] TO [next_usr]
GO
