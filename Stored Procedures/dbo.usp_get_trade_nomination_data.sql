SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                   
                     
CREATE procedure [dbo].[usp_get_trade_nomination_data]                                              
(                                                           
   @tradeNum    int,                                                    
   @executor    varchar(50)                                                  
)                                                        
as                                                  
set nocount on                                              
                                                       
SELECT                                                    
t.trade_num                    AS TradeNum,                                          
t.trader_init                  As TradeInIt,                                                             
(iu.user_first_name +' '+ iu.user_last_name)   AS TraderInitStr,                                                 
iu.email_address          AS CommContEmail, --FOR PMI                                             
iu.user_init as UserInIt,                                            
t.acct_ref_num          AS AcctRefNum, --FOR PMI                                                
(mngr.user_first_name+ ' '+ mngr.user_last_name)   AS TraderMngrInitStr, --FOR PMI                                                
mngr.email_address         AS TraderMngrEMail,  --FOR PMI                                                
                                                  
                                                
-- Counterpart details                                                 
                                              
cpt.acct_short_name    AS TradeCounterPartyShortName,                                                
cpt.acct_full_name    AS TradeCounterPartyFullName,                                                      
                                                        
                                                
cp.acct_full_name                AS CounterPartyAcctFullName,                                                 
                                                
cp.acct_full_name                AS CounterpartyFullName,                                                            
                                                
cpa.acct_addr_fax_num              AS CounterPartyAcctAccountFaxNum,                                                
                                                
cpa.acct_addr_fax_num              AS CounterpartyFaxInfoForInvoice,                                                
                                                
cpa.acct_addr_fax_num        AS CounterPartyFaxInfo,                                                            
                                                
cpa.acct_addr_ph_num              AS CounterPartyAccountPhoneNum,                                                   
                                                
cpa.acct_addr_email                        AS CounterpartyEmailInfoForInvoice,                                                        
                                                
                                                         
                                                
                                                            
                                                
( isnull(cpa.acct_addr_line_1 ,'')+' '+                                                             
                                                
isnull(cpa.acct_addr_line_2,'') +' '+                                                            
                                                
isnull(cpa.acct_addr_line_3,'') +' '+                                                            
                                                
isnull(cpa.acct_addr_line_4,'') +' '+                                                              
                                                
isnull(cpa.acct_addr_city,'')  +' '+                                                            
                             
isnull(cpa.state_code,'')  +' '+               
                                                
isnull(cpa.acct_addr_zip_code,''))+' '+                                              
                                                
isnull(cpa.country_code,'')       AS CounterPartyAccountAddressStr,                                                  
             
( isnull(cpa.acct_addr_line_1 ,'')+' '+                                                             
                       
isnull(cpa.acct_addr_line_2,'') +' '+                                                            
                      
isnull(cpa.acct_addr_line_3,'') +' '+                                                            
                                                
isnull(cpa.acct_addr_line_4,'') +' '+                                                              
                                                
isnull(cpa.acct_addr_city,'')  +' '+                                                            
                                                
isnull(cpa.state_code,'')  +' '+                                                     
                                                
isnull(cpa.acct_addr_zip_code,''))+' '+                                                            
                                               
isnull(cpa.country_code,'')          AS   CounterpartyAddressInfo,                                                 
                                                
 isnull(cpa.acct_addr_line_1 ,'-') AS   CounterPartyAddrLine1,                                                          
                                                
isnull(cpa.acct_addr_line_2,'-')        AS   CounterPartyAddrLine2,                                          
                                                
isnull(cpa.acct_addr_line_3,'-')      AS   CounterPartyAddrLine3,                                                            
                                                
isnull(cpa.acct_addr_line_4,'-')      AS   CounterPartyAddrLine4,                                                          
                                                
isnull(cpa.acct_addr_city,'-')      AS   CounterPartyCity,                                                         
                                              
isnull(cpa.state_code,'-')        AS   CounterPartyState,                                                           
                                                
isnull(cpa.acct_addr_zip_code,'-')      AS   CounterPartyZipCode,                                         
                                                
isnull(cpa.country_code,'-')          AS   CounterpartyCountryCode,                                                
                                                        
                                                
cpa.acct_addr_line_1             AS CounterPartyAcctAddrLine1,                                                            
                                                
cpa.acct_addr_line_2             AS CounterPartyAcctAddrLine2,                                                            
                                                
(isnull(cpa.acct_addr_city,'')  +' '+                                                 
                                                
isnull(cpa.state_code,'')+' '+                                                            
                                                
isnull(cpa.acct_addr_zip_code,'') )       AS CounterPartyAcctCityAndStateInfo,                                                            
                                                
cpa.country_code               AS CounterPartyAcctAddrCountryCode,                                                            
                                                
cpa.acct_addr_line_1             AS CounterPartyAcctAddrLine1ForConfirms,                                                           
                          
cpa.acct_addr_line_2             AS CounterPartyAcctAddrLine2ForConfirms,                                                           
                                    
(isnull(cpa.acct_addr_city,'') +' '+                                                            
                                                
isnull(cpa.state_code,'')+' '+                                                         
                                                
isnull(cpa.acct_addr_zip_code,'') )      AS CounterPartyAcctCityAndStateInfoForConfirms,                      
                                                
cpa.country_code               AS CounterPartyAcctAddrCountryCodeForConfirms,                                                           
                                      
cpac.acct_cont_last_name           AS CounterpartyAccountLastName,                                                            
                                                
(cpac.acct_cont_first_name+' '+                                                            
                                                
cpac.acct_cont_last_name)            AS CounterpartyAccountContactNameforContract,                                                  
                                              
(cpac.acct_cont_first_name+' '+                                                            
                                                
cpac.acct_cont_last_name)            AS CounterPartyAcctContactFullName,                               
                                                
cpac.acct_cont_off_ph_num           AS CounterpartyAccountContactPhNum,                                                            
                                                
cpac.acct_cont_fax_num            AS CounterpartyAccountContactFaxNum,                                                             
                                                
cpac.acct_cont_email             AS CounterpartyAccountContactEmail,                                                             
                                                
(cpac.acct_cont_first_name+' '+                                                            
                                                
cpac.acct_cont_last_name)            AS CounterpartyAccountContactNameforContractForConfirms,                                                          
                                                
cpac.acct_cont_off_ph_num           AS CounterpartyAccountContactPhNumForConfirms,                                                           
                                                
cpac.acct_cont_fax_num            AS CounterpartyAccountContactFaxNumForConfirms,                                                            
                                                
cpac.acct_cont_email             AS CounterpartyAccountContactEmailInfoForConfirms,                                                             
                                                
(CASE WHEN cp.acct_short_name LIKE 'BP%'                                                             
                                                
THEN 'YES' ELSE 'NO' END )           AS IsCounterpartyBPOrSubsidiaries,                                                            
                                                
                                                            
                                                
(DATENAME(month, t.contr_date)+' '+                                                            
                                                
DATENAME(day, t.contr_date)+','+                                                            
                                                
DATENAME(year, t.contr_date) )           AS ContrDateString,                                                                  
                                                
(DATENAME(month, getdate())+' '+               
                                                
DATENAME(day, getdate())+','+                                                            
                                                
DATENAME(year, getdate()) )               AS TodayDateString,                                                            
                                                
--           AS priceTermStartDateForSwaps                                                            
                                                
--           AS priceTermEndDateForSwaps                                          
                                                
cmt.cmnt_text                AS TradeCommentStr,                                                              
                                  
                                                                                  
                                                
(SELECT TOP 1 tii.p_s_ind FROM trade_item                                                             
                                                
tii WHERE tii.item_type = 'W'                                                             
             
AND tii.trade_num = @tradeNum)         AS PSIndFromTradeItem,-------------trade_num Input                                                            
                                         
REPLACE(CONVERT(VARCHAR(10),                                                            
                                                
t.contr_date,1), '/', '/')        AS ContrDate,                                                            
                                                
                                                            
                                                
--Trade Order                                                            
                                                
tro.order_num                AS OrderNum,                                                            
                                                
tro.order_type_code              AS OrderTypeCode,                                                            
                                                
                                                            
                                                
--Trade Item      -- Booking company                                           
                                                
bp.acct_full_name            AS BookingCompanyAcctFullName,                                                 
                                                
bp.acct_full_name              AS BookingCompFullName,                                                           
                                                
bp.acct_short_name              AS BookingCompanyAcctShortName,                                                         
                                                
bpa.acct_addr_fax_num              AS BookingCompanyAcctAccountFaxNum,                                                            
                                                
bpa.acct_addr_ph_num              AS BookingCompanyAccountPhoneNum,                                                            
                                                
( isnull(bpa.acct_addr_line_1 ,'')+' '+                                                             
                                                
isnull(bpa.acct_addr_line_2,'') +' '+                                                            
                                                
isnull(bpa.acct_addr_line_3,'') +' '+                                                            
                                                
isnull(bpa.acct_addr_line_4,'') +' '+                                                              
                                                
isnull(bpa.acct_addr_city,'')  +' '+                                                            
                                                
isnull(bpa.state_code,'')  +' '+                                                            
                                                
isnull(bpa.acct_addr_zip_code,''))+' '+                                                            
                                                
isnull(bpa.country_code,'')             AS BookingCompanyAccountAddressStr,                                   
                            
 ( isnull(bpa.acct_addr_line_1 ,'')+' '+                                                             
                                                
isnull(bpa.acct_addr_line_2,'') +' '+                                                            
                                                
isnull(bpa.acct_addr_line_3,'') +' '+                                   
                                                
isnull(bpa.acct_addr_line_4,'') +' '+                                                              
                                                
isnull(bpa.acct_addr_city,'')  +' '+                                                            
                                                
isnull(bpa.state_code,'')  +' '+                             
                                                
isnull(bpa.acct_addr_zip_code,''))+' '+                                                            
                                                
isnull(bpa.country_code,'')             AS BookingCompanyContractAddressesInfo,                                                  
                                                
isnull(bpa.acct_addr_line_1,'-')      AS BookingCompanyContractAddrLine1,                                                
isnull(bpa.acct_addr_line_2 ,'-')            AS BookingCompanyContractAddrLine2,                                                                    
isnull(bpa.acct_addr_line_3, '-')            AS BookingCompanyContractAddrLine3,                                                   
isnull(bpa.acct_addr_line_4,'-')             AS BookingCompanyContractAddrLine4,                                          
isnull(bpa.acct_addr_city,'-')        AS BookingCompanyContractCity,                                                
isnull(bpa.state_code,'-')         AS BookingCompanyContractState,                                                
isnull(bpa.acct_addr_zip_code,'-')       AS BookingCompanyContractZipCode,                                                
isnull(bpa.country_code,'-')         AS BookingCompanyContractCountryCode,                        
                                                
                                                
bpa.acct_addr_line_1             AS BookingCompanyAcctAddrLine1,                                                            
bpa.acct_addr_line_2             AS BookingCompanyAcctAddrLine2,                                                            
                                                
(isnull(bpa.acct_addr_city,'')  +' '+                                                            
                     
isnull(bpa.state_code,'')+' '+                                                            
                                                
isnull(bpa.acct_addr_zip_code,'') )       AS BookingCompanyAcctCityAndStateInfo,                                                            
                                                
bpa.country_code               AS BookingCompanyAcctAddrCountryCode,                                                            
                                                
bpac.acct_cont_last_name           AS BookingCompanyAccountLastName,                                                 
                                                
(bpac.acct_cont_first_name+' '+                                                            
                                                
bpac.acct_cont_last_name)            AS BookingCompanyAccountContactNameforContract,                                                          
                                   
bpac.acct_cont_off_ph_num   AS BookingCompanyAccountContactPhNum,                                                            
                                                
bpac.acct_cont_fax_num            AS BookingCompanyAccountContactFaxNum,                                                         
                                                
bpac.acct_cont_email             AS BookingCompanyAccountContactEmail,                                                           
                                                
(bpac.acct_cont_first_name+' '+                                                            
                                                
bpac.acct_cont_last_name)            AS BookingCompanyAccountContactNameforContractForBioDieselAndOrRins,                                                            
                                                
bpac.acct_cont_off_ph_num  AS BookingCompanyAccountContactPhNumForBioDieselAndOrRins,                                                            
                                                
bpac.acct_cont_fax_num            AS BookingCompanyAccountContactFaxNumForBioDieselAndOrRins,                                                           
                                                
bpac.acct_cont_email             AS BookingCompanyAccountContactEmailInfoForBioDieselAndOrRins,              
                                                
                                                
                                                
                          
                                                
brkr.acct_full_name              AS BrokerAcctFullName,                                                            
                                                
(CASE WHEN ti.brkr_num IS NULL                                                            
                                              
 OR ti.brkr_comm_amt IS NULL THEN '' ELSE                                                            
                                                
 (CONVERT(varchar(10),ti.brkr_comm_amt)+' '+                                                            
                                                
 rtrim(ti.brkr_comm_curr_code) +'/ '+                                                            
                                                
 ti.brkr_comm_uom_code ) END )            AS BrkrCommAmtStr,                                                
                                              
 (brkrac.acct_cont_first_name+' '+                                                 
brkrac.acct_cont_last_name)            AS BrokerCompanyAccountContactName,  -- broker contact details                                              
brkrac.acct_cont_email             AS BrokerCompanyAccountContactEmailInfo,                                                         
                                                          
                                                
ti.cmdty_code                   AS CmdtyCode, --CommodityCode                                                   
                                                
ti.cmdty_code                 AS CommodityCode,                                                 
                                                
