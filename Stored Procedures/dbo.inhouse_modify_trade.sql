SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[inhouse_modify_trade] 
( 
   @tradeNum             int = null,  
   @contrDate            varchar(30) = null,  
   @locNum               int = null,  
   @creatorInit          char(3) = null,  
   @masterLocNum         int = null,  
   @comment              varchar(15) = null,  
   @cmntNum              int = null,  
   @ztradeInd            char(1) = null,  
   @inhouseType          char(1) = null,  
   @trader               char(3) = null,  
   @portNum              int = null,  
   @isHedgeInd           char(1) = null,  
   @psInd1               char(1) = null,  
   @qty1                 float = null,  
   @tp1                  varchar(8) = null,  
   @cmdty1               varchar(8) = null,  
   @mkt1                 varchar(8) = null,  
   @strike1              float = null,  
   @pc1                  char(1) = null,  
   @avgPrice1            float = null,  
   @priceCurr1           char(4) = null,  
   @priceUom1            char(4) = null,  
   @trader1              char(3) = null,  
   @portNum1             int = null,  
   @isHedgeInd1          char(1) = null,  
   @fromDeliveryDate     varchar(10) = null,  
   @toDeliveryDate       varchar(10) = null,  
   @itemTransId          int = null,  
   @futOptPhyTransId     int = null,  
   @fillTransId          int = null,  
   @tradeTransId         int = null,  
   @tradeModInit         char(3) = null,  
   @orderTransId         int = null,  
   @syncTransId          int = null,  
   @newTradeModDate      varchar(30) = null,  
   @aTransId             int = null     
)
as  
set nocount on
declare	@status int  
declare	@itemType char(1)  
declare	@creationDate datetime  
declare @modificationDate datetime   
declare @sqlString varchar(255)  
declare @oldModDate datetime  
declare @deleteCount int  
declare @deletionCount int  
declare @deleteTrade char(1)  
declare @orderTypeCode char(8)  
declare @oldOrderTypeCode char(8)  
declare @trdPrd varchar(8)  
declare @bsi1 varchar(8)  
declare @oldZTradeInd char(15)  
declare @temp varchar(15)  
declare @warning int  
declare @oldTransId int  
  
   select @warning = null  
   /* check to make sure that the trade has not been modified 
      before trying to update/delete anything  */  
  
   select @oldTransId = trans_id 
   from dbo.trade 
   where trade_num = @tradeNum  
   if (@oldTransId != @tradeTransId)  
      return -708  
  
   select @modificationDate = getdate()  
   select @sqlString = null  
  
   if (@inhouseType = 'F') 
   begin  
      select @orderTypeCode = 'FUTURE'  
      select @itemType = 'F'  
   end  
   else if (@inhouseType = 'O') 
   begin  
      select @orderTypeCode = 'EXCHGOPT'  
      select @itemType = 'E'  
   end  
   else 
   begin  
      select @orderTypeCode = 'PHYSICAL'  
      select @itemType = 'P'  
   end  
  
   /* check if the trade type or z-trade indicator was changed.  If it wasa return error.  This   
	    restriction is imposed because of TDN number conflicts.  If trade A was entered as a Future trade,   
	    it is given a bsi number eg.10  When this is changed to a Physical, since the physicals are not  
	    fed to RISC, a delete for bsi number 10 must be issued.  Since we don;t have that level of  
	    sophistication in the database for create_risc_file to handle these cases, changing trade types or  
	    z-trade indicator is prevented */  
  
   select @oldOrderTypeCode = order_type_code, 
          @oldZTradeInd = order_strategy_name 
   from dbo.trade_order 
   where trade_num = @tradeNum and 
         order_num = 1  
  
   if ((@oldOrderTypeCode = 'FUTURE') and ((@inhouseType = 'O') 
       or (@inhouseType = 'P'))) or ((@oldOrderTypeCode = 'PHYSICAL') and 
      ((@inhouseType = 'O') or (@inhouseType = 'F'))) or 
      ((@oldOrderTypeCode = 'EXCHGOPT') and ((@inhouseType = 'F') or 
      (@inhouseType = 'P')))  
      return -728  
  
   if (substring(@oldZTradeInd,14,1) != @ztradeInd)   
      return -730  
  
   if (@inhouseType = 'F') or (@inhouseType = 'O') 
   begin  
      /* check if 'BSI' alias exists  */  
      select @temp = commkt_alias_name 
      from dbo.commodity_market_alias 
      where alias_source_code = 'BSI' and   
	          commkt_key = (select commkt_key 
                          from dbo.commodity_market 
                          where cmdty_code = @cmdty1 and mkt_code = @mkt1)	  
      if (@@rowcount = 0)  
         return -731  
  
      /* check if we have a valid trading period, if month is tradable and 
         there is a trading period */  
      exec @status = dbo.inhouse_validate_trdprd @cmdty1, @mkt1, @tp1, @itemType, @contrDate, @trdPrd output  
      if (@status != 0) and (@status != -583)  
         return @status  
  
      if (@status = -583)  
         select @warning = @status  
   end  
   else 
   begin  
      select @trdPrd = null  
      /* if it's a physical trade, no need to validate, just get trading period */  
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
  
   /* check if QF_TPS alias exists for all trades */  
   /* don't need to do this for now  
   select @temp = commkt_alias_name 
   from dbo.commodity_market_alias 
   where alias_source_code = 'QF_TPS' and 
         commkt_key = (select commkt_key 
                       from dbo.commodity_market 
                       where cmdty_code = @cmdty1 and mkt_code = @mkt1)  
   if (@@rowcount = 0)  
      return -732  
   */  
  
   /* update trade - has to be done for any change to trade */  
   update dbo.trade_sync 
   set trade_sync_inds = '0000---X',  
       trans_id = @aTransId  
   where trade_num = @tradeNum and  
         trans_id = @syncTransId  
  
   if (@@rowcount != 1)  
      return -801  
  
   update dbo.trade 
   set trader_init = @trader1,  
       contr_date = @contrDate,  
       creator_init = @creatorInit,  
       trade_mod_date = @newTradeModDate,  
       trade_mod_init = @tradeModInit,  
       port_num = @portNum,  
       /* is_hedge_ind = @isHedgeInd, */  
       trans_id = @aTransId  
   where trade_num = @tradeNum and  
         trans_id = @tradeTransId  
   if (@@rowcount != 1)   
      return -709  
  
   /* update trade_order_on_exch since futcap reads from it */  
   update dbo.trade_order_on_exch 
   set order_price = @avgPrice1,  
       order_price_curr_code = @priceCurr1,  
       trans_id = @aTransId  
   where trade_num = @tradeNum  
   if (@@rowcount != 1)  
      return -735  
  
   /* update pei_comment if exists */  
   if (@cmntNum is not null) 
   begin  
      select @status = cmnt_num 
      from dbo.pei_comment 
      where cmnt_num = @cmntNum  
      if (@@rowcount = 0) 
      begin  
         insert into dbo.pei_comment(cmnt_num, tiny_cmnt, trans_id)  
           values (@cmntNum, @comment, @aTransId)  
         if (@@rowcount != 1)  
            return -585  
      end  
      else 
      begin  
         update dbo.pei_comment 
         set tiny_cmnt = @comment,  
             trans_id = @aTransId  
         where cmnt_num = @cmntNum  
         if (@@rowcount != 1)  
            return -586  
      end  
   end  
  
   if (@orderTypeCode = 'FUTURE') 
   begin    
      select @bsi1 = null  
      if (@portNum1 is not null) 
      begin  
         exec @status = dbo.quickfill_find_bsi @portNum1, @bsi1 output  
         if (@status != 0)   
            return @status  
      end  
	  
      /* don't need to do this for now  
      exec @status = dbo.quickfill_find_risc_alias @cmdty1, @mkt1, @orderTypeCode  
      if (@status != 0)   
         return @status  
      */  
  
      update dbo.trade_item 
      set p_s_ind = @psInd1,  
          cmdty_code = @cmdty1,  
          risk_mkt_code = @mkt1,  
          title_mkt_code = @mkt1,  
          trading_prd = @trdPrd,  
          contr_qty = @qty1,  
          contr_qty_uom_code = 'LOTS',  
          avg_price = @avgPrice1,  
          price_curr_code = @priceCurr1,  
          price_uom_code = @priceUom1,  
          real_port_num = @portNum1,  
          hedge_pos_ind = @isHedgeInd1,  
          idms_acct_alloc = @bsi1,  
          cmnt_num = @cmntNum,  
          trans_id = @aTransId  
      where trade_num = @tradeNum and  
            order_num = 1 and  
            item_num = 1 and  
            trans_id = @itemTransId  
      if (@@rowcount != 1)  
         return -711  
  
      update dbo.trade_item_fut 
      set fut_price_curr_code = @priceCurr1,  
          total_fill_qty = @qty1,  
          fill_qty_uom_code = 'LOTS',  
          avg_fill_price = @avgPrice1,  
          trans_id = @aTransId  
      where trade_num = @tradeNum and  
            order_num = 1 and  
            item_num = 1 and  
            trans_id = @futOptPhyTransId  
      if (@@rowcount != 1)  
         return -712  
  
      update dbo.trade_item_fill 
      set fill_qty = @qty1,  
          fill_qty_uom_code = 'LOTS',  
          fill_price = @avgPrice1,  
          fill_price_uom_code = @priceUom1,  
          fill_price_curr_code = @priceCurr1,  
          fill_date = @contrDate,  
          trans_id = @aTransId  
      where trade_num = @tradeNum and  
            order_num = 1 and  
            item_num = 1 and  
            item_fill_num = 1 and  
            trans_id = @fillTransId   
      if (@@rowcount != 1)  
         return -714  		  
   end /* if (@orderTypeCode */  
   else if (@orderTypeCode = 'EXCHGOPT') 
   begin  
      select @bsi1 = null  
      if (@portNum1 is not null) 
      begin  
         exec @status = dbo.quickfill_find_bsi @portNum1, @bsi1 output  
         if (@status != 0)   
            return @status  
      end  
	  
      /* update trade_item and trade_item_exch_opt */  
      update dbo.trade_item 
      set p_s_ind = @psInd1,  
          cmdty_code = @cmdty1,  
          risk_mkt_code = @mkt1,  
          title_mkt_code = @mkt1,  
          trading_prd = @trdPrd,  
          contr_qty = @qty1,  
          contr_qty_uom_code = 'LOTS',  
          avg_price = @avgPrice1,  
          price_curr_code = @priceCurr1,  
          price_uom_code = @priceUom1,  
          real_port_num = @portNum1,  
          hedge_pos_ind = @isHedgeInd1,  
          idms_acct_alloc = @bsi1,  
          cmnt_num = @cmntNum,  
          trans_id = @aTransId  
      where trade_num = @tradeNum and  
            order_num = 1 and  
            item_num = 1 and  
            trans_id = @itemTransId  
      if (@@rowcount != 1)  
         return -711  
	  
      update dbo.trade_item_exch_opt 
      set put_call_ind = @pc1,  
          strike_price = @strike1,  
          strike_price_uom_code = @priceUom1,  
          strike_price_curr_code = @priceCurr1,  
          total_fill_qty = @qty1,  
          fill_qty_uom_code = 'LOTS',  
          avg_fill_price = @avgPrice1,  
          trans_id = @aTransId  
      where trade_num = @tradeNum and  
            order_num = 1 and  
            item_num = 1 and   
            trans_id = @futOptPhyTransId  
      if (@@rowcount != 1)  
         return -713  
		
      update dbo.trade_item_fill 
      set fill_qty = @qty1,  
          fill_qty_uom_code = 'LOTS',  
          fill_price = @avgPrice1,  
          fill_price_uom_code = @priceUom1,  
          fill_price_curr_code = @priceCurr1,  
          fill_date = @contrDate,  
          trans_id = @aTransId  
      where trade_num = @tradeNum and  
            order_num = 1 and  
            item_num = 1 and  
            item_fill_num = 1 and  
            trans_id = @fillTransId  
	  
      if (@@rowcount != 1)  
         return -714  
   end /* end if order type is an option */  
   else if (@orderTypeCode = 'PHYSICAL') 
   begin  
      /* update trade_item and trade_item_wet_phy */  
      update dbo.trade_item 
      set p_s_ind = @psInd1,  
          cmdty_code = @cmdty1,  
          risk_mkt_code = @mkt1,  
          title_mkt_code = @mkt1,  
          trading_prd = @trdPrd,  
          contr_qty = @qty1,  
          contr_qty_uom_code = 'LOTS',  
          avg_price = @avgPrice1,  
          price_curr_code = @priceCurr1,  
          price_uom_code = @priceUom1,  
          real_port_num = @portNum1,  
          hedge_pos_ind = @isHedgeInd1,  
          cmnt_num = @cmntNum,  
          trans_id = @aTransId  
      where trade_num = @tradeNum and  
            order_num = 1 and  
            item_num = 1 and  
            trans_id = @itemTransId  
      if (@@rowcount != 1)  
         return -711  
  
      update dbo.trade_item_wet_phy 
      set del_date_from = @fromDeliveryDate,  
          del_date_to = @toDeliveryDate,  
          trans_id = @aTransId  
      where trade_num = @tradeNum and  
            order_num = 1 and  
            item_num = 1 and   
            trans_id = @futOptPhyTransId  
      if (@@rowcount != 1)  
         return -725  
  
      update dbo.trade_item_fill 
      set fill_qty = @qty1,  
          fill_qty_uom_code = 'LOTS',  
          fill_price = @avgPrice1,  
          fill_price_uom_code = @priceUom1,  
          fill_price_curr_code = @priceCurr1,  
          fill_date = @contrDate,  
          trans_id = @aTransId  
      where trade_num = @tradeNum and  
            order_num = 1 and  
            item_num = 1 and  
            item_fill_num = 1 and  
            trans_id = @fillTransId  
      if (@@rowcount != 1)  
         return -714  
   end  
   if (@warning is null)  
      return @tradeNum  
   else 
      return @warning  
GO
GRANT EXECUTE ON  [dbo].[inhouse_modify_trade] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'inhouse_modify_trade', NULL, NULL
GO
