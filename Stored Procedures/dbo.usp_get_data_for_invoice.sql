SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[usp_get_data_for_invoice]                      
@voucherNum INT,                          
@executor as VARCHAR(15),        
@isPriliminary char(1) = 'N'                                                
AS                            
                       
DECLARE @firstWPPCostNum AS INT                        
DECLARE @voucherNumStr AS VARCHAR(15)                        
DECLARE @Moisture AS float          
DECLARE @Franchis AS float             
DECLARE @DryQty AS float          
                        
SET @voucherNumStr = convert(VARCHAR(15),@voucherNum)                           
SET  @firstWPPCostNum = (                        
       SELECT TOP 1 convert(INT, convert(VARCHAR(MAX),tdd.attr_value))                         
       FROM temp_docgen_data tdd WHERE                          
       tdd.key5 = @voucherNumStr AND              
       tdd.executor = @executor AND                           
       tdd.attr_name = 'firstWPPCostNum'                           
       ORDER BY tdd.creation_time DESC                        
      )                           
SET  @Moisture = (                            
       SELECT TOP 1 convert(FLOAT, convert(VARCHAR(MAX),tdd.attr_value))                             
       FROM temp_docgen_data tdd WHERE                              
       tdd.key5 = @voucherNumStr AND                  
       tdd.executor = @executor AND                               
       tdd.attr_name = 'moistureVal'                               
       ORDER BY tdd.creation_time DESC                            
      )           
SET  @Franchis = (                            
       SELECT TOP 1 convert(FLOAT, convert(VARCHAR(MAX),tdd.attr_value))                             
       FROM temp_docgen_data tdd WHERE                              
       tdd.key5 = @voucherNumStr AND                  
       tdd.executor = @executor AND                               
       tdd.attr_name = 'franchisVal'                               
       ORDER BY tdd.creation_time DESC                            
      )         
SET @DryQty =(          
 SELECT TOP 1 convert(FLOAT, convert(VARCHAR(MAX),tdd.attr_value))                                         
 FROM temp_docgen_data tdd                             
 WHERE  tdd.key5 = @voucherNumStr AND                              
 tdd.executor = @executor AND                               
 tdd.attr_name = 'dryQtyVal'                              
 ORDER BY tdd.creation_time DESC                            
 )         
SELECT                           
 (                        
  SELECT TOP 1 tdd.attr_value                         
  FROM temp_docgen_data tdd WHERE                          
  tdd.key5 = @voucherNumStr AND                           
  tdd.executor = @executor AND                           
  tdd.attr_name = 'acctFullNameBookComp'                          
  ORDER BY tdd.creation_time DESC                        
  )AS BookingCompFullName,                              
 (                        
  SELECT TOP 1 tdd.attr_value                         
  FROM temp_docgen_data tdd                         
  WHERE  tdd.key5 = @voucherNumStr AND                           
  tdd.executor = @executor AND                           
  tdd.attr_name = 'bookingCompanyContractAddressesInfo'                          
  ORDER BY tdd.creation_time DESC                        
 )AS BookingCompanyContractAddressesInfo, --Line1 and Line2                         
 (                        
  SELECT TOP 1 tdd.attr_value                         
  FROM temp_docgen_data tdd                         
  WHERE  tdd.key5 = @voucherNumStr AND                          
  tdd.executor = @executor AND                           
  tdd.attr_name = 'acctFullNameCounterParty'                          
  ORDER BY tdd.creation_time DESC                        
 )AS CounterpartyFullName,                            
 (                        
  SELECT TOP 1  UPPER(CAST(tdd.attr_value AS NVARCHAR(max)))                         
  FROM temp_docgen_data tdd WHERE tdd.key5 = @voucherNumStr AND                           
  tdd.executor = @executor AND                           
  tdd.attr_name = 'counterpartyAddressInfo'                          
  ORDER BY tdd.creation_time DESC                        
 )AS CounterpartyAddressInfo,            
 cpbi.bank_name   AS CounterpartyBankName,                        
 bcbi.bank_name   AS BookingCompanyBankName,                            
-- Voucher table fields                     
 @voucherNum      AS VoucherNum,                        
 (                        
  DATENAME(month, v.voucher_creation_date)+' '+                        
  DATENAME(day, v.voucher_creation_date)+','+                        
  DATENAME(year, v.voucher_creation_date)                         
 )AS VoucherCreationDate,                           
 (                        
  DATENAME(month, v.voucher_due_date)+' '+                        
  DATENAME(day, v.voucher_due_date)+','+                        
  DATENAME(year, v.voucher_due_date)                         
 )AS VoucherDueDate,                        
 v.voucher_pay_recv_ind    AS VoucherPayRecvInd,                            
 v.voucher_status      AS VoucherStatus,                          
 --v.voucher_type_code     AS VoucherTypeCode,                          
 --v.voucher_cat_code,                           
 v.voucher_pay_recv_ind    AS VoucherPayRecInd,                          
 --v.acct_num,                           
 --v.acct_instr_num,                           
 --v.voucher_tot_amt     AS VoucherTotalAmt,                          
 --v.voucher_curr_code    AS VoucherCurrCode,                          
 v.credit_term_code     AS CreditTermCode,                          
 v.pay_method_code     AS PayMethodCode,                          
 v.pay_term_code      AS PayTermCode,                          
 v.voucher_pay_days AS VoucherPayDays,                          
 v.voch_tot_paid_amt     AS VoucherTotPaidAmt,                          
 --v.voucher_creation_date,                          
  v.voucher_creator_init    AS VoucherCreatorInit,                          
  --v.voucher_auth_reqd_ind,                          
  --v.voucher_auth_date,                          
  --v.voucher_auth_init,                          
  v.voucher_eff_date     AS VoucherEffDate,                          
 --v.voucher_print_date,                          
  --v.voucher_send_to_cust_date,                           
  v.voucher_book_date    AS VoucherBookDate,                          
  v.voucher_mod_date AS VoucherModDate,                          
  v.voucher_mod_init     AS VoucherModInit,                          
  v.voucher_writeoff_init   AS VoucherWriteOffInit,                           
  v.voucher_writeoff_date   AS VoucherWriteOffDate,                          
  v.voucher_cust_inv_amt    AS VoucherCustInvAmt,                          
  v.voucher_cust_inv_date   AS VoucherCustInvDate,                          
  --v.voucher_short_cmnt,                          
  --v.cmnt_num,                          
  --v.voucher_book_comp_num,                           
  v.voucher_book_curr_code   AS VoucherBookCurrCode,                           
  v.voucher_book_exch_rate   AS VoucherBookExchRate,                          
  v.voucher_xrate_conv_ind   AS VoucherXRateConvInd,                          
  v.voucher_loi_num     AS VoucherLoiNum,                           
  --v.voucher_arap_acct_code,                          
  --v.voucher_send_to_arap_date,                           
  v.voucher_cust_ref_num    AS VoucherCustRefNum,                           
  v.voucher_book_prd_date   AS VoucherBookPrdDate,                           
  --v.voucher_paid_date    AS VoucherPaidDate,                           
  --v.voucher_due_date    AS VoucherDueDate,                           
  --v.voucher_acct_name,                          
  --v.voucher_book_comp_name,                           
 v.cash_date       AS CashDate,                          
 --v.trans_id,       
 v.ref_voucher_num     AS RefVoucherNum,                          
 v.custom_voucher_string     AS CustomVoucherString,                          
 v.voucher_reversal_ind    AS VoucherReversalInd,                          
 v.voucher_hold_ind     AS VoucherHoldInd,               
 --v.max_line_num,                          
 --v.book_comp_acct_bank_id,                          
 --v.cp_acct_bank_id,                           
 v.voucher_inv_curr_code    AS VoucherInvCurrCode,                          
 v.voucher_inv_exch_rate    AS VoucherInvExchRate,                          
 v.invoice_exch_rate_comment   AS InvoiceExchRateComment,                           
 v.cust_inv_recv_date    AS CustInvRecvDate,                          
 v.cust_inv_type_ind     AS CustInvTypeInd,                          
 --v.special_bank_instr,                          
 --v.revised_book_comp_bank_id,                           
 v.voucher_expected_pay_date   AS VoucherExpectedPayDate,                          
 --v.external_ref_key,                          
 v.cpty_inv_curr_code    AS CptyInvCurrCode,                          
 v.voucher_approval_date    AS VoucherApprovalDate,                          
 --v.voucher_approval_init,                          
 --v.sap_invoice_number,                          
 --                           
                        
