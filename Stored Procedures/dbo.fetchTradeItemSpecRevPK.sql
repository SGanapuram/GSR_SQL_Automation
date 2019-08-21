SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchTradeItemSpecRevPK]
(  
   @asof_trans_id   bigint,  
   @item_num        smallint,  
   @order_num       smallint,  
   @spec_code       char(8),  
   @trade_num       int  
)  
as  
set nocount on  
declare @trans_id   bigint  
   select @trans_id = trans_id  
   from dbo.trade_item_spec  
   where trade_num = @trade_num and  
         order_num = @order_num and  
         item_num = @item_num and  
         spec_code = @spec_code  
if @trans_id <= @asof_trans_id  
begin  
   select   
       asof_trans_id = @asof_trans_id,  
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
         spec_code = @spec_code  
end  
else  
begin  
   set rowcount 1  
   select   
  asof_trans_id = @asof_trans_id,  
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
         spec_code = @spec_code and  
         trans_id <= @asof_trans_id and  
      resp_trans_id > @asof_trans_id  
   order by trans_id desc  
end  
return  
GO
GRANT EXECUTE ON  [dbo].[fetchTradeItemSpecRevPK] TO [next_usr]
GO
