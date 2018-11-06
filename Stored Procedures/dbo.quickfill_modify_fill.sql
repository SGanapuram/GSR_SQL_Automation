SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[quickfill_modify_fill]
(
   @tradeNum               int = null,
   @orderNum               smallint = null,
   @itemNum                smallint = null,
   @fillNum                smallint = null,
   @fillQty                float = null,
   @fillQtyUom             char(4) = null,
   @fillPrice              float = null,
   @fillPriceUom           varchar(4) = null,
   @fillPriceCurr          char(8) = null,
   @fillDate               varchar(30) = null,
   @tradeModInit           char(3) = null,
   @masterLocNum           int = null,
   @newTransId             int = null,
   @fillTransId            int = null
)
as
set nocount on

   update dbo.trade_item_fill 
   set fill_qty = @fillQty,
       fill_qty_uom_code = @fillQtyUom,
       fill_price = @fillPrice,
       fill_price_uom_code = @fillPriceUom,
       fill_price_curr_code = @fillPriceCurr,
       fill_date = @fillDate,
       trans_id = @newTransId
   where trade_num = @tradeNum and
         order_num = @orderNum and
         item_num = @itemNum and
         item_fill_num = @fillNum and
         trans_id = @fillTransId

   if (@@rowcount != 1)
      return -545
   return 0
GO
GRANT EXECUTE ON  [dbo].[quickfill_modify_fill] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'quickfill_modify_fill', NULL, NULL
GO