cmdty.cmdty_short_name        AS CommodityShortName,   -- migrated as CmdtyShortName                                                
                                                
cmdty.cmdty_full_name                AS CommodityFullName,   -- m as CmdtyFullNmae                                                 
                                                
                                                   
                                
(SELECT  c.cmnt_text FROM comment c LEFT                              
                                                
OUTER JOIN trade_item ti1 ON ti1.cmnt_num =                                                             
                 
c.cmnt_num  WHERE ti1.order_num=1 AND                                                             
                                                
ti1.item_num =1 AND ti1.trade_num = @tradeNum)   AS FirstTradeOrderLongComment, -------------trade_num Input                                                            
                                                
cmdty.cmdty_full_name        AS CmdtyFullNmae,   -- CostCommodityName                                                   
                                                
cmdty.cmdty_short_name        AS CmdtyShortName,   --CommodityShortName                                  
                                                
(CASE WHEN ti.item_type = 'W'THEN                                                            
                                                
cmdty.cmdty_full_name ELSE '' END)        AS PhysicalCmdtyFullName,                                                            
                                                
                                                            
                                                
(SELECT cmdt1.cmdty_full_name  FROM trade_item ti1                                                            
                                                
LEFT OUTER JOIN commodity cmdt1                         
                                                
ON ti1.cmdty_code=cmdt1.cmdty_code                                                            
                                                
WHERE ti1.item_num=1 AND ti1.order_num=1 AND                                                            
                                                
ti1.trade_num =@tradeNum)           AS PhysicalCmdtyFullNameForBioDWithRINS, -------------trade_num Input                                                            
                                                
                                                            
                                                
ti.contr_qty                AS ContrQty,                                                
                                                
ti.contr_qty                    AS ContractQty,                           
                                                
u.uom_full_name                   AS ContrQtyUomName,                                                          
                                                
(convert(VARCHAR(20),ti.contr_qty ))      AS GetContrQtyStr,                                                            
                                                
ti.contr_qty                AS GetContrQtyString, --clear decimals if 0,                                                   
                                                
                                                                  
                                                
tro.strip_summary_ind            AS StripSummaryInd,                                                            
                                                
ti.contr_qty_uom_code             AS ContrQtyUomCode,                                                  
                    
qtyuom.uom_full_name        AS ContrQtyUomFullName,    -- added                                                       
                                                
(CASE WHEN ti.avg_price IS NULL THEN '0'                                                 
                                                
ELSE ti.avg_price end)        AS TradeItemAvgPrice,    -- added                                                       
                                                
priceuom.uom_short_name        AS PriceUomShortName,  -- added                                                  
                                                
m.mot_full_name          AS MotFullName,    -- added                                                 
                             
m.mot_short_name                  AS MotShortName, -- MotShortName,                             
                                   
mt.mot_type_code                   AS MotTypeCode,                                                 
                                                
mt.mot_type_short_name                AS MotTypeShortName,                                                
                                                
                                                              
(CASE WHEN tro.order_type_code='PHYSICAL'                                                            
                                                
 AND tro.order_num = ti.order_num AND                       
          
tro.trade_num = ti.trade_num  THEN                                                            
                                                
(DATENAME(year, tiwp.del_date_from))+'-'+                                                            
                                                
CONVERT(VARCHAR(2),tiwp.del_date_from, 1)+'-'+                                                          
                                                
DATENAME(dd, tiwp.del_date_from) ELSE '' END)   AS DelDateFromPhy,                                                            
                                                
                                                            
         
(CASE WHEN tro.order_type_code='PHYSICAL'                                                            
                                                
AND tro.order_num = ti.order_num AND                                                             
                                                
tro.trade_num = ti.trade_num  THEN                                                            
                                                
(DATENAME(year, tiwp.del_date_to))+'-'+                                                            
                                                
CONVERT(VARCHAR(2),tiwp.del_date_to, 1)+'-'+                                                            
                          
DATENAME(dd, tiwp.del_date_to) ELSE '' END)    AS DelDateToPhy ,                                                 
                                                
                                                
                                                
(DATENAME(year, ttinfo.contr_start_date))+'-'+                                                            
                             
CONVERT(VARCHAR(2),ttinfo.contr_start_date, 1)+'-'+                                                          
                                                
DATENAME(dd, ttinfo.contr_end_date)    AS TermStartDate,                                                 
                                                
                                                
                      
(DATENAME(year, ttinfo.contr_end_date))+'-'+                                                            
                                                
CONVERT(VARCHAR(2),ttinfo.contr_end_date, 1)+'-'+                                                            
                                             
DATENAME(dd, ttinfo.contr_end_date)    AS TermEndDate ,                                                           
                                                
                                                
                                                
                                                          
                                                
                                                   
                                                
(CASE WHEN tro.order_type_code='PHYSICAL'                  
                                                
 AND tro.order_num = ti.order_num AND                                                             
                                                
tro.trade_num = ti.trade_num  THEN                                                            
                                                
tiwp.del_loc_code ELSE '' END)          AS DelLocCode,                                                  
                                                
                                                          
                                                
                                                           
                                                
dl.loc_name                  AS DelLocName,                                                            
                                                
--tiwp.del_term_code               AS DelTermCode,                            
                                  
ti.formula_ind                 AS FormulaInd,                                                            
                                                
                                                            
                                                
( SELECT TOP 1 ti1.formula_ind FROM trade_item ti1                                                            
                                                
WHERE ti1.trade_num =@tradeNum)         AS FormulaIndForBioDWithRINS,                                                            
                                                
                                                                
                                                
ti.item_num                  AS ItemNum,                                                            
                                                
ti.item_type          AS ItemType,                                                            
                            
(CASE WHEN ti.item_type = 'W' THEN                                                            
                                                
ti.contr_qty_uom_code ELSE '' END)        AS PhysicalContrQtyUomCode,                                            
                                                
                                                            
                                                
                                                    
                                                
(SELECT ti1.contr_qty_uom_code FROM trade_item ti1                                                        
                                                
WHERE ti1.item_type = 'W' AND ti1.order_num = 1                                                             
             
AND ti1.item_num = 1 AND                                                             
                                                
ti1.trade_num =@tradeNum)            AS PhysicalContrQtyUomCodeForBioDWithRins,                                                            
                                                
                                                               
                                                
  --            AS IsSwapBuyFixedOrFloat,                                                            
                                                
  --           AS IsSwapSellFixedOrFloat,                                                            
                                                
(CASE WHEN mt.mot_type_short_name = tiwp.mot_code                                                            
                                                
THEN mt.mot_type_short_name ELSE                                                            
                                                
mt.mot_type_short_name+'/ '+ tiwp.mot_code END)  AS MotCodeStr,    --MotCode                                                    
                                                
tiwp.mot_code             AS MotCode,                                                 
                              
--            AS OtcExpDate,                                                            
                                                
--            AS OtcOptionType,                                                
                                                
--            AS OtcPremium,                                          
                                                
--            AS OtcPremiumCurrCode,                                                            
                                                
--            AS OtcPremiumPayDate,                                                            
                                                
--            AS OtcSettlementType,                                                            
                                     
pt.pay_term_code As PayTermCode,                                                
pt.pay_term_contr_desc             AS PayTermContrDesc,                                                          
                                                
pt.pay_term_desc                AS PayTermDesc,                                                 
                
pm.pay_method_desc                         AS PaymentMethodDescription,                                                
                                                
(CASE WHEN ti.price_curr_code IS NULL THEN '-'                                                 
                                                
ELSE ti.price_curr_code end)         AS PriceCurrCode,                                                
                                             
(CASE WHEN f.formula_type ='A' OR                                                            
                                                
 f.formula_type ='T' THEN                                                            
                                                
 REPLACE(CONVERT(VARCHAR(10),                                                            
                                                
 apt.price_term_end_date, 1), '/', '/') ELSE                                                             
                                   
 '' END)             AS PriceTermEndDate,                         
                         
 (CASE WHEN f.formula_type ='A' OR                                                            
                                                
 f.formula_type ='T' THEN                                                            
                                                
 REPLACE(CONVERT(VARCHAR(10),                                                       
                                                
 apt.price_term_start_date, 1), '/', '/') ELSE                                                             
                                   
 '' END)             AS PriceTermStartDateStr,                                                           
                                                
(CASE WHEN f.formula_type ='A' OR f.formula_type ='T' THEN                                                            
                                                
 REPLACE(CONVERT(VARCHAR(10),                                                            
                                                
 apt.price_term_start_date, 1), '/', '/')                                                             
                                                
 WHEN f.formula_type = 'E' THEN                                                             
                                                
 (SELECT TOP 1 Convert(VARCHAR(10),                                                            
                                                
 e.event_pricing_days) +' '+ e.event_name                                                             
                                                
 FROM event_price_term e WHERE                                                             
                   
 e.formula_num=f.formula_num)ELSE                                                             
                                             
 '' END)                  AS PriceTermStartDate,                                                  
                                                 
                                                  
 (SELECT TOP 1                                                        
 e.event_pricing_days                                                     
 FROM event_price_term e WHERE                                                  
 e.formula_num=f.formula_num)      AS EventPricingDays,                                           
                                           
  (SELECT TOP 1                                                        
 e.event_start_end_days                                                     
 FROM event_price_term e WHERE                                                  
 e.formula_num=f.formula_num)      AS EventStartEndDays,                                             
                                           
                                           
  (SELECT TOP 1                                                        
 e.quote_type             FROM event_price_term e WHERE                                                  
 e.formula_num=f.formula_num)      AS QuoteType,                                           
                                           
  (SELECT TOP 1                                                        
 e.event_oper                                                    
 FROM event_price_term e WHERE                                                  
 e.formula_num=f.formula_num)      AS EventOper,                    
                     
 (SELECT TOP 1                                                        
 e.event_name                                                     
 FROM event_price_term e WHERE                                                  
 e.formula_num=f.formula_num)      AS EventName,                                                
                                                
(CASE WHEN (SELECT count(*)  FROM formula_condition fc WHERE fc.formula_num =f.formula_num AND(                                                 
                                                
 (fc.formula_cond_type = 'S:SUN'  AND  ((fc.formula_cond_last_next_ind ='-')  OR fc.formula_cond_last_next_ind ='+' )) OR                                                 
                                                
  (fc.formula_cond_type = 'A:SAT'  AND  ((fc.formula_cond_last_next_ind ='-')  OR fc.formula_cond_last_next_ind ='+' )) OR                                                            
                                                
  (fc.formula_cond_type = 'H:HOLY'  AND  ((fc.formula_cond_last_next_ind ='-')  OR fc.formula_cond_last_next_ind ='+'  OR fc.formula_cond_last_next_ind ='L')))                                                            
                                                
   ) = 0 THEN '(Good Business days)'                                                             
                                                
   ELSE                                                             
                                                
           ( SELECT ((CASE WHEN (SELECT count(*)  FROM formula_condition fc WHERE fc.formula_num =f.formula_num AND fc.formula_cond_type = 'S:SUN'  AND  fc.formula_cond_last_next_ind ='-') >0 THEN                                                          
  
                                                
'Sundays:Last Known Quote'                                                             
                                                
              WHEN (SELECT count(*)  FROM formula_condition fc WHERE fc.formula_num =f.formula_num AND fc.formula_cond_type = 'S:SUN'  AND  fc.formula_cond_last_next_ind ='+') >0 THEN                                                            
                                                
                 'Sundays:Next Known Quote'                                                            
                                                
                 ELSE 'Sundays:Excluded'END) +' '+                                                            
                                                
(CASE WHEN (SELECT count(*)  FROM formula_condition fc WHERE fc.formula_num =f.formula_num AND fc.formula_cond_type = 'A:SAT'  AND  fc.formula_cond_last_next_ind ='-') >0 THEN                               
                                                
                 'Saturdays:Last Known Quote'                                                             
                                                
                    WHEN (SELECT count(*)  FROM formula_condition fc WHERE fc.formula_num =f.formula_num AND fc.formula_cond_type = 'A:SAT'  AND  fc.formula_cond_last_next_ind ='+') >0 THEN                                                            
                                                
                    'Saturdays:Next Known Quote'                                                            
                                                
                    ELSE 'Saturdays:Excluded'END) +' '+                                                            
                                                
              (CASE WHEN (SELECT count(*)  FROM formula_condition fc WHERE fc.formula_num =f.formula_num AND fc.formula_cond_type = 'H:HOLY'  AND  fc.formula_cond_last_next_ind ='-') >0 THEN                                                            
                                                
                 'Holidays:Last Known Quote'                                                           
                                                
 WHEN (SELECT count(*)  FROM formula_condition fc WHERE fc.formula_num =f.formula_num AND fc.formula_cond_type = 'H:HOLY'  AND  fc.formula_cond_last_next_ind ='+') >0 THEN                                                            
                                                
                     'Holidays:Next Known Quote'                                                            
                         
                     WHEN (SELECT count(*)  FROM formula_condition fc WHERE fc.formula_num =f.formula_num AND fc.formula_cond_type = 'H:HOLY'  AND  fc.formula_cond_last_next_ind ='L') >0 THEN                                                            
                                                
                    'Holidays:Closest Known Quot'                                                            
                                                
                     ELSE 'Holidays:Excluded'END)                                                 
                                                
                    ) )                                                       
                                                
                                                                       
                                                
                   END )            AS PricingTermsStr,                                                          
                                                
                                                           
                                                
--              AS PutCallIndDescription, --for OTC                                                            
                                                
