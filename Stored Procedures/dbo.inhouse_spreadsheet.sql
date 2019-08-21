SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[inhouse_spreadsheet] 
(
   @tradeNum		      int = null,
   @contrDate		      varchar(15) = null,
   @locNum		        int = null,
   @creatorInit		    char(3) = null,
   @masterLocNum	    int = null,
   @creationDate	    varchar(40) = null,
   @comment		        varchar(15) = null,
   @cmntNum		        int = null,
   @ztradeInd		      char(1) = null,
   @inhouseType		    char(1) = null,
   @trader		        char(3) = null,
   @portNum		        int = null,
   @isHedgeInd		    char(1) = null,
   @psInd1		        char(1) = null,
   @qty1		          float = null,
   @tp1			          varchar(8) = null,
   @commktAlias		    varchar(8) = null,
   @strike1		        float = null,
   @pc1			          char(1) = null,
   @avgPrice1		      float = null,
   @trader1		        char(3) = null,
   @portNum1		      int = null,
   @isHedgeInd1		    char(1) = null,
   @fromDeliveryDate	varchar(10) = null,
   @toDeliveryDate	  varchar(10) = null,
   @bsiFillNum1		    int = null,
   @aTransId		      int = null
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
declare @trdPrd varchar(8)
declare @expZoneCode char(8)
declare @temp varchar(15)
declare @warning int
declare @cmdty1 varchar(8)
declare @mkt1 varchar(8)
declare @commktKey int
declare @priceCurr1	char(4)
declare @priceUom1 char(4)

   select @warning = null
   if (@ztradeInd = 'N') and ((@portNum is null) or (@portNum1 is null))
      return -700
   else if (@ztradeInd = 'Y') and ((@portNum is null) and (@portNum1 is null))
      return -729

   select @bsi1 = null

   /* find out if for the given portfolio's there is one bsi account */
   if ((@inhouseType = 'F') or (@inhouseType = 'O')) and 
      (@portNum1 is not null) 
   begin
      exec @status = dbo.quickfill_find_bsi @portNum1, @bsi1 output
      if (@status != 0) and (@status != -583)
         return @status
   end

   /* since a commodity market alias is given, look for the 
      commodity and market */
   select @cmdty1 = null
   select @mkt1 = null
   select @commktKey = null
   select @priceCurr1 = null
   select @priceUom1 = null

   if (@commktAlias is not null) 
   begin
      /* look in commkt alias table for a match */
      select @commktKey = commkt_key 
      from dbo.commodity_market_alias 
      where alias_source_code = 'QF_TPS' and 
            commkt_alias_name = @commktAlias

      if (@commktKey is null)
         return -732

      /** now find the commodity market **/
      select @cmdty1 = cmdty_code, 
             @mkt1 = mkt_code 
      from dbo.commodity_market 
      where commkt_key = @commktKey

      /** price curr and uom ***/
      if @inhouseType = 'F' 
      begin
         select @priceCurr1 = commkt_curr_code, 
                @priceUom1 = commkt_price_uom_code 
         from dbo.commkt_future_attr 
         where commkt_key = @commktKey
         
         if (@priceCurr1 is null) or (@priceUom1 is null)
	          return -736
      end
      else if @inhouseType = 'O' 
      begin
         select @priceCurr1 = commkt_curr_code, 
                @priceUom1 = commkt_price_uom_code 
         from dbo.commkt_option_attr 
         where commkt_key = @commktKey

	       if (@priceCurr1 is null) or (@priceUom1 is null)
            return -736
      end
      else if @inhouseType = 'P' 
      begin
         select @priceCurr1 = commkt_curr_code, 
                @priceUom1 = commkt_price_uom_code 
         from dbo.commkt_future_attr 
         where commkt_key = @commktKey

         if (@priceCurr1 is null) or (@priceUom1 is null)
            select @priceCurr1 = commkt_curr_code, 
                   @priceUom1 = commkt_price_uom_code 
            from dbo.commkt_future_attr 
            where commkt_key = @commktKey
         
         if (@priceCurr1 is null) or (@priceUom1 is null)
            return -736
      end
   end

   /* check to see if any of the necessary fields are null */
   if (@contrDate is null) or 
      (@psInd1 is null) or
      (@qty1 is null) or 
      (@tp1 is null) or
      (@cmdty1 is null) or 
      (@mkt1 is null) or 
      (@locNum is null)
      return -701

   /* find out orderTypeCode from given data. */
   if (@inhouseType = 'F')
   begin
      select @orderTypeCode = 'FUTURE'
      select @itemType = 'F'
   end
   else if (@inhouseType = 'O')
   begin
      select @orderTypeCode = 'EXCHGOPT'
      select @itemType = 'E'

      /* find the strike price uom and curr code for all the items provided */
      exec dbo.quickfill_find_curr_uom 1,
                                       @cmdty1,
                                       @mkt1,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null, 
                                       @strikeUom1 output,
                                       @strikeCurr1 output,
                                       @strikeUom2 output,
                                       @strikeCurr2 output, 
                                       @strikeUom3 output,
                                       @strikeCurr3 output,
                                       @strikeUom4 output,
                                       @strikeCurr4 output

      if @masterLocNum = 0
         select @expZoneCode = 'NEW YORK'
      else if @masterLocNum = 1
         select @expZoneCode = 'LONDON'
      else if @masterLocNum = 3
         select @expZoneCode = 'SINGAPOR'
   end
   else 
   begin
      select @orderTypeCode = 'PHYSICAL'
      select @itemType = 'W'
   end

   /* check if the alias_source_codes exist for all futures 
      and options trades */
   if (@inhouseType != 'P') and (@ztradeInd = 'N') 
   begin
      /* check if 'BSI' alias exists */
      select @temp = commkt_alias_name 
      from dbo.commodity_market_alias 
      where alias_source_code = 'BSI' and 
	    commkt_key = (select commkt_key 
                    from dbo.commodity_market 
                    where cmdty_code = @cmdty1 and 
                          mkt_code = @mkt1)	
      if (@@rowcount = 0)
         return -731

      /* don't need this now
      exec @status = dbo.quickfill_find_risc_alias @cmdty1, @mkt1, @orderTypeCode
      if (@status != 0)
         return @status
      */
   end

   /* check if QF_TPS alias exists for all trades */
   select @temp = commkt_alias_name 
   from dbo.commodity_market_alias 
   where alias_source_code = 'QF_TPS' and 
         commkt_key = (select commkt_key 
                       from dbo.commodity_market 
                       where cmdty_code = @cmdty1 and 
                             mkt_code = @mkt1)
   if (@@rowcount = 0)
      return -732

   /* now that we have all the information, save trade */
   if (@cmntNum is not null) and (@comment is not null) 
   begin
      insert into dbo.pei_comment
          (cmnt_num, tiny_cmnt, trans_id)
       values(@cmntNum, @comment, @aTransId)
      if (@@rowcount != 1)
         return -585
   end

   insert into dbo.trade_sync
        (trade_num,trade_sync_inds,trans_id)
    values(@tradeNum, '0000---X', @aTransId)

   insert into dbo.trade 
        (trade_num, trader_init, trade_status_code, conclusion_type,
         inhouse_ind, contr_date, contr_tlx_hold_ind, creation_date,
         creator_init, port_num, trans_id)
     values (@tradeNum, @trader, 'UNALLOC', 'C', 'Y', @contrDate,
             'Y', @creationDate, @creatorInit, @portNum, @aTransId) 
   if @@rowcount = 0
      return -702

   insert into dbo.trade_order 
        (trade_num, order_num, order_type_code,order_strategy_name,
         order_status_code,bal_ind,strip_summary_ind,trans_id)
     values (@tradeNum, 1, @orderTypeCode, replicate(' ',13) + @ztradeInd,
             NULL, 'N', 'N', @aTransId)
   if @@rowcount = 0
      return -703

   insert into dbo.trade_order_on_exch 
        (trade_num, order_num, order_price, order_price_curr_code,trans_id)
     values(@tradeNum,1,@avgPrice1,@priceCurr1,@aTransId)

   if @@rowcount = 0
      return -733

   if (@inhouseType = 'F') or (@inhouseType = 'O') 
   begin
      /* check if we have a valid trading period */
      exec @status = dbo.inhouse_validate_trdprd @cmdty1, 
                                                 @mkt1, 
                                                 @tp1, 
                                                 @itemType, 
                                                 @contrDate, 
                                                 @trdPrd output
      if (@status < 0) and (@status != -583)
         return @status

      if (@status < 0)
         select @warning = @status
   end
   else 
   begin
      /* if it's a physical trade, no need to validate, just get trading period */
      select @trdPrd = null
      select @trdPrd = trading_prd 
      from dbo.trading_period 
      where trading_prd_desc = @tp1 and 
            commkt_key = (select commkt_key 
                          from dbo.commodity_market 
                          where cmdty_code = @cmdty1 and 
                                mkt_code = @mkt1)
      if (@trdPrd is null)
         return -581
   end

   if (@itemType = 'F')
   begin
      insert into dbo.trade_item 
       (trade_num, order_num, item_num, item_status_code,
        p_s_ind, booking_comp_num, cmdty_code, risk_mkt_code,
        title_mkt_code, trading_prd, contr_qty, contr_qty_uom_code,
        item_type, formula_ind, priced_qty_uom_code, avg_price,
        price_curr_code, price_uom_code, idms_acct_alloc, fut_trader_init,
        real_port_num, hedge_pos_ind, cmnt_num, trans_id)
      values (@tradeNum,
              1,
              1,
              'N',   /** completely filled **/
              @psInd1,
              24, 
              @cmdty1,
              @mkt1,
              @mkt1,
              @trdPrd,
              @qty1, 
              'LOTS',
              @itemType,
              'N', 
              'LOTS',
              @avgPrice1,
              @priceCurr1,
              @priceUom1,
              @bsi1,
              @trader1,
              @portNum1,
              @isHedgeInd1,
              @cmntNum,
              @aTransId) 
	
      if @@rowcount = 0
         return -704
	
      insert into dbo.trade_item_fut
        (trade_num, order_num, item_num, settlement_type,
         fut_price, fut_price_curr_code, total_fill_qty,
         fill_qty_uom_code, avg_fill_price, trans_id)
       values(@tradeNum,
              1,
              1,
              'P',
              NULL,		/* futprice */
              NULL,		/* futpricecurrcode */
              @qty1,		/* totalfillqty */
              'LOTS',		/* fillqtyuomcode */
              @avgPrice1,	/* avgfillprice */
              @aTransId)
	
      if @@rowcount = 0
         return -705		
   end  /* end if (@itemType ... */
   else if (@orderTypeCode = 'EXCHGOPT') 
   begin
      /* creating option related information */
      insert into dbo.trade_item 
           (trade_num, order_num, item_num, item_status_code,
            p_s_ind, booking_comp_num, cmdty_code, risk_mkt_code,
            title_mkt_code, trading_prd, contr_qty, contr_qty_uom_code,
            item_type, formula_ind, priced_qty_uom_code, avg_price,
            price_curr_code, price_uom_code, idms_acct_alloc, fut_trader_init,
            real_port_num, hedge_pos_ind, cmnt_num, trans_id)
	      values (@tradeNum,
                1,
                1,
                'N',   /* completely filled */
                @psInd1,
                24,
                @cmdty1,
                @mkt1,
                @mkt1,
                @trdPrd,
                @qty1, 
                'LOTS',
                @itemType,
                'N', 
                'LOTS',
                @avgPrice1,
                @priceCurr1,
                @priceUom1,
                @bsi1,
                @trader1,
                @portNum1,
                @isHedgeInd1,
                @cmntNum,
                @aTransId) 
	
      if @@rowcount = 0
         return -704
	
      insert into dbo.trade_item_exch_opt 
         (trade_num, order_num, item_num, put_call_ind,
          strike_price, strike_price_uom_code, strike_price_curr_code,
          exp_zone_code, total_fill_qty, fill_qty_uom_code,
          avg_fill_price, trans_id)
       values (@tradeNum,
               1,
               1,
               @pc1,
               @strike1,
               @strikeUom1, 
               @strikeCurr1,
               @expZoneCode,
               @qty1,
               'LOTS',
               @avgPrice1, 
               @aTransId)
	
      if @@rowcount = 0
         return -706
   end
   else if (@orderTypeCode = 'PHYSICAL') 
   begin
      insert into dbo.trade_item 
        (trade_num, order_num, item_num, item_status_code, p_s_ind,
         booking_comp_num, cmdty_code, risk_mkt_code, title_mkt_code,
         trading_prd, contr_qty, contr_qty_uom_code, item_type,
         formula_ind, priced_qty_uom_code, avg_price, price_curr_code,
         price_uom_code, real_port_num, hedge_pos_ind, cmnt_num, trans_id)
       values (@tradeNum,
               1,
               1,
               'N',   /** completely filled **/
               @psInd1,
               24, 
               @cmdty1,
               @mkt1,
               @mkt1,
               @trdPrd,
               @qty1, 
               'LOTS',
               @itemType,
               'N', 
               'LOTS',
               @avgPrice1,
               @priceCurr1,
               @priceUom1,
               @portNum1,
               @isHedgeInd1,
               @cmntNum,
               @aTransId) 
	
      if @@rowcount = 0
         return -704

      insert into dbo.trade_item_wet_phy 
        (trade_num, order_num, item_num,
         del_date_from, del_date_to, trans_id)
       values (@tradeNum,
               1,
               1,
               @fromDeliveryDate,
               @toDeliveryDate,
               @aTransId)

      if @@rowcount = 0
         return -724		
   end 
	
   insert into dbo.trade_item_fill
     (trade_num, order_num, item_num, item_fill_num,
      fill_qty, fill_qty_uom_code, fill_price,
      fill_price_curr_code, fill_price_uom_code, fill_status,
      fill_date, bsi_fill_num, trans_id)
    values (@tradeNum,
            1,
            1,
            1,
            @qty1,
            'LOTS',
            @avgPrice1,
            @priceCurr1,
            @priceUom1,
            NULL,
            @contrDate,
            @bsiFillNum1,
            @aTransId)
	
   if @@rowcount = 0
      return -707

   if (@warning is null)
      return @tradeNum
   else 
      return @warning
GO
GRANT EXECUTE ON  [dbo].[inhouse_spreadsheet] TO [next_usr]
GO
