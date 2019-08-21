SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchTradeItemToTradeItemSpec]
(  
   @asof_trans_id   bigint,  
   @item_num        smallint,  
   @order_num       smallint,  
   @trade_num       int  
)  
as  
set nocount on  
select  
    asof_trans_id=@asof_trans_id,  
    cmnt_num,  
 equiv_del_cmdty_code,  
 equiv_del_mkt_code,
 equiv_del_period,
 equiv_pay_deduct_ind,  
    item_num,  
    order_num,  
    resp_trans_id = null,  
    spec_code,  
    spec_max_val,  
    spec_min_val,  
    spec_provisional_val,  
    spec_test_code,  
    spec_typical_val,  
    splitting_limit,  
    trade_num,  
    trans_id,  
 use_in_cost_ind,  
 use_in_formula_ind  
from dbo.trade_item_spec  
where trade_num = @trade_num and   
      order_num = @order_num and   
      item_num = @item_num and   
      trans_id <= @asof_trans_id  
union  
select  
    asof_trans_id=@asof_trans_id,  
    cmnt_num,  
 equiv_del_cmdty_code,  
 equiv_del_mkt_code,  
 equiv_del_period,
 equiv_pay_deduct_ind,  
 item_num,  
    order_num,  
    resp_trans_id,  
    spec_code,  
    spec_max_val,  
    spec_min_val,  
    spec_provisional_val,  
    spec_test_code,  
    spec_typical_val,  
    splitting_limit,  
    trade_num,  
    trans_id,  
 use_in_cost_ind,  
 use_in_formula_ind  
from dbo.aud_trade_item_spec  
where trade_num = @trade_num and   
      order_num = @order_num and   
      item_num = @item_num and   
      (trans_id <= @asof_trans_id and   
       resp_trans_id > @asof_trans_id)  
return  
GO
GRANT EXECUTE ON  [dbo].[fetchTradeItemToTradeItemSpec] TO [next_usr]
GO