(                         
 CASE WHEN (                        
   SELECT TOP 1 ac1.acct_cont_off_ph_num FROM                         
   voucher v1 LEFT OUTER JOIN account_instruction ai1                        
   ON ai1.acct_num= v1.voucher_book_comp_num AND ai1.acct_instr_type_code = 'INVOICE'                        
   LEFT OUTER JOIN  account_contact ac1                         
   ON ac1.acct_num = ai1.acct_num AND ac1.acct_cont_off_ph_num IS NOT NULL                        
   WHERE v1.voucher_num =@voucherNum                        
   ) IS NOT NULL THEN                        
   (                        
   SELECT TOP 1 ac1.acct_cont_off_ph_num FROM                         
   voucher v1 LEFT OUTER JOIN account_instruction ai1                        
   ON ai1.acct_num= v1.voucher_book_comp_num AND ai1.acct_instr_type_code = 'INVOICE'                        
   LEFT OUTER JOIN  account_contact ac1                         
   ON ac1.acct_num = ai1.acct_num AND ac1.acct_cont_off_ph_num IS NOT NULL                        
   WHERE v1.voucher_num =@voucherNum                        
   )ELSE                        
   (                        
   SELECT TOP 1 aa1.acct_addr_ph_num FROM  account_address aa1                         
   WHERE aa1.acct_num = v.voucher_book_comp_num                        
   )                        
END                
)AS BookingCompanyPhoneInfoForInvoice,                        
                           
(                        
 SELECT                         
  (                        
  CASE WHEN                         
  ( SELECT TOP 1 ac1.acct_cont_fax_num FROM                         
   voucher v1 LEFT OUTER JOIN account_instruction ai1                        
   ON ai1.acct_num= v1.voucher_book_comp_num AND ai1.acct_instr_type_code = 'INVOICE'                        
   LEFT OUTER JOIN  account_contact ac1                         
   ON ac1.acct_num = ai1.acct_num AND ac1.acct_cont_fax_num IS NOT NULL                        
   WHERE v1.voucher_num =@voucherNum                        
  ) IS NOT NULL THEN                        
  (                        
   SELECT TOP 1 ac1.acct_cont_fax_num FROM                         
   voucher v1 LEFT OUTER JOIN account_instruction ai1                        
   ON ai1.acct_num= v1.voucher_book_comp_num AND ai1.acct_instr_type_code = 'INVOICE'                        
   LEFT OUTER JOIN  account_contact ac1                         
   ON ac1.acct_num = ai1.acct_num AND ac1.acct_cont_fax_num IS NOT NULL             WHERE v1.voucher_num =@voucherNum                        
  ) ELSE                        
  (                        
   SELECT TOP 1 aa1.acct_addr_fax_num FROM  account_address aa1                         
   WHERE aa1.acct_num = v.voucher_book_comp_num                        
  )                        
 END                         
 )                        
)AS BookingCompanyFaxInfoForInvoice,                        
                        
(                        
SELECT ( CASE WHEN (SELECT TOP 1 ac1.acct_cont_email FROM                         
voucher v1 LEFT OUTER JOIN account_instruction ai1                        
ON ai1.acct_num= v1.voucher_book_comp_num AND ai1.acct_instr_type_code = 'INVOICE'                        
 LEFT OUTER JOIN  account_contact ac1                         
 ON ac1.acct_num = ai1.acct_num AND ac1.acct_cont_email IS NOT NULL                        
 WHERE v1.voucher_num =@voucherNum) IS NOT NULL THEN                        
              
   (SELECT TOP 1 ac1.acct_cont_email FROM                         
 voucher v1 LEFT OUTER JOIN account_instruction ai1                        
 ON ai1.acct_num= v1.voucher_book_comp_num AND ai1.acct_instr_type_code = 'INVOICE'                        
 LEFT OUTER JOIN  account_contact ac1                         
 ON ac1.acct_num = ai1.acct_num AND ac1.acct_cont_email IS NOT NULL                        
 WHERE v1.voucher_num =@voucherNum) ELSE         
                         
 (SELECT TOP 1 aa1.acct_addr_email FROM  account_address aa1                         
 WHERE aa1.acct_num = v.voucher_book_comp_num)                        
 END ) )  AS BookingCompanyEmailInfoForInvoice,                         
cpaa.acct_addr_ph_num     AS CounterpartyPhoneInfoForInvoice,                        
cpaa.acct_addr_fax_num     AS CounterpartyFaxInfoForInvoice,                        
cpaa.acct_addr_email     AS CounterpartyEmailInfoForInvoice,                        
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'accountContactNameInfo'                          
 ORDER BY tdd.creation_time DESC)AS CounterPartyAcctContactFullName ,                           
                        
 (SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'accountContactFaxInfo'                          
 ORDER BY tdd.creation_time DESC)  AS CounterPartyFaxInfo,                           
                        
pm.pay_method_desc      AS PaymentMethodDescription,                        
bcbi.swift_code       AS BookingCompanyBankSwiftCode,                        
bcbi.bank_acct_no      AS BookingCompanyBankAcctNo,                        
cpbi.swift_code AS CounterpartyBankSwiftCode,                        
cpbi.bank_acct_no       AS CounterpartyBankAcctNo,                        
                        
(CASE WHEN len(cmdt.cmdty_full_name) < 16 THEN                        
      cmdt.cmdty_full_name                         
      WHEN len(cmdt.cmdty_short_name) < 16 THEN                        
       cmdt.cmdty_short_name                         
       ELSE                        
       cmdt.cmdty_code END)  AS CostCommodityName,                        
