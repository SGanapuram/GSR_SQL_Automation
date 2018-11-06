SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_get_physical_preliminary_invoice_data]
(
   @voucherNum int
)
AS  
select       
bc.acct_full_name            									  AS BookingCompFullName,      
(SELECT TOP 1 aa1.acct_addr_line_1 FROM       
   account_address aa1      
  WHERE aa1.acct_num =v.voucher_book_comp_num AND       
  aa1.acct_addr_line_1 IS NOT NULL AND aa1.acct_addr_status='A')  AS BookingCompanyContractAddressesInfoLine1,      
(SELECT TOP 1 aa1.acct_addr_line_2 FROM       
  account_address aa1      
  WHERE aa1.acct_num =v.voucher_book_comp_num AND       
  aa1.acct_addr_line_2 IS NOT NULL AND aa1.acct_addr_status='A')  AS BookingCompanyContractAddressesInfoLine2,      
( SELECT (CASE WHEN bcaa.acct_addr_city IS NULL THEN      
  '' ELSE (isnull(bcaa.acct_addr_city,'')+', ') END)+        
  isnull(bcaa.state_code,'')+' '+      
  isnull(bcaa.acct_addr_zip_code,''))        					  AS BookingCompanyContractAddressesInfoLine1ForInvoice,      
        
bcaa.country_code                								  AS BookingCompanyContractAddressesInfoCountryCodeForInvoice,      
      
cp.acct_full_name            									  AS CounterpartyFullName,      
(SELECT TOP 1 aa1.acct_addr_line_1 FROM       
   account_address aa1      
  WHERE aa1.acct_num =v.acct_num AND       
  aa1.acct_addr_line_1 IS NOT NULL AND aa1.acct_addr_status='A' ) AS CounterpartyAddressInfoLine1,      
(SELECT TOP 1 aa1.acct_addr_line_2 FROM       
  account_address aa1      
  WHERE aa1.acct_num =v.acct_num AND       
  aa1.acct_addr_line_2 IS NOT NULL AND aa1.acct_addr_status='A') AS CounterpartyAddressInfoLine2,      
        
( SELECT (CASE WHEN cpaa.acct_addr_city IS NULL THEN      
  '' ELSE (isnull(cpaa.acct_addr_city,'')+', ') END)+        
  isnull(cpaa.state_code,'')+' '+      
  isnull(cpaa.acct_addr_zip_code,''))       					 AS CounterpartyAddressInfoLine1ForInvoice,     
cpaa.country_code             									 AS CounterpartyAddressInfoCountryCodeForInvoice,      
cpbi.bank_name              									 AS CounterpartyBankName,      
bcbi.bank_name              									 AS BookingCompanyBankName,      
v.voucher_num              										 AS VoucherNum,      
-- v.voucher_creation_date AS VoucherCreationDate,      
(DATENAME(month, v.voucher_creation_date)+' '+      
DATENAME(day, v.voucher_creation_date)+','+      
DATENAME(year, v.voucher_creation_date) )      					 AS VoucherCreationDate,      
--v.voucher_due_date as VoucherDueDate,      
(DATENAME(month, v.voucher_due_date)+' '+      
DATENAME(day, v.voucher_due_date)+','+      
DATENAME(year, v.voucher_due_date) )       						 AS VoucherDueDate,      
v.voucher_pay_recv_ind           								 AS VoucherPayRecvInd,      
      
( CASE WHEN (SELECT TOP 1 ac1.acct_cont_off_ph_num FROM       
 voucher v1 LEFT OUTER JOIN account_instruction ai1      
 ON ai1.acct_num= v1.voucher_book_comp_num AND ai1.acct_instr_type_code = 'INVOICE'      
 LEFT OUTER JOIN  account_contact ac1       
 ON ac1.acct_num = ai1.acct_num AND ac1.acct_cont_off_ph_num IS NOT NULL      
 WHERE v1.voucher_num =@voucherNum) IS NOT NULL THEN      
   (SELECT TOP 1 ac1.acct_cont_off_ph_num FROM       
 voucher v1 LEFT OUTER JOIN account_instruction ai1      
 ON ai1.acct_num= v1.voucher_book_comp_num AND ai1.acct_instr_type_code = 'INVOICE'      
 LEFT OUTER JOIN  account_contact ac1       
 ON ac1.acct_num = ai1.acct_num AND ac1.acct_cont_off_ph_num IS NOT NULL      
 WHERE v1.voucher_num =@voucherNum) ELSE      
 (SELECT TOP 1 aa1.acct_addr_ph_num FROM  account_address aa1       
 WHERE aa1.acct_num = v.voucher_book_comp_num)      
 END )                											AS BookingCompanyPhoneInfoForInvoice,       
