SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[usp_update_real_portfolio_forTOI]  
@trade_num int,  
@order_num  int,  
@item_num  INT,  
@real_port_num INT,  
@use_account_areement_for_EB BIT,  
@orig_cmdty_code  CHAR(8)  
AS  
BEGIN  
set nocount on

 PRINT '[usp_update_real_portfolio_forTOI] Started'  
 DECLARE  @port_type CHAR(2)  
 DECLARE @TempAcctNum VARCHAR(32)  
 DECLARE @AcctNum INT  
 DECLARE @prod_Type CHAR(1) --item_type of trade_item  
 DECLARE @acctTypeCode  CHAR(8)  
 DECLARE @IsAnyCostVouchered BIT  
 DECLARE @CostCount INT  
 DECLARE @canTradewithBookingCompCount INT  
 DECLARE @InhouseInd CHAR(1)  
 DECLARE @acct_status CHAR(1)  
 DECLARE @attribute_value CHAR(1)  
 DECLARE @IsFX_Exposure_ON CHAR(1)  
 DECLARE @desired_pl_curr_code CHAR(8)  
 DECLARE @reciprocal BIT  
 DECLARE @target_key1ForMultiplierForBBL VARCHAR(16)  
 DECLARE @target_key1ForMultiplierForMT VARCHAR(16)  
 DECLARE @aMultiplier VARCHAR(20)  
 DECLARE @factor DECIMAL(20,10)  
 DECLARE @trans_id INT  
 DECLARE @curr_commodity_primUOM CHAR(4)  
 DECLARE @curr_commodity_secUOM CHAR(4)  
 DECLARE @orig_commodity_primUOM CHAR(4)  
 DECLARE @orig_commodity_secUOM CHAR(4)  
 DECLARE @self_uom_Conv_rate DECIMAL(20,10)  
 DECLARE @old_port_num INT
DECLARE @updQuery VARCHAR(2000)
declare @canUpdateUomConrate BIT
  
    
 SET @desired_pl_curr_code = 'USD'  
 SET @IsFX_Exposure_ON = 'N'  
 SET @attribute_value = 'N'  
 SET @IsAnyCostVouchered = 0  
 SET @AcctNum = 0  
 SET @CostCount= 0  
 SET @acct_status = 0  
 SET @canTradewithBookingCompCount = 0  
 SET @acct_status = 'I'  
 SET @reciprocal = 0  
 SET @aMultiplier = NULL  
 SET @factor = NULL  
 SET @prod_Type = NULL  
 SET @curr_commodity_primUOM = NULL  
 SET @curr_commodity_secUOM = NULL  
 SET @orig_commodity_primUOM = NULL  
 SET @orig_commodity_secUOM = NULL  
 SET @updQuery = 'UPDATE trade_item SET '