c.cost_num  AS CostNum,                          
RTRIM(c.cost_type_code)    AS CostTypeCode,                          
                         
 (CASE WHEN c.cost_pay_rec_ind ='P' THEN                        
(c.cost_amt * -1)                         
WHEN c.cost_pay_rec_ind ='R' THEN                        
c.cost_amt                        
 END )      AS CostAmt,                         
RTRIM(secc.cost_type_code)    AS CostTypeCodeForSecondaryCost,                         
                        
(CASE WHEN secc.cost_pay_rec_ind ='P' THEN                        
(secc.cost_amt * -1)                         
WHEN secc.cost_pay_rec_ind ='R' THEN                        
secc.cost_amt                
 END )      AS CostAmtForSecondaryCost,                        
secc.cost_due_date   AS CostDueDateForSecondaryCost,                        
seccfr.cost_type_code    AS CostTypeCodeForFrieghtSecondaryCost,                         
                        
(CASE WHEN seccfr.cost_pay_rec_ind ='P' THEN                        
(seccfr.cost_amt * -1)                         
WHEN seccfr.cost_pay_rec_ind ='R' THEN                        
seccfr.cost_amt                        
 END )      AS CostAmtForFrieghtSecondaryCost,            
seccfr.cost_due_date   AS CostDueDateForFrieghtSecondaryCost,                        
seccinsp.cost_type_code    AS CostTypeCodeForInspSecondaryCost,                         
                        
(CASE WHEN seccinsp.cost_pay_rec_ind ='P' THEN                        
(seccinsp.cost_amt * -1)                         
WHEN seccinsp.cost_pay_rec_ind ='R' THEN                        
seccinsp.cost_amt                        
 END )      AS CostAmtForInspSecondaryCost,                        
seccinsp.cost_due_date   AS CostDueDateForInspSecondaryCost,                   
REPLACE(CONVERT(VARCHAR(10),c.cost_due_date, 1), '/', '/')  AS CostDueDate,                          
                        
(CASE WHEN ship.oid IS NULL THEN '' ELSE                        
  (select convert(VARCHAR,ship.oid)                            
   where c.cost_owner_code IN('AI','AA','A')) END)  AS ShipmentOidForCost,                        
                        
(CASE WHEN prcl.oid IS NULL THEN '' ELSE                        
 (select convert(VARCHAR,prcl.oid)                             
 where c.cost_owner_code IN('AI','AA','A')) END)   AS ParcelOidForCost,                                                 
(CASE WHEN c.cost_owner_key3 IS NULL THEN '' ELSE                        
  (select convert(VARCHAR,c.cost_owner_key3)                            
    where c.cost_owner_code IN('AI','AA','A')) END)  AS ActualNumStrForCost,                               
 --c.creation_date as CostCreationDate,                        
 REPLACE(CONVERT(VARCHAR(10),c.creation_date, 1), '/', '/')  AS CostCreationDate,                        
                  
c.cost_prim_sec_ind AS CostPrimSecInd,				  
 (CASE WHEN c.cost_pay_rec_ind ='P' THEN                        
'Buy'                         
WHEN c.cost_pay_rec_ind ='R' THEN                        
'Sell'                        
       ELSE '' END )       AS PSInd,                        
lloc.loc_name       AS LoadPortLocationForAllocationItem,                        
dloc.loc_name AS FinalDestLocationForAllocationItem,  --destinationLabel                          
REPLACE(CONVERT(VARCHAR(10),actual.ai_est_actual_date, 1), '/', '/') AS ActualDate,                            
REPLACE(CONVERT(VARCHAR(10),ship.start_date, 1), '/', '/')   AS ShipmentStartDate,                        
REPLACE(CONVERT(VARCHAR(10),ship.end_date, 1), '/', '/')     AS ShipmentEndDate,                             
                        
(CASE WHEN c.cost_amt_type = 'F' OR c.cost_amt_type IS NULL                        
    THEN 'Flat'                        
    ELSE 'Unit Price' END                        
)    AS    CostAmountTypeDesc,                        
c.cost_qty_uom_code    AS CostQtyUomCode,                            
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                           
tdd.key6 = convert(VARCHAR,c.cost_num) AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'costQtyUomCodeInfo'                          
 ORDER BY tdd.creation_time DESC)  AS CostQtyUomCodeInfo,                          
--c.cost_qty AS CostQty,                           
                        
  (SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                           
tdd.key6 = convert(VARCHAR,c.cost_num) AND                          
tdd.executor = @executor AND              
tdd.attr_name = 'costQtyStrInfo'                          
 ORDER BY tdd.creation_time DESC)  AS CostQtyStrInfo,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                           
tdd.key6 = convert(VARCHAR,c.cost_num) AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'costAmtStrInfo'                          
 ORDER BY tdd.creation_time DESC)AS CostAmtStrInfo,                      
                        
/*(CASE WHEN c.cost_pay_rec_ind = 'P' AND c.cost_amt IS NOT NULL                        
    THEN (c.cost_amt * -1)                        
   ELSE c.cost_amt END                           
)   AS CostAmtStrInfo,   */                              
 --new          
           
MotCode=                    
case                     
when ti.item_type = 'D' then tidp.mot_code                    
when ti.item_type = 'W' then tiwp.mot_code                    
end  ,                       
--tiwp.mot_code     AS MotCode,   --migrated            
MotFullName=                    
case                     
when ti.item_type = 'D' then md.mot_full_name                    
when ti.item_type = 'W' then m.mot_full_name                    
end  ,           
MotShortName=                    
case       
when ti.item_type = 'D' then md.mot_short_name                    
when ti.item_type = 'W' then m.mot_short_name                    
end  ,           
MotTypeCode=                    
case                     
when ti.item_type = 'D' then md.mot_type_code                    
when ti.item_type = 'W' then m.mot_type_code                    
end  ,           
MotTypeShortName=                    
case                     
when ti.item_type = 'D' then mtd.mot_type_short_name                    
when ti.item_type = 'W' then mt.mot_type_short_name                    
end  ,                         
--m.mot_full_name     AS MotFullName,   --migrated                        
--m.mot_short_name    AS MotShortName,   --migrated                        
--m.mot_type_code     AS MotTypeCode,   --migrated               
--mt.mot_type_short_name   AS MotTypeShortName,  --migrated               
                   
