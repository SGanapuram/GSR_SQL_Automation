SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchTrdOrderToTrdOrderBunker]
(
   @asof_trans_id      int,
   @order_num          smallint,
   @trade_num          int
)
as
set nocount on
 
   select asof_trans_id = @asof_trans_id,
          auto_alloc_ind,
          brkr_cont_num,
          brkr_num,
          brkr_ref_num,
          brkr_tel_num,
          bunker_type,
          comm_amt,
          comm_curr_code,
          comm_uom_code,
          duty_ind,
          fiscal_class_code,
          not_to_vouch_ind,
          order_num,
          resp_trans_id = NULL,
          trade_num,
          trans_id,
          transp_price_amt,
          transp_price_comp_ind,
          transp_price_curr_code,
          transp_price_type,
          vat_ind
   from dbo.trade_order_bunker
   where trade_num = @trade_num and
         order_num = @order_num and
         trans_id <= @asof_trans_id
   union
   select asof_trans_id = @asof_trans_id,
          auto_alloc_ind,
          brkr_cont_num,
          brkr_num,
          brkr_ref_num,
          brkr_tel_num,
          bunker_type,
          comm_amt,
          comm_curr_code,
          comm_uom_code,
          duty_ind,
          fiscal_class_code,
          not_to_vouch_ind,
          order_num,
          resp_trans_id,
          trade_num,
          trans_id,
          transp_price_amt,
          transp_price_comp_ind,
          transp_price_curr_code,
          transp_price_type,
          vat_ind
   from dbo.aud_trade_order_bunker
   where trade_num = @trade_num and
         order_num = @order_num and
         (trans_id <= @asof_trans_id and
          resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchTrdOrderToTrdOrderBunker] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchTrdOrderToTrdOrderBunker', NULL, NULL
GO