--ti.price_uom_code               AS PriceUomCode,                                                            
                      ti.p_s_ind                  AS PSInd,                                       
                                                
ti.risk_mkt_code                AS RiskMktCode,                                                            
                                                
--            AS StrikePrice, --for OTC                            
                                                
--             AS StrikePriceCurrCode, --for OTC                                                            
                                                
--            AS SwapBuyPriceCurrCode,                   
                                                
--            AS SwapBuyPricePremiumStr,                                                                                                            
--            AS SwapBuyPriceQuoteStr,                                                            
                                                
--            AS SwapSellPricePremiumStr,                                                            
                                                
--            AS SwapSellPriceQuoteStr,                                                            
                                                
                 
                                           
(select sum(ti1.contr_qty) FROM trade t1                                                             
                                                
LEFT OUTER JOIN trade_order to1                                                              
                                                
ON t1.trade_num = to1.trade_num                                                             
                                                
LEFT OUTER JOIN trade_item ti1                                             
                                                
ON ti1.order_num =to1.order_num AND                                            
                                              
ti1.trade_num = t1.trade_num                                                            
                                                
WHERE                                             
                                                
to1.strip_summary_ind != 'Y' AND                                                             
                                                
ti1.item_type='W'                                                            
                                                
AND t1.trade_num = @tradeNum)          AS TotalContrQty,                                                            
                                    
                                                
(select sum(tri1.contr_qty) FROM trade tr1                                                             
LEFT OUTER JOIN trade_order tro1                                                              
ON tr1.trade_num = tro1.trade_num                                                             
LEFT OUTER JOIN trade_item tri1                                                            
ON tri1.order_num =tro1.order_num AND                     
tri1.trade_num = tr1.trade_num                                                            
WHERE                                                            
tro1.strip_summary_ind != 'Y'                                                  
AND tr1.trade_num = @tradeNum)          AS TotalTermOrSpotFixedContrQty,                                                  
                                                
(select sum(ti1.contr_qty) FROM trade t1                                                            
LEFT OUTER JOIN trade_order to1                                                              
ON t1.trade_num = to1.trade_num                                                             
LEFT OUTER JOIN trade_item ti1                                                            
ON ti1.order_num =to1.order_num AND                                          
ti1.trade_num = t1.trade_num                                                            
WHERE                                                            
to1.strip_summary_ind != 'Y' AND                                                             
ti1.item_type='W' AND to1.order_num=1                                                            
AND t1.trade_num = @tradeNum)            AS TotalContrQtyForBioDWithRINS,                                                            
                                                
--            AS TotalPremium, --for OTC                                                            
                                                
ti.trading_prd                 AS TradingPrd,                                                          
                                                
(CASE WHEN ti.item_type = 'W'  THEN                                                            
                                                
(DATENAME(year, tiwp.del_date_from))+'-'+                                                            
                                                
CONVERT(VARCHAR(2),tiwp.del_date_from, 1)+'-'+                                                            
                                                
DATENAME(dd, tiwp.del_date_from) ELSE '' END)    AS DelFrom,                                                            
                                                
(CASE WHEN ti.item_type = 'W'  THEN                                                            
                                                
'- '+REPLACE(CONVERT(VARCHAR(10),                                                            
                                        
tiwp.del_date_to, 1), '/', '/') ELSE '' END)    AS DelTo,                                                            
                                            
                                                 
                                                
(SELECT TOP 1 tdd.attr_value  FROM temp_docgen_data tdd WHERE                                          
                                                
tdd.key1 = convert(VARCHAR(15),ti.trade_num) AND                                                         
                                                
tdd.key2 = convert(VARCHAR(15),ti.order_num) AND                                                         
                                                
tdd.key3 = convert(VARCHAR(15),ti.item_num)  AND                                                        
                                                
tdd.executor = @executor and                                                         
                                                
tdd.attr_name = 'priceString' ORDER BY tdd.creation_time DESC)              AS PriceString,-- there is some more logic 19                                                    
                                                
(SELECT TOP 1 tdd.attr_value  FROM temp_docgen_data tdd WHERE                                                        
                        
tdd.key1 = convert(VARCHAR(15),ti.trade_num) AND                                       
                                                
--tdd.key2 = convert(VARCHAR(15),ti.order_num) AND                                                         
                         
--tdd.key3 = convert(VARCHAR(15),ti.item_num)  AND                                                        
                                                
tdd.executor = @executor and                                                         
                                                
tdd.attr_name = 'quoteTermDesc' ORDER BY tdd.creation_time DESC)              AS QuoteTermDesc,-- there is some more logic 19                                                          
                                 
(SELECT TOP 1 tdd.attr_value  FROM temp_docgen_data tdd WHERE                                                        
                                                
tdd.key1 = convert(VARCHAR(15),ti.trade_num) AND                                                         
                                              
--tdd.key2 = convert(VARCHAR(15),ti.order_num) AND                                                         
                                                
--tdd.key3 = convert(VARCHAR(15),ti.item_num)  AND                                                        
                                                
tdd.executor = @executor and                                                         
                                                
tdd.attr_name = 'pricingPeriodString' ORDER BY tdd.creation_time DESC)             AS PricingPeriodString,-- MOH                                                 
                                     
                                                
(SELECT TOP 1 tdd.attr_value  FROM temp_docgen_data tdd WHERE                                                        
                                                
tdd.key1 = convert(VARCHAR(15),ti.trade_num) AND                                                         
                                                
tdd.key2 = convert(VARCHAR(15),ti.order_num) AND                                                          
                                                
tdd.key3 = convert(VARCHAR(15),ti.item_num)  AND                                                        
                                                
tdd.executor = @executor and                                                         
                                                
tdd.attr_name = 'formulaString' ORDER BY tdd.creation_time DESC)              AS FormulaString,-- MOH                                              
                                          
(SELECT TOP 1 tdd.attr_value  FROM temp_docgen_data tdd WHERE                                                        
                                                
tdd.key1 = convert(VARCHAR(15),ti.trade_num) AND                                                         
                         
tdd.executor = @executor and                                                         
                                          
tdd.attr_name = 'FormulaStringData' ORDER BY tdd.creation_time DESC)              AS FormulaStringMarketQuote,-- MOH                                              
                                                
(SELECT TOP 1 tdd.attr_value  FROM temp_docgen_data tdd WHERE                                                        
                                                
tdd.key1 = convert(VARCHAR(15),ti.trade_num) AND                                                         
                                                
--tdd.key2 = convert(VARCHAR(15),ti.order_num) AND                              
                                                
--tdd.key3 = convert(VARCHAR(15),ti.item_num)  AND                                                        
                                                
tdd.executor = @executor and                                                         
                                                
tdd.attr_name = 'contractMinQtyTotal' ORDER BY tdd.creation_time DESC)              AS ContractMinQtyTotal,-- MOH                                                 
                                                
(SELECT TOP 1 tdd.attr_value  FROM temp_docgen_data tdd WHERE                                                        
                 
tdd.key1 = convert(VARCHAR(15),ti.trade_num) AND                                                         
                                               
--tdd.key2 = convert(VARCHAR(15),ti.order_num) AND                                                         
                                                
--tdd.key3 = convert(VARCHAR(15),ti.item_num)  AND                                                        
                         
tdd.executor = @executor and                                                         
                                                
tdd.attr_name = 'contractMaxQtyTotal' ORDER BY tdd.creation_time DESC)              AS ContractMaxQtyTotal,-- MOH                                                 
                                                
(SELECT TOP 1 tdd.attr_value  FROM temp_docgen_data tdd WHERE                                                        
                                                
tdd.key1 = convert(VARCHAR(15),ti.trade_num) AND                                                         
                                                
--tdd.key2 = convert(VARCHAR(15),ti.order_num) AND                                                         
                                                
--tdd.key3 = convert(VARCHAR(15),ti.item_num)  AND                                                        
                                                
tdd.executor = @executor and                                    
                                                
tdd.attr_name = 'contractFixedQtyTotal' ORDER BY tdd.creation_time DESC)              AS ContractFixedQtyTotal,-- MOH                                                 
                                                        
                                     
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                                            
                                                
tdd.key1 = convert(VARCHAR(15),ti.trade_num) AND                                                         
                                                
tdd.key2 = convert(VARCHAR(15),ti.order_num) AND                                                         
                                                
tdd.key3 = convert(VARCHAR(15),ti.item_num)  AND                                      
                                                
tdd.executor = @executor and                                                          
                                                
tdd.attr_name = 'priceStringForBioDWithRins' ORDER BY tdd.creation_time DESC)   AS PriceStringForBioDWithRINS,-- there is some more logic 20                                                             
                                    
                                                            
                                                
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                      
                                                
tdd.key1 = convert(VARCHAR(15),ti.trade_num) AND                                                         
                                                
tdd.key2 = convert(VARCHAR(15),ti.order_num) AND                                                         
                                                
tdd.key3 = convert(VARCHAR(15),ti.item_num)  AND                                                      
                    
tdd.executor = @executor and                                                        
                                                
tdd.attr_name = 'formulaDescription' ORDER BY tdd.creation_time DESC)        AS FormulaDescription ,                                                               
                                                
                                                    
                                                
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                                                                                
tdd.key1 = convert(VARCHAR(15),ti.trade_num) AND                                                         
                                                
tdd.key2 = convert(VARCHAR(15),ti.order_num) AND                                                         
                                                
tdd.key3 = convert(VARCHAR(15),ti.item_num)  AND                                                          
                                                
tdd.executor = @executor and                                            
                                                
tdd.attr_name = 'deemedDueDate' ORDER BY tdd.creation_time DESC)        AS DeemedDueDate,                                                
                                         
                                                
                                                
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                                                        
                                                
tdd.key1 = convert(VARCHAR(15),ti.trade_num) AND                                                         
                                                
tdd.key2 = convert(VARCHAR(15),ti.order_num) AND                                                 
                                               
tdd.key3 = convert(VARCHAR(15),ti.item_num)  AND                                                          
                                                
tdd.executor = @executor and                                                        
                                                
tdd.attr_name = 'counterpartyAccountContactNameforContractForConfm' ORDER BY tdd.creation_time DESC)        AS counterpartyAccountContactNameforContractForConfm,                                          
                                                
                                                
                                                
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                                                 
                                                
tdd.key1 = convert(VARCHAR(15),ti.trade_num) AND                                                         
                                                
tdd.key2 = convert(VARCHAR(15),ti.order_num) AND                                                         
                                                
tdd.key3 = convert(VARCHAR(15),ti.item_num)  AND                                                          
                                                
tdd.executor = @executor and                                                        
                                                
tdd.attr_name = 'transactionPrice' ORDER BY tdd.creation_time DESC)        AS TransactionPrice ,                    
                                                
ali.origin_loc_code            AS LoadLocCode,  --m                                                
                                                
loadloc.loc_name            AS LoadLocName , --m                                                
                                                
REPLACE(CONVERT(VARCHAR(10),alit.eta_date, 1), '/', '/')     AS ETADate ,                                                
                                                
            
                            
(DATENAME(month, tiwp.del_date_from)+' '+                                                        
                                                
DATENAME(day, tiwp.del_date_from)+', '+                                                              
                                                
DATENAME(year, tiwp.del_date_from) )        AS DelDateFrom,                                                  
                                                
                                                  
                                                
(DATENAME(month, tiwp.del_date_to)+' '+                                                              
                                                
DATENAME(day, tiwp.del_date_to)+', '+                                                              
                                                
DATENAME(year, tiwp.del_date_to) )        AS DelDateTo,                                                
                                                
                                                
                                              
(DATENAME(month, tiwp.del_date_from)+' '+                                                       
                                                
DATENAME(day, tiwp.del_date_from)+'-'+                                                  
                                                
DATENAME(day, tiwp.del_date_to)+', '+                                                              
                                                
DATENAME(year, tiwp.del_date_from) )          AS DeliveryPeriod,                                                 
                                                
                                                
                                                
(DATENAME(month, ttinfo.contr_start_date)+' '+                                        
                                                DATENAME(day, ttinfo.contr_start_date)+'-'+                                                  
                                                
DATENAME(day, ttinfo.contr_end_date)+', '+                                                              
                                                
DATENAME(year, ttinfo.contr_start_date) )         AS TradeTermPeriod,                                                 
ti.contr_qty          AS TermContractQty,                                         
termuom.uom_full_name                   AS TermContrQtyUomName,                                                
                                               
--pm.pay_method_desc                      AS PaymentMethodDescription,  -- revisit                                                      
                                                
                                                                      
                                                
--ti.trade_num AS TradeNum,  duplicate                                                
                                                
--ti.order_num    AS OrderNum,                                                  
                                                
--ti.item_num              AS ItemNum,                                                  
                                                
(convert(VARCHAR, ti.trade_num)+'/'+                                                  
                                                
 convert(VARCHAR,ti.order_num) +'/'+                                                  
                                                
 convert(VARCHAR,ti.item_num ))         AS RefNR,                                                   
                                                
                                                
                                                
(DATENAME(month, t.contr_date)+' '+                                                             
                                                
DATENAME(day, t.contr_date)+', '+                                                              
                                                
DATENAME(year, t.contr_date) )         AS TradeContrDate,                                                 
                                                