(SELECT ( CASE WHEN (SELECT TOP 1 ac1.acct_cont_fax_num FROM       
 voucher v1 LEFT OUTER JOIN account_instruction ai1      
 ON ai1.acct_num= v1.voucher_book_comp_num AND ai1.acct_instr_type_code = 'INVOICE'      
 LEFT OUTER JOIN  account_contact ac1       
 ON ac1.acct_num = ai1.acct_num AND ac1.acct_cont_fax_num IS NOT NULL      
 WHERE v1.voucher_num =@voucherNum) IS NOT NULL THEN      
   (SELECT TOP 1 ac1.acct_cont_fax_num FROM       
 voucher v1 LEFT OUTER JOIN account_instruction ai1      
 ON ai1.acct_num= v1.voucher_book_comp_num AND ai1.acct_instr_type_code = 'INVOICE'      
 LEFT OUTER JOIN  account_contact ac1       
 ON ac1.acct_num = ai1.acct_num AND ac1.acct_cont_fax_num IS NOT NULL      
 WHERE v1.voucher_num =@voucherNum) ELSE      
 (SELECT TOP 1 aa1.acct_addr_fax_num FROM  account_address aa1       
 WHERE aa1.acct_num = v.voucher_book_comp_num)      
 END ))               											AS BookingCompanyFaxInfoForInvoice,      
       
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
 END ) )               											AS BookingCompanyEmailInfoForInvoice,       
cpaa.acct_addr_ph_num             								AS CounterpartyPhoneInfoForInvoice,      
cpaa.acct_addr_fax_num             								AS CounterpartyFaxInfoForInvoice,      
cpaa.acct_addr_email             								AS CounterpartyEmailInfoForInvoice,      
(SELECT TOP 1 ac1.acct_cont_first_name +' '+ac1.acct_cont_last_name       
FROM account_contact ac1 WHERE ac1.acct_cont_status ='A'       
AND ac1.acct_num=v.acct_num)           							AS CounterPartyAcctContactFullName,      
pm.pay_method_desc              								AS PaymentMethodDescription,      
bcbi.swift_code              									AS BookingCompanyBankSwiftCode,      
bcbi.bank_acct_no             									AS BookingCompanyBankAcctNo,      
cpbi.swift_code                 								AS CounterpartyBankSwiftCode,      
cpbi.bank_acct_no              									AS CounterpartyBankAcctNo,      
      
(CASE WHEN len(cmdt.cmdty_full_name) < 16 THEN      
      cmdt.cmdty_full_name       
      WHEN len(cmdt.cmdty_short_name) < 16 THEN      
       cmdt.cmdty_short_name       
       ELSE      
       cmdt.cmdty_code END)           							AS CostCommodityName,      
             
c.cost_num                										AS CostNum,      
(CASE WHEN ship.oid IS NULL THEN '' ELSE      
  (select convert(VARCHAR,ship.oid)  
   where c.cost_owner_code IN('AI','AA','A')) END)        		AS ShipmentOidForCost,      
    
(CASE WHEN prcl.oid IS NULL THEN '' ELSE      
 (select convert(VARCHAR,prcl.oid)   
 where c.cost_owner_code IN('AI','AA','A')) END)         		AS ParcelOidForCost,     
    
(CASE WHEN c.cost_owner_key3 IS NULL THEN '' ELSE      
  (select convert(VARCHAR,c.cost_owner_key3)  
    where c.cost_owner_code IN('AI','AA','A')) END)        		AS ActualNumStrForCost,     
      
 --c.creation_date as CostCreationDate,      
 REPLACE(CONVERT(VARCHAR(10),c.creation_date, 1), '/', '/') 	AS CostCreationDate,      
 (CASE WHEN c.cost_pay_rec_ind ='P' THEN      
        'Buy'       
        WHEN c.cost_pay_rec_ind ='R' THEN      
        'Sell'      
        ELSE '' END )                							AS PSInd,      
