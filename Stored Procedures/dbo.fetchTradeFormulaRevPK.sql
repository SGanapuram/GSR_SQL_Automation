SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchTradeFormulaRevPK]
(
   @asof_trans_id      bigint,
   @formula_num        int,
   @item_num           smallint,
   @order_num          smallint,
   @trade_num          int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.trade_formula
where trade_num = @trade_num and
      order_num = @order_num and
      item_num = @item_num and
      formula_num = @formula_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
	  conc_del_item_oid,
	  cp_formula_oid,
      fall_back_ind,
      fall_back_to_formula_num,
      formula_num,
      formula_qty_opt,
      item_num,
	  modified_default_ind,
      order_num,
      resp_trans_id = null,
      trade_num,
      trans_id
   from dbo.trade_formula
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num and
         formula_num = @formula_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
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
         formula_num = @formula_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchTradeFormulaRevPK] TO [next_usr]
GO