ti.cmdty_code     AS CommodityCode,  --migrated as CommodityCode                        
cmdty.cmdty_short_name   AS CommodityShortName,   -- migrated as CmdtyShortName                        
cmdty.cmdty_full_name   AS CommodityFullName,   -- m as CmdtyFullNmae      
cmdty.is_composite  as IsComposite,      
cmdty.sec_uom_code as SecUomCode,                         
(DATENAME(month, tiwp.del_date_from)+' '+                              
DATENAME(day, tiwp.del_date_from)+', '+                              
DATENAME(year, tiwp.del_date_from) )AS DelDateFrom,  -- m as DelDateFrom                        
(DATENAME(month, tiwp.del_date_to)+' '+                              
DATENAME(day, tiwp.del_date_to)+', '+                              
DATENAME(year, tiwp.del_date_to) )AS DelDateTo,    -- m as DelDateTo                        
(DATENAME(month, tiwp.del_date_from)+' '+                              
DATENAME(day, tiwp.del_date_from)+'-'+                        
DATENAME(day, tiwp.del_date_to)+', '+                              
DATENAME(year, tiwp.del_date_from) )  AS DeliveryPeriod,   -- m as DeliveryPeriod                        
ti.trade_num     AS TradeNum,  -- m as TradeNum                        
ti.order_num     AS OrderNum,  -- m as OrderNum                        
ti.item_num      AS ItemNum,   -- m as ItemNum                        
(convert(VARCHAR, ti.trade_num)+'/'+                          
 convert(VARCHAR,ti.order_num) +'/'+                          
 convert(VARCHAR,ti.item_num )) AS RefNR, -- m as   RefNR                        
ti.contr_qty     AS ContractQty,   -- m as ContractQty                        
u.uom_full_name     AS ContrQtyUomName,  -- m as ContrQtyUomName                         
ti.contr_qty_uom_code   AS ContrQtyUomCode,  -- m as ContrQtyUomCode                         
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                           
tdd.key6 = convert(VARCHAR,c.cost_num) AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'costUnitPriceStrInfo'                          
 ORDER BY tdd.creation_time DESC)AS CostUnitPriceStrInfo,                           
                        
/*( SELECT TOP 1 c1.cost_unit_price FROM cost c1 WHERE c1.cost_num                          
 IN(vc.cost_num) AND c1.cost_type_code = 'PR')     AS CostUnitPrice, */                          
( SELECT TOP 1 c1.cost_price_curr_code FROM cost c1 WHERE              
c1.cost_num IN(vc.cost_num) )                         
--AND c1.cost_type_code = 'PR')                            
AS CostPriceCurrCode,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                           
tdd.key6 = convert(VARCHAR,c.cost_num) AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'costPriceUomCodeInfo'                          
 ORDER BY tdd.creation_time DESC)      AS CostPriceUomCodeInfo,                          
                        
/*( SELECT TOP 1 c1.cost_price_uom_code FROM cost c1 WHERE                           
c1.cost_num IN(vc.cost_num) AND c1.cost_type_code = 'PR')  AS CostPriceUomCode,*/                          
 v.voucher_tot_amt    AS VoucherTotAmt,                          
 v.voucher_curr_code   AS VoucherCurrCode,                          
pt.pay_term_contr_desc   AS PayTermContrDesc,   -- m                         
pt.pay_term_desc    AS PayTermDesc,   --m                         
(DATENAME(month, t.contr_date)+' '+                              
DATENAME(day, t.contr_date)+', '+                              
DATENAME(year, t.contr_date) ) AS TradeContrDate,  --m                         
ali.origin_loc_code    AS LoadLocCode,   --m                        
loadloc.loc_name    AS LoadLocName,   -- basisLabel                        
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                      
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'bookingCompBankInfo'                          
 ORDER BY tdd.creation_time DESC)AS BookingCompBankInfo,                          
                
/*(SELECT                            
 (CASE WHEN bcbi.bank_name IS NULL THEN                          
 '' ELSE bcbi.bank_name + (CHAR(13) + CHAR(10))END) +                          
 (CASE WHEN bcbi.bank_acct_no IS NULL THEN                          
 '' ELSE 'ACCOUNT: '+ bcbi.bank_acct_no + (CHAR(13) + CHAR(10))END) +                          
 (CASE WHEN bcbi.acct_bank_routing_num IS NULL THEN                          
 '' ELSE 'ABA: '+bcbi.acct_bank_routing_num + (CHAR(13) + CHAR(10))END) +                          
 (CASE WHEN bcbi.swift_code IS NULL THEN                          
 '' ELSE 'SWIFT: '+bcbi.swift_code + (CHAR(13) + CHAR(10))END) +                          
 (CASE WHEN v.book_comp_acct_bank_id IS NULL THEN                          
 '' ELSE 'Through:' + (CHAR(13) + CHAR(10))END) +                          
 (CASE WHEN bcbi.corresp_bank_name IS NULL THEN                          
 '' ELSE 'FOR THE ACCOUNT OF: '+bcbi.corresp_bank_name + (CHAR(13) + CHAR(10))END)+                          
 (CASE WHEN bcbi.corresp_bank_acct_no IS NULL THEN                          
 '' ELSE 'ACCOUNT: '+ bcbi.corresp_bank_acct_no + (CHAR(13) + CHAR(10))END)+                          
 (CASE WHEN bcbi.corresp_bank_routing_num IS NULL THEN                          
 '' ELSE 'ABA: '+bcbi.corresp_bank_routing_num + (CHAR(13) + CHAR(10))END)+                          
 (CASE WHEN bcbi.corresp_swift_code IS NULL THEN                          
 '' ELSE 'SWIFT: '+bcbi.corresp_swift_code + (CHAR(13) + CHAR(10))END)+                          
 (CASE WHEN bcbi.further_credit_to IS NULL THEN                          
 '' ELSE 'IN FAVOUR OF: '+bcbi.further_credit_to + (CHAR(13) + CHAR(10))END)+                          
 (CASE WHEN bcbi.further_credit_to_ext_acct_key IS NULL THEN                          
 '' ELSE 'Account NO.: '+bcbi.further_credit_to_ext_acct_key + (CHAR(13) + CHAR(10))END)                          
 )AS BookingCompBankInfo,*/                          
--c.cost_amt      AS CostAmount,                          
--c.cost_unit_price    AS CostUnitPriceDetail,                          
--c.cost_price_uom_code    AS CostPriceUomCodeDetail,                          
                        
c.cost_book_exch_rate   AS CostBookExchRate,                          
v.voucher_paid_date    AS VoucherPaidDate,                          
                        
--(DATENAME(month, alit.bl_date)+' '+                            
--DATENAME(day, alit.bl_date)+', '+                              
--DATENAME(year, alit.bl_date) ) AS BLDate,                          
                        