lloc.loc_name             										AS LoadPortLocationForAllocationItem,      
dloc.loc_name              										AS FinalDestLocationForAllocationItem,                 
REPLACE(CONVERT(VARCHAR(10),actual.ai_est_actual_date, 1), '/', '/') AS ActualDate,          
REPLACE(CONVERT(VARCHAR(10),ship.start_date, 1), '/', '/')  	AS ShipmentStartDate,      
REPLACE(CONVERT(VARCHAR(10),ship.end_date, 1), '/', '/')    	AS ShipmentEndDate,      
(CASE WHEN c.cost_amt_type = 'C' OR c.cost_amt_type = 'f'      
 THEN ''      
 ELSE convert(VARCHAR,c.cost_unit_price) END      
)               												AS CostUnitPriceStrInfo,      
(CASE WHEN c.cost_amt_type = 'F' OR c.cost_amt_type IS NULL      
    THEN 'Flat'      
    ELSE 'Unit Price' END      
)                    											AS CostAmountTypeDesc,      
c.cost_qty_uom_code           									AS CostQtyUomCode,       
c.cost_qty               										AS CostQty,   
(CASE WHEN c.cost_pay_rec_ind = 'P' AND c.cost_amt IS NOT NULL      
   THEN (c.cost_amt * -1)      
   ELSE c.cost_amt END         
)               												AS CostAmtStrInfo,       
       
 --new      
tiwp.mot_code													AS MotCode,
m.mot_full_name													AS MotFullName,
m.mot_short_name												AS MotShortName,
m.mot_type_code													AS MotTypeCode,
mt.mot_type_short_name											AS MotTypeShortName,
ti.cmdty_code													AS CommodityCode,
cmdty.cmdty_short_name											AS CommodityShortName,
cmdty.cmdty_full_name											AS CommodityFullName,

(DATENAME(month, tiwp.del_date_from)+' '+            
DATENAME(day, tiwp.del_date_from)+', '+            
DATENAME(year, tiwp.del_date_from) ) 							AS DelDateFrom,

(DATENAME(month, tiwp.del_date_to)+' '+            
DATENAME(day, tiwp.del_date_to)+', '+            
DATENAME(year, tiwp.del_date_to) )								AS DelDateTo,  

(DATENAME(month, tiwp.del_date_from)+' '+            
DATENAME(day, tiwp.del_date_from)+'-'+
DATENAME(day, tiwp.del_date_to)+', '+            
DATENAME(year, tiwp.del_date_from) )	   						AS DeliveryPeriod,

ti.trade_num													AS TradeNum,
ti.order_num													AS OrderNum,
ti.item_num														AS ItemNum,
(convert(VARCHAR, ti.trade_num)+'/'+
 convert(VARCHAR,ti.order_num) +'/'+
 convert(VARCHAR,ti.item_num ))									AS RefNR,
ti.contr_qty													AS ContractQty,
u.uom_full_name													AS ContrQtyUomName,
ti.contr_qty_uom_code											AS ContrQtyUomCode,

( SELECT TOP 1 c1.cost_unit_price FROM cost c1 WHERE c1.cost_num
 IN(vc.cost_num) AND c1.cost_type_code = 'PR')					AS CostUnitPrice, 
( SELECT TOP 1 c1.cost_price_curr_code FROM cost c1 WHERE 
c1.cost_num IN(vc.cost_num) AND c1.cost_type_code = 'PR')		AS CostPriceCurrCode,
( SELECT TOP 1 c1.cost_price_uom_code FROM cost c1 WHERE 
c1.cost_num IN(vc.cost_num) AND c1.cost_type_code = 'PR')		AS CostPriceUomCode,

 v.voucher_tot_amt												AS VoucherTotAmt,
 v.voucher_curr_code											AS VoucherCurrCode,

pt.pay_term_contr_desc											AS PayTermContrDesc,
pt.pay_term_desc												AS PayTermDesc,
																
(DATENAME(month, t.contr_date)+' '+            
DATENAME(day, t.contr_date)+', '+            
DATENAME(year, t.contr_date) )									AS TradeContrDate,
ali.origin_loc_code												AS LoadLocCode,
loadloc.loc_name												AS LoadLocName,

(SELECT  
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
 )																AS BookingCompBankInfo,
