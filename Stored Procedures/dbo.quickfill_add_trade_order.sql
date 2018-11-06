SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[quickfill_add_trade_order]
(
   @tradeNum              int = null,
   @trader                char(3) = null,
   @contrDate             varchar(15) = null,
   @creationDate          varchar(30) = null,
   @orderTypeCode         varchar(8) = null,
   @orderPrice            float = null,
   @orderPriceCurrCode    char(4) = null,
   @orderPoints           float = null,
   @orderInstrCode        varchar(8) = null,
   @mfNum                 varchar(8) = null,
   @efpInd                char(1) = null,
   @creatorInit		        char(3) = null,
   @aTransId		          int = null
)
as
set nocount on
declare @tradeStatusCode char(8)
declare @conclusionType char(1)
declare @contrTelex char(1)
declare @balInd char(1)
declare @efpMess char(15)
declare @orderNum smallint

   select @tradeStatusCode = 'UNALLOC'
   select @conclusionType = 'C'
   select @contrTelex = 'Y'
   select @balInd = 'N'

   insert into dbo.trade 
       (trade_num, trader_init, trade_status_code, conclusion_type,
        contr_date, contr_tlx_hold_ind, creation_date, creator_init, trans_id)
     values (@tradeNum,
             @trader,
             @tradeStatusCode,
             @conclusionType,
             @contrDate,
             @contrTelex,
             @creationDate,
             @creatorInit,
             @aTransId) 
   if @@rowcount = 0
      return -504

   insert into dbo.trade_sync
	      (trade_num, trade_sync_inds, trans_id)
     values(@tradeNum, '0000---X', @aTransId)
   if @@rowcount = 0
      return -801

   /* the construction of this efpmess is in two places.  so, if you 
      change here you would have to do the same in quickfill_modifyTrade 
      too */

   if (@mfNum is null) and (@efpInd is null)
      select @efpMess = 'N'
   else 
   begin
      if (@efpInd is null)
         select @efpMess = 'N'
      else
         select @efpMess = @efpInd

      if (@mfNum is not null)
         select @efpMess = @efpMess + @mfNum
   end

   insert into dbo.trade_order 
         (trade_num, order_num, order_type_code, order_status_code,
          bal_ind, strip_summary_ind, order_strategy_name, trans_id)
        values (@tradeNum,
                1,
                @orderTypeCode,
                NULL,
                @balInd,
                'N',
                @efpMess,
                @aTransId)
   if @@rowcount = 0
      return -505

   insert into dbo.trade_order_on_exch 
       (trade_num, order_num, order_price, order_price_curr_code,
        order_points, order_instr_code, trans_id)
      values (@tradeNum,
              1,
              @orderPrice,
              @orderPriceCurrCode,
              @orderPoints,
              @orderInstrCode,
              @aTransId)
   if @@rowcount = 0
      return -506

return @tradeNum
GO
GRANT EXECUTE ON  [dbo].[quickfill_add_trade_order] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'quickfill_add_trade_order', NULL, NULL
GO