delt.del_term_desc    AS DelTermDesc,    --m                        
rtrim(delt.del_term_code)  AS DelTermCode, -- new  --m                        
titleloc.loc_name    AS TitleTransferLocation, --new  -- transferLocationLabel                        
titletranscountryloc.country_name AS TitleTransferCountry,  -- new                          
UPPER((DATENAME(month, t.concluded_date)+' '+                              
DATENAME(day, t.concluded_date)+', '+                              
DATENAME(year, t.concluded_date) ))AS ConcludedDate,   --new                          
tiwp.tol_sign     AS TolSign,  --new                          
tiwp.tol_qty     AS TolQty,  --new                          
tiwp.tol_qty_uom_code      AS TolQtyUomCode,  --new                          
tiwp.tol_opt     AS TolOpt,  --new                          
--fc.formula_comp_curr_code  AS FormulaCompCurrCode,                           
--fc.formula_comp_uom_code   AS FormulaCompUomCode,                        
(select top 1 formula_comp_curr_code from formula_body fb, formula_component fc where                                  
fb.formula_num = fc.formula_num                              
and formula_body_type in ('P','M')                                  
and formula_comp_type = 'U'                                  
and fb.formula_num in (select  TOP 1 formula_num from trade_formula where trade_num = ti.trade_num and fall_back_ind = @isPriliminary))                       
 AS FormulaCompCurrCode,                                       
(select top 1 formula_comp_uom_code from formula_body fb, formula_component fc where                                  
fb.formula_num = fc.formula_num                                  
and formula_body_type in ('P','M')                  
and formula_comp_type = 'U'                                  
and fb.formula_num in (select  TOP 1 formula_num from trade_formula where trade_num = ti.trade_num and fall_back_ind = @isPriliminary)) --fc.formula_comp_uom_code                                    
AS FormulaCompUomCode,                         
rtrim(ti.price_curr_code)     AS PriceCurrencyCode,                          
rtrim(ti.price_uom_code)  AS PriceUomCode,                          
(                        
  SELECT TOP 1 quote_diff  FROM simple_formula                          
  WHERE quote_commkt_key in                         
  (                        
  SELECT distinct cm.commkt_key                           
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
  where quote_trading_prd = qpp.real_trading_prd                        
  )                         
)    AS QuoteDiff,                          
(                        
 SELECT TOP 1 quote_diff_curr_code  FROM simple_formula                           
 WHERE quote_commkt_key in                         
  (                        
  SELECT distinct cm.commkt_key                           
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
  where quote_trading_prd = qpp.real_trading_prd                        
  )                         
)AS QuoteDiffCurrCode,                          
(                        
 SELECT TOP 1 quote_diff_uom_code  FROM simple_formula                           
 WHERE quote_commkt_key in                         
  (                        
  SELECT distinct cm.commkt_key                           
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
  where quote_trading_prd = qpp.real_trading_prd                        
 )                         
) AS QuoteDiffUomCode,                          
--spec.spec_desc      AS SpecDesc,                       
ISNULL(STUFF((SELECT TOP 1 ':'+LTRIM(RTRIM(lclSpec.spec_desc))   AS [text()]                      
   FROM trade_item_spec lclTis                       
   JOIN specification lclSpec ON lclTis.spec_code= lclSpec.spec_code                       
   WHERE  lclTis.trade_num =ti.trade_num AND lclTis.order_num =ti.order_num AND lclTis.item_num=ti.item_num FOR XML PATH('')),1,1,''),'')                      
    AS SpecDesc,                         
--tispec.spec_typical_val   AS SpecTypicalVal,                       
 ISNULL(STUFF((SELECT TOP 1 ':'+ LTRIM(RTRIM(lclTis.spec_typical_val))  AS [text()]                      
   FROM trade_item_spec lclTis                       
   JOIN specification lclSpec ON lclTis.spec_code= lclSpec.spec_code                       
   WHERE  lclTis.trade_num =ti.trade_num AND lclTis.order_num =ti.order_num AND lclTis.item_num=ti.item_num FOR XML PATH('')),1,1,''),'')                      
    AS SpecTypicalVal,                       
                        
excp.excp_addns_desc   AS ExepAddnsDesc,                          
v.voucher_type_code     AS VoucherType,                          
f.formula_precision    AS  FormulaPrecision,       --NEW                          
ti.avg_price      AS  PriceDescription,       --NEW                          
tiwploc.loc_name     AS  DeliveryLocation,-- NEW                          
ct.credit_term_desc    AS CreditTermDesc,                          
REPLACE(CONVERT(VARCHAR(10),alit.eta_date, 1), '/', '/')     AS ETADate,                          
aiinsp.insp_comp_short_name  AS InspCompShortName,                          
ali.nomin_qty_max    AS NominQtyMax,                          
(DATENAME(month, alit.lay_days_start_date)+' '+                              
DATENAME(day, alit.lay_days_start_date)+'-'+                          
DATENAME(day, alit.lay_days_end_date)+', '+                              
DATENAME(year, alit.lay_days_start_date) ) AS LayDays,                          
DATENAME(year, v.voucher_creation_date)AS VoucherCreatedYear,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'originalVoucherNumLabel'                          
 ORDER BY tdd.creation_time DESC)AS OriginalVoucherNumLabel,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'physicalInvoiceDescription'                          
 ORDER BY tdd.creation_time DESC)AS PhysicalInvoiceDescription,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'voucherDateLableInfo'                          
 ORDER BY tdd.creation_time DESC)AS VoucherDateLableInfo,                          
                        
 (SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'accountContactNameInfo'                          
 ORDER BY tdd.creation_time DESC)AS CounterpartyContactNameInfo,                        
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'accountContactPhoneInfo'                          
 ORDER BY tdd.creation_time DESC)AS CounterpartyContactPhoneInfo,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'accountContactFaxInfo'                          
 ORDER BY tdd.creation_time DESC)AS CounterpartyContactFaxInfo,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'accountContactEmailInfo'                          
 ORDER BY tdd.creation_time DESC)AS CounterpartyContactEmailInfo,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                 
tdd.attr_name = 'contractNumberInfo'                          
 ORDER BY tdd.creation_time DESC) AS  ContractNumberInfo ,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'customCounterpartyRefNum'                          
 ORDER BY tdd.creation_time DESC) AS CustomCounterpartyRefNum,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'deliveryBasis'                          
 ORDER BY tdd.creation_time DESC)  AS DeliveryBasis,                            
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'costCodeInfo'                          
 ORDER BY tdd.creation_time DESC)  AS CostCodeInfo,                             
                    
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'blInfoLabel'                          
 ORDER BY tdd.creation_time DESC)  AS BlInfoLabel,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'blDate'                          
 ORDER BY tdd.creation_time DESC)  AS BLdate,                         
                        
 (SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'deemedBlDateLabel'                          
 ORDER BY tdd.creation_time DESC)  AS DeemedBlDateLabel,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'blNoLabel'                          
 ORDER BY tdd.creation_time DESC)  AS BlNoLabel,                       
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'transportValue'                          
 ORDER BY tdd.creation_time DESC)  AS TransportValue,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'norDateLabel'                          
 ORDER BY tdd.creation_time DESC)  AS NorDateLabel,                          
                    
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'transportLabel'                          
 ORDER BY tdd.creation_time DESC)  AS TransportLabel,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'loadPortLabel'                          
 ORDER BY tdd.creation_time DESC)  AS LoadPortLabel,                          
                        
 (SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE              
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'dischPortLabel'                          
 ORDER BY tdd.creation_time DESC)  AS DischPortLabel,                         
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'counterpartyVATStr'                          
 ORDER BY tdd.creation_time DESC)   AS CounterpartyVATStr,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                           