c.cost_amt														AS CostAmount,
c.cost_unit_price												AS CostUnitPriceDetail,
c.cost_price_uom_code								 			AS CostPriceUomCodeDetail,

c.cost_book_exch_rate											AS CostBookExchRate,
v.voucher_paid_date												AS VoucherPaidDate,
(DATENAME(month, alit.bl_date)+' '+            
DATENAME(day, alit.bl_date)+', '+            
DATENAME(year, alit.bl_date) )									AS BLDate
       
from voucher v left outer join voucher_cost vc      
on v.voucher_num = vc.voucher_num      
left outer join cost c      
on vc.cost_num = c.cost_num      
left outer join commodity cmdt      
on cmdt.cmdty_code = c.cost_code       
left outer join allocation_item ali      
on ali.alloc_num=c.cost_owner_key1 and ali.alloc_item_num = c.cost_owner_key2  AND (c.cost_owner_code IN('AI','AA','A'))    
LEFT OUTER JOIN shipment ship      
ON ship.alloc_num = c.cost_owner_key1    
LEFT OUTER JOIN parcel prcl      
on prcl.alloc_num=c.cost_owner_key1 and prcl.alloc_item_num=c.cost_owner_key2    
LEFT OUTER JOIN ai_est_actual actual      
on actual.alloc_num=c.cost_owner_key1 and actual.alloc_item_num=c.cost_owner_key2 AND actual.ai_est_actual_num =c.cost_owner_key3       
left outer join payment_method pm      
on v.pay_method_code = pm.pay_method_code      
left outer join account bc      
on v.voucher_book_comp_num = bc.acct_num      
left outer JOIN (SELECT TOP 1 aa1.* FROM  voucher v1 LEFT OUTER JOIN account_address aa1       
     ON aa1.acct_num =v1.voucher_book_comp_num WHERE aa1.acct_addr_status = 'A' AND v1.voucher_num = @voucherNum) AS bcaa      
on v.voucher_book_comp_num = bcaa.acct_num      
left outer join account cp      
on v.acct_num = cp.acct_num      
left outer JOIN (SELECT TOP 1 aa1.* FROM  voucher v1 LEFT OUTER JOIN account_address aa1       
     ON aa1.acct_num =v1.acct_num WHERE aa1.acct_addr_status = 'A' AND v1.voucher_num = @voucherNum) AS cpaa      
on v.acct_num = bcaa.acct_num      
      
left outer join account_bank_info cpbi       
on v.cp_acct_bank_id = cpbi.acct_bank_id       
left outer join account_bank_info bcbi       
on v.book_comp_acct_bank_id = bcbi.acct_bank_id      
LEFT OUTER JOIN location lloc      
ON lloc.loc_code = ali.load_port_loc_code      
LEFT OUTER JOIN location dloc      
ON dloc.loc_code = ali.final_dest_loc_code      

LEFT OUTER JOIN trade t
ON c.cost_owner_key6 = t.trade_num
LEFT OUTER JOIN trade_item ti
ON c.cost_owner_key6 = ti.trade_num AND c.cost_owner_key7 = ti.order_num AND c.cost_owner_key8 = ti.item_num
LEFT OUTER JOIN  trade_item_wet_phy tiwp            
ON ti.trade_num = tiwp.trade_num AND ti.order_num = tiwp.order_num AND ti.item_num = tiwp.item_num 
LEFT OUTER JOIN commodity cmdty            
ON ti.cmdty_code=cmdty.cmdty_code 
LEFT OUTER JOIN payment_term pt            
ON v.pay_term_code = pt.pay_term_code
LEFT OUTER JOIN uom u
ON u.uom_code = ti.contr_qty_uom_code
LEFT OUTER JOIN mot m
ON m.mot_code = tiwp.mot_code
LEFT OUTER JOIN mot_type mt
ON mt.mot_type_code = m.mot_type_code 
LEFT OUTER JOIN location loadloc
ON loadloc.loc_code = ali.origin_loc_code
LEFT OUTER JOIN allocation_item_transport alit
ON  alit.alloc_num = ali.alloc_num AND  alit.alloc_item_num = ali.alloc_item_num
      
where v.voucher_num = @voucherNum

return
GO
GRANT EXECUTE ON  [dbo].[usp_get_physical_preliminary_invoice_data] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_get_physical_preliminary_invoice_data', NULL, NULL
GO
