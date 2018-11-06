SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[quickfill_add_trade] 
(
   @tradeNum		        int = null,
   @contrDate		        varchar(15) = null,
   @orderPrice		      float = null,
   @orderPriceCurrCode	char(8) = null,
   @orderPriceUomCode	  varchar(4) = null,
   @orderPoints		      float =	null,
   @orderInstrCode	    varchar(8) = null,
   @mfNum		            varchar(8) = null,
   @efpInd		          char(1) = null,
   @clearingBrkr	      int = null,
   @locNum		          int = null,
   @creatorInit		      char(3) = null,
   @creationDate	      varchar(40) = null,
   @comment		          varchar(15) = null,
   @cmntNum		          int = null,
   @aTransId		        int = null,
   @itemNum1		        smallint = null,
   @psInd1		          char(1) = null,
   @qty1		            float = null,
   @tp1			            varchar(8) = null,
   @cmdty1		          varchar(8) = null,
   @mkt1		            varchar(8) = null,
   @strike1		          float = null,
   @pc1			            char(1) = null,
   @trader1		          char(3) = null,
   @avgPrice1		        float = null,
   @totalFillQty1	      float = null,
   @portNum1		        int = null,
   @isHedgeInd1		      char(1) = null,
   @flrBrkr1		        int = null,
   @fillQty1		        float = null,
   @fillPrice1		      float = null,
   @fillPriceUom1	      varchar(4) = null,
   @fillPriceCurr1	    char(8) = null,
   @bsiFillNum1		      int = null,
   @itemNum2		        smallint = null,
   @psInd2		          char(1) = null,
   @qty2		            float = null,
   @tp2			            varchar(8) = null,
   @cmdty2		          varchar(8) = null,
   @mkt2		            varchar(8) = null,
   @strike2		          float = null,
   @pc2			            char(1) = null,
   @trader2		          char(3) = null,
   @avgPrice2		        float = null,
   @totalFillQty2	      float = null,
   @portNum2		        int = null,
   @isHedgeInd2		      char(1) = null,
   @flrBrkr2		        int = null,
   @fillQty2		        float = null,
   @fillPrice2		      float = null,
   @fillPriceUom2	      varchar(4) = null,
   @fillPriceCurr2	    char(8) = null,
   @bsiFillNum2		      int = null,
   @itemNum3		        smallint = null,
   @psInd3		          char(1) = null,
   @qty3		            float = null,
   @tp3			            varchar(8) = null,
   @cmdty3		          varchar(8) = null,
   @mkt3		            varchar(8) = null,
   @strike3		          float = null,
   @pc3			            char(1) = null,
   @trader3		          char(3) = null,
   @avgPrice3		        float = null,
   @totalFillQty3	      float = null,
   @portNum3		        int = null,
   @isHedgeInd3		      char(1) = null,
   @flrBrkr3		        int = null,
   @fillQty3		        float = null,
   @fillPrice3		      float = null,
   @fillPriceUom3	      varchar(4) = null,
   @fillPriceCurr3	    char(8) = null,
   @bsiFillNum3		      int = null,
   @itemNum4		        smallint = null,
   @psInd4		          char(1) = null,
   @qty4		            float = null,
   @tp4			            varchar(8) = null,
   @cmdty4		          varchar(8) = null,
   @mkt4		            varchar(8) = null,
   @strike4		          float = null,
   @pc4			            char(1) = null,
   @trader4		          char(3) = null,
   @avgPrice4		        float = null,
   @totalFillQty4	      float = null,
   @portNum4		        int = null,
   @isHedgeInd4		      char(1) = null,
   @flrBrkr4		        int = null,
   @fillQty4		        float = null,
   @fillPrice4		      float = null,
   @fillPriceUom4	      varchar(4) = null,
   @fillPriceCurr4	    char(8) = null,
   @bsiFillNum4		      int = null
)
as
set nocount on
declare	@status int
declare	@orderTypeCode varchar(8)
declare	@itemType char(1)
declare	@strikeUom1 char(4)
declare	@strikeCurr1 char(4)
declare	@strikeUom2 char(4)
declare	@strikeCurr2 char(4)
declare	@strikeUom3 char(4)
declare	@strikeCurr3 char(4)
declare	@strikeUom4 char(4)
declare	@strikeCurr4 char(4)
declare	@bsi1 varchar(8)
declare	@bsi2 varchar(8)
declare	@bsi3 varchar(8)
declare	@bsi4 varchar(8)
declare	@fillNum int
declare @modDate datetime
declare @warning int

   select @modDate = getdate()
   select @warning = null

   /* find out if for the given portfolio's there is one bsi account */
   exec @status = dbo.quickfill_find_bsi @portNum1, @bsi1 output
   if (@status != 0) 
      return @status

   /* check to see if any of the necessary fields are null */
   if (@contrDate is null) or 
      (@itemNum1 is null) or 
      (@psInd1 is null) or
      (@qty1 is null) or 
      (@tp1 is null) or
      (@cmdty1 is null) or 
      (@mkt1 is null) or 
      (@trader1 is null) or 
      (@bsi1 is null) or 
      (@locNum is null)
      return -500

   /* find out orderTypeCode from given data. */
   if (@strike1 is null) and (@pc1 is null)
   begin
      select @orderTypeCode = 'FUTURE'
      select @itemType = 'F'
   end
   else
   begin
      select @orderTypeCode = 'EXCHGOPT'
      select @itemType = 'E'

      /* find the strike price uom and curr 
         code for all the items provided */
      execute dbo.quickfill_find_curr_uom @itemNum1,
                                          @cmdty1,
                                          @mkt1,
                                          @itemNum2,
                                          @cmdty2,
                                          @mkt2,
                                          @itemNum3,
                                          @cmdty3,
                                          @mkt3,
                                          @itemNum4,
                                          @cmdty4,
                                          @mkt4, 
                                          @strikeUom1 output,
                                          @strikeCurr1 output,
                                          @strikeUom2 output,
                                          @strikeCurr2 output, 
                                          @strikeUom3 output,
                                          @strikeCurr3 output,
                                          @strikeUom4 output,
                                          @strikeCurr4 output
   end

   /* check if there is a different item type for different items, 
      if there is flag error */
   if (@orderTypeCode = 'FUTURE')
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

   /*  don't do this for now check if the alias_source_codes exist 
   exec @status = dbo.quickfill_find_risc_alias @cmdty1, 
                                                @mkt1, 
                                                @orderTypeCode
   if (@status != 0)
      return @status
   */

   /* if itemNum2 exists check for valid data */
   if @itemNum2 is not null 
   begin
      exec @status = dbo.quickfill_find_bsi @portNum2, @bsi2 output
      if (@status != 0) 
         return @status

      /* don't do this for now
      exec @status = dbo.quickfill_find_risc_alias @cmdty2, @mkt2, @orderTypeCode
      if (@status != 0)
	       return @status
      */

      if (@psInd2 is null) or 
         (@qty2 is null) or 
         (@tp2 is null) or 
         (@cmdty2 is null) or 
         (@mkt2 is null) or
         (@trader2 is null) or 
         (@bsi2 is null)
	       return -501
   end

   /* if itemNum3 exists check for valid data */
   if @itemNum3 is not null 
   begin
      exec @status = dbo.quickfill_find_bsi @portNum3, @bsi3 output
      if (@status != 0) 
         return @status

      /* don't do this for now
      exec @status = dbo.quickfill_find_risc_alias @cmdty3, @mkt3, @orderTypeCode
      if (@status != 0)
         return @status
      */

      if (@psInd3 is null) or 
         (@qty3 is null) or 
         (@tp3 is null) or 
         (@cmdty3 is null) or 
         (@mkt3 is null) or
         (@trader3 is null) or 
         (@bsi3 is null)
	       return -502
   end

   /* if itemNum4 exists check for valid data */
   if @itemNum4 is not null 
   begin
      exec @status = dbo.quickfill_find_bsi @portNum4, @bsi4 output
      if (@status != 0) 
         return @status

      /* don't do this for now
      exec @status = dbo.quickfill_find_risc_alias @cmdty4, @mkt4, @orderTypeCode
      if (@status != 0)
         return @status
      */

      if (@psInd4 is null) or 
         (@qty4 is null) or 
         (@tp4 is null) or 
         (@cmdty4 is null) or 
         (@mkt4 is null) or
         (@trader4 is null) or 
         (@bsi4 is null)
	       return -503
   end

   select @fillNum = 1

   /* now that we have all the information, save trade */
   if (@cmntNum is not null) and (@comment is not null) 
   begin
      insert into dbo.pei_comment(cmnt_num,tiny_cmnt,trans_id)
          values(@cmntNum, @comment, @aTransId)
      if (@@rowcount != 1)
         return -585
   end

   exec @status = dbo.quickfill_add_trade_order @tradeNum,
                                                @trader1,
                                                @contrDate,
                                                @creationDate,
                                                @orderTypeCode,
                                                @orderPrice,
                                                @orderPriceCurrCode,
                                                @orderPoints,
                                                @orderInstrCode,
                                                @mfNum,
                                                @efpInd,
                                                @creatorInit,
                                                @aTransId

   if (@status = -504) or (@status = -505) or (@status = -506)
      return @status

   exec @status = dbo.quickfill_add_trade_item @tradeNum,
                                               1,	
                                               @itemNum1,
                                               @psInd1,
                                               @cmdty1,
                                               @mkt1,
                                               @mkt1, 
                                               @tp1,
                                               @qty1,
                                               @itemType,
                                               @orderPriceCurrCode,
                                               @orderPriceUomCode, 
                                               @avgPrice1,
                                               @totalFillQty1,
                                               @bsi1,
                                               @flrBrkr1,
                                               @clearingBrkr, 
                                               @pc1,
                                               @strike1,
                                               @strikeUom1,
                                               @strikeCurr1,
                                               @trader1,
                                               @creatorInit, 
                                               @portNum1,
                                               @isHedgeInd1,
                                               @contrDate,
                                               @cmntNum,
                                               @efpInd,
                                               @aTransId,
                                               @locNum

   if (@status < 0) and (@status != -582) and (@status != -583)
      return @status

   if (@status = -582) or (@status = -583)
      select @warning = @status

   if @fillQty1 is not null
   begin
      exec @status = dbo.quickfill_add_fill @tradeNum,
                                            1,
                                            @itemNum1,
                                            @fillNum,
                                            @fillQty1,
                                            'LOTS', 
                                            @fillPrice1,
                                            @fillPriceUom1,
                                            @fillPriceCurr1,
                                            @contrDate,
                                            @bsiFillNum1,
                                            @aTransId
      if (@status < 0)
         return @status
   end

   if @itemNum2 is not null
   begin
      exec @status = dbo.quickfill_add_trade_item @tradeNum,
                                                  1,
                                                  @itemNum2,
                                                  @psInd2,
                                                  @cmdty2,
                                                  @mkt2,
                                                  @mkt2, 
                                                  @tp2,
                                                  @qty2,
                                                  @itemType,
                                                  @fillPriceCurr2,
                                                  @fillPriceUom2, 
                                                  @avgPrice2,
                                                  @totalFillQty2,
                                                  @bsi2,
                                                  @flrBrkr2,
                                                  @clearingBrkr,	
                                                  @pc2,
                                                  @strike2,
                                                  @strikeUom2,
                                                  @strikeCurr2,
                                                  @trader2,
                                                  @creatorInit, 
                                                  @portNum2,
                                                  @isHedgeInd2,
                                                  @contrDate,
                                                  @cmntNum,
                                                  @efpInd,
                                                  @aTransId,
                                                  @locNum

      if (@status < 0) and (@status != -582) and (@status != -583)
         return @status

      if (@warning is null) and ((@status = -582) or (@status = -583))
         select @warning = @status
	
      if @fillQty2 is not null
      begin
         exec @status = dbo.quickfill_add_fill @tradeNum,
                                               1,
                                               @itemNum2,
                                               @fillNum,
                                               @fillQty2,
                                               'LOTS', 
                                               @fillPrice2,
                                               @fillPriceUom2,
                                               @fillPriceCurr2,
                                               @contrDate,
                                               @bsiFillNum2,
                                               @aTransId
         if (@status < 0)
            return @status
      end
   end

   if @itemNum3 is not null
   begin
      exec @status = dbo.quickfill_add_trade_item @tradeNum,
                                                  1,
                                                  @itemNum3,
                                                  @psInd3,
                                                  @cmdty3,
                                                  @mkt3,
                                                  @mkt3, 
                                                  @tp3,
                                                  @qty3,
                                                  @itemType,
                                                  @fillPriceCurr3,
                                                  @fillPriceUom3, 
                                                  @avgPrice3,
                                                  @totalFillQty3,
                                                  @bsi3,
                                                  @flrBrkr3,
                                                  @clearingBrkr, 
                                                  @pc3,
                                                  @strike3,
                                                  @strikeUom3,
                                                  @strikeCurr3,
                                                  @trader3,
                                                  @creatorInit,
                                                  @portNum3,
                                                  @isHedgeInd3,
                                                  @contrDate,
                                                  @cmntNum,
                                                  @efpInd,
                                                  @aTransId,
                                                  @locNum

      if (@status < 0) and (@status != -582) and (@status != -583)
         return @status

      if (@warning is null) and ((@status = -582) or (@status = -583))
         select @warning = @status
	
      if @fillQty3 is not null
      begin
         exec @status = dbo.quickfill_add_fill @tradeNum,
                                               1,
                                               @itemNum3,
                                               @fillNum,
                                               @fillQty3,
                                               'LOTS', 
                                               @fillPrice3,
                                               @fillPriceUom3,
                                               @fillPriceCurr3,
                                               @contrDate,
                                               @bsiFillNum3,
                                               @aTransId
         if @status = -510
            return @status
      end
   end

   if @itemNum4 is not null
   begin
      exec @status = dbo.quickfill_add_trade_item @tradeNum,
                                                  1,
                                                  @itemNum4,
                                                  @psInd4,
                                                  @cmdty4,
                                                  @mkt4,
                                                  @mkt4, 
                                                  @tp4,
                                                  @qty4,
                                                  @itemType,
                                                  @fillPriceCurr4,
                                                  @fillPriceUom4,
                                                  @avgPrice4,
                                                  @totalFillQty4,
                                                  @bsi4,
                                                  @flrBrkr4,
                                                  @clearingBrkr, 
                                                  @pc4,
                                                  @strike4,
                                                  @strikeUom4,
                                                  @strikeCurr4,
                                                  @trader4,
                                                  @creatorInit, 
                                                  @portNum4,
                                                  @isHedgeInd4,
                                                  @contrDate,
                                                  @cmntNum,
                                                  @efpInd,
                                                  @aTransId,
                                                  @locNum

      if (@status < 0) and (@status != -582) and (@status != -583)
         return @status

      if (@warning is null) and ((@status = -582) or (@status = -583))
         select @warning = @status
	
      if @fillQty4 is not null
      begin
         exec @status = dbo.quickfill_add_fill @tradeNum,
                                               1,
                                               @itemNum4,
                                               @fillNum,
                                               @fillQty4,
                                               'LOTS', 
                                               @fillPrice4,
                                               @fillPriceUom4,
                                               @fillPriceCurr4,
                                               @contrDate,
                                               @bsiFillNum4,
                                               @aTransId

         if @status = -510 
            return @status
      end
   end

   if (@warning is null)
      return @tradeNum
   else 
      return @warning
GO
GRANT EXECUTE ON  [dbo].[quickfill_add_trade] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'quickfill_add_trade', NULL, NULL
GO