tdd.key6 = convert(VARCHAR,c.cost_num) AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'density'                          
 ORDER BY tdd.creation_time DESC)    AS Density,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                               
tdd.key5 = @voucherNumStr AND                           
tdd.key6 = convert(VARCHAR,c.cost_num) AND                  
tdd.executor = @executor AND                           
tdd.attr_name = 'costCodeDescription'                          
 ORDER BY tdd.creation_time DESC)    AS CostCodeDescription,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                           
tdd.key6 = convert(VARCHAR,c.cost_num) AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'grossNetBillingInfo'                          
 ORDER BY tdd.creation_time DESC)    AS GrossNetBillingInfo,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'voucherAmtStringInfo'                          
 ORDER BY tdd.creation_time DESC)    AS VoucherAmtStringInfo,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                        
tdd.executor = @executor AND                           
tdd.attr_name = 'priorPaymentLabel'                          
 ORDER BY tdd.creation_time DESC)    AS PriorPaymentLabel,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE       
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'priorPaymentSumStrInfo'                          
 ORDER BY tdd.creation_time DESC)    AS PriorPaymentSumStrInfo,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'lastPaymentDateLabel'                          
 ORDER BY tdd.creation_time DESC)    AS LastPaymentDateLabel,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'lastPaymentDateInfo'                          
 ORDER BY tdd.creation_time DESC)    AS LastPaymentDateInfo,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE   
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'payorName'                          
 ORDER BY tdd.creation_time DESC)    AS PayorName,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'voucherNetDueInfo'             ORDER BY tdd.creation_time DESC)    AS VoucherNetDueInfo,                          
 (SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'dueDateStr'                          
 ORDER BY tdd.creation_time DESC)    AS DueDateStr,                         
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'creditTerms'                          
 ORDER BY tdd.creation_time DESC)    AS CreditTerms,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'bDensity'        
 ORDER BY tdd.creation_time DESC)    AS BDensity,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'eDensity'                          
 ORDER BY tdd.creation_time DESC)    AS EDensity,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'invoiceContact'                          
 ORDER BY tdd.creation_time DESC)    AS invoiceContact,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'contactEmail'                          
 ORDER BY tdd.creation_time DESC)    AS ContactEmail,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                          
tdd.key5 = @voucherNumStr AND                          
tdd.executor = @executor AND                           
tdd.attr_name = 'contactPhoneNum'                          
 ORDER BY tdd.creation_time DESC)    AS ContactPhoneNum,                          
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                         
tdd.key5 = @voucherNumStr AND                        
tdd.executor = @executor AND                        
tdd.attr_name = 'bookingCompanyVATStr'                        
ORDER BY tdd.creation_time DESC)     AS BookingCompanyVATStr, --NEW                              
                        
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                        
tdd.key5 = @voucherNumStr AND                        
tdd.executor = @executor AND                        
tdd.attr_name = 'bookingAcctFiscalRep'                        
ORDER BY tdd.creation_time DESC)     AS BookingAcctFiscalRep, --NEW                          
              
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                        
tdd.key5 = @voucherNumStr AND                        
tdd.executor = @executor AND                         
tdd.attr_name = 'localTaxCurrency'                        
ORDER BY tdd.creation_time DESC)     AS localTaxCurrency, --NEW                        
                              
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                        
tdd.key5 = @voucherNumStr AND                        
tdd.executor = @executor AND                         
tdd.attr_name = 'localCargoValue'                        
ORDER BY tdd.creation_time DESC)     AS localCargoValue, --NEW                        
                              
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                        
tdd.key5 = @voucherNumStr AND                        
tdd.executor = @executor AND                         
tdd.attr_name = 'localTaxRateStr'                        
ORDER BY tdd.creation_time DESC)     AS localTaxRateStr, --NEW                        
                              
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                        
tdd.key5 = @voucherNumStr AND                        
tdd.executor = @executor AND                         
tdd.attr_name = 'localVatAmtStr'                        
ORDER BY tdd.creation_time DESC)     AS localVatAmtStr, --NEW                        
                              
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                        
tdd.key5 = @voucherNumStr AND                        
tdd.executor = @executor AND                         
tdd.attr_name = 'totalLocalAmt'                        
ORDER BY tdd.creation_time DESC)     AS totalLocalAmt, --NEW                              
                            
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE  tdd.key5 = @voucherNumStr AND                        
tdd.executor = @executor AND                         
tdd.attr_name = 'secondaryQty'                        
ORDER BY tdd.creation_time DESC)     AS secondaryQty, --NEW                              
                            
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                        
tdd.key5 = @voucherNumStr AND                        
tdd.executor = @executor AND                         
tdd.attr_name = 'secondaryQtyUomCodeInfo'                        
ORDER BY tdd.creation_time DESC)     AS secondaryQtyUomCodeInfo, --NEW                            
                          
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                              
tdd.key5 = @voucherNumStr AND                              
tdd.executor = @executor AND                               
tdd.attr_name = 'InvoiceVatAmt'                              
ORDER BY tdd.creation_time DESC)     AS InvoiceVatAmt, --NEW                          
                          
--ADSO-3327 -- moved this Calculation to java service for ISsue ADSO-3954           
(                            
  SELECT TOP 1 tdd.attr_value                             
  FROM temp_docgen_data tdd                             
  WHERE  tdd.key5 = @voucherNumStr AND                              
  tdd.executor = @executor AND                               
  tdd.attr_name = 'wmtQtyVal'                              
  ORDER BY tdd.creation_time DESC                            
 )AS wmtQty,              
            
--ADSO-3327 --moved this Calculation to java service for ISsue ADSO-3954         
               
@DryQty as DryQty,                 
                     
@Franchis  as Fanchise,                          
                      
DNMT =                   
CASE                           
 WHEN @Franchis =0 THEN @DryQty                         
 WHEN @Franchis > 0 then @DryQty -(@DryQty * @Franchis/100)                                     
 end,                
            
--ADSO-3327            
@Moisture as MOISTURE,         
PrilimPercentage=                    
case                     
when ti.item_type = 'D' then tidp.prelim_percentage                    
when ti.item_type = 'W' then tiwp.prelim_percentage                    
end  ,                  
(select oid from shipment where alloc_num = ali.alloc_num)  as Ship_Num,                  
 ali.alloc_num,                   
 STUFF ((select ', '+CONVERT(varchar(10),a.ct_doc_num)+ ' - ' + a.acct_full_name                  
from (SELECT DISTINCT ct_doc_num,lcacct.acct_full_name from assign_trade at left outer join lc l on l.lc_num = at.ct_doc_num                   
left outer join account lcacct on lcacct.acct_num =  l.lc_issuing_bank where trade_num=ti.trade_num and order_num = ti.order_num and item_num =ti.item_num)a                  
for xml path('')) , 1, 1, '') as LcNum_IssueBank ,                
                