CASE ti.item_type                                                 
 WHEN 'W' THEN (SELECT d.del_term_desc FROM trade_item_wet_phy w                                                 
     JOIN delivery_term d ON d.del_term_code = w.del_term_code                                 
  WHERE w.trade_num=ti.trade_num AND w.order_num=ti.order_num AND w.item_num=ti.item_num)                                                
   --TODO: ALL ITEM TYPES, S-STORAGE,T-TRANSPORT, C-CASHPHY (SWAP)                                                
    WHEN 'S' THEN (SELECT d.del_term_desc FROM trade_item_storage st                                                
     JOIN delivery_term d ON d.del_term_code = st.del_term_code                                                
  WHERE st.trade_num=ti.trade_num AND st.order_num=ti.order_num AND st.item_num=ti.item_num)                                                
                                                   
 ELSE ''                                  
END                                                
--delt.del_term_desc                                                            
AS DelTermDesc,                                                 
                                                
CASE ti.item_type                                                 
 WHEN 'W' THEN (SELECT rtrim(d.del_term_code) FROM trade_item_wet_phy w                                                 
     JOIN delivery_term d ON d.del_term_code = w.del_term_code                                                
  WHERE w.trade_num=ti.trade_num AND w.order_num=ti.order_num AND w.item_num=ti.item_num)                                                
   --TODO: ALL ITEM TYPES, S-STORAGE,T-TRANSPORT, C-CASHPHY (SWAP)                                              
    WHEN 'S' THEN (SELECT rtrim(d.del_term_code) FROM trade_item_storage st                                                
     JOIN delivery_term d ON d.del_term_code = st.del_term_code                                                
  WHERE st.trade_num=ti.trade_num AND st.order_num=ti.order_num AND st.item_num=ti.item_num)                                             
 ELSE ''                                                    
END                                                
--rtrim(delt.del_term_code)                                                   
   AS DelTermCode, -- new                                                    
                                                
titleloc.loc_name            AS TitleTransferLocation, --new                                                 
                                             
titletranscountryloc.country_name        AS TitleTransferCountry,  -- new                                                  
                                               
UPPER((DATENAME(month, t.concluded_date)+' '+                                         
                                                
DATENAME(day, t.concluded_date)+', '+                                                              
                                               
DATENAME(year, t.concluded_date) ))        AS ConcludedDate,   --new                                                  
                                                
tiwp.tol_sign             AS TolSign,  --new                                                  
                                                
isnull(tiwp.tol_qty,0)             AS TolQty,  --new                                  
                                                
tiwp.tol_qty_uom_code   AS TolQtyUomCode,  --new                                                  
                                                
tiwp.tol_opt             AS TolOpt,  --new                         
tiwp.min_qty_uom_code             AS MinTolQtyUomCode,  --#ADSO-7521                         
tiwp.max_qty_uom_code             AS MaxTolQtyUomCode,  --#ADSO-7521                                                
tiwp.density_ind  AS DensityIndicator,                                    
isnull(tiwp.min_qty,0)             AS MinTolQty,                                            
isnull(tiwp.max_qty,0)             AS MaxTolQty,                                            
--fc.formula_comp_curr_code          AS FormulaCompCurrCode,                                                 
--fc.formula_comp_uom_code           AS FormulaCompUomCode,                                                  
                                                
(select top 1  formula_comp_curr_code from formula_component                                                 
where formula_num in (select formula_num from formula  where formula_num=f.formula_num)) AS FormulaCompCurrCode,                                                   
                                                
(select top 1  formula_comp_uom_code from formula_component                                                 
where formula_num in (select formula_num from formula  where formula_num=f.formula_num))  AS FormulaCompUomCode,                                                
                                                
rtrim(ti.price_curr_code)             AS PriceCurrencyCode,                                                  
           
rtrim(ti.price_uom_code)          AS PriceUomCode,                                                 
                                                
(SELECT TOP 1 quote_diff  FROM simple_formula                                                   
                                                
WHERE quote_commkt_key in (SELECT distinct cm.commkt_key                                                   
                                        
FROM commodity_market cm                         
                                                
join formula_component fc on fc.commkt_key=cm.commkt_key                                               
                                                
join trade_formula tf on tf.formula_num=fc.formula_num                                  
                                                
join trade_item tim on tim.trade_num=tf.trade_num and                                                   
                                                
tim.order_num=tf.order_num and tim.item_num=tf.item_num                            
                                                
AND tim.trading_prd = fc.trading_prd                                                  
                                                
AND tim.trade_num =ti.trade_num AND tim.order_num=ti.order_num                                                 
                                                
AND tim.item_num = ti.item_num                                                  
                                                
join quote_pricing_period qpp on qpp.formula_num=fc.formula_num                                                  
                                                
 and qpp.formula_body_num=fc.formula_body_num                                                   
                                                
 and qpp.formula_comp_num=fc.formula_comp_num                                                  
                                                
where quote_trading_prd = qpp.real_trading_prd) )    AS QuoteDiff,                                                  
                                                
                                             
                                                
(SELECT TOP 1 quote_diff_curr_code  FROM simple_formula                                         
                                                
WHERE quote_commkt_key in (SELECT distinct cm.commkt_key                                                   
                                                
FROM commodity_market cm                                                   
                                                
join formula_component fc on fc.commkt_key=cm.commkt_key                                                   
                                                
join trade_formula tf on tf.formula_num=fc.formula_num                                                   
                                                
join trade_item tim on tim.trade_num=tf.trade_num and                                                   
                                                
tim.order_num=tf.order_num and tim.item_num=tf.item_num                                                   
                                                
AND tim.trading_prd = fc.trading_prd                                                  
                                                
AND tim.trade_num =ti.trade_num AND tim.order_num=ti.order_num                                         
                                                
AND tim.item_num = ti.item_num                                                  
                                         
join quote_pricing_period qpp on qpp.formula_num=fc.formula_num                                                  
                    
 and qpp.formula_body_num=fc.formula_body_num                                                   
                                                
 and qpp.formula_comp_num=fc.formula_comp_num                                                  
                                                
where quote_trading_prd = qpp.real_trading_prd) )    AS QuoteDiffCurrCode,                             
                                                
                                                  
                                                
(SELECT TOP 1 quote_diff_uom_code  FROM simple_formula                                          
                  
WHERE quote_commkt_key in (SELECT distinct cm.commkt_key                                                   
                                                
FROM commodity_market cm                                                   
                                                
join formula_component fc on fc.commkt_key=cm.commkt_key                                                   
                                                
join trade_formula tf on tf.formula_num=fc.formula_num                                                   
                                                
join trade_item tim on tim.trade_num=tf.trade_num and                                                   
                                                
tim.order_num=tf.order_num and tim.item_num=tf.item_num                                                   
                                                
AND tim.trading_prd = fc.trading_prd                                                  
                                                
AND tim.trade_num =ti.trade_num AND tim.order_num=ti.order_num                                                   
                                                
AND tim.item_num = ti.item_num                                                  
                                                
join quote_pricing_period qpp on qpp.formula_num=fc.formula_num                                                  
                    
 and qpp.formula_body_num=fc.formula_body_num                  
                                                
 and qpp.formula_comp_num=fc.formula_comp_num                                                  
                                                
where quote_trading_prd = qpp.real_trading_prd) )    AS QuoteDiffUomCode,                                                
                                                
spec.spec_desc              AS SpecDesc,                                       
                                                
                                                
                                                
                                  
                                                
(CASE WHEN tispec.spec_code <>'BDENSITY' AND tispec.spec_code <> 'EDENSITY'                                                            
                                                
 THEN                                                            
                                                
 tispec.spec_typical_val                                                
                                                
  ELSE                                                             
                                                
 (SELECT titspec.spec_typical_val FROM trade_item_spec titspec WHERE titspec.trade_num = ti.trade_num  AND titspec.order_num = ti.order_num                                                  
                                                
AND titspec.item_num = ti.item_num AND titspec.spec_code= 'BDENSITY' )                                                
                                                
 END)                AS SpecTypicalVal,                                                
                                                
 (SELECT titspec.spec_typical_val FROM trade_item_spec titspec WHERE titspec.trade_num = ti.trade_num  AND titspec.order_num = ti.order_num                                                  
                                                
AND titspec.item_num = ti.item_num AND titspec.spec_code= 'BDENSITY ' )   AS BDensityTypicalVal,         
        
                                              
(SELECT TOP 1 IsNull(titspec.spec_typical_val,0) FROM trade_item_spec titspec WHERE titspec.trade_num = ti.trade_num  AND titspec.order_num = ti.order_num                                                  
                                                
AND titspec.item_num = ti.item_num AND titspec.spec_code like '%API%' )   AS APITypicalVal,            
                                         
                                                
--tispec.spec_typical_val           AS SpecTypicalVal,                                                
                                
--tibdspec.spec_typical_val   AS BDensitySpecTypicalValue,                                           
                                                
excp.excp_addns_desc           AS ExepAddnsDesc,                                                  
                                                
f.formula_precision            AS  FormulaPrecision,       --NEW                                                  
                                                
ti.avg_price              AS  PriceDescription,     --NEW                                                  
                         
tiwploc.loc_name             AS  DeliveryLocation,       -- NEW                                                  
                                                
ct.credit_term_desc            AS CreditTermDesc,                                             
ct.credit_term_code            AS CreditTermCode,                                                 
                                                
aiinsp.insp_comp_short_name          AS InspCompShortName,                                                  
                                                
ali.nomin_qty_max            AS NominQtyMax,                                                  
ali.inspector_percent   AS InspectionFees,  -- AS per logistics app                                                
acctinsp.acct_short_name   AS InspectionCompany, -- AS per logistics app                                                
                                                
                                                
(DATENAME(month, alit.lay_days_start_date)+' '+                                                              
                                                
DATENAME(day, alit.lay_days_start_date)+'-'+                      
                        
DATENAME(day, alit.lay_days_end_date)+', '+                                                            
                                                
DATENAME(year, alit.lay_days_start_date) )         AS LayDays,                                                
                                                
lploc.loc_name   AS LoadPortLabel,                                                
                                                
( SELECT TOP 1 c.pay_method_code FROM cost c WHERE                                          
                                                
c.cost_owner_key6= ti.trade_num AND c.cost_owner_key7= ti.order_num AND c.cost_owner_key8 = ti.item_num)                                               
                                                
--AND c1.cost_type_code = 'PR')                                                    
                                 
                       AS PayMethodCode,                                                
                                                
(DATENAME(month, alit.bl_date)+' '+                                                              
                                                
DATENAME(day, alit.bl_date)+', '+                                                              
                                                
DATENAME(year, alit.bl_date) )         AS BLDate,                                
                                           
                                                
( SELECT sum(CASE c1.cost_pay_rec_ind WHEN 'P' THEN -c1.cost_amt ELSE c1.cost_amt END) FROM cost c1                                                 
left outer join trade_order tro1 on tro1.trade_num =@tradeNum                                                
left outer join trade_item ti1 on ti1.trade_num =@tradeNum  WHERE                                                  
c1.cost_owner_key6= ti1.trade_num AND c1.cost_owner_key7= ti1.order_num AND c1.cost_owner_key8 = ti1.item_num                                                
AND c1.cost_type_code='WPP' AND c1.cost_status <> 'CLOSED'                                                 
AND tro1.strip_summary_ind !='Y' ) AS TotalWPPCostAmt,                                                
                                                
/*( SELECT sum(CASE c.cost_pay_rec_ind WHEN 'P'THEN -c.cost_amt ELSE c.cost_amt END) FROM cost c WHERE                                                   
c.cost_owner_key6= ti.trade_num AND c.cost_owner_key7= ti.order_num AND c.cost_owner_key8 = ti.item_num                                                
AND c.cost_type_code NOT IN                                                 
('WPP', 'RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR')                                                
AND c.cost_code LIKE '%FREIGHT%' AND c.cost_status <> 'CLOSED' AND tro.strip_summary_ind !='Y'                                                
AND tro.trade_num= ti.trade_num AND tro.order_num= ti.order_num) AS TotalFreightCostAmt,*/                                       
( SELECT sum(CASE c1.cost_pay_rec_ind WHEN 'P' THEN -c1.cost_amt ELSE c1.cost_amt END) FROM cost c1                                       
left outer join trade_order tro1 on tro1.trade_num =@tradeNum                                                
left outer join trade_item ti1 on ti1.trade_num =@tradeNum  WHERE                                                   
c1.cost_owner_key6= ti1.trade_num AND c1.cost_owner_key7= ti1.order_num AND c1.cost_owner_key8 = ti1.item_num                                                
AND c1.cost_type_code NOT IN                                                 
('WPP', 'RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR')                                                
AND c1.cost_code LIKE '%FREIGHT%' AND c1.cost_status <> 'CLOSED' AND tro1.strip_summary_ind !='Y')  AS TotalFreightCostAmt,                               
                            
/*( SELECT sum(CASE c.cost_pay_rec_ind WHEN 'P'THEN -c.cost_amt ELSE c.cost_amt END) FROM cost c WHERE                                                   
c.cost_owner_key6= ti.trade_num AND c.cost_owner_key7= ti.order_num AND c.cost_owner_key8 = ti.item_num                                                
AND c.cost_type_code NOT IN                                                 
('WPP', 'RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR')                                                
AND c.cost_code LIKE '%INSPECT%' AND c.cost_status <> 'CLOSED' AND tro.strip_summary_ind !='Y'                    
AND tro.trade_num= ti.trade_num AND tro.order_num= ti.order_num) AS TotalInspectionCostAmt,*/                                                
                                                                               
