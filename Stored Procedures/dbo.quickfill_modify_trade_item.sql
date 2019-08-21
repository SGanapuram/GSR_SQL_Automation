SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[quickfill_modify_trade_item]
(
   @tradeNum           int = null,
   @orderNum           int = null,
   @itemNum            smallint = null,
   @psInd              char(1) = null,
   @qty                float = null,
   @tp                 varchar(8) = null,
   @cmdty              varchar(8) = null,
   @mkt                varchar(8) = null,
   @strike             float = null,
   @pc                 char(1) = null,
   @trader             char(3) = null,
   @avgPrice           float = null,
   @totalFillQty       float = null,
   @priceCurr          char(8) = null,
   @priceUom           varchar(4) = null,
   @portNum            int = null,
   @isHedgeInd         char(1) = null,
   @tradeModInit       char(3) = null,
   @contractDate       varchar(15) = null,
   @orderBroker        int = null,   
   @clearingBrkr       int = null,
   @modificationDate   datetime = null,
   @locNum             int = null,
   @isNewTradeItem     char(1) = null,
   @itemTransId        int = null,
   @futOptTransId      int = null,
   @cmntNum            int = null,
   @efpInd             char(1) = null,
   @aTransId           int = null
)
as
set nocount on
declare @orderTypeCode char(8)
declare @status int
declare @bbrefNum int
declare	@bsi varchar(8)
declare @itemStatusCode varchar(8)
declare @trdPrd varchar(8)
declare @temp char(1)
declare @warning int

   select @orderTypeCode = null
   select @warning = null

   if (@itemNum is null)
      return 0

   select @orderTypeCode = order_type_code 
   from dbo.trade_order 
   where trade_num = @tradeNum and 
         order_num = @orderNum

   /* make sure that we are not trying to save an option for 
      a FUTURE or a future for an EXCHGOPT */
   if (@orderTypeCode = 'FUTURE') 
   begin
      if (@strike is not null) or (@pc is not null)
         return -588
   end
   else 
      if (@strike is null) or (@pc is null)
	       return -588

   /* find item's item_status_code */
   if (@totalFillQty = 0) or (@totalFillQty is null)
      select @itemStatusCode = 'A'
   else if (@qty > @totalFillQty)
      select @itemStatusCode = 'I'
   else if (@qty = @totalFillQty)
      select @itemStatusCode = 'N'

   /* check if we have a valid trading period */
   select @temp = substring(@orderTypeCode,1,1)
   exec @status = dbo.quickfill_validate_trdprd @cmdty, @mkt, @tp, @temp, 
                                                @contractDate, @efpInd, @trdPrd output
   if (@status = -580) or (@status =-581)
      return @status

   if (@status < 0)
      select @warning = @status

   /* if it is a future do one set of things, if option, another set */
   if (@orderTypeCode = 'FUTURE') 
   begin
      exec @status = dbo.quickfill_find_bsi @portNum, @bsi output
      if (@status != 0) 
         return @status
	
      /* don't do this for now
      exec @status = dbo.quickfill_find_risc_alias @cmdty, @mkt, @orderTypeCode
      if (@status != 0) 
         return @status
      */

      if (@isNewTradeItem = 'N') 
      begin
         /* update trade_item and trade_item_fut */
         update dbo.trade_item 
         set p_s_ind = @psInd,
             cmdty_code = @cmdty,
             risk_mkt_code = @mkt,
             title_mkt_code = @mkt,
             trading_prd = @trdPrd,
             contr_qty = @qty,
             contr_qty_uom_code = 'LOTS',
             avg_price = @avgPrice,
             price_curr_code = @priceCurr,
             price_uom_code = @priceUom,
             brkr_num = @orderBroker,
             real_port_num = @portNum,
             hedge_pos_ind = @isHedgeInd,
             idms_acct_alloc = @bsi,
             item_status_code = @itemStatusCode,
             trans_id = @aTransId,
             cmnt_num = @cmntNum
         where trade_num = @tradeNum and
               order_num = @orderNum and
               item_num = @itemNum and
               trans_id = @itemTransId
	
         if (@@rowcount != 1)
            return -525
	
         update dbo.trade_item_fut 
         set fut_price_curr_code = @priceCurr,
             total_fill_qty = @totalFillQty,
             fill_qty_uom_code = 'LOTS',
             avg_fill_price = @avgPrice,
             clr_brkr_num = convert(int,@clearingBrkr),
             trans_id = @aTransId
         where trade_num = @tradeNum and
               order_num = @orderNum and
               item_num = @itemNum and
               trans_id = @futOptTransId	
         if (@@rowcount != 1)
            return -526
      end 
      else 
      begin
	       exec @status = dbo.quickfill_add_trade_item @tradeNum,
                                                     @orderNum,	
                                                     @itemNum,
                                                     @psInd,
                                                     @cmdty,
                                                     @mkt,
                                                     @mkt, 
                                                     @tp,
                                                     @qty,
                                                     'F',
                                                     @priceCurr,
                                                     @priceUom, 
                                                     @avgPrice,
                                                     @totalFillQty,
                                                     @bsi,
                                                     @orderBroker,
                                                     @clearingBrkr, 
                                                     null,
                                                     null,
                                                     null,
                                                     null,
                                                     @trader,
                                                     @tradeModInit, 
                                                     @portNum,
                                                     @isHedgeInd,
                                                     @contractDate,
                                                     @cmntNum,
                                                     @efpInd,
                                                     @aTransId,
                                                     @locNum
	
	       if (@status = -507) or (@status = -508) or (@status = -509) or 
            (@status = 513) or (@status = 514) or (@status = -515) or 
            (@status = -516) or (@status = -517) or (@status = -518) or 
            (@status = -519) or (@status = -520) or (@status = -521) or 
            (@status = -522) or (@status = -523) or (@status = -524)
         begin
            rollback tran
            return @status
	       end 

	       if (@status = -582) or (@status = -583) and (@warning is null)
            select @warning = @status
      end
   end /* if (@orderTypeCode */
   else if (@orderTypeCode = 'EXCHGOPT') 
   begin
      exec @status = dbo.quickfill_find_bsi @portNum, @bsi output
      if (@status != 0) 
         return @status
	
      if (@isNewTradeItem = 'N') 
      begin
         /* update trade_item and trade_item_fut */
	       update dbo.trade_item 
         set p_s_ind = @psInd,
             cmdty_code = @cmdty,
             risk_mkt_code = @mkt,
             title_mkt_code = @mkt,
             trading_prd = @trdPrd,
             contr_qty = @qty,
             contr_qty_uom_code = 'LOTS',
             avg_price = @avgPrice,
             price_curr_code = @priceCurr,
             price_uom_code = @priceUom,
             brkr_num = @orderBroker,
             real_port_num = @portNum,
             hedge_pos_ind = @isHedgeInd,
             idms_acct_alloc = @bsi,
             trans_id = @aTransId,
             item_status_code = @itemStatusCode,
             cmnt_num = @cmntNum
         where trade_num = @tradeNum and
               order_num = @orderNum and
               item_num = @itemNum and
               trans_id = @itemTransId
         if (@@rowcount != 1)
            return -525
	
         update dbo.trade_item_exch_opt 
         set put_call_ind = @pc,
             strike_price = @strike,
             strike_price_uom_code = @priceUom,
             strike_price_curr_code = @priceCurr,
             total_fill_qty = @totalFillQty,
             fill_qty_uom_code = 'LOTS',
             avg_fill_price = @avgPrice,
             clr_brkr_num = convert(int,@clearingBrkr),
             trans_id = @aTransId
         where trade_num = @tradeNum and
               order_num = @orderNum and
               item_num = @itemNum and 
               trans_id = @futOptTransId
         if (@@rowcount != 1)
            return -529
      end 
      else 
      begin
         exec @status = dbo.quickfill_add_trade_item @tradeNum,
                                                     @orderNum,	
                                                     @itemNum,
                                                     @psInd,
                                                     @cmdty,
                                                     @mkt,
                                                     @mkt, 
                                                     @tp,
                                                     @qty,
                                                     'E',
                                                     @priceCurr,
                                                     @priceUom, 
                                                     @avgPrice,
                                                     @totalFillQty,
                                                     @bsi,
                                                     @orderBroker,
                                                     @clearingBrkr, 
                                                     @pc,
                                                     @strike,
                                                     @priceCurr,
                                                     @priceUom,
                                                     @trader,
                                                     @tradeModInit, 
                                                     @portNum,
                                                     @isHedgeInd,
                                                     @contractDate,
                                                     @cmntNum,
                                                     @efpInd,
                                                     @aTransId,
                                                     @locNum

	
         if (@status = -507) or (@status = -508) or (@status = -509) or 
            (@status = 513) or (@status = 514) or (@status = -515) or 
            (@status = -516) or (@status = -517) or (@status = -518) or 
            (@status = -519) or (@status = -520) or (@status = -521) or 
            (@status = -522) or (@status = -523) or (@status = -524)
         begin
            rollback tran
            return @status
         end 
         if (@status = -582) or (@status = -583) and (@warning is null)
	          select @warning = @status
      end
   end /* end if order type is an option */
   if (@warning is null)
      return 0
   else 
      return @warning
GO
GRANT EXECUTE ON  [dbo].[quickfill_modify_trade_item] TO [next_usr]
GO