(select               
SUM(CASE WHEN c.cost_pay_rec_ind ='P' THEN  (c.cost_amt * -1)                        
WHEN c.cost_pay_rec_ind ='R' THEN  c.cost_amt                        
END)  from voucher v                
inner join voucher_cost vc on v.voucher_num=vc.voucher_num                
inner join cost c on c.cost_num= vc.cost_num                
where v.voucher_type_code ='FINAL' and c.cost_type_code in               
('WPP','DPP', 'RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR')               
and v.voucher_num= @voucherNum) as TotalFinalWPPCost,                 
                
(select               
SUM(CASE WHEN c.cost_pay_rec_ind ='P' THEN  (c.cost_amt * -1)                         
WHEN c.cost_pay_rec_ind ='R' THEN  c.cost_amt                      
END) from voucher v         
inner join voucher_cost vc on v.voucher_num=vc.voucher_num                    
inner join cost c on c.cost_num= vc.cost_num                    
where v.voucher_type_code ='FINAL' and c.cost_type_code in ('PO','PFO')                    
and v.voucher_num= @voucherNum) as TotalFinalPOCost,                    
                    
(select top 1 c.cost_price_curr_code from voucher v           
inner join voucher_cost vc on v.voucher_num=vc.voucher_num                    
inner join cost c on c.cost_num= vc.cost_num                    
where v.voucher_type_code ='FINAL' and c.cost_type_code in ('PO','PFO')                    
and v.voucher_num= @voucherNum) as FinalPOCurrCode  ,      
              
(select top 1 c.cost_price_curr_code from voucher v                
inner join voucher_cost vc on v.voucher_num=vc.voucher_num                
inner join cost c on c.cost_num= vc.cost_num                
where v.voucher_type_code ='FINAL' and c.cost_type_code in               
('WPP','DPP', 'RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR')               
and v.voucher_num= @voucherNum) as FinalWPPCurrCode  ,            
            
(select cmnt.cmnt_text from comment cmnt             
where cmnt.cmnt_num = (Select cmnt_num from cost cc             
where cc.cost_num = c.cost_num)) as CostLongComments,          
          
(                            
  REPLACE(CONVERT(CHAR(11), v.voucher_creation_date, 106),' ',' - ')                             
 )AS VoucherCreationDateInddMMMYYY,                               
 (                            
  REPLACE(CONVERT(CHAR(11), v.voucher_due_date, 106),' ',' - ')                             
 )AS VoucherDueDateInddMMMYYY,           
           
 ISNULL(STUFF((SELECT '-'+LTRIM(RTRIM(ccc.cost_num))   AS [text()]                          
   FROM cost ccc                           
   JOIN voucher_cost vcc ON ccc.cost_num= vcc.cost_num                            
   WHERE  vcc.voucher_num =@voucherNum FOR XML PATH('')),1,1,''),'')                          
    AS CostNumList,          
          
(SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                    
tdd.key5 = @voucherNumStr AND                    
tdd.executor = @executor AND                     
tdd.attr_name = 'blDateList'                    
 ORDER BY tdd.creation_time DESC)  AS BLDateList,            
           
 (SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                    
tdd.key5 = @voucherNumStr AND                    
tdd.executor = @executor AND                     
tdd.attr_name = 'loadPortList'                    
 ORDER BY tdd.creation_time DESC)  AS LoadPortList,           
           
 (SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                    
tdd.key5 = @voucherNumStr AND                    
tdd.executor = @executor AND                     
tdd.attr_name = 'dischPortList'                    
 ORDER BY tdd.creation_time DESC)  AS DischPortList,          
          
 (SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                    
tdd.key5 = @voucherNumStr AND                    
tdd.executor = @executor AND                     
tdd.attr_name = 'bookingCompBankName'                    
 ORDER BY tdd.creation_time DESC)  AS BookingCompBankName,          
          
 (SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                    
tdd.key5 = @voucherNumStr AND                    
tdd.executor = @executor AND                     
tdd.attr_name = 'bookingCompBankAccountNum'                    
 ORDER BY tdd.creation_time DESC)  AS BookingCompBankAccountNum,          
          
 (SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                    
tdd.key5 = @voucherNumStr AND                    
tdd.executor = @executor AND                     
tdd.attr_name = 'bookingCompBankSwiftCode'                    
 ORDER BY tdd.creation_time DESC)  AS BookingCompBankSwiftCode,          
          
 (SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                    
tdd.key5 = @voucherNumStr AND                    
tdd.executor = @executor AND                     
tdd.attr_name = 'correspBankName'                    
 ORDER BY tdd.creation_time DESC)  AS CorrespBankName,           
           
 (SELECT TOP 1 tdd.attr_value FROM temp_docgen_data tdd WHERE                    
tdd.key5 = @voucherNumStr AND                    
tdd.executor = @executor AND                     
tdd.attr_name = 'correspBankSwiftCode'              
 ORDER BY tdd.creation_time DESC)  AS CorrespBankSwiftCode,          
          
(DATENAME(month, actual.ai_est_actual_date)+' '+                              
DATENAME(day, actual.ai_est_actual_date)+', '+                              
DATENAME(year, actual.ai_est_actual_date) ) AS ActualDateInMonthDayYearFormat,          
          
DATENAME(month, actual.ai_est_actual_date) AS ActualMonth,          
          
DATENAME(year, actual.ai_est_actual_date) AS ActualYear,          
( SELECT TOP 1 tdd.attr_value                         
 FROM temp_docgen_data tdd                         
  WHERE  tdd.key5 = @voucherNumStr AND                           
  tdd.executor = @executor AND                           
 tdd.attr_name = 'bookingCompanyInvoiceAddressesInfo'                          
  ORDER BY tdd.creation_time DESC                        
 )AS BookingCompanyInvoiceAddressesInfo,          
           
DelTermDescription= case                       
             when ti.item_type = 'D' then deltdp.del_term_desc                      
             when ti.item_type = 'W' then delt.del_term_desc                      
             end ,            
             
convert(VARCHAR(15),actual.alloc_num) + '/' +             
convert(VARCHAR(15),actual.alloc_item_num) + '/' +             
convert(VARCHAR(15),actual.ai_est_actual_num) as AllocationActualStr,                           
      
(select top 1 cei.cost_desc from voucher v           
inner join voucher_cost vc on v.voucher_num=vc.voucher_num                    
inner join cost c on c.cost_num= vc.cost_num                    
inner join cost_ext_info cei on c.cost_num= cei.cost_num       
where c.cost_type_code in ('PRF','PFO')                    
and v.voucher_num= @voucherNum) as PrefinalCostDesc      
                        