--( SELECT sum(CASE c1.cost_pay_rec_ind WHEN 'P'THEN -c1.cost_amt ELSE c1.cost_amt END) FROM cost c1                                                
--left outer join trade_order tro1 on tro1.trade_num =@tradeNum                                                
--left outer join trade_item ti1 on ti1.trade_num =@tradeNum  WHERE                                                   
--c1.cost_owner_key6= ti1.trade_num AND c1.cost_owner_key7= ti1.order_num AND c1.cost_owner_key8 = ti1.item_num                                                
--AND c1.cost_type_code NOT IN                                                 
--('WPP', 'RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR')                                                
--AND (c1.cost_code not LIKE '%TRANSPRT%' or  c1.cost_code not LIKE '%INSPECT%' or  c1.cost_code not LIKE '%INSURANC%' or  c1.cost_code not LIKE '%COMMISS%' or  c1.cost_code not LIKE '%FREIGHT%')                                                 
--AND c1.cost_status <> 'CLOSED' AND tro1.strip_summary_ind !='Y')  AS TotalOtherCostAmt,                               
                            
 --for New Moh changes.  Search with other cost code                                           
                                                                                           
( SELECT sum(CASE c1.cost_pay_rec_ind WHEN 'P'THEN -c1.cost_amt ELSE c1.cost_amt END) FROM cost c1                                                
left outer join trade_order tro1 on tro1.trade_num =@tradeNum                                                
left outer join trade_item ti1 on ti1.trade_num =@tradeNum  WHERE                                 
c1.cost_owner_key6= ti1.trade_num AND c1.cost_owner_key7= ti1.order_num AND c1.cost_owner_key8 = ti1.item_num                                                
AND c1.cost_type_code NOT IN                                                 
('WPP', 'RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR')                                                
AND c1.cost_code LIKE '%BANK%' AND c1.cost_status <> 'CLOSED' AND tro1.strip_summary_ind !='Y')  AS TotalBankCostAmt,                                                
       
       
 (Case when tro.strip_summary_ind='Y'                                
 THEN                                          
                (SELECT RTRIM(LTRIM(ccode.cost_code_desc))+' '+(CASE c1.cost_amt_type WHEN 'F' THEN convert(varchar,c1.cost_amt) ELSE convert(varchar,c1.cost_unit_price) END)+' '+RTRIM(LTRIM(c1.cost_price_curr_code))+(CASE c1.cost_amt_type WHEN 'F' THEN 
'' ELSE ('/'+RTRIM(LTRIM(c1.cost_price_uom_code))) END)+'!'  as 'data()'                               
         FROM cost c1 left outer join cost_code ccode on c1.cost_code=ccode.cost_code where                              
         c1.cost_owner_key6=ti.trade_num AND      
         c1.cost_owner_key7 in(select MIN(order_num) from trade_order tro1 where tro1.trade_num=@tradeNum AND tro1.strip_summary_ind like '%N%') AND      
         c1.cost_owner_key8=1  AND                            
         (c1.cost_code LIKE  '%FREIGHT%' or c1.cost_code like'%ZIFR%')                            
         AND c1.cost_type_code NOT IN                               
         ('WPP','RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR') FOR XML path(''))                                                                                          
  
       
                               
                                
Else                                
                                                
             (SELECT RTRIM(LTRIM(ccode.cost_code_desc))+' '+(CASE c1.cost_amt_type WHEN 'F' THEN convert(varchar,c1.cost_amt) ELSE convert(varchar,c1.cost_unit_price) END)+' '+RTRIM(LTRIM(c1.cost_price_curr_code))+(CASE c1.cost_amt_type WHEN 'F' THEN '' ELSE ('/'+RTRIM(LTRIM(c1.cost_price_uom_code))) END)+'!'  as 'data()'                               
         FROM cost c1 left outer join cost_code ccode on c1.cost_code=ccode.cost_code where                               
         c1.cost_owner_key6=ti.trade_num AND      
         c1.cost_owner_key7= ti.order_num AND      
         c1.cost_owner_key8=ti.item_num  AND                            
         (c1.cost_code LIKE  '%FREIGHT%' or c1.cost_code like'%ZIFR%')                            
         AND c1.cost_type_code NOT IN                               
         ('WPP','RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR') FOR XML path(''))                                  
End                                
                                
)                      AdditionalUnitCostTransport,        
      
 (Case when tro.strip_summary_ind='Y'                        
 THEN                                          
              (SELECT RTRIM(LTRIM(ccode.cost_code_desc))+' '+(CASE c1.cost_amt_type WHEN 'F' THEN convert(varchar,c1.cost_amt) ELSE convert(varchar,c1.cost_unit_price) END)+' '+RTRIM(LTRIM(c1.cost_price_curr_code))+(CASE c1.cost_amt_type WHEN 'F' THEN ''
 ELSE ('/'+RTRIM(LTRIM(c1.cost_price_uom_code))) END)+'!'  as 'data()'                               
         FROM cost c1 left outer join cost_code ccode on c1.cost_code=ccode.cost_code where                            
         c1.cost_owner_key6=ti.trade_num AND      
         c1.cost_owner_key7 in(select MIN(order_num) from trade_order tro1 where tro1.trade_num=@tradeNum AND tro1.strip_summary_ind like '%N%') AND      
         c1.cost_owner_key8=1  AND                            
         c1.cost_code LIKE '%ZING%'                             
         AND c1.cost_type_code NOT IN                               
         ('WPP','RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR') FOR XML path(''))                                                                                          
  
    
                              
                     
Else                                
                                                
             (SELECT RTRIM(LTRIM(ccode.cost_code_desc))+' '+(CASE c1.cost_amt_type WHEN 'F' THEN convert(varchar,c1.cost_amt) ELSE convert(varchar,c1.cost_unit_price) END)+' '+RTRIM(LTRIM(c1.cost_price_curr_code))+(CASE c1.cost_amt_type WHEN 'F' THEN '' ELSE ('/'+RTRIM(LTRIM(c1.cost_price_uom_code))) END)+'!'  as 'data()'                               
         FROM cost c1 left outer join cost_code ccode on c1.cost_code=ccode.cost_code where                        
         c1.cost_owner_key6=ti.trade_num AND      
         c1.cost_owner_key7= ti.order_num AND      
         c1.cost_owner_key8=ti.item_num  AND                            
         c1.cost_code LIKE '%ZING%'                            
         AND c1.cost_type_code NOT IN                               
         ('WPP','RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR') FOR XML path('') )                                 
End                                
                                
)                     AdditionalUnitCostInsurance,        
      
 (Case when tro.strip_summary_ind='Y'                                
 THEN                                          
            (SELECT RTRIM(LTRIM(ccode.cost_code_desc))+' '+(CASE c1.cost_amt_type WHEN 'F' THEN convert(varchar,c1.cost_amt) ELSE convert(varchar,c1.cost_unit_price) END)+' '+RTRIM(LTRIM(c1.cost_price_curr_code))+(CASE c1.cost_amt_type WHEN 'F' THEN '' ELSE ('/'+RTRIM(LTRIM(c1.cost_price_uom_code))) END)+'!'  as 'data()'                               
         FROM cost c1 left outer join cost_code ccode on c1.cost_code=ccode.cost_code where                            
         c1.cost_owner_key6=ti.trade_num AND      
         c1.cost_owner_key7 in(select MIN(order_num) from trade_order tro1 where tro1.trade_num=@tradeNum AND tro1.strip_summary_ind like '%N%') AND      
         c1.cost_owner_key8=1  AND                            
         (c1.cost_code LIKE  '%ZIST%' or c1.cost_code LIKE  '%ZISG%')                            
         AND c1.cost_type_code NOT IN                               
         ('WPP','RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR') FOR XML path(''))                                                                                          
  
    
                              
                                
Else                                
                                                
             (SELECT RTRIM(LTRIM(ccode.cost_code_desc))+' '+(CASE c1.cost_amt_type WHEN 'F' THEN convert(varchar,c1.cost_amt) ELSE convert(varchar,c1.cost_unit_price) END)+' '+RTRIM(LTRIM(c1.cost_price_curr_code))+(CASE c1.cost_amt_type WHEN 'F' THEN '' ELSE ('/'+RTRIM(LTRIM(c1.cost_price_uom_code))) END)+'!'  as 'data()'                               
         FROM cost c1 left outer join cost_code ccode on c1.cost_code=ccode.cost_code where                              
         c1.cost_owner_key6=ti.trade_num AND      
         c1.cost_owner_key7= ti.order_num AND      
         c1.cost_owner_key8=ti.item_num  AND                            
        (c1.cost_code LIKE  '%ZIST%' or c1.cost_code LIKE  '%ZISG%')                          
         AND c1.cost_type_code NOT IN                               
         ('WPP','RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR') FOR XML path(''))                                  
End                                
                                
)                     AdditionalUnitCostInspection,        
      
 (Case when tro.strip_summary_ind='Y'                                
 THEN                                          
         (SELECT RTRIM(LTRIM(c1.cost_short_cmnt))+' '+(CASE c1.cost_amt_type WHEN 'F' THEN convert(varchar,c1.cost_amt) ELSE convert(varchar,c1.cost_unit_price) END)+' '+RTRIM(LTRIM(c1.cost_price_curr_code))+(CASE c1.cost_amt_type WHEN 'F' THEN '' ELSE ('
/'+RTRIM(LTRIM(c1.cost_price_uom_code))) END)+'!'  as 'data()'                                 
         FROM cost c1 where                              
         c1.cost_owner_key6=ti.trade_num AND      
         c1.cost_owner_key7 in(select MIN(order_num) from trade_order tro1 where tro1.trade_num=@tradeNum AND tro1.strip_summary_ind like '%N%') AND      
         c1.cost_owner_key8=1  AND                            
         c1.cost_code LIKE '%ZOTH%'                              
         AND c1.cost_type_code NOT IN                               
         ('WPP','RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR') FOR XML path(''))                                                                                          
  
    
                              
                                
Else                                
            
         (SELECT RTRIM(LTRIM(c1.cost_short_cmnt))+' '+(CASE c1.cost_amt_type WHEN 'F' THEN convert(varchar,c1.cost_amt) ELSE convert(varchar,c1.cost_unit_price) END)+' '+RTRIM(LTRIM(c1.cost_price_curr_code))+(CASE c1.cost_amt_type WHEN 'F' THEN '' ELSE ('
/'+RTRIM(LTRIM(c1.cost_price_uom_code))) END)+'!'  as 'data()'                          
         FROM cost c1 where                              
         c1.cost_owner_key6=ti.trade_num AND      
         c1.cost_owner_key7= ti.order_num AND      
         c1.cost_owner_key8=ti.item_num  AND                            
         c1.cost_code LIKE '%ZOTH%'                             
         AND c1.cost_type_code NOT IN                               
         ('WPP','RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR') FOR XML path('') )                                 
End                                
                                
)                     AdditionalUnitCostOthers,         
      
      
      
      
      
 (Case when tro.strip_summary_ind='Y'                                
 THEN                                          
         (SELECT sum(CASE c1.cost_pay_rec_ind WHEN 'P' THEN -c1.cost_amt ELSE c1.cost_amt END)                               
         FROM cost c1 where                              
         c1.cost_owner_key6=ti.trade_num AND      
         c1.cost_owner_key7 in(select MIN(order_num) from trade_order tro1 where tro1.trade_num=@tradeNum AND tro1.strip_summary_ind like '%N%') AND      
         c1.cost_owner_key8=1  AND                            
         (c1.cost_code like '%FREIGHT%' or c1.cost_code like'%ZIFR%')                     
         AND c1.cost_type_code NOT IN                               
         ('WPP','RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR')       
         AND c1.cost_status <> 'CLOSED')                                                                                                                        
                                
Else                                
                                                
         (SELECT sum(CASE c1.cost_pay_rec_ind WHEN 'P' THEN -c1.cost_amt ELSE c1.cost_amt END)                             
         FROM cost c1 where                              
         c1.cost_owner_key6=ti.trade_num AND      
         c1.cost_owner_key7= ti.order_num AND      
         c1.cost_owner_key8=ti.item_num  AND                            
         (c1.cost_code like '%FREIGHT%' or c1.cost_code like'%ZIFR%')                            
         AND c1.cost_type_code NOT IN                               
         ('WPP','RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR') AND       
         c1.cost_status <> 'CLOSED' )        
                                        
End                                
                                
)              As      TotalTransportationCostAmt,        
      
      
 (Case when tro.strip_summary_ind='Y'                                
 THEN                                          
         (SELECT sum(CASE c1.cost_pay_rec_ind WHEN 'P' THEN -c1.cost_amt ELSE c1.cost_amt END)                               
         FROM cost c1 where                              
         c1.cost_owner_key6=ti.trade_num AND      
         c1.cost_owner_key7 in(select MIN(order_num) from trade_order tro1 where tro1.trade_num=@tradeNum AND tro1.strip_summary_ind like '%N%') AND      
         c1.cost_owner_key8=1  AND                            
         c1.cost_code LIKE '%ZING%'                             
         AND c1.cost_type_code NOT IN                               
         ('WPP','RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR')       
         AND c1.cost_status <> 'CLOSED')                          
                                
Else                                
                                                
         (SELECT sum(CASE c1.cost_pay_rec_ind WHEN 'P' THEN -c1.cost_amt ELSE c1.cost_amt END)                             
         FROM cost c1 where                              
         c1.cost_owner_key6=ti.trade_num AND      
         c1.cost_owner_key7= ti.order_num AND      
         c1.cost_owner_key8=ti.item_num  AND                            
         c1.cost_code LIKE '%ZING%'                            
         AND c1.cost_type_code NOT IN                               
         ('WPP','RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR') AND       
         c1.cost_status <> 'CLOSED' )        
                                        
End                                
                                
)              As      TotalInsuranceCostAmt,        
      
      
 (Case when tro.strip_summary_ind='Y'                                
 THEN                                          
         (SELECT sum(CASE c1.cost_pay_rec_ind WHEN 'P' THEN -c1.cost_amt ELSE c1.cost_amt END)                               
         FROM cost c1 where                              
         c1.cost_owner_key6=ti.trade_num AND      
         c1.cost_owner_key7 in(select MIN(order_num) from trade_order tro1 where tro1.trade_num=@tradeNum AND tro1.strip_summary_ind like '%N%') AND      
         c1.cost_owner_key8=1  AND                            
         (c1.cost_code LIKE '%ZISG%' OR c1.cost_code LIKE '%ZIST%')                            
         AND c1.cost_type_code NOT IN                               
         ('WPP','RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR')       
         AND c1.cost_status <> 'CLOSED')                                                                                                                        
                                
Else                                
                                                
         (SELECT sum(CASE c1.cost_pay_rec_ind WHEN 'P' THEN -c1.cost_amt ELSE c1.cost_amt END)                             
         FROM cost c1 where                              
         c1.cost_owner_key6=ti.trade_num AND      
         c1.cost_owner_key7= ti.order_num AND      
         c1.cost_owner_key8=ti.item_num  AND                            
         (c1.cost_code LIKE '%ZISG%' OR c1.cost_code LIKE '%ZIST%')                          
         AND c1.cost_type_code NOT IN                               
         ('WPP','RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR') AND       
         c1.cost_status <> 'CLOSED' )        
                                        
End                                
                                
)              As      TotalInspectionCostAmt,       
      
      
 (Case when tro.strip_summary_ind='Y'                                
 THEN                                          
         (SELECT sum(CASE c1.cost_pay_rec_ind WHEN 'P' THEN -c1.cost_amt ELSE c1.cost_amt END)                               
         FROM cost c1 where                              
         c1.cost_owner_key6=ti.trade_num AND      
         c1.cost_owner_key7 in(select MIN(order_num) from trade_order tro1 where tro1.trade_num=@tradeNum AND tro1.strip_summary_ind like '%N%') AND      
         c1.cost_owner_key8=1  AND                            
         c1.cost_code LIKE '%ZOTH%'                             
         AND c1.cost_type_code NOT IN                               
         ('WPP','RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR')       
         AND c1.cost_status <> 'CLOSED')                                                                                                                        
                                
Else     
                                                
         (SELECT sum(CASE c1.cost_pay_rec_ind WHEN 'P' THEN -c1.cost_amt ELSE c1.cost_amt END)                             
         FROM cost c1 where                              
         c1.cost_owner_key6=ti.trade_num AND      
         c1.cost_owner_key7= ti.order_num AND      
         c1.cost_owner_key8=ti.item_num  AND                            
         c1.cost_code LIKE '%ZOTH%'                           
         AND c1.cost_type_code NOT IN                               
         ('WPP','RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR') AND       
         c1.cost_status <> 'CLOSED' )        
                                        
End                                
                                
)              As      TotalOtherCostAmt,      
      
      
 (Case when tro.strip_summary_ind='Y'                                
 THEN                                          
         (SELECT sum(CASE c1.cost_pay_rec_ind WHEN 'P' THEN -c1.cost_amt ELSE c1.cost_amt END)                               
         FROM cost c1 where                              
         c1.cost_owner_key6=ti.trade_num AND      
         c1.cost_owner_key7 in(select MIN(order_num) from trade_order tro1 where tro1.trade_num=@tradeNum AND tro1.strip_summary_ind like '%N%') AND      
         c1.cost_owner_key8=1  AND                            
         c1.cost_code LIKE '%BROKERAG%'                             
         AND c1.cost_type_code NOT IN     
         ('WPP','RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR')       
         AND c1.cost_status <> 'CLOSED')                                                                                                                        
                                
Else                                
                                                
         (SELECT sum(CASE c1.cost_pay_rec_ind WHEN 'P' THEN -c1.cost_amt ELSE c1.cost_amt END)                             
         FROM cost c1 where                              
         c1.cost_owner_key6=ti.trade_num AND      
         c1.cost_owner_key7= ti.order_num AND      
         c1.cost_owner_key8=ti.item_num  AND                            
         c1.cost_code LIKE '%BROKERAG%'                           
         AND c1.cost_type_code NOT IN                               
         ('WPP','RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR') AND       
         c1.cost_status <> 'CLOSED' )        
                                        
End                                
                                
)             as TotalComissionCostAmt,      
                                                
                                                
                                                
(SELECT isnull(strip_detail_order_count,0)                                  
      FROM dbo.trade_order                                   
       WHERE strip_summary_ind='Y'  AND trade_num=ti.trade_num  and order_num =ti.order_num) as StripCount,                                                
(select tro.strip_detail_order_count ) as EstimatedDeliveries ,                                                
                                            
(select tiwp1.del_date_from from trade_item_wet_phy tiwp1 where                                                 
tiwp1.trade_num = @tradeNum and                                                 
tiwp1.order_num =(select min(to1.order_num) from trade_order to1 where to1.trade_num = @tradeNum) and                                                
tiwp1.item_num = (select min(ti1.item_num) from trade_item ti1 where ti1.trade_num = @tradeNum) ) TermDelDateFrom,                               
                                                
(select tiwp1.del_date_to from trade_item_wet_phy tiwp1 where                                                 
tiwp1.trade_num = @tradeNum and                                                 
tiwp1.order_num =(select max(to1.order_num) from trade_order to1 where to1.trade_num = @tradeNum) and                                                
tiwp1.item_num = (select max(ti1.item_num) from trade_item ti1 where ti1.trade_num = @tradeNum)  ) TermDelDateTo,                                                
                                                
                                                
( SELECT TOP 1 ltrim(rtrim(c.cost_price_curr_code)) FROM cost c WHERE                                                   
                                                
c.cost_owner_key6= ti.trade_num AND c.cost_owner_key7= ti.order_num AND c.cost_owner_key8 = ti.item_num                                          
                                                
AND c.cost_type_code='WPP') AS CostPriceCurrCode,                                                
                                                
                                 
(Case when tro.strip_summary_ind='Y'                                
 then                                          
                                            
     ( CASE WHEN (SELECT TOP 1 c2.cost_amt_type FROM                                                         
                                                
      cost c2 WHERE  c2.cost_owner_key6= ti.trade_num AND c2.cost_owner_key7= ti.order_num AND c2.cost_owner_key8 = ti.item_num                            
                                                
      AND c2.cost_type_code='WPP') ='F' THEN                                                        
                                                
      0.0                                                
                                                
      ELSE                                                    
                                                
     (SELECT TOP 1 c3.cost_unit_price FROM                                                         
                                 
      cost c3 WHERE  c3.cost_owner_key6= ti.trade_num AND c3.cost_owner_key7 in(select MIN(order_num) from trade_order tro1 where tro1.trade_num=@tradeNum AND tro1.strip_summary_ind like '%N%') AND c3.cost_owner_key8 = 1                                  
  
     
     
        
              
                                                
      AND c3.cost_type_code='WPP') END)                                   
Else                                
     ( CASE WHEN (SELECT TOP 1 c2.cost_amt_type FROM                         
                                                
      cost c2 WHERE  c2.cost_owner_key6= ti.trade_num AND c2.cost_owner_key7= ti.order_num AND c2.cost_owner_key8 = ti.item_num                                                
                                                
      AND c2.cost_type_code='WPP') ='F' THEN                                                        
                                                
      0.0                          
                                                
      ELSE                                                    
                                                
     (SELECT TOP 1 c3.cost_unit_price FROM                                                         
                                                
      cost c3 WHERE  c3.cost_owner_key6= ti.trade_num AND c3.cost_owner_key7= ti.order_num AND c3.cost_owner_key8 = ti.item_num                                                
                                   
       AND c3.cost_type_code='WPP') END)                                  
End                                
                                
)                      AS CostUnitPriceStrInfo,                                      
                                                
                                                
                                                
( SELECT TOP 1 ltrim(rtrim(c.cost_price_uom_code)) FROM cost c WHERE                                                   
                                                
c.cost_owner_key6= ti.trade_num AND c.cost_owner_key7= ti.order_num AND c.cost_owner_key8 = ti.item_num                                                
                                                
AND c.cost_type_code='WPP') AS CostPriceUomCodeInfo,                                                
                                                
                                                
                                                
                                                
                                                
isnull(bookComp.bank_name,'')  + CHAR(10) + convert(VARCHAR(10),bookComp.bank_acct_no) +  CHAR(10) + isnull(bookComp.acct_bank_routing_num,'')                                                  
                                                
+ '  ' + isnull(bookComp.swift_code,'') + CHAR(10) + isnull(bookComp.corresp_bank_name,'') + CHAR(10) + isnull(bookComp.corresp_bank_acct_no,'') +                                                
                                                
 +  CHAR(10) + isnull(bookComp.corresp_bank_routing_num,'') + ' ' + isnull(bookComp.corresp_swift_code,'') + CHAR(10) + isnull(bookComp.further_credit_to,'') +                                                
                                                
  CHAR(10) + isnull(bookComp.further_credit_to_ext_acct_key,'')             
                                                
AS BookingCompBankInfo,                                                
                                                
                                                 
                                                
 ( SELECT sum(c.cost_amt) FROM cost c WHERE                                                   
                                                
c.cost_owner_key6= ti.trade_num AND c.cost_owner_key7= ti.order_num AND c.cost_owner_key8 = ti.item_num                                                
                                                
AND c.cost_status <> 'CLOSED' AND c.cost_code LIKE '%DEMURR%') AS TotalDemurrCostAmt,                                                
                                                
                                                
                                                
secc.cost_code            AS CostCodeForSecondaryCost,                                                 
                                                
secc.cost_type_code            AS CostTypeCodeForSecondaryCost,                            
                                                
(CASE WHEN secc.cost_pay_rec_ind ='P' THEN                                                        
                                                
        (secc.cost_amt * -1)                                                         
                                                
        WHEN secc.cost_pay_rec_ind ='R' THEN                                                        
                                                
  secc.cost_amt                                                        
                                                
         END )              AS CostAmtForSecondaryCost,                                        
                                                
(DATENAME(month, secc.cost_due_date)+' '+                                                              
                                                
DATENAME(day, secc.cost_due_date)+', '+                                                    
                                                
DATENAME(year, secc.cost_due_date) )         AS CostDueDateForSecondaryCost,                                                
                                                
ccode.cost_code_desc    AS CostCodeDescForSecondaryCost,                                                
                                                
(DATENAME(month, p.estimated_date)+' '+                                                              
                                                
DATENAME(day, p.estimated_date)+', '+                                                              
                        
DATENAME(year, p.estimated_date) )   AS EstimatedDate,                                                
                                                
(DATENAME(month, p.sch_from_date)+' '+                                                              
                                 
DATENAME(day, p.sch_from_date)+', '+                                                  
                                                
DATENAME(year, p.sch_from_date) )     AS SchFromDate,                                                
                                                
(DATENAME(month, p.sch_to_date)+' '+                                                              
                                                
DATENAME(day, p.sch_to_date)+', '+                                                              
                                                
DATENAME(year, p.sch_to_date) )    AS SchToDate,              
                                                
                                                
-- tags                                                
(SELECT TOP 1 Upper(target_key1)  FROM entity_tag  et WHERE et.key1=Convert(VARCHAR,@tradeNum) AND  et.entity_tag_id =                                                 
(SELECT TOP 1 etd.oid FROM  entity_tag_definition etd                                       
WHERE etd.entity_tag_name = 'MOHGuarSpecTI' AND etd.tag_status='A' and etd.entity_id=                                                 
(SELECT oid FROM icts_entity_name WHERE entity_name='TradeItem')))       AS GuaranteedSpec,                                                
                                              
(SELECT TOP 1 Upper(target_key1)  FROM entity_tag  et WHERE et.key1=Convert(VARCHAR,@tradeNum) AND  et.entity_tag_id =                            
(SELECT TOP 1 etd.oid FROM  entity_tag_definition etd                                                  
WHERE etd.entity_tag_name = 'BaseOnWhatQty' AND etd.tag_status='A' and etd.entity_id=                                                 
(SELECT oid FROM icts_entity_name WHERE entity_name='TradeItem')))       AS BasePriceOnWhichQty,                                                
                                                
(SELECT TOP 1 Upper(target_key1)  FROM entity_tag  et WHERE et.key1=Convert(VARCHAR,@tradeNum) AND  et.entity_tag_id =                                                 
(SELECT TOP 1 etd.oid FROM  entity_tag_definition etd                                                  
WHERE etd.entity_tag_name = 'QuantIsBinding' AND etd.tag_status='A' and etd.entity_id=                                                 
(SELECT oid FROM icts_entity_name WHERE entity_name='TradeItem')))       AS QuantityBinding,                                                    
                                                
(SELECT TOP 1 Upper(target_key1)  FROM entity_tag  et WHERE et.key1=Convert(VARCHAR,@tradeNum) AND  et.entity_tag_id =                                                 
(SELECT TOP 1 etd.oid FROM  entity_tag_definition etd                                                  
WHERE etd.entity_tag_name = 'QualityIsBinding' AND etd.tag_status='A' and etd.entity_id=                                        
(SELECT oid FROM icts_entity_name WHERE entity_name='TradeItem')))       AS QualityBinding,                                                
                                                
--Upper(et.target_key1)      AS GuaranteedSpec,                                      
--Upper(etbp.target_key1)      AS BasePriceOnWhichQty,                                                
--Upper(etqb.target_key1)      AS QuantityBinding,                                                
--Upper(etqlb.target_key1)     AS QualityBinding,                                                
                                                
--                                                
s.start_loc_code       AS StartLocCode,                                                
lloc.loc_name        AS StartLocName,                                                
(DATENAME(month, s.start_date )+' '+                        
DATENAME(day, s.start_date )+', '+                                                  
DATENAME(year, s.start_date ) )    AS LoadDate, --added                                                
disport.loc_name       AS DischargePortLocName,                                                
countr.country_name       AS DischPortCountry,                                                
loadPortcountr.country_name  AS LoadPortCountry,                                              
locExt.state_code       AS DischPortLocStateCode,                                                
cmdtyprice.cmdty_full_name AS UnitPriceCurrencyDescription,                                                
priceuom.uom_full_name      AS PriceUomCodeDescription,                                                
                                                
                                                
(SELECT TOP 1 formula_comp_val_type                                 
from formula_component where                                                 
formula_comp_type = 'G'                                                
and formula_num in                                                 
(select TOP 1 formula_num from trade_formula where                                          
trade_num = @tradeNum and fall_back_ind = 'N') )    AS FormulaValueType,                                                 
                                                
(SELECT TOP 1                                                 
CASE formula_comp_val_type                                                 
WHEN 'L' THEN 'LOW'                                                
WHEN 'H' THEN 'HIGH'                                                 
WHEN 'E' THEN 'ESTIMATED'                                                
WHEN 'A' THEN  'AVERAGE'                                                
WHEN 'C' THEN  'CLOSE'                                                
END                                                
                                                
from formula_component where                                                 
formula_comp_type = 'G'                                           
and formula_num in                                                 
(select TOP 1 formula_num from trade_formula where                                
trade_num = @tradeNum and fall_back_ind = 'N') )    AS FormulaValueTypeText,                                                 
                                                
                                                
(select top 1 cmdty_full_name from commodity where cmdty_code IN  (                                                
select cmdty_code from commodity_market where commkt_key in                                                 
(select commkt_key from formula_component where                                                 
formula_comp_type = 'G'                                                 
and formula_num in (select  TOP 1 formula_num FROM  trade_formula where trade_num = @tradeNum and fall_back_ind = 'N')) )) AS FormulaCmdtyFullName,                                                
                                                
(select top 1 cmdty_short_name from commodity where cmdty_code IN  (                                                
select cmdty_code from commodity_market where commkt_key in                                                 
(select commkt_key from formula_component where                           
formula_comp_type = 'G'                                                 
and formula_num in (select  TOP 1 formula_num FROM  trade_formula where trade_num = @tradeNum and fall_back_ind = 'N')) )) AS FormulaCmdtyShortName,                                                
                                                
                                                
(select top 1 price_source_code from formula_component where                                                 
formula_comp_type = 'G'                                                
and formula_num in (select  TOP 1 formula_num from trade_formula where trade_num = @tradeNum and fall_back_ind = 'N')) AS FormulaPublication,                                                
                                                
(select top 1 mkt_full_name from market where mkt_code in (                                                
select mkt_code from commodity_market where commkt_key in                                                 
(select commkt_key from formula_component where                                                 
formula_comp_type = 'G'                                                 
and formula_num in (select  TOP 1 formula_num from trade_formula where trade_num = @tradeNum and fall_back_ind = 'N')) )) AS FormulaMktFullName,                                                
                                                
(select top 1 formula_body_string from formula_body where                                                 
formula_body_type = 'P'                                                 
and formula_num in (select  TOP 1 formula_num from trade_formula where trade_num = @tradeNum and fall_back_ind = 'N')) AS FormulaPlusMinusEstimOrDiffe,                                                
                                                
(SELECT top 1  abs(differential_val) from formula_body where                                                 
formula_body_type = 'P'                                                 
and formula_num in (select  TOP 1 formula_num from trade_formula where trade_num = @tradeNum and fall_back_ind = 'N')) AS FormulaDifferentialValAbsolute,                                   
                                               
(SELECT top 1 CONVERT(varchar(10), abs(differential_val)) + '.00' from formula_body where                                                 
formula_body_type = 'P'                                                 
and formula_num in (select  TOP 1 formula_num from trade_formula where trade_num = @tradeNum and fall_back_ind = 'N')) AS FormulaDifferentialValAbsString,                                                
                                                
                                                
(SELECT top 1 differential_val from formula_body where                                             
formula_body_type = 'P'                                                 
and formula_num in (select  TOP 1 formula_num from trade_formula where trade_num = @tradeNum and fall_back_ind = 'N')) AS FormulaDifferentialVal,                                          
                                                
(select top 1 CASE                                                 
WHEN differential_val < 0 THEN 'MINUS'                                                
ELSE 'PLUS'                                                
END                                                
 from formula_body where                                                 
formula_body_type = 'P'                                                 
and formula_num in (select TOP 1 formula_num from trade_formula where trade_num = @tradeNum and fall_back_ind = 'N')) AS FormulaDifferentialValPlusMinusText,                                                
                                                
                                                
(select top 1 formula_comp_val from formula_body fb, formula_component fc where                                                
fb.formula_num = fc.formula_num                                                
and formula_body_type in ('P','M')                                                
and formula_comp_type = 'U'                                                
and fb.formula_num in (select  TOP 1 formula_num from trade_formula where trade_num = @tradeNum and fall_back_ind = 'N')) AS FormulaEstimOrDiffe,                                                
                                                
(select top 1 formula_comp_curr_code from formula_body fb, formula_component fc where                                                
fb.formula_num = fc.formula_num                                                
and formula_body_type in ('P','M')                                                
and formula_comp_type = 'U'                                                
and fb.formula_num in (select  TOP 1 formula_num from trade_formula where trade_num = @tradeNum and fall_back_ind = 'N')) AS FormulaCurrCode,                                                
                                                
                                                
(select top 1 formula_comp_uom_code from formula_body fb, formula_component fc where                                                
fb.formula_num = fc.formula_num                                                
and formula_body_type in ('P','M')                                                
and formula_comp_type = 'U'                                                
and fb.formula_num in (select  TOP 1 formula_num from trade_formula where trade_num = @tradeNum and fall_back_ind = 'N')) AS FormulaUomCode,               
              
(select  top 1 ISNULL(differential_val,0) from formula_body where               
(formula_body_type like '%P%' or formula_body_type like '%Q%') AND               
complexity_ind like '%S%' AND               
formula_num in (select  top 1 formula_num from trade_formula where trade_num = @tradeNum and fall_back_ind like '%N%')) As FormulaDifferentialValSimple,                
              
              
(select top 1 ISNULL(differential_val,0) from formula_body  where formula_body_type like '%M%' AND formula_num in               
(select  top 1 formula_num from trade_formula where trade_num = @tradeNum and fall_back_ind like '%N%'))   As FormulaPremiumVal,              
              
f.formula_curr_code as 'FormulaCurrCodeStr',f.formula_uom_code as 'FormulaUomCodeStr',            
        
(select top 1 ISNULL(formula_comp_val,0.0) from formula_component fc where fc.formula_comp_type like '%U%' AND         
(fc.formula_comp_name like '%FREIGHT_DESC%' OR fc.formula_comp_name like '%FREIGHT_ESC%') AND         
fc.formula_num in (select  top 1 formula_num from trade_formula where trade_num = @tradeNum and fall_back_ind like '%N%')) As FormulaComponentValueFreight,        
              
                                       
                                                
                                                
cmt.cmnt_text                AS LongComments,                                              
                                              
(SELECT TOP 1 tdd.attr_value  FROM temp_docgen_data tdd WHERE                                                        
                                                
tdd.key1 = convert(VARCHAR(15),ti.trade_num) AND                                                         
                                                
tdd.key2 = convert(VARCHAR(15),ti.order_num) AND                                                         
                                                
tdd.key3 = convert(VARCHAR(15),ti.item_num)  AND                                                        
                                                
tdd.executor = @executor and                                                         
                                                
tdd.attr_name = 'netQuoteSwapReceivable' ORDER BY tdd.creation_time DESC)       AS NetQuoteSwapReceivable,                                                                                   
(SELECT TOP 1 tdd.attr_value  FROM temp_docgen_data tdd WHERE                                                        
                                                
tdd.key1 = convert(VARCHAR(15),ti.trade_num) AND                                                         
                                                
tdd.key2 = convert(VARCHAR(15),ti.order_num) AND                                                         
                                                
tdd.key3 = convert(VARCHAR(15),ti.item_num)  AND                                                        
                                                
tdd.executor = @executor and                                                         
           
tdd.attr_name = 'netQuoteSwapPayable' ORDER BY tdd.creation_time DESC)              AS NetQuoteSwapPayable,                                              
                                              
cmdtyprice.cmdty_full_name as PriceCurrencyFullName,                                              
                                              
ti.gtc_code as GtcCode,                                              
                                              
gtco.gtc_desc as GtcDescription                          
                                                
                                                
                                            
--secc.cost_due_date   AS CostDueDateForSecondaryCost                                                
                                                
--sum(secc.cost_amt)   AS TotalCostAmtForSecondaryCost                                                
                                
                         
                                                      
                          
                                                            
                                                
                                                            
               
FROM trade t LEFT OUTER JOIN icts_user iu                                                            
                                                
ON t.trader_init = iu.user_init                                                    
--BELOW FOR PMI                                                
LEFT OUTER JOIN (SELECT TOP 1 mn.* FROM icts_user mn                                                
 WHERE mn.user_init IN                                                 
  ( SELECT d.manager_init                                                
  FROM icts_user iu JOIN department d ON iu.desk_code=d.dept_code                                                
  JOIN trade trd ON iu.user_init = trd.trader_init                                                 
  WHERE trd.trade_num = @tradeNum )                                                
 ) AS mngr                                    
 ON t.trade_num = @tradeNum                                                
                                                
                                                
LEFT OUTER JOIN account cp                                                            
                                                
ON t.acct_num = cp.acct_num                                                          
                                                
LEFT OUTER JOIN (select top 1 ad.* from trade tr left outer join account_address ad                                                             
                                                
         on tr.acct_num = ad.acct_num                                             
                                                
   where ad.acct_addr_status = 'A' and tr.trade_num = @tradeNum) as cpa -------------trade_num Input                                                            
                                                
ON t.acct_num = cpa.acct_num                                                      
                                                
LEFT OUTER JOIN (select top 1 ad.* from trade tr left outer join account_contact ad                                                             
                                                
         on tr.acct_num = ad.acct_num                                                             
                                                
         where ad.acct_cont_status = 'A' and tr.trade_num = @tradeNum) cpac -------------trade_num Input                                                            
                                             
ON t.acct_num = cpac.acct_num                                                            
                          
LEFT OUTER JOIN trade_order tro                                                            
                                                
ON t.trade_num = tro.trade_num                                                            
                                     
LEFT OUTER JOIN  trade_item ti                                                     
                                                
ON t.trade_num = ti.trade_num AND ti.order_num = tro.order_num                                                            
                                                
LEFT OUTER JOIN trade_comment tc                                                             
                                                
ON t.trade_num = tc.trade_num AND tc.trade_cmnt_type ='T'                                                            
                                                
LEFT OUTER JOIN comment cmt             
                                                
ON tc.cmnt_num = cmt.cmnt_num                                                  
                
left outer join cost secc                                                        
                                                
on secc.cost_owner_key6 = ti.trade_num AND secc.cost_owner_key7= ti.order_num AND secc.cost_owner_key8= ti.item_num                                                 
                                                
AND secc.cost_status='OPEN'                                             
                                                
AND secc.cost_prim_sec_ind='S'                                                
                                                
AND secc.cost_owner_code IN ('A','AI')                                                
                                                
LEFT OUTER JOIN cost_code ccode                                                
                                                
ON ccode.cost_code = secc.cost_code                                                
                                                
                           
                                                
--AND secc.cost_type_code NOT IN                                                 
                                                
--('WPP', 'RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR')                                                           
                                                
--LEFT OUTER JOIN comment trcmt                                                            
                                                
--ON trcmt.cmnt_num = (SELECT ti1.cmnt_num FROM trade_item ti1 WHERE ti1.order_num=1 AND ti1.item_num =1 AND ti1.trade_num=@tradeNum)                                                            
                                                
                                                            
                                                
                                                            
                                                
LEFT OUTER JOIN account bp                                
                                                
ON ti.booking_comp_num = bp.acct_num                                                            
                                                
LEFT OUTER JOIN ( SELECT TOP 1 aa.* FROM trade t1                                                             
                                                
     right OUTER JOIN trade_order tr1                                                            
                                                
     ON t1.trade_num = tr1.trade_num                                                            
                                                
     LEFT OUTER JOIN trade_item ti1                                                            
                                                
     ON tr1.order_num = ti1.order_num AND t1.trade_num=ti1.trade_num                                    
                                                
     LEFT OUTER JOIN account_address aa                                                            
                                                
     ON  ti1.booking_comp_num = aa.acct_num                
                                                
                                                                 
                                                
     WHERE     t1.trade_num =  @tradeNum AND aa.acct_addr_status ='A') bpa                                                     
                                                
ON ti.booking_comp_num = bpa.acct_num   --AND bpa.acct_addr_num = 1-- (SELECT TOP 1 bpa.acct_addr_num WHERE bpa.acct_num = bp.acct_num )                                                            
                                                
                                                            
                                                
LEFT OUTER JOIN (SELECT TOP 1 ac.* FROM trade t1                                       
                                                
     LEFT OUTER JOIN trade_order tr1                                                            
                                                
     ON t1.trade_num = tr1.trade_num                                                   
                                                
     LEFT OUTER JOIN trade_item ti1                                                            
                                                
     ON tr1.order_num = ti1.order_num AND t1.trade_num=ti1.trade_num                                                             
                     LEFT OUTER JOIN account_contact ac                                                           
                                                
  ON  ti1.booking_comp_num = ac.acct_num                                                                  
                                                
     WHERE     t1.trade_num =  @tradeNum AND ac.acct_cont_status ='A')  bpac  -------------trade_num Input                                                            
                                                
ON ti.booking_comp_num = bpac.acct_num                                                       
                                                
 LEFT OUTER JOIN (SELECT TOP 1 ac.* FROM trade t1                                                             
                                                
     LEFT OUTER JOIN trade_order tr1                                                            
                                                
     ON t1.trade_num = tr1.trade_num                                                            
                                                
     LEFT OUTER JOIN trade_item ti1                                                            
                                                
     ON tr1.order_num = ti1.order_num AND t1.trade_num=ti1.trade_num                                                             
                                                
     LEFT OUTER JOIN account_contact ac                                                            
                                                
     ON  ti1.brkr_num = ac.acct_num                                                                  
                                                
     WHERE     t1.trade_num =  @tradeNum AND ac.acct_cont_status ='A')  brkrac  -------------trade_num Input                                                            
                                                
ON ti.brkr_num = brkrac.acct_num                                                           
                                                            
                                      
LEFT OUTER JOIN account brkr                                        
                                                
ON ti.brkr_num = brkr.acct_num                                                             
                                                
LEFT OUTER JOIN commodity cmdty                                                            
                                                
ON ti.cmdty_code=cmdty.cmdty_code                                                            
                                                
LEFT OUTER JOIN  trade_item_wet_phy tiwp                                                            
                                                
ON ti.trade_num = tiwp.trade_num AND                                                            
                                               
   ti.order_num = tiwp.order_num AND                                                             
                                                
   ti.item_num = tiwp.item_num                                                             
                                                
LEFT OUTER JOIN location dl                                                            
                  
ON tiwp.del_loc_code = dl.loc_code                                                            
                                                
LEFT OUTER JOIN mot m                                                            
                                                
ON tiwp.mot_code = m.mot_code                                                            
                                                
LEFT OUTER JOIN mot_type mt                                                            
                                                
ON m.mot_type_code = mt.mot_type_code                                                            
                                                
LEFT OUTER JOIN payment_term pt                        
                                                
ON tiwp.pay_term_code = pt.pay_term_code                                                 
             
LEFT OUTER JOIN trade_formula tf                                                            
                                                
ON ti.trade_num =tf.trade_num AND                                                            
                                                
 ti.order_num = tf.order_num AND                                                            
                                                
 ti.item_num = tf.item_num AND                                                            
                                                
 tf.fall_back_ind = 'N' AND ti.formula_ind ='Y'                                                      
                          
LEFT OUTER JOIN formula f                                                     
                                                
ON tf.formula_num = f.formula_num                                                            
                                                
LEFT OUTER JOIN avg_buy_sell_price_term apt                                                            
                                                
ON f.formula_num = apt.formula_num                                                            
                                                
--LEFT OUTER JOIN temp_docgen_data tdd                                                            
                                                
--ON tdd.key1 = convert(VARCHAR(15),ti.trade_num) AND tdd.key2 = convert(VARCHAR(15),ti.order_num) AND tdd.key3 = convert(VARCHAR(15),ti.item_num)                                                             
                                                
--LEFT OUTER JOIN formula_condition fcnd                                                            
                                                
--ON f.formula_num = fcnd.formula_num                                                   
                                                
left outer join uom qtyuom                                                
                                                
on ti.contr_qty_uom_code =qtyuom.uom_code                                                    
                                                
left outer join uom priceuom                                                
                                                
on ti.price_uom_code =priceuom.uom_code                                            
                                                
left outer join allocation_item ali                                               
          
ON ali.trade_num = ti.trade_num AND ali.order_num= ti.order_num AND ali.item_num =ti.item_num                                                
                                                
left outer join account acctinsp                                                 
                                                
ON acctinsp.acct_num = ali.insp_acct_num                                                
                                                
LEFT OUTER JOIN allocation_item_transport alit                                                  
                      
ON  alit.alloc_num = ali.alloc_num AND  alit.alloc_item_num = ali.alloc_item_num    --parcel                                                
                                                
LEFT OUTER JOIN parcel p                                                
                                                
ON p.trade_num= @tradeNum AND p.alloc_num= ali.alloc_num AND p.alloc_item_num=ali.alloc_item_num                                                  
                     
LEFT OUTER JOIN shipment s                                                
                                                
ON s.oid = p.shipment_num                                                
                                                
                                                
                                                
LEFT OUTER JOIN location loadloc                                                  
                                                
ON loadloc.loc_code = ali.origin_loc_code                                                  
                                 
LEFT OUTER JOIN uom u                            
                                                
ON u.uom_code = ti.contr_qty_uom_code                                                 
                                                
--LEFT OUTER JOIN delivery_term delt                                                  
                                                
--ON delt.del_term_code = tiwp.del_term_code                                                  
                                                
LEFT OUTER JOIN location titleloc                                            
                                                
ON titleloc.loc_code = ali.title_tran_loc_code                                                
                                                
LEFT OUTER JOIN allocation_item_vat alivat                                                  
                                                
ON alivat.alloc_num= ali.alloc_num AND alivat.alloc_item_num= ali.alloc_item_num                                                   
                                                
LEFT OUTER JOIN country titletranscountryloc                                                        
                                                
ON titletranscountryloc.country_code = alivat.title_transfer_country_code                                                 
                                                
 --LEFT OUTER JOIN formula_component fc                                              
                                                
--ON fc.formula_num = tf.formula_num                                                  
                                                
LEFT OUTER JOIN trade_item_spec tispec                                                  
                                                
ON tispec.trade_num = ti.trade_num AND tispec.order_num = ti.order_num AND tispec.item_num = ti.item_num                                                 
                                                
--LEFT OUTER JOIN trade_item_spec tiBDspec                                                  
                                                
--ON tiBDspec.trade_num = ti.trade_num AND tibdspec.order_num = ti.order_num AND tibdspec.item_num = ti.item_num AND tibdspec.spec_code='BDENSITY'                                                
                                                
LEFT OUTER JOIN specification spec                                            
                                                
ON spec.spec_code= tispec.spec_code                                                   
                                             
LEFT OUTER JOIN exceptions_additions excp                                                  
                                                
ON excp.excp_addns_code= ti.excp_addns_code                                               
         
LEFT OUTER JOIN location tiwploc                                                  
                                                
ON tiwploc.loc_code = tiwp.del_loc_code                                                 
                                                
LEFT OUTER JOIN credit_term ct                                                  
                                                
ON ct.credit_term_code = tiwp.credit_term_code                                                  
                                                
LEFT OUTER JOIN allocation_item_insp aiinsp                                                  
                                                
ON aiinsp.alloc_num = alit.alloc_num AND aiinsp.alloc_item_num= alit.alloc_item_num                                                   
                                                
LEFT OUTER JOIN location lploc                                                  
                                                
ON lploc.loc_code= ti.load_port_loc_code                                                 
                                          
LEFT OUTER JOIN location lloc                                                  
                                                
ON lloc.loc_code= s.start_loc_code                                                 
                                                
                                                
                                                
--left outer join cost c                                                        
                                                
--on c.cost_owner_key6= ti.trade_num AND c.cost_owner_key7= ti.order_num AND c.cost_owner_key8 = ti.item_num                                                 
                                                
                                                
                                     
left outer join payment_method pm                                                        
                                                
on  pm.pay_method_code  = ( SELECT TOP 1 c1.pay_method_code FROM cost c1 WHERE                                                   
                                                
c1.cost_owner_key6= ti.trade_num AND c1.cost_owner_key7= ti.order_num AND c1.cost_owner_key8 = ti.item_num)                                                 
                                                
                                                
                                                
LEFT OUTER JOIN account_bank_info bookComp                                                  
                                        
ON bookComp.acct_num = ti.booking_comp_num AND bookComp.book_comp_num= ti.booking_comp_num                                                 
                                                
LEFT OUTER JOIN trade_term_info ttinfo                                                  
                                                
ON ttinfo.trade_num = @tradeNum                                                
                                                
left outer join uom termuom                                                
                                                
on ttinfo.trade_num = @tradeNum AND ttinfo.trade_num= ti.trade_num AND ti.contr_qty_uom_code =termuom.uom_code                                                   
                                                
/*                                                
                                                
LEFT OUTER JOIN entity_tag  et ON et.entity_tag_id = (SELECT TOP 1 etd.oid FROM  entity_tag_definition etd                                              
WHERE etd.entity_tag_name = 'MOHGuarSpecTI' AND etd.tag_status='A' and etd.entity_id= (SELECT oid FROM icts_entity_name WHERE entity_name='TradeItem'))                                                 
                                                
LEFT OUTER JOIN entity_tag_definition etd  -- hardcoded entity tag name as per MOH                                                
                                                
ON etd.entity_tag_name = 'MOHGuarSpecTI' AND etd.tag_status='A' AND  etd.entity_id= (SELECT oid FROM icts_entity_name WHERE entity_name='TradeItem')                                                 
AND etd.oid = (SELECT TOP 1 et.entity_tag_id FROM entity_tag et WHERE et.key1=Convert(VARCHAR,@tradeNum))                                                
                                                
                                                
--LEFT OUTER JOIN entity_tag  et                                                
                                                
--ON et.key1 = Convert(VARCHAR,@tradeNum) AND et.entity_tag_id=etd.oid                                                
                                                
                         
                                                
LEFT OUTER JOIN entity_tag_definition etdbp  -- hardcoded entity tag name as per MOH                                                
                                                
ON etdbp.entity_tag_name = 'BaseOnWhatQty' AND etdbp.tag_status='A' AND  etdbp.entity_id= (SELECT oid FROM icts_entity_name WHERE entity_name='TradeItem')                                                 
AND etdbp.oid = (SELECT TOP 1 et.entity_tag_id FROM entity_tag et WHERE et.key1=Convert(VARCHAR,@tradeNum))                                                
                 
--LEFT OUTER JOIN entity_tag  etbp                                                
                                                
--ON etbp.key1 = Convert(VARCHAR,@tradeNum) AND etbp.entity_tag_id=etdbp.oid                                                
                                                
LEFT OUTER JOIN entity_tag_definition etdqb  -- hardcoded entity tag name as per MOH                                                
                                                
ON etdqb.entity_tag_name ='QuantIsBinding' AND etdqb.tag_status='A' AND  etdqb.entity_id= (SELECT oid FROM icts_entity_name WHERE entity_name='TradeItem')                                                 
AND etdqb.oid = (SELECT TOP 1 et.entity_tag_id FROM entity_tag et WHERE et.key1=Convert(VARCHAR,@tradeNum))                                                
                                                
--LEFT OUTER JOIN entity_tag  etqb                                                
                                                
--ON etqb.key1 = Convert(VARCHAR,@tradeNum) AND etqb.entity_tag_id=etdqb.oid                                                
                                                
LEFT OUTER JOIN entity_tag_definition etdqlb  -- hardcoded entity tag name as per MOH                                                
                                                
ON etdqlb.entity_tag_name ='QualityIsBinding' AND etdqlb.tag_status='A' AND  etdqlb.entity_id= (SELECT oid FROM icts_entity_name WHERE entity_name='TradeItem')                                                 
AND etdqlb.oid = (SELECT TOP 1 et.entity_tag_id FROM entity_tag et WHERE et.key1=Convert(VARCHAR,@tradeNum))                                                
                                            
--LEFT OUTER JOIN entity_tag  etqlb                                                
                                                
--ON etqlb.key1 = Convert(VARCHAR,@tradeNum) AND etqlb.entity_tag_id=etdqlb.oid                                                
                                                
*/                                                
                                                
LEFT OUTER JOIN location disport                 
                                                
ON disport.loc_code= ti.disch_port_loc_code                                                 
                                                
LEFT OUTER JOIN country countr                                                  
                     
ON countr.country_code= (select TOP 1 country_code from location_ext_info where loc_code = (                                                
select TOP 1 disch_port_loc_code from trade_item where trade_num = @tradeNum))                                                
                                              
LEFT OUTER JOIN country loadPortcountr                                                
                                              
ON loadPortcountr.country_code= (select TOP 1 country_code from location_ext_info where loc_code = (                                              
select TOP 1 load_port_loc_code from trade_item where trade_num = @tradeNum))                                              
                                                
LEFT OUTER JOIN commodity cmdtyprice                                                  
                                                
ON cmdtyprice.cmdty_code= ti.price_curr_code                                                 
                                                
LEFT OUTER JOIN location_ext_info locExt                                                  
                                                
ON locExt.loc_code= ti.disch_port_loc_code                                                  
                                                
left outer join account cpt                                              
on t.acct_num= cpt.acct_num                                            
                          left outer join gtc gtco                                  
on ti.gtc_code=gtco.gtc_code               
                                              
WHERE t.trade_num = @tradeNum --trade_numInput                                                                                                       
   
--delete  temp_docgen_data  where key1 = convert(varchar,@tradeNum) and executor = @executor
GO
GRANT EXECUTE ON  [dbo].[usp_get_trade_nomination_data] TO [next_usr]
GO
