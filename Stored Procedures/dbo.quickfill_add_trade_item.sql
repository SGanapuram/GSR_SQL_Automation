SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[quickfill_add_trade_item] 
( 
   @tradeNum		    int = null,  
   @orderNum		    smallint = null,  
   @itemNum		      smallint = null,  
   @psInd		        char(1) = null,  
   @cmdtyCode		    varchar(8) = null,  
   @riskMktCode		  varchar(8) = null,  
   @titleMktCode	  varchar(8) = null,  
   @tp		          varchar(8) = null,  
   @qty			        float = null,  
   @itemType		    char(1) = null,  
   @priceCurrCode	  char(8) = null,  
   @priceUomCode	  varchar(4) = null,  
   @avgPrice		    float = null,  
   @totalFillQty	  float = null,  
   @bsiNum		      varchar(8) = null,  
   @brkrNum		      int = null,  
   @clearingBrkr	  int = null,  
   @putCallInd		  char(1) = null,  
   @strikePrice		  float = null,  
   @strikeUom		    char(4) = null,  
   @strikeCurr		  char(4) = null,  
   @traderInit		  char(3) = null,  
   @creatorInit		  char(3) = null,  
   @portNum		      int = null,  
   @isHedgeInd		  char(1) = null,  
   @contrDate		    varchar(15) = null,  
   @cmntNum		      int = null,  
   @efpInd		      char(1) = null,  
   @aTransId		    int = null,  
   @locNum		      int = null 
) 
as  
set nocount on
declare @formulaInd char(1)  
declare @strikePriceCurrCode char(4)  
declare @strikePriceUomCode char(4)  
declare @expZoneCode char(8)  
declare @status int  
declare @itemStatusCode varchar(8)  
declare @trdPrd varchar(8)  
  
   select @formulaInd = 'N'  
   if @locNum = 0  
      select @expZoneCode = 'NEW YORK'  
   else if @locNum = 1  
      select @expZoneCode = 'LONDON'  
   else if @locNum = 3  
      select @expZoneCode = 'SINGAPOR'  
  
   select @itemStatusCode = 'A'  
   if (@totalFillQty = null)  
      select @itemStatusCode = 'A'  
   else if (@qty > @totalFillQty)  
      select @itemStatusCode = 'I'  
   else if (@qty = @totalFillQty)  
      select @itemStatusCode = 'N'  
  
   /* check if we have a valid trading period */  
   exec @status = dbo.quickfill_validate_trdprd @cmdtyCode, 
                                                @riskMktCode, 
                                                @tp, 
                                                @itemType, 
                                                @contrDate, 
                                                @efpInd, 
                                                @trdPrd output  
   if (@status = -580) or (@status = -581)  
      return @status  
  
   if (@itemType = 'F')  
   begin  
      /* make sure that we are not saving an option */  
      if (@strikePrice is not null) or (@putCallInd is not null)  
         return -588  
  
      insert into dbo.trade_item   
           (trade_num, order_num, item_num, item_status_code,  
            p_s_ind, booking_comp_num, cmdty_code, risk_mkt_code,  
            title_mkt_code, trading_prd, contr_qty, contr_qty_uom_code,  
            item_type, formula_ind, priced_qty_uom_code, avg_price,  
            price_curr_code, price_uom_code, idms_acct_alloc, brkr_num,  
            fut_trader_init, real_port_num, hedge_pos_ind, cmnt_num, trans_id)  
	      values (@tradeNum,  
			          @orderNum,  
			          @itemNum,  
			          @itemStatusCode,  
			          @psInd,  
			          24,   
			          @cmdtyCode,  
			          @riskMktCode,  
			          @titleMktCode,  
			          @trdPrd,  
			          @qty,   
			          'LOTS',  
                @itemType,  
                @formulaInd,   
                'LOTS',  
			          @avgPrice,  
			          @priceCurrCode,  
			          @priceUomCode,  
			          @bsiNum,  
                @brkrNum,		/* brkrnum */  
                @traderInit,  
                @portNum,  
                @isHedgeInd,  
                @cmntNum,  
                @aTransId)   
  
      if @@rowcount = 0  
	       return -507  
  
      insert into dbo.trade_item_fut  
	        (trade_num, order_num, item_num, settlement_type,  
           fut_price, fut_price_curr_code, total_fill_qty,  
           fill_qty_uom_code, avg_fill_price, clr_brkr_num, trans_id)  
       values (@tradeNum,  
               @orderNum,  
               @itemNum,  
               'P',  
	             NULL,		/* futprice */  
               NULL,		/* futpricecurrcode */  
               @totalFillQty,	/* totalfillqty */  
               'LOTS',		/* fillqtyuomcode */  
               @avgPrice,	/* avgfillprice */  
               @clearingBrkr,  
               @aTransId)  
  
	    if @@rowcount = 0  
		     return -508  		  
   end  /* end if (@itemType ... */  
   else 
   begin  
      /* make sure we have both strike and put call indicator. */  
      if (@strikePrice is null) or (@putCallInd is null)  
         return -588  
  
      /* creating option related information */  
      insert into dbo.trade_item   
	          (trade_num, order_num, item_num, item_status_code, p_s_ind,  
             booking_comp_num, cmdty_code, risk_mkt_code, title_mkt_code,  
             trading_prd, contr_qty, contr_qty_uom_code, item_type, formula_ind,  
	           priced_qty_uom_code, avg_price, price_curr_code, price_uom_code,  
             idms_acct_alloc, brkr_num, fut_trader_init, real_port_num, cmnt_num, trans_id)  
	     values (@tradeNum,  
		           @orderNum,  
		           @itemNum,  
		           @itemStatusCode,  
		           @psInd,  
		           24,  
		           @cmdtyCode,  
		           @riskMktCode,  
		           @titleMktCode,  
		           @trdPrd,  
		           @qty,   
	             'LOTS',  
               @itemType,  
               @formulaInd,   
               'LOTS',  
               @avgPrice,  
               @priceCurrCode,  
               @priceUomCode,  
               @bsiNum,  
               @brkrNum,  
               @traderInit,  
               @portNum,  
               @cmntNum,  
               @aTransId)   
  
      if @@rowcount = 0  
         return -507  
  
      declare @commkt_key int  
      declare @expdate datetime  
  
      select @commkt_key = commkt_key  
      from dbo.commodity_market  
      where mkt_code = @riskMktCode and  
            cmdty_code = @cmdtyCode  
  
      select @expdate = opt_exp_date  
      from dbo.trading_period  
      where commkt_key = @commkt_key and  
            trading_prd = @trdPrd  
  
      if not @@rowcount = 1  
         select @expdate = null  
  
      insert into dbo.trade_item_exch_opt   
           (trade_num, order_num, item_num, put_call_ind, strike_price,  
            strike_price_uom_code, strike_price_curr_code, exp_date, exp_zone_code,  
            total_fill_qty, fill_qty_uom_code, avg_fill_price, clr_brkr_num, trans_id)  
	     values (@tradeNum,  
		           @orderNum,  
		           @itemNum,  
		           @putCallInd,  
		           @strikePrice,  
		           @strikeUom,   
               @strikeCurr,  
               @expdate,  
               @expZoneCode,  
               @totalFillQty,  
               'LOTS',  
               @avgPrice,   
               @clearingBrkr,  
               @aTransId)  
  
      if @@rowcount = 0  
         return -509  
   end   
   return @status  
GO
GRANT EXECUTE ON  [dbo].[quickfill_add_trade_item] TO [next_usr]
GO
