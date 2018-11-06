SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[quickfill_add_fill]
(
   @tradeNum         int = null,
   @orderNum         smallint = null,
   @itemNum          smallint = null,
   @fillNum          smallint = null,
   @fillQty          float = null,
   @fillQtyUom       char(4) = null,
   @fillPrice        float = null,
   @fillPriceUom     varchar(4) = null,
   @fillPriceCurr    char(8) = null,
   @fillDate         varchar(30) = null,
   @bsiFillNum       int = null,
   @aTransId         int = null
)
as
set nocount on

   /* find out what the fill status is */
   insert into dbo.trade_item_fill
       (trade_num,
        order_num,
        item_num,
        item_fill_num,
        fill_qty,
        fill_qty_uom_code,
        fill_price,
        fill_price_curr_code,
        fill_price_uom_code,
        fill_status,
        fill_date,
        bsi_fill_num,
        inhouse_trade_num,
        inhouse_order_num,
        inhouse_item_num,
        inhouse_fill_num,
        in_out_house_ind,
        trans_id)
      values
        (@tradeNum,
         @orderNum,
         @itemNum,
         @fillNum,
         @fillQty,
         @fillQtyUom,
         @fillPrice,
         @fillPriceCurr,
         @fillPriceUom,
         NULL,
         @fillDate,
         @bsiFillNum,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL,
         @aTransId)
   if @@rowcount = 0
      return -510
   return 0
GO
GRANT EXECUTE ON  [dbo].[quickfill_add_fill] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'quickfill_add_fill', NULL, NULL
GO