SET @self_uom_Conv_rate = NULL
set @canUpdateUomConrate = 0
   
  
 SELECT @port_type = port_type FROM portfolio WHERE port_num = @real_port_num  
 PRINT 'Port_type = ' + @port_type  
 IF (@port_type IS NOT NULL AND @port_type = 'R')   
 BEGIN  
   /* Begin - new trans_id script */
   begin tran
   begin try
       exec dbo.gen_new_transaction_NOI @app_name = 'Dashboard'
   end try
   begin catch
     if @@trancount > 0
        rollback tran
     print '=> Error occurred while executing the ''gen_new_transaction_NOI'' stored procedure!'    
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto endofsp
   end catch
   commit tran
   select @trans_id = null
   select @trans_id = last_num from dbo.icts_trans_sequence where oid = 1
   if @trans_id is null
   begin
      print '=> Failed to obtain a new trans_id for insert!'
      goto endofsp
   end
   /* End - new trans_id script */

  
   --Get the Old portfolio Number to update Inhouse Ind=Y based Trade item distributions
   SELECT @old_port_num = real_port_num FROM trade_item WHERE trade_num = @trade_num AND order_num = @order_num AND item_num = @item_num
   SET @updQuery = @updQuery + ' real_port_num = (select real_port_num from #myTemp), '  
   --UPDATE trade_item SET real_port_num = @real_port_num, trans_id = @trans_id WHERE trade_num = @trade_num AND order_num = @order_num AND item_num = @item_num
   PRINT 'Appended query for Trade_item update with portfolio = ' +  CONVERT(varchar(10),@real_port_num)
    
    
  --Check if isAnycostVouchered for this trade item  
   select @CostCount=count (*) from cost   
   where   
   cost_owner_key6=@trade_num and   
   cost_owner_key7=@order_num and   
   cost_owner_key8=@item_num and   
   cost_status in ('VOUCHED', 'PAID') and   
   cost_type_code not in ('RB','RC')  
  
   PRINT '@CostCount = ' +  CONVERT(varchar(10),@CostCount)  
   IF(@CostCount > 0)  
       set @IsAnyCostVouchered = 1  
   ELSE  
       set @IsAnyCostVouchered = 0  
          
        --Get the account num for Booking company   
   select @TempAcctNum = tag_value from portfolio_tag where port_num = @real_port_num  AND tag_name = 'BOOKCOMP'-- it gives the account num mapped to this portfolio     
   IF(@TempAcctNum IS NOT NULL AND @IsAnyCostVouchered = 0)  
   BEGIN  
     set @AcctNum = convert(INT,@TempAcctNum) --Convert @AcctNum into integer here   
     print '@AcctNum = ' + @TempAcctNum  
     SELECT @InhouseInd = inhouse_ind FROM trade WHERE trade_num = @trade_num  
     IF(@InhouseInd <> 'Y' AND @InhouseInd <> 'I' AND @use_account_areement_for_EB = 1)   
     BEGIN  
      SELECT @prod_Type = item_type from trade_item WHERE trade_num = @trade_num AND order_num = @order_num AND item_num = @item_num  
     END  
     print '@prod_Type = ' + @prod_Type  
     IF(@AcctNum > 0)  
      SELECT @acctTypeCode = acct_type_code, @acct_status = acct_status  FROM account WHERE acct_num = @AcctNum  
  
     IF(@prod_Type IS NOT NULL)  
      SELECT @canTradewithBookingCompCount = count(*) FROM  account_agreement WHERE product_type = @prod_Type AND target_book_comp_num = @AcctNum  
     print '@acctTypeCode = ' + @acctTypeCode + ' ,@acct_status = ' + @acct_status + 
     ' ,@canTradewithBookingCompCount=' + CONVERT(varchar(10),@canTradewithBookingCompCount)  
      
     IF(@acctTypeCode = 'PEICOMP' AND @acct_status = 'A' AND (@prod_Type IS NULL OR @canTradewithBookingCompCount > 0))    
     BEGIN  
         set @AcctNum = @AcctNum -- no change,u can chage the condition later to handle this  
         --setGtcForAcctCmmktIfNeeded - Its logic has usage of user defaults from plist file. So not considered for SP.  
     END  
     ELSE  
     begin  
         set @AcctNum = NULL  
         PRINT '@AcctNum is null '   
     end
     SET @updQuery = @updQuery + ' booking_comp_num = (select AcctNum from #myTemp), '
     --UPDATE trade_item SET booking_comp_num = @AcctNum, trans_id = @trans_id  WHERE trade_num = @trade_num AND order_num = @order_num AND item_num = @item_num  
     if(@AcctNum  is not null)  
      PRINT 'Appended query for updating booking_comp_num = ' + CONVERT(varchar(10),@AcctNum)  
     else  
      PRINT 'Appended query for updating booking_comp_num to NULL as trading with this booking company is not allowed'   
  
               
             /*  
    --The below code has !(trade item isInDB) condition based. So no need to implement here as trade item is in DB at this point  
             -- like this:  if (![item isInDb] && [anExt respondsToSelector:@selector(setCreditTerm:)]){  
             OC Code:  
    if ([[Constants valueForAttributeName:@"UseAccountDfltCreditTermOnly"] booleanValue])  
                    [defControl  defaultCreditTermsInTrade:refObject];  
                else if (!createdAsCopyOf && currItem)  
      [defControl defaultCreditTermsInTradeItem:currItem];  
     
    Below is Partly implemented SQL code - commenetd  
             SELECT @attribute_value = attribute_value FROM constants WHERE attribute_name = 'UseAccountDfltCreditTermOnly'  
             IF(@attribute_value = 'Y')  
             BEGIN  
    create table #account_credit_info (  
        prim_cr_term_code   char(8),   
        sec_cr_term_code   char(8),   
        dflt_cr_term_code char(8) )  
    insert #account_credit_info   
select prim_cr_term_code, sec_cr_term_code ,dflt_cr_term_code  
    from account_credit_info where acct_num = @AcctNum  
      
       IF((SELECT count(*) FROM #account_credit_info) > 0)  
       BEGIN  
       END  
             END  
             */  
               
             /*The below OC code is not required to convert as it is to decide the mandatory things set up on UI.  
               if ([[self currentItemPanel] respondsToSelector:@selector(changeTextFieldColor)])  
                    [[self currentItemPanel] performSelector:@selector(changeTextFieldColor)];  
             */  
   END --end of IF(@TempAcctNum IS NOT NULL AND @IsAnyCostVouchered = 0) 
    
   --[currItem setDefaultUomConvRate];  
   create table #curr_commodity  
   (    
       cmdty_code CHAR(8),  
       prim_uom_code CHAR(4),  
       sec_uom_code  CHAR(4)  
   )   
   INSERT INTO #curr_commodity  
   SELECT cmdty_code, prim_uom_code,sec_uom_code  FROM commodity   
   WHERE cmdty_code = (SELECT cmdty_code FROM trade_item WHERE trade_num = @trade_num AND order_num = @order_num AND item_num = @item_num)  
   print '#curr_commodity created'  
   IF(  
     (SELECT count(*) FROM #curr_commodity) > 0   
    AND   
     (SELECT attribute_value FROM constants WHERE attribute_name = 'UsePaperConvBBLtoMTForPosConv') = 'Y'  
     AND   
     (SELECT item_type from trade_item WHERE trade_num = @trade_num AND order_num = @order_num AND item_num = @item_num) = 'F'   
   )  
   BEGIN  
      SELECT @target_key1ForMultiplierForBBL = et.target_key1   
      FROM entity_tag_definition etd JOIN entity_tag et ON etd.oid = et.entity_tag_id   
      WHERE etd.entity_tag_name = 'MultiplierForBBL' AND et.key1 = @real_port_num  
     
      SELECT @target_key1ForMultiplierForMT = et.target_key1   
      FROM entity_tag_definition etd JOIN entity_tag et ON etd.oid = et.entity_tag_id   
      WHERE etd.entity_tag_name = 'MultiplierForMT' AND et.key1 = @real_port_num  
     
      PRINT '@target_key1ForMultiplierForMT=' + @target_key1ForMultiplierForMT  
      PRINT '@target_key1ForMultiplierForBBL=' + @target_key1ForMultiplierForBBL  
      
      IF((SELECT prim_uom_code FROM #curr_commodity) = 'BBL' AND (SELECT sec_uom_code FROM #curr_commodity) = 'MT')  
      BEGIN  
        SET  @aMultiplier = @target_key1ForMultiplierForBBL  
        IF(@aMultiplier IS NULL)  
        BEGIN  
          SET @aMultiplier = @target_key1ForMultiplierForMT  
          SET @reciprocal = 1  
        END  
      END  
      ELSE  
      IF((SELECT prim_uom_code FROM #curr_commodity) = 'MT' AND (SELECT sec_uom_code FROM #curr_commodity) = 'BBL')  
      BEGIN  
        SET  @aMultiplier = @target_key1ForMultiplierForMT  
        IF(@aMultiplier IS NULL)  
        BEGIN  
          SET @aMultiplier = @target_key1ForMultiplierForBBL  
          SET @reciprocal = 1  
        END  
      END  
      PRINT '@aMultiplier = ' + @aMultiplier  
      IF(@aMultiplier IS NOT NULL)  
      BEGIN  
       SET @factor = cast(@aMultiplier as decimal(20,10))   
       IF(@reciprocal =1 AND @factor > 0)  
         SET @factor = 1/@factor  
      END  
      PRINT '@factor = ' + @factor  
      
      SET @canUpdateUomConrate   = 0
      IF(@factor IS NOT NULL AND @factor > 0)  
      BEGIN
        set @self_uom_Conv_rate = @factor
        set @canUpdateUomConrate = 1
         --UPDATE trade_item SET uom_conv_rate = @factor, trans_id = @trans_id    
         --WHERE trade_num = @trade_num AND order_num = @order_num AND item_num = @item_num --HERE @factor IS DECIMAL(20,10) WHERE AS uom_conv_rate IS FLOAT(8,53)  
         PRINT 'Appended query for updating uom_conv_rate = ' + CONVERT(varchar(100),@factor)  
      END  
      ELSE   
      BEGIN  
       SELECT @self_uom_Conv_rate = uom_conv_rate FROM trade_item WHERE trade_num = @trade_num AND order_num = @order_num AND item_num = @item_num  
       IF(@self_uom_Conv_rate IS NOT NULL)  
       BEGIN 
           set @canUpdateUomConrate = 1 
                  --get plist commodity  
                  create table #orig_commodity  
                (    
           cmdty_code CHAR(8),  
           prim_uom_code CHAR(4),  
           sec_uom_code  CHAR(4)  
               )   
               INSERT INTO #orig_commodity  
               SELECT cmdty_code, prim_uom_code,sec_uom_code  FROM commodity   
               WHERE cmdty_code = @orig_cmdty_code  
         
               IF((SELECT COUNT(*) FROM #orig_commodity) > 0)  
               BEGIN  
              SELECT @curr_commodity_primUOM = prim_uom_code,@curr_commodity_secUOM =sec_uom_code  FROM #curr_commodity   
              SELECT @orig_commodity_primUOM = prim_uom_code,@orig_commodity_secUOM =sec_uom_code  FROM #orig_commodity   
              IF((@curr_commodity_primUOM <> @orig_commodity_primUOM) OR (@curr_commodity_secUOM <> @orig_commodity_secUOM))  
              BEGIN  
                                IF(@self_uom_Conv_rate > 0 AND @curr_commodity_primUOM = @orig_commodity_secUOM AND @curr_commodity_secUOM=@orig_commodity_primUOM)  
                                       SET @self_uom_Conv_rate = 1/@self_uom_Conv_rate  
                                ELSE  
                                BEGIN  
                                     SET @self_uom_Conv_rate = NULL  
                                     PRINT 'updated uom_Conv_rate is NULL'  
                                END  
                     
                                --    UPDATE trade_item   SET uom_conv_rate = @self_uom_Conv_rate , trans_id = @trans_id   
                                --WHERE trade_num = @trade_num AND order_num = @order_num AND item_num = @item_num  
                                PRINT 'Appended query for updating uom_Conv_rate of trade item '  
              END  
           END  
       END  
       ELSE  
           PRINT 'self_uom_Conv_rate is NULL'  
      END  
      if(@canUpdateUomConrate = 1)
      begin
            SET @updQuery = @updQuery + ' uom_conv_rate = (select self_uom_Conv_rate from #myTemp), ' 
            set @canUpdateUomConrate = 0
        end 
     END  
    
     
     --[currItem setHasDefaultHedgeRateInd:'\0']; This is used for app purpose. so no need to implement  
    
     /* if([[Constants valueForAttributeName:@"FX_Exposure_ON"] booleanValue])  
            [currItem setHedgeCurrency:[[currItem realPortfolio] desiredCurrency]];  
            */  
     SELECT @IsFX_Exposure_ON = attribute_value FROM constants WHERE attribute_name = 'FX_Exposure_ON'  
     print '@IsFX_Exposure_ON = ' + @IsFX_Exposure_ON  
     IF(@IsFX_Exposure_ON = 'Y')  
     BEGIN  
         SELECT @desired_pl_curr_code = desired_pl_curr_code FROM portfolio WHERE port_num = @real_port_num  
         SET @updQuery = @updQuery + ' hedge_curr_code = (select desired_pl_curr_code from #myTemp) , '  
         --UPDATE trade_item   
         --SET hedge_curr_code = @desired_pl_curr_code , trans_id = @trans_id   
         --WHERE trade_num = @trade_num AND order_num = @order_num AND item_num = @item_num  
         PRINT 'Appended query for updating hedge_curr_code = ' + @desired_pl_curr_code  
     END  
         
       /* below YB code is Panel related. So not required - my belief  
        if ([[self currentItemPanel] respondsToSelector:@selector(realPortfolioDidChanged)])  
            [[self currentItemPanel] performSelector:@selector(realPortfolioDidChanged)];  
     */  
     
    
     create table  #myTemp 
     (
            real_port_num INT,
            AcctNum INT,
            self_uom_Conv_rate DECIMAL(20,10) ,
            desired_pl_curr_code CHAR(8) ,
            trans_id INT,
            trade_num int,  
            order_num  int,  
            item_num  INT
     )
     INSERT INTO #myTemp      VALUES(@real_port_num,@AcctNum,@self_uom_Conv_rate,@desired_pl_curr_code,@trans_id,@trade_num,@order_num,@item_num)
     SET @updQuery = @updQuery + ' trans_id = (select trans_id from #myTemp) WHERE trade_num = (select trade_num from #myTemp) AND order_num = (select order_num from #myTemp) AND item_num = (select item_num from #myTemp)'
     PRINT '@updQuery =  ' + @updQuery
     EXEC (@updQuery)
     PRINT 'trade_item is updated with portfolio and the dependent attributes'
     drop table #myTemp
     
     --Update Trade Item distributions here              
       --When Trade's Inhouse Indicator is N                                          
       UPDATE trade_item_dist SET real_port_num = @real_port_num, trans_id = @trans_id 
       WHERE trade_num = @trade_num AND order_num = @order_num AND item_num = @item_num
      AND 
       NOT EXISTS(SELECT 1 FROM trade t LEFT JOIN trade_item_dist d ON t.trade_num = d.trade_num 
       where t.inhouse_ind = 'Y' AND t.port_num = d.real_port_num AND t.trade_num = @trade_num)
      
      --When Trade's Inhouse Indicator is Y
      UPDATE trade_item_dist SET real_port_num = (SELECT port_num FROM trade WHERE trade_num = @trade_num), trans_id = @trans_id 
       WHERE trade_num = @trade_num AND order_num = @order_num AND item_num = @item_num
      AND 
       EXISTS(SELECT 1 FROM trade t LEFT JOIN trade_item_dist d ON t.trade_num = d.trade_num 
       where t.inhouse_ind = 'Y' AND t.port_num = d.real_port_num AND d.real_port_num = @old_port_num AND t.trade_num = @trade_num)

     PRINT 'trade_item_dist is updated with portfolio '
  
 END --end of IF (@port_type IS NOT NULL AND @port_type = 'R') 
 print '[usp_update_real_portfolio_forTOI] ended'  
 endofsp:
END 

GO
GRANT EXECUTE ON  [dbo].[usp_update_real_portfolio_forTOI] TO [next_usr]
GO