from voucher v left outer join voucher_cost vc                        
on v.voucher_num = vc.voucher_num                        
left outer join cost c                        
on vc.cost_num = c.cost_num                          
left outer join cost secc         
on secc.cost_num = vc.cost_num AND secc.cost_type_code NOT IN                         
('WPP', 'RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR')                              
left outer join cost seccfr                        
on seccfr.cost_num = vc.cost_num  AND seccfr.cost_code LIKE '%FREIGHT%'                            
left outer join cost seccinsp                          
on seccinsp.cost_num = vc.cost_num AND seccinsp.cost_code LIKE '%INSPECT%'                 
left outer join commodity cmdt                        
on cmdt.cmdty_code = c.cost_code                            
LEFT OUTER JOIN cost firstWPPCost                           
ON firstWPPCost.cost_num = @firstWPPCostNum                               
left outer join allocation_item ali                        
--on ali.alloc_num=c.cost_owner_key1 and ali.alloc_item_num = c.cost_owner_key2  AND (c.cost_owner_code IN('AI','AA','A'))                              
ON firstWPPCost.cost_owner_key1= ali.alloc_num AND firstWPPCost.cost_owner_key2= ali.alloc_item_num AND (firstWPPCost.cost_owner_code IN('AI','AA'))                               
LEFT OUTER JOIN allocation_item_vat alivat                          
ON alivat.alloc_num= ali.alloc_num AND alivat.alloc_item_num= ali.alloc_item_num                          
LEFT OUTER JOIN shipment ship                        
ON ship.alloc_num = firstWPPCost.cost_owner_key1                                
LEFT OUTER JOIN parcel prcl                        
on prcl.alloc_num=firstWPPCost.cost_owner_key1 and prcl.alloc_item_num=firstWPPCost.cost_owner_key2                                
LEFT OUTER JOIN ai_est_actual actual                        
on actual.alloc_num=firstWPPCost.cost_owner_key1 and actual.alloc_item_num=firstWPPCost.cost_owner_key2 AND actual.ai_est_actual_num =firstWPPCost.cost_owner_key3                                             
left outer join payment_method pm                        
on v.pay_method_code = pm.pay_method_code                        
                        
--left outer join account bc                        
--on v.voucher_book_comp_num = bc.acct_num                        
--left outer JOIN (SELECT TOP 1 aa1.* FROM  voucher v1 LEFT OUTER JOIN account_address aa1                         
--ON aa1.acct_num =v1.voucher_book_comp_num WHERE aa1.acct_addr_status = 'A' AND v1.voucher_num = @voucherNum) AS bcaa                        
--on v.voucher_book_comp_num = bcaa.acct_num                        
--left outer join account cp                        
--on v.acct_num = cp.acct_num                        
                        
left outer JOIN (SELECT TOP 1 aa1.* FROM  voucher v1 LEFT OUTER JOIN account_address aa1                         
     ON aa1.acct_num =v1.acct_num WHERE aa1.acct_addr_status = 'A' AND v1.voucher_num = @voucherNum) AS cpaa                        
on v.acct_num = cpaa.acct_num                        
left outer join account_bank_info cpbi                         
on v.cp_acct_bank_id = cpbi.acct_bank_id                         
left outer join account_bank_info bcbi                         
on v.book_comp_acct_bank_id = bcbi.acct_bank_id                        
LEFT OUTER JOIN location lloc                        
ON lloc.loc_code = ali.load_port_loc_code                        
LEFT OUTER JOIN location dloc                           
ON dloc.loc_code = ali.final_dest_loc_code                           
LEFT OUTER JOIN location titleloc                        
ON titleloc.loc_code = ali.title_tran_loc_code                            
LEFT OUTER JOIN country titletranscountryloc                        
ON titletranscountryloc.country_code = alivat.title_transfer_country_code                         
LEFT OUTER JOIN trade t                          
ON firstWPPCost.cost_owner_key6 = t.trade_num                          
LEFT OUTER JOIN trade_item ti                          
ON firstWPPCost.cost_owner_key6 = ti.trade_num AND firstWPPCost.cost_owner_key7 = ti.order_num AND firstWPPCost.cost_owner_key8 = ti.item_num                          
LEFT OUTER JOIN  trade_item_wet_phy tiwp                          
ON ti.trade_num = tiwp.trade_num AND ti.order_num = tiwp.order_num AND ti.item_num = tiwp.item_num                           
LEFT OUTER JOIN  trade_item_dry_phy tidp                                        
ON ti.trade_num = tidp.trade_num AND ti.order_num = tidp.order_num AND ti.item_num = tidp.item_num                        
LEFT OUTER JOIN commodity cmdty                            
ON ti.cmdty_code=cmdty.cmdty_code                           
LEFT OUTER JOIN payment_term pt                              
ON v.pay_term_code = pt.pay_term_code                          
LEFT OUTER JOIN uom u                          
ON u.uom_code = ti.contr_qty_uom_code                          
LEFT OUTER JOIN mot m                         
ON m.mot_code = tiwp.mot_code          
LEFT OUTER JOIN mot md                         
ON md.mot_code = tidp.mot_code                             
LEFT OUTER JOIN mot_type mt                          
ON mt.mot_type_code = m.mot_type_code           
LEFT OUTER JOIN mot_type mtd                          
ON mtd.mot_type_code = md.mot_type_code                             
LEFT OUTER JOIN location loadloc                          
ON loadloc.loc_code = ali.origin_loc_code                          
LEFT OUTER JOIN allocation_item_transport alit                      
ON  alit.alloc_num = ali.alloc_num AND  alit.alloc_item_num = ali.alloc_item_num                          
LEFT OUTER JOIN delivery_term delt                          
ON delt.del_term_code = tiwp.del_term_code                          
LEFT OUTER JOIN trade_formula tf                          
ON tf.trade_num = ti.trade_num AND tf.order_num= ti.order_num AND tf.item_num= ti.item_num  and tf.fall_back_ind = @isPriliminary                      
--LEFT OUTER JOIN formula_component fc                          
--ON fc.formula_num = tf.formula_num                          
--LEFT OUTER JOIN trade_item_spec tispec                          
--ON tispec.trade_num = ti.trade_num AND tispec.order_num = ti.order_num AND tispec.item_num = ti.item_num                          
--LEFT OUTER JOIN specification spec                          
--ON spec.spec_code= tispec.spec_code                          
LEFT OUTER JOIN exceptions_additions excp                          
ON excp.excp_addns_code= ti.excp_addns_code                          
LEFT OUTER JOIN formula f                          
on f.formula_num = tf.formula_num --and f.formula_num = fc.formula_num                          
LEFT OUTER JOIN location tiwploc                          
ON tiwploc.loc_code = tiwp.del_loc_code                          
LEFT OUTER JOIN credit_term ct                          
ON ct.credit_term_code = tiwp.credit_term_code                          
LEFT OUTER JOIN allocation_item_insp aiinsp                          
ON aiinsp.alloc_num = alit.alloc_num AND aiinsp.alloc_item_num= alit.alloc_item_num              
LEFT OUTER JOIN delivery_term deltdp                            
ON deltdp.del_term_code = tidp.del_term_code                      
where v.voucher_num = @voucherNum             
GO
GRANT EXECUTE ON  [dbo].[usp_get_data_for_invoice] TO [next_usr]
GO
