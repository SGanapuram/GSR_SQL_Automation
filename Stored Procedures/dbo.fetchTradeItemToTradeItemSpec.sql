SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchTradeItemToTradeItemSpec]
(
   @asof_trans_id      int,
   @item_num           smallint,
   @order_num          smallint,
   @trade_num          int
)
as
set nocount on
 
   select asof_trans_id = @asof_trans_id,
          cmnt_num,
          item_num,
          order_num,
          resp_trans_id = NULL,
          spec_code,
          spec_max_val,
          spec_min_val,
          spec_provisional_val,
          spec_test_code,
          spec_typical_val,
          splitting_limit,
          trade_num,
          trans_id
   from dbo.trade_item_spec
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num and
         trans_id <= @asof_trans_id
   union
   select asof_trans_id = @asof_trans_id,
          cmnt_num,
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
          trans_id
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
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchTradeItemToTradeItemSpec', NULL, NULL
GO
