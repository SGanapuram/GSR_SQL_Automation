SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[quickfill_modify_trade]
(
   @tradeNum		int = null,
   @orderNum		int = null, 
   @contrDate		varchar(30) = null,
   @orderPrice		float = null,
   @orderPriceCurrCode	char(8) = null,
   @orderPriceUomCode	varchar(4) = null,
   @orderPoints		float =	null,
   @orderInstrCode	varchar(8) = null,
   @mfNum		varchar(8) = null,
   @clearingBrkr	int = null,
   @efpInd		char(1) = null,
   @locNum		int = null,
   @creatorInit		char(3) = null,
   @comment		varchar(15) = null,
   @cmntNum		int = null,
   @itemNum1		smallint = null,
   @psInd1		char(1) = null,
   @qty1		float = null,
   @tp1			varchar(8) = null,
   @cmdty1		varchar(8) = null,
   @mkt1		varchar(8) = null,
   @strike1		float = null,
   @pc1			char(1) = null,
   @trader1		char(3) = null,
   @avgPrice1		float = null,
   @totalFillQty1	float = null,
   @portNum1		int = null,
   @isHedgeInd1		char(1) = null,
   @flrBrkr1		int = null,
   @isNewTradeItem1	char(1) = null,
   @itemTransId1	int = null,
   @futOptTransId1	int = null,
   @itemNum2		smallint = null,
   @psInd2		char(1) = null,
   @qty2		float = null,
   @tp2			varchar(8) = null,
   @cmdty2		varchar(8) = null,
   @mkt2		varchar(8) = null,
   @strike2		float = null,
   @pc2			char(1) = null,
   @trader2		char(3) = null,
   @avgPrice2		float = null,
   @totalFillQty2	float=null,
   @portNum2		int = null,
   @isHedgeInd2		char(1) = null,
   @flrBrkr2		int = null,
   @priceCurr2		varchar(8) = null,
   @priceUom2		varchar(8) = null,
   @isNewTradeItem2	char(1) = null,
   @itemTransId2	int = null,
   @futOptTransId2	int = null,
   @itemNum3		smallint = null,
   @psInd3		char(1) = null,
   @qty3		float = null,
   @tp3			varchar(8) = null,
   @cmdty3		varchar(8) = null,
   @mkt3		varchar(8) = null,
   @strike3		float = null,
   @pc3			char(1) = null,
   @trader3		char(3) = null,
   @avgPrice3		float = null,
   @totalFillQty3	float = null,
   @portNum3		int = null,
   @isHedgeInd3		char(1) = null,
   @flrBrkr3		int = null,
   @priceCurr3		varchar(8),
   @priceUom3		varchar(8),
   @isNewTradeItem3	char(1) = null,
   @itemTransId3	int = null,
   @futOptTransId3	int = null,
   @itemNum4		smallint = null,
   @psInd4		char(1) = null,
   @qty4		float = null,
   @tp4			varchar(8) = null,
   @cmdty4		varchar(8) = null,
   @mkt4		varchar(8) = null,
   @strike4		float = null,
   @pc4			char(1) = null,
   @trader4		char(3) = null,
   @avgPrice4		float = null,
   @totalFillQty4	float = null,
   @portNum4		int = null,
   @isHedgeInd4		char(1) = null,
   @flrBrkr4		int = null,
   @priceCurr4		varchar(8) = null,
   @priceUom4		varchar(8) = null,
   @isNewTradeItem4	char(1) = null,
   @itemTransId4	int = null,
   @futOptTransId4	int = null,
   @tradeTransId	int = null,
   @newTradeModInit	char(3) = null,
   @orderTransId	int = null,
   @orderExchTransId	int = null,
   @newTradeTransId	int = null,
   @newTradeModDate	datetime = null,
   @tradeSyncTransId	int = null
)
as
set nocount on
declare	@status int
declare	@itemType char(1)
declare	@creationDate datetime
declare	@headline1 varchar(255)
declare	@headline2 varchar(255)
declare	@headline3 varchar(255)
declare	@headline4 varchar(255)
declare @modificationDate datetime 
declare @sqlString varchar(255)
declare @oldTransId int
declare @oldOrderPrice float
declare @oldOrderPriceCurrCode char(8)
declare @oldOrderPoints float
declare @oldOrderInstrCode char(8)
declare @oldStratName varchar(8)
declare @deleteCount int
declare @deletionCount int
declare @deleteTrade char(1)
declare @orderTypeCode char(8)
declare @efpMess varchar(15)
declare @warning int

   /* check to make sure that the trade has not been modified 
      before trying to update/delete anything  */
   select @oldTransId = trans_id 
   from dbo.trade 
   where trade_num = @tradeNum

   select @warning = null
   if (@oldTransId != @tradeTransId)
      return -544

   select @oldStratName = order_strategy_name, 
          @orderTypeCode = order_type_code 
   from dbo.trade_order 
   where trade_num = @tradeNum and 
         order_num = @orderNum

   /* check if there is a different item type for different items, 
      if there is, flag error */
   if (@orderTypeCode = "FUTURE")
   begin
      if (@strike1 is not null) or 
         (@pc1 is not null) or 
         (@strike2 is not null) or
         (@pc2 is not null) or 
         (@strike3 is not null) or
         (@pc3 is not null) or 
         (@strike4 is not null) or 
         (@pc4 is not null)
         return -588
   end
   else 
   begin
      if (@qty1 is not null) and (@strike1 is null) and (@pc1 is null)
         return -588
      if (@qty2 is not null) and (@strike2 is null) and (@pc2 is null)
         return -588
      if (@qty3 is not null) and (@strike3 is null) and (@pc3 is null)
         return -588
      if (@qty4 is not null) and (@strike4 is null) and (@pc4 is null)
         return -588
   end

   select @modificationDate = getdate()
   select @sqlString = null

   /* update trade - has to be done for any change to trade */
   update dbo.trade 
   set trader_init = @trader1,
       contr_date = @contrDate,
       creator_init = @creatorInit,
       trade_mod_date = @newTradeModDate,
       trade_mod_init = @newTradeModInit,
       trans_id = @newTradeTransId
   where trade_num = @tradeNum and
         trans_id = @tradeTransId
   if (@@rowcount != 1) 
      return -532

   update dbo.trade_sync 
   set trade_sync_inds = '0000---X',
       trans_id = @newTradeTransId
   where trade_num = @tradeNum and 
         trans_id = @tradeSyncTransId
   if (@@rowcount != 1)
      return -802

   /* upadte trade_order if the strat name's are different, i.e., 
      mainframe pos number was updated. */

   /*  the construction of this efpmess is in two places. so, if 
       you change here you would have to do the same in 
       quickfill_add_trade_order too */
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

   if (@oldStratName != @efpMess) 
   begin
      update dbo.trade_order 
      set order_strategy_name = @efpMess,
          trans_id = @newTradeTransId
      where trade_num = @tradeNum and
            order_num = @orderNum and 
            trans_id = @orderTransId
      if (@@rowcount != 1)
         return -565
   end

   /* update pei_comment if exists */
   if (@cmntNum is not null) 
   begin
      select @status = cmnt_num 
      from dbo.pei_comment 
      where cmnt_num = @cmntNum
      if (@@rowcount = 0) 
      begin
         insert into dbo.pei_comment(cmnt_num, tiny_cmnt, trans_id)
             values(@cmntNum, @comment, @newTradeTransId)
         if (@@rowcount != 1)
            return -585
      end
      else 
      begin
         update dbo.pei_comment 
         set tiny_cmnt = @comment,
             trans_id = @newTradeTransId
         where cmnt_num = @cmntNum
         if (@@rowcount != 1)
            return -586
      end
   end

   /* trade_order_on_exch has to be modified only if the order_price, 
      order_points etc change  */
   select @oldOrderPrice = null
   select @oldOrderPriceCurrCode = null
   select @oldOrderPoints = null
   select @oldOrderInstrCode = null

   select @oldOrderPrice = order_price,
          @oldOrderPriceCurrCode = order_price_curr_code,
          @oldOrderPoints = order_points,
          @oldOrderInstrCode = order_instr_code
   from dbo.trade_order_on_exch
   where trade_num = @tradeNum and
         order_num = @orderNum

   if (@@rowcount = 0) 
   begin
      /* this could happen for EFP's since they are entered using TC
         and TC does not create a trade_order_on_exch record */
      insert into dbo.trade_order_on_exch
         (trade_num, order_num, order_price, order_price_curr_code,
          order_points, order_instr_code, trans_id)
        values(@tradeNum, @orderNum, @orderPrice, @orderPriceCurrCode,
               @orderPoints, @orderInstrCode, @newTradeTransId)
      if (@@rowcount != 1)
         return -506
   end
   else
      if (@oldOrderPrice != @orderPrice) or 
         (@oldOrderPriceCurrCode != @orderPriceCurrCode) or
         (@oldOrderPoints != @orderPoints) or 
         (@oldOrderInstrCode != @orderInstrCode) 
      begin
         update dbo.trade_order_on_exch 
         set order_price = @orderPrice,
             order_price_curr_code = @orderPriceCurrCode,
             order_points = @orderPoints,
             order_instr_code = @orderInstrCode,
             trans_id = @newTradeTransId
         where trade_num = @tradeNum and
               order_num = @orderNum and
               trans_id = @orderExchTransId	
         if (@@rowcount != 1)
            return -534
      end

   /* process one item at a time */
   exec @status = dbo.quickfill_modify_trade_item 
                                           @tradeNum,
                                           @orderNum,
                                           @itemNum1,
                                           @psInd1,
                                           @qty1,
                                           @tp1,
                                           @cmdty1,
                                           @mkt1,
                                           @strike1,
                                           @pc1,
                                           @trader1,
                                           @avgPrice1,
                                           @totalFillQty1,
                                           @orderPriceCurrCode,
                                           @orderPriceUomCode,
                                           @portNum1,
                                           @isHedgeInd1,
                                           @newTradeModInit,
                                           @contrDate,
                                           @flrBrkr1,
                                           @clearingBrkr,
                                           @modificationDate,
                                           @locNum,
                                           @isNewTradeItem1,
                                           @itemTransId1,
                                           @futOptTransId1,
                                           @cmntNum,
                                           @efpInd,
                                           @newTradeTransId

   if (@status < 0) and (@status != -582) and (@status != -583)
      return @status

   if (@warning is null) and ((@status = -582) or (@status = -583))
      select @warning = @status

   exec @status = dbo.quickfill_modify_trade_item 
                                           @tradeNum,
                                           @orderNum,
                                           @itemNum2,
                                           @psInd2,
                                           @qty2,
                                           @tp2,
                                           @cmdty2,
                                           @mkt2,
                                           @strike2,
                                           @pc2,
                                           @trader2,
                                           @avgPrice2,
                                           @totalFillQty2,
                                           @priceCurr2,
                                           @priceUom2,
                                           @portNum2,
                                           @isHedgeInd2,
                                           @newTradeModInit,
                                           @contrDate,
                                           @flrBrkr2,
                                           @clearingBrkr,
                                           @modificationDate,
                                           @locNum,
                                           @isNewTradeItem2,
                                           @itemTransId2,
                                           @futOptTransId2,
                                           @cmntNum,
                                           @efpInd,
                                           @newTradeTransId

   if (@status < 0) and (@status != -582) and (@status != -583)
      return @status

   if (@warning is null) and ((@status = -582) or (@status = -583))
      select @warning = @status

   exec @status = dbo.quickfill_modify_trade_item 
                                           @tradeNum,
                                           @orderNum,
                                           @itemNum3,
                                           @psInd3,
                                           @qty3,
                                           @tp3,
                                           @cmdty3,
                                           @mkt3,
                                           @strike3,
                                           @pc3,
                                           @trader3,
                                           @avgPrice3,
                                           @totalFillQty3,
                                           @priceCurr3,
                                           @priceUom3,
                                           @portNum3,
                                           @isHedgeInd3,
                                           @newTradeModInit,
                                           @contrDate,
                                           @flrBrkr3,
                                           @clearingBrkr,
                                           @modificationDate,
                                           @locNum,
                                           @isNewTradeItem3,
                                           @itemTransId3,
                                           @futOptTransId3,
                                           @cmntNum,
                                           @efpInd,
                                           @newTradeTransId

   if (@status < 0) and (@status != -582) and (@status != -583)
      return @status

   if (@warning is null) and ((@status = -582) or (@status = -583))
      select @warning = @status

   exec @status = dbo.quickfill_modify_trade_item 
                                           @tradeNum,
                                           @orderNum,
                                           @itemNum4,
                                           @psInd4,
                                           @qty4,
                                           @tp4,
                                           @cmdty4,
                                           @mkt4,
                                           @strike4,
                                           @pc4,
                                           @trader4,
                                           @avgPrice4,
                                           @totalFillQty4,
                                           @priceCurr4,
                                           @priceUom4,
                                           @portNum4,
                                           @isHedgeInd4,
                                           @newTradeModInit,
                                           @contrDate,
                                           @flrBrkr4,
                                           @clearingBrkr,
                                           @modificationDate,
                                           @locNum,
                                           @isNewTradeItem4,
                                           @itemTransId4,
                                           @futOptTransId4,
                                           @cmntNum,
                                           @efpInd,
                                           @newTradeTransId

   if (@status < 0) and (@status != -582) and (@status != -583)
      return @status

   if (@warning is null) and ((@status = -582) or (@status = -583))
      select @warning = @status

   if (@warning is null)		
      return @tradeNum
   else 
      return @warning
GO
GRANT EXECUTE ON  [dbo].[quickfill_modify_trade] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'quickfill_modify_trade', NULL, NULL
GO
