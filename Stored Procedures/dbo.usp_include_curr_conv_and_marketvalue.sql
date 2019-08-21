SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
    
CREATE procedure [dbo].[usp_include_curr_conv_and_marketvalue]      
    
(      
    
@iPortNum int,      
    
@iAsOfDate1 date,      
    
@iAsOfDate2 date,      
    
@iToCurr char(8)      
    
)      
    
as      
   
begin  

--DECLARE @iPortNum int = 5117      
    
--DECLARE @iAsOfDate1 date = '03 Aug 2016'      
    
--DECLARE @iAsOfDate2 date = '12 Aug 2016'
    
--DECLARE @iToCurr char(8)   = 'USD'   
    
SET nocount on      
    
Create table #invCostTbl        
(        
inventoryNum int,        
invPortNum int,        
invPosNum int,        
invTINum int,        
invOrderNum smallint,        
invItemNum smallint,        
invItemType char(1), --It Should be 'S'        
invItemPSInd char(1),
invCmdtyCode char(8),

invPortShortName varchar(25),
invPortFullName varchar(255),
invItemCmdtyShortName varchar(15),
invItemCmdtyFullName varchar(40),
invItemAcctShortName nvarchar(30), --CounterParty
invItemAcctFullName nvarchar(510),
invLocName varchar(40), -- may be TitleTrans

invCostCurrCode char(8),
invCostUomCode char(8),
        
        
invTIContrQty float,        
invTIContrQtyUom char(4),        
invTIPortNum int,        
        
invItemAllocNum int,        
invItemAllocItemNum smallint,        
invAIFullyActualized char(1),        
        
        
invOppTiNum int,        
invOppOrderNum smallint,        
invOppItemNum smallint,        
invOppItemType char(1), --It Should may be 'S' or 'W'         
invOppItemPSInd char(1),        
invOppTiContrQty float,        
invOppTiContrQtyUom char(4),        
invOppTIPortNum int,        
invOppTICmdtyCode char(8),        
invOppItemAllocNum int,        
invOppItemAllocItemNum smallint,        
invOppAIFullyActualized char(1),        
        
invAllocType char(1), -- need for  Inv Adjestments i.e. 'J'        
        
invOppItemActualAllocNum int,        
invOppItemActualAINum smallint,        
invOppItemActualNum smallint,        
actualDate date,        
        
        
costNum int,        
costPayRecInd char(1),        
costAmt float,        
costQty float,        
costQtyUomCode char(4),        
costUnitPrice float,        
costTypeCode char(8),        
costOwnerCode char(2),        
costStatus char(8),        
costEffDate date,        
        
invBDQty float,         
invBDActQty float,        
invBDCost float,        
invBDCostCurrCode char(4),        
invBDType char(1),        
invBDStatus char(1),        
        
        
        
        
PrimaryActQtyBtnDates float,        
        
ReceivedActQtyBtnDates float,        
        
SaleActQtyBtnDates float,        
        
PrimaryActQtyUomBtnDates char(4),        
        
        
SecondaryActQtyBtnDates float,        
        
SecondaryActQtyUomBtnDates char(4),        
        
        
-------*********--------------        
        
UnitPrice float,        
        
UnitPriceUom char(4),        
        
UnitPriceCurr char(4),        
        
---asof_date date,        
costEffOrActualDate date,        
        
-----******************--------------------        
        
---------****** inv Open and closed  Qty(s) ***---------        
        
OpenInvQtyOnAsOfDate1 float,        
ClosedInvQtyOnAsOfDate1 float,
OpenOrClosedInvQtyUom  varchar(4),

SecOpenInvQtyOnAsOfDate1 float,        
SecClosedInvQtyOnAsOfDate1 float,
SecOpenOrClosedInvQtyUom  varchar(4) 
      
)        
        
        
-------************************--------------        
        
--**** Get All real ports of @iPortNum *****------        
create table #RealPortChildren (port_num int)        
create table #children (port_num int,port_type char(2) )        
insert into #RealPortChildren(port_num) exec port_children  @iPortNum, 'R'        
drop table #children        
-------************************--------------        
--drop table #RealPortChildren        
        
---********* Get Inv number for given portNum *********----------------------        
        
declare @invTable table (ID int IDENTITY(1,1) PRIMARY KEY, inv_num int)        
   
insert into @invTable select distinct inv_num from inventory where port_num in (select distinct port_num from #RealPortChildren)        
   
 Declare @invruns table(id int, bdDate date, bdQty float, bdUom varchar(4), bdAllocNum int, bdAllocItemNum int, invNum int,--invBDNum int,        
        bdType varchar(8), pTradeNum int, counterpartyName varchar(120), RunningBalance float, 
        EndOfDayBalance float, associatedTrade varchar(40), invBDCost int, 
        SecBdQty   float, SecBdUom   varchar(4),                     
        SecRunningBalance  float, SecEndOfDayBalance   float )        
   ----     insert into @invruns exec usp_invruns 7041        
        DECLARE @a INT = (select MAX(ID) from @invTable)        
  DECLARE @inum int = 0        
        WHILE @a > 0        
        BEGIN        
            select @inum =  inv_num from @invTable where ID = @a        
            insert into @invruns exec usp_invruns_include_sec_qty @inum        
            SET @a = @a - 1        
        END 
                  
   --select * from  @invruns        
        
------*****************************-------------------------------------------        
insert into  #invCostTbl        
(        
inventoryNum ,        
invPortNum ,        
invPosNum,        
invTINum ,        
invOrderNum ,        
invItemNum ,        
invItemType , --It Should be 'S'        
invItemPSInd ,
invCmdtyCode,

invPortShortName,
invPortFullName, 
invItemCmdtyShortName,
invItemCmdtyFullName,
invItemAcctShortName,
invItemAcctFullName,  
invLocName,     

invCostCurrCode,
invCostUomCode,
        
invTIContrQty ,        
invTIContrQtyUom ,        
invTIPortNum ,        
        
invItemAllocNum ,        
invItemAllocItemNum ,        
invAIFullyActualized,        
        
invOppTiNum ,        
invOppOrderNum ,        
invOppItemNum ,        
invOppItemType , --It Should may be 'S' or 'W'         
invOppItemPSInd ,        
invOppTiContrQty ,        
invOppTiContrQtyUom ,        
invOppTIPortNum ,        
invOppTICmdtyCode,        
invOppItemAllocNum ,        
invOppItemAllocItemNum ,        
invOppAIFullyActualized,        
        
invAllocType , -- need for  Inv Adjestments i.e. 'J'        
        
invOppItemActualAllocNum ,        
invOppItemActualAINum ,        
invOppItemActualNum ,        
actualDate,        
        
        
costNum ,        
costPayRecInd ,        
costAmt ,        
costQty ,        
costQtyUomCode ,        
costUnitPrice ,        
costTypeCode ,        
costOwnerCode ,        
costStatus ,        
costEffDate,        
        
invBDQty ,         
invBDActQty ,        
invBDCost ,        
invBDCostCurrCode ,        
invBDType ,        
 invBDStatus ,        
        
        
        
        
PrimaryActQtyBtnDates ,        
        
ReceivedActQtyBtnDates ,        
        
SaleActQtyBtnDates ,        
        
PrimaryActQtyUomBtnDates ,        
        
        
SecondaryActQtyBtnDates ,        
        
SecondaryActQtyUomBtnDates ,        
--aie.ai_est_actual_net_qty as NetQtyBtnDates ,        
--aie.ai_net_qty_uom_code as NetQtyUomBtnDates ,        
--aie.ai_est_actual_gross_qty as GrossQtyBtnDates ,        
--aie.ai_gross_qty_uom_code as GrossQtyUomBtnDates ,        
        
-------*********--------------        
        
UnitPrice ,        
        
UnitPriceUom ,        
        
UnitPriceCurr ,        
        
costEffOrActualDate,        
        
---asof_date,        
        
        
        
-----******************--------------------        
        
---------****** inv Open and closed  Qty(s) ***---------        
        
OpenInvQtyOnAsOfDate1 ,        
ClosedInvQtyOnAsOfDate1,
OpenOrClosedInvQtyUom,

SecOpenInvQtyOnAsOfDate1,        
SecClosedInvQtyOnAsOfDate1,
SecOpenOrClosedInvQtyUom        
        
)        
----*** Get all detail data for inv which are related to given port num(including child) *******------        
(select distinct        
--**** Required fields in report *****-----        
        
---****************Key fields *********-----------------        
        
inv.inv_num as inventoryNum,        
inv.port_num as invPortNum,        
inv.pos_num as invPosNum,        
ti.trade_num as invTINum,        
ti.order_num as invOrderNum,        
ti.item_num as invItemNum,        
ti.item_type as invItemType, --It Should be 'S'        
ti.p_s_ind  as invItemPSInd,
inv.cmdty_code as invCmdtyCode,        

port.port_short_name  invPortShortName,
port.port_full_name  invPortFullName, 
cmdty.cmdty_short_name  as invItemCmdtyShortName,
cmdty.cmdty_full_name  as invItemCmdtyFullName,
acct.acct_short_name  as invItemAcctShortName,
acct.acct_full_name  as invItemAcctFullName,
loc.loc_name as invLocName,

inv.inv_cost_curr_code  as invCostCurrCode,
inv.inv_cost_uom_code as invCostUomCode,

        
ti.contr_qty as invTIContrQty,        
ti.contr_qty_uom_code as invTIContrQtyUom,        
ti.real_port_num as invTIPortNum,        
        
ai.alloc_num as invItemAllocNum,        
ai.alloc_item_num as invItemAllocItemNum,        
ai.fully_actualized as invAIFullyActualized,        
        
ti2.trade_num as invOppTiNum,        
ti2.order_num as invOppOrderNum,        
ti2.item_num as invOppItemNum,        
ti2.item_type as invOppItemType, --It Should may be 'S' or 'W'         
ti2.p_s_ind  as invOppItemPSInd,        
ti2.contr_qty as invOppTiContrQty,        
ti2.contr_qty_uom_code as invOppTiContrQtyUom,        
ti2.real_port_num as invOppTIPortNum,        
ti2.cmdty_code as invOppTICmdtyCode,        
ai2.alloc_num as invOppItemAllocNum,        
ai2.alloc_item_num as invOppItemAllocItemNum,        
ai2.fully_actualized as invOppAIFullyActualized,        
        
a.alloc_type_code as invAllocType, -- need for  Inv Adjestments i.e. 'J'        
        
aie.alloc_num as invOppItemActualAllocNum,        
aie.alloc_item_num as invOppItemActualAINum,        
aie.ai_est_actual_num as invOppItemActualNum,        
aie.ai_est_actual_date as actualDate,        
        
        
c.cost_num as costNum,        
c.cost_pay_rec_ind as costPayRecInd,          
(case when c.cost_pay_rec_ind = 'P' then (-c.cost_amt)
else c.cost_amt end) as costAmt,          
c.cost_qty as costQty,        
c.cost_qty_uom_code as costQtyUomCode,        
c.cost_unit_price as costUnitPrice,        
c.cost_type_code as costTypeCode,        
c.cost_owner_code as costOwnerCode,        
c.cost_status as costStatus,        
c.cost_eff_date as costEffDate,        
        
ibd.inv_b_d_qty as invBDQty,         
ibd.inv_b_d_actual_qty as invBDActQty,        
ibd.inv_b_d_cost invBDCost,        
ibd.inv_b_d_cost_curr_code as invBDCostCurrCode,        
ibd.inv_b_d_type as invBDType,        
ibd.inv_b_d_status as invBDStatus,        
        
        
        
        
--------*******************************-----------------        
        
--********** "Received Qty Between AsOfDates" P/S Ind = P  combination of below two fields ******----------------        
---****** "Sale Qty" also handle here P/S Ind = S ****-----------------------------        
        
(case when ti2.billing_type = 'G' then aie.ai_est_actual_gross_qty        
else aie.ai_est_actual_net_qty end) as PrimaryActQtyBtnDates,        
        
(case when ti2.p_s_ind = 'P' and ti2.billing_type = 'G' then  aie.ai_est_actual_gross_qty        
   when ti2.p_s_ind = 'P'  then  aie.ai_est_actual_net_qty --and ti2.billing_type != 'G'        
   else 0 end) as  ReceivedActQtyBtnDates,        
        
(case when ti2.p_s_ind = 'S' and ti2.billing_type = 'G' then  aie.ai_est_actual_gross_qty        
   when ti2.p_s_ind = 'S' then  aie.ai_est_actual_net_qty --and ti2.billing_type != 'G'        
   else 0 end) as SaleActQtyBtnDates,        
        
(case when ti2.billing_type = 'G' then aie.ai_gross_qty_uom_code        
else aie.ai_net_qty_uom_code end) as PrimaryActQtyUomBtnDates,        
        
        
(case when ti2.billing_type = 'G' then aie.secondary_actual_gross_qty        
else aie.secondary_actual_net_qty end) as SecondaryActQtyBtnDates,        
        
aie.secondary_qty_uom_code as SecondaryActQtyUomBtnDates,        
--aie.ai_est_actual_net_qty as NetQtyBtnDates,        
--aie.ai_net_qty_uom_code as NetQtyUomBtnDates,        
--aie.ai_est_actual_gross_qty as GrossQtyBtnDates,        
--aie.ai_gross_qty_uom_code as GrossQtyUomBtnDates,        
        
-------*********--------------        
        
---****** Unit Price and their Uom,Curr ****-----------------------------          
(case when ti2.item_type in('S','T') and a.alloc_type_code != 'J' then inv.inv_avg_cost           
when (isnull(c.cost_unit_price,0) != 0 and c.cost_type_code  in ('WPP', 'DPP', 'RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'NO' , 'BOAI' , 'CPP' , 'CPR'))  then  c.cost_unit_price
--0th actual it may null          
      else inv.inv_avg_cost  end) as UnitPrice,          
          
(case when ti2.item_type in('S','T') and a.alloc_type_code != 'J' then inv.inv_cost_uom_code          
when (c.cost_price_uom_code is not null and c.cost_type_code  in ('WPP', 'DPP', 'RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'NO' , 'BOAI' , 'CPP' , 'CPR'))then  c.cost_price_uom_code  
  --0th actual it may null          
      else inv.inv_cost_uom_code  end) as UnitPriceUom,          
          
          
          
(case when ti2.item_type in('S','T') and a.alloc_type_code != 'J' then inv.inv_cost_curr_code          
      when (c.cost_price_curr_code is not null and c.cost_type_code  in ('WPP', 'DPP', 'RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'NO' , 'BOAI' , 'CPP' , 'CPR'))  then  c.cost_price_curr_code  
      --0th actual it may null          
      else inv.inv_cost_curr_code  end) as UnitPriceCurr,          
          
          
(case when ti2.item_type in('S','T') and a.alloc_type_code != 'J' then aie.ai_est_actual_date      
      when (c.cost_eff_date is not null and c.cost_type_code  in ('WPP', 'DPP', 'RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'NO' , 'BOAI' , 'CPP' , 'CPR')) then  c.cost_eff_date
      --0th actual it may null    
      else aie.ai_est_actual_date  end) as costEffOrActualDate,                
          
--(case  when isnull(aie.ai_est_actual_date,0) !=0 then aie.ai_est_actual_date                 
--       else c.cost_eff_date end) as asof_date,        
        
-----******************--------------------        
        
---------****** inv Open and closed  Qty(s) ***---------        
        
(select top 1 EndOfDayBalance from @invruns where invNum = ai.inv_num and CAST(bdDate as DATE) <= @iAsOfDate1  order by bdDate desc) as OpenInvQtyOnAsOfDate1,        
(select top 1 EndOfDayBalance from @invruns where invNum = ai.inv_num and CAST(bdDate as DATE) <= @iAsOfDate2 order by bdDate desc) as ClosedInvQtyOnAsOfDate1,        
(select top 1 bdUom from @invruns where invNum = ai.inv_num) as OpenOrClosedInvQtyUom,

(select top 1 SecEndOfDayBalance from @invruns where invNum = ai.inv_num and CAST(bdDate as DATE) <= @iAsOfDate1  order by bdDate desc) as SecOpenInvQtyOnAsOfDate1,        
(select top 1 SecEndOfDayBalance from @invruns where invNum = ai.inv_num and CAST(bdDate as DATE) <= @iAsOfDate2 order by bdDate desc) as SecClosedInvQtyOnAsOfDate1,
(select top 1 SecBdUom from @invruns where invNum = ai.inv_num) as SecOpenOrClosedInvQtyUom        
   
        
-------------***************************---------------------------------------------------        
        
        
        
---,*         
from inventory inv         
LEFT OUTER JOIN trade_item ti on ti.trade_num = inv.trade_num  and ti.order_num = inv.order_num --Get storage TI related to INV        
LEFT OUTER JOIN portfolio port on port.port_num = inv.port_num
LEFT OUTER JOIN commodity cmdty on cmdty.cmdty_code = ti.cmdty_code
LEFT OUTER JOIN trade t1 on t1.trade_num = ti.trade_num
LEFT OUTER JOIN account acct on acct.acct_num = t1.acct_num
LEFT OUTER JOIN trade_item_storage storage on ti.trade_num = storage.trade_num  and ti.order_num = storage.order_num and ti.item_num = storage.item_num --TI(S) Related to inv        
LEFT OUTER JOIN trade_item_transport trans on ti.trade_num = trans.trade_num  and ti.order_num = trans.order_num and ti.item_num = trans.item_num --TI(S) Related to inv        
LEFT OUTER JOIN location loc on  (storage.storage_loc_code is not null and loc.loc_code = storage.storage_loc_code) or (trans.del_loc_code is not null and loc.loc_code = trans.del_loc_code)
LEFT OUTER JOIN allocation_item ai on ai.trade_num = ti.trade_num  and ai.order_num = ti.order_num and ai.item_num = ti.item_num -- AI(S) related to Inv storage item        
LEFT OUTER JOIN allocation_item ai2 on ai2.alloc_num = ai.alloc_num ----and  ai2.alloc_item_num != ai.alloc_item_num --AI(S) Related to inv excluding INV storage TI alloc        
LEFT OUTER JOIN trade_item ti2 on ti2.trade_num = ai2.trade_num  and ti2.order_num = ai2.order_num and ti2.item_num = ai2.item_num --TI(S) Related to inv        
--LEFT OUTER JOIN trade_item_wet_phy wet on ti2.trade_num = wet.trade_num  and ti2.order_num = wet.order_num and ti2.item_num = wet.item_num --TI(S) Related to inv        
--LEFT OUTER JOIN trade_item_dry_phy dry on ti2.trade_num = dry.trade_num  and ti2.order_num = dry.order_num and ti2.item_num = dry.item_num --TI(S) Related to inv        
--LEFT OUTER JOIN location loc on (wet.del_loc_code is not null and loc.loc_code = wet.del_loc_code) or (dry.del_loc_code is not null or loc.loc_code = dry.del_loc_code)
LEFT OUTER JOIN ai_est_actual aie on ai2.alloc_num = aie.alloc_num and  ai2.alloc_item_num = aie.alloc_item_num --Actual(s) Realted to inv and given dates        
LEFT OUTER JOIN allocation a on a.alloc_num = ai.alloc_num        
LEFT OUTER JOIN inventory_build_draw ibd on ibd.inv_num = inv.inv_num and ibd.trade_num = ai2.trade_num  and ibd.order_num = ai2.order_num and ibd.item_num = ai2.item_num  and         
ai2.alloc_num = ibd.alloc_num and  ai2.alloc_item_num = ibd.alloc_item_num        
LEFT OUTER JOIN cost c on c.cost_status  not in ('CLOSED') and         
((c.cost_owner_key1 = aie.alloc_num and c.cost_owner_key2 = aie.alloc_item_num         
and         
((c.cost_owner_key3 = aie.ai_est_actual_num and c.cost_owner_code in ('AA'))  or (c.cost_owner_key3 is null and c.cost_owner_code in ('AI')))))        
-- or         
--(c.cost_owner_code in ('TI') and c.cost_owner_key1 = ti2.trade_num and c.cost_owner_key2 = ti2.order_num and c.cost_owner_key3 = ti2.item_num and c.cost_type_code not in ('WPP', 'DPP', 'RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SP
  
    
      
--P' , 'SWAP' , 'SWPR' , 'BO' , 'NO' , 'BOAI' , 'CPP' , 'CPR'))) --only TI secondary)        
        
where inv.inv_num in (select distinct inv_num from @invTable) and ai.alloc_num is not null
--and CAST(aie.ai_est_actual_date as DATE) >=@iAsOfDate1 
and CAST(aie.ai_est_actual_date as DATE) <=@iAsOfDate2        
        
        
union        
        
select distinct        
--**** Required fields in report *****-----        
        
---****************Key fields *********-----------------        
        
inv.inv_num as inventoryNum,        
inv.port_num as invPortNum,        
inv.pos_num as invPosNum,        
ti.trade_num as invTINum,        
ti.order_num as invOrderNum,        
ti.item_num as invItemNum,        
ti.item_type as invItemType, --It Should be 'S'        
ti.p_s_ind  as invItemPSInd,
inv.cmdty_code as invCmdtyCode, 

port.port_short_name  invPortShortName,
port.port_full_name  invPortFullName,
cmdty.cmdty_short_name  as invItemCmdtyShortName,
cmdty.cmdty_full_name  as invItemCmdtyFullName,
acct.acct_short_name  as invItemAcctShortName,
acct.acct_full_name  as invItemAcctFullName,
loc.loc_name as invLocName,

inv.inv_cost_curr_code  as invCostCurrCode,
inv.inv_cost_uom_code as invCostUomCode,

        
ti.contr_qty as invTIContrQty,        
ti.contr_qty_uom_code as invTIContrQtyUom,        
ti.real_port_num as invTIPortNum,        
        
ai.alloc_num as invItemAllocNum,        
ai.alloc_item_num as invItemAllocItemNum,        
ai.fully_actualized as invAIFullyActualized,        
        
ti2.trade_num as invOppTiNum,        
ti2.order_num as invOppOrderNum,        
ti2.item_num as invOppItemNum,        
ti2.item_type as invOppItemType, --It Should may be 'S' or 'W'         
ti2.p_s_ind  as invOppItemPSInd,        
ti2.contr_qty as invOppTiContrQty,        
ti2.contr_qty_uom_code as invOppTiContrQtyUom,        
ti2.real_port_num as invOppTIPortNum,        
ti2.cmdty_code as invOppTICmdtyCode,        
ai2.alloc_num as invOppItemAllocNum,        
ai2.alloc_item_num as invOppItemAllocItemNum,        
ai2.fully_actualized as invOppAIFullyActualized,        
        
a.alloc_type_code as invAllocType, -- need for  Inv Adjestments i.e. 'J'        
        
aie.alloc_num as invOppItemActualAllocNum,        
aie.alloc_item_num as invOppItemActualAINum,        
aie.ai_est_actual_num as invOppItemActualNum,        
aie.ai_est_actual_date as actualDate,        
        
        
c.cost_num as costNum,          
c.cost_pay_rec_ind as costPayRecInd,          
(case when c.cost_pay_rec_ind = 'P' then (-c.cost_amt)
else c.cost_amt end) as costAmt,           
c.cost_qty as costQty,        
c.cost_qty_uom_code as costQtyUomCode,        
c.cost_unit_price as costUnitPrice,        
c.cost_type_code as costTypeCode,        
c.cost_owner_code as costOwnerCode,        
c.cost_status as costStatus,        
c.cost_eff_date as costEffDate,        
        
ibd.inv_b_d_qty as invBDQty,         
ibd.inv_b_d_actual_qty as invBDActQty,        
ibd.inv_b_d_cost invBDCost,        
ibd.inv_b_d_cost_curr_code as invBDCostCurrCode,        
ibd.inv_b_d_type as invBDType,        
ibd.inv_b_d_status as invBDStatus,        
        
        
        
        
--------*******************************-----------------        
        
--********** "Received Qty Between AsOfDates" P/S Ind = P  combination of below two fields ******----------------        
---****** "Sale Qty" also handle here P/S Ind = S ****-----------------------------        
        
(case when ti2.billing_type = 'G' then aie.ai_est_actual_gross_qty        
else aie.ai_est_actual_net_qty end) as PrimaryActQtyBtnDates,        
        
(case when ti2.p_s_ind = 'P' and ti2.billing_type = 'G' then  aie.ai_est_actual_gross_qty        
   when ti2.p_s_ind = 'P'  then  aie.ai_est_actual_net_qty --and ti2.billing_type != 'G'        
   else 0 end) as  ReceivedActQtyBtnDates,        
        
(case when ti2.p_s_ind = 'S' and ti2.billing_type = 'G' then  aie.ai_est_actual_gross_qty        
   when ti2.p_s_ind = 'S' then  aie.ai_est_actual_net_qty --and ti2.billing_type != 'G'        
   else 0 end) as SaleActQtyBtnDates,        
        
(case when ti2.billing_type = 'G' then aie.ai_gross_qty_uom_code        
else aie.ai_net_qty_uom_code end) as PrimaryActQtyUomBtnDates,        
        
        
(case when ti2.billing_type = 'G' then aie.secondary_actual_gross_qty        
else aie.secondary_actual_net_qty end) as SecondaryActQtyBtnDates,        
        
aie.secondary_qty_uom_code as SecondaryActQtyUomBtnDates,        
--aie.ai_est_actual_net_qty as NetQtyBtnDates,        
--aie.ai_net_qty_uom_code as NetQtyUomBtnDates,        
--aie.ai_est_actual_gross_qty as GrossQtyBtnDates,        
--aie.ai_gross_qty_uom_code as GrossQtyUomBtnDates,        
        
-------*********--------------        
        
---****** Unit Price and their Uom,Curr ****-----------------------------        
(case when ti2.item_type in('S','T') and a.alloc_type_code != 'J' then inv.inv_avg_cost         
when (isnull(c.cost_unit_price,0) != 0 and c.cost_type_code in ('WPP', 'DPP', 'RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'NO' , 'BOAI' , 'CPP' , 'CPR'))  then  c.cost_unit_price   
--0th actual it may null        
      else inv.inv_avg_cost  end) as UnitPrice,        
        
(case when ti2.item_type in('S','T') and a.alloc_type_code != 'J' then inv.inv_cost_uom_code        
when (c.cost_price_uom_code is not null and c.cost_type_code  in ('WPP', 'DPP', 'RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'NO' , 'BOAI' , 'CPP' , 'CPR'))then  c.cost_price_uom_code 
   --0th actual it may null        
      else inv.inv_cost_uom_code  end) as UnitPriceUom,        
        
        
        
(case when ti2.item_type in('S','T') and a.alloc_type_code != 'J' then inv.inv_cost_curr_code        
      when (c.cost_price_curr_code is not null and c.cost_type_code  in ('WPP', 'DPP', 'RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'NO' , 'BOAI' , 'CPP' , 'CPR'))  then  c.cost_price_curr_code  
      --0th actual it may null        
      else inv.inv_cost_curr_code  end) as UnitPriceCurr,        
        
        
(case when ti2.item_type in('S','T') and a.alloc_type_code != 'J' then aie.ai_est_actual_date        
      when (c.cost_eff_date is not null and c.cost_type_code  in ('WPP', 'DPP', 'RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'NO' , 'BOAI' , 'CPP' , 'CPR')) then  c.cost_eff_date 
         --0th actual it may null        
      else aie.ai_est_actual_date  end) as costEffOrActualDate,             
        
--(case  when isnull(aie.ai_est_actual_date,0) !=0 then aie.ai_est_actual_date               
--       else c.cost_eff_date end) as asof_date,        
        
-----******************--------------------        
        
---------****** inv Open and closed  Qty(s) ***---------        
        
(select top 1 EndOfDayBalance from @invruns where invNum = ai.inv_num and CAST(bdDate as DATE) <= @iAsOfDate1  order by bdDate desc) as OpenInvQtyOnAsOfDate1,        
(select top 1 EndOfDayBalance from @invruns where invNum = ai.inv_num and CAST(bdDate as DATE) <= @iAsOfDate2 order by bdDate desc) as ClosedInvQtyOnAsOfDate1        ,
(select top 1 bdUom from @invruns where invNum = ai.inv_num) as OpenOrClosedInvQtyUom,

(select top 1 SecEndOfDayBalance from @invruns where invNum = ai.inv_num and CAST(bdDate as DATE) <= @iAsOfDate1  order by bdDate desc) as SecOpenInvQtyOnAsOfDate1,        
(select top 1 SecEndOfDayBalance from @invruns where invNum = ai.inv_num and CAST(bdDate as DATE) <= @iAsOfDate2 order by bdDate desc) as SecClosedInvQtyOnAsOfDate1,
(select top 1 SecBdUom from @invruns where invNum = ai.inv_num) as SecOpenOrClosedInvQtyUom        
           
        
-------------***************************---------------------------------------------------        
        
        
        
---,*         
from inventory inv         
LEFT OUTER JOIN trade_item ti on ti.trade_num = inv.trade_num  and ti.order_num = inv.order_num --Get storage TI related to INV        
LEFT OUTER JOIN portfolio port on port.port_num = inv.port_num
LEFT OUTER JOIN commodity cmdty on cmdty.cmdty_code = ti.cmdty_code
LEFT OUTER JOIN trade t1 on t1.trade_num = ti.trade_num
LEFT OUTER JOIN account acct on acct.acct_num = t1.acct_num
LEFT OUTER JOIN trade_item_storage storage on ti.trade_num = storage.trade_num  and ti.order_num = storage.order_num and ti.item_num = storage.item_num --TI(S) Related to inv        
LEFT OUTER JOIN trade_item_transport trans on ti.trade_num = trans.trade_num  and ti.order_num = trans.order_num and ti.item_num = trans.item_num --TI(S) Related to inv        
LEFT OUTER JOIN location loc on  (storage.storage_loc_code is not null and loc.loc_code = storage.storage_loc_code) or (trans.del_loc_code is not null and loc.loc_code = trans.del_loc_code)
LEFT OUTER JOIN allocation_item ai on ai.trade_num = ti.trade_num  and ai.order_num = ti.order_num and ai.item_num = ti.item_num -- AI(S) related to Inv storage item        
LEFT OUTER JOIN allocation_item ai2 on ai2.alloc_num = ai.alloc_num ----and  ai2.alloc_item_num != ai.alloc_item_num --AI(S) Related to inv excluding INV storage TI alloc        
LEFT OUTER JOIN trade_item ti2 on ti2.trade_num = ai2.trade_num  and ti2.order_num = ai2.order_num and ti2.item_num = ai2.item_num --TI(S) Related to inv        
--LEFT OUTER JOIN trade_item_wet_phy wet on ti2.trade_num = wet.trade_num  and ti2.order_num = wet.order_num and ti2.item_num = wet.item_num --TI(S) Related to inv        
--LEFT OUTER JOIN trade_item_dry_phy dry on ti2.trade_num = dry.trade_num  and ti2.order_num = dry.order_num and ti2.item_num = dry.item_num --TI(S) Related to inv        
--LEFT OUTER JOIN location loc on (wet.del_loc_code is not null and loc.loc_code = wet.del_loc_code) or (dry.del_loc_code is not null or loc.loc_code = dry.del_loc_code)
LEFT OUTER JOIN ai_est_actual aie on ai2.alloc_num = aie.alloc_num and  ai2.alloc_item_num = aie.alloc_item_num --Actual(s) Realted to inv and given dates        
LEFT OUTER JOIN allocation a on a.alloc_num = ai.alloc_num        
LEFT OUTER JOIN inventory_build_draw ibd on ibd.inv_num = inv.inv_num and ibd.trade_num = ai2.trade_num  and ibd.order_num = ai2.order_num and ibd.item_num = ai2.item_num  and         
ai2.alloc_num = ibd.alloc_num and  ai2.alloc_item_num = ibd.alloc_item_num        
INNER JOIN cost c on c.cost_status  not in ('CLOSED') and         
        
(c.cost_owner_code in ('TI') and c.cost_owner_key1 = ti2.trade_num and c.cost_owner_key2 = ti2.order_num and c.cost_owner_key3 = ti2.item_num and c.cost_type_code not in ('WPP', 'DPP', 'RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP'
  
    
      
 , 'SWAP' , 'SWPR' , 'BO' , 'NO' , 'BOAI' , 'CPP' , 'CPR')) --only TI secondary)        
        
where inv.inv_num in (select distinct inv_num from @invTable) and ai.alloc_num is not null 
--and CAST(aie.ai_est_actual_date as DATE) >=@iAsOfDate1 
and CAST(aie.ai_est_actual_date as DATE) <=@iAsOfDate2        
)--End of select        
        
        
        
---***********GET CURR CONV Factor and fill it in #currConvFinalTable *******------------        
        
create table #currConvFinalTable (asof_date date,eff_date date ,price_curr_code varchar(4),estFinalInd char(1),Rate float(53),divide_multiply_ind char(4))        
        
create table #currConvResultTable (Rate float(53),divide_multiply_ind char(4))        
        
create table #effPriceTable (ID1 int IDENTITY(1,1) PRIMARY KEY,costEffOrActualDate date,UnitPriceCurr char(4))        
        
IF @iToCurr is not null -- 'SKIPS While Loop        
BEGIN        
insert into #effPriceTable( costEffOrActualDate, UnitPriceCurr)         
(        
 select distinct costEffOrActualDate,  UnitPriceCurr from #invCostTbl        
)        
END         
        
DECLARE @z int = (select MAX(ID1) from #effPriceTable)        
  DECLARE @asofDate Date = null        
  DECLARE @effDate Date = null        
  DECLARE @frmCurrCode varchar(4) = null        
  DECLARE @rate float(53) = null        
  DECLARE @ind char(4) = null        
  DECLARE @toDayDate date = GETDATE()        
  DECLARE @estFinalInd char(1)= 'F';        
        WHILE @z > 0        
        BEGIN        
            select @effDate =  costEffOrActualDate,@frmCurrCode = UnitPriceCurr from #effPriceTable t where t.ID1 = @z        
                   
            ---*************** 1 Get currRate for todaye *******-----------------        
            --set @asofDate = @toDayDate --TodaysDate        
                    
            --IF @effDate > @asofDate BEGIN  SET @estFinalInd = 'E' END        
            --ELSE BEGIN SET @estFinalInd = 'F' END        
                    
            --IF NOT EXISTS (select 1 from #currConvFinalTable where asof_date = @asofDate and  eff_date = @effDate and price_curr_code = @frmCurrCode)        
            --BEGIN        
            --delete from #currConvResultTable          
            --insert into #currConvResultTable(Rate,divide_multiply_ind) exec usp_currency_exch_rate @asofDate, @frmCurrCode , @iToCurr,@effDate,@estFinalInd        
                    
                   
            --select top 1 @rate =  Rate,@ind = divide_multiply_ind from #currConvResultTable        
                
            -- INSERT into #currConvFinalTable(asof_date ,eff_date,price_curr_code,estFinalInd,Rate ,divide_multiply_ind ) values (@asofDate,@effDate,@frmCurrCode, @estFinalInd,@rate,@ind)        
            --END        
                   
           ---*************** 2 Get currRate for asOfDate1  *******-----------------        
             set @asofDate = @iAsOfDate1 --TodaysDate        
                    
            IF @effDate > @asofDate BEGIN  SET @estFinalInd = 'E' END        
            ELSE BEGIN SET @estFinalInd = 'F' END        
                    
            IF NOT EXISTS (select 1 from #currConvFinalTable where asof_date = @asofDate and  eff_date = @effDate and price_curr_code = @frmCurrCode)        
            BEGIN        
            delete from #currConvResultTable          
            insert into #currConvResultTable(Rate,divide_multiply_ind) exec usp_currency_exch_rate @asofDate, @frmCurrCode , @iToCurr,@effDate,@estFinalInd        
                    
                   
            select top 1 @rate =  Rate,@ind = divide_multiply_ind from #currConvResultTable        
                  
            INSERT into #currConvFinalTable(asof_date ,eff_date,price_curr_code,estFinalInd,Rate ,divide_multiply_ind ) values (@asofDate,@effDate,@frmCurrCode, @estFinalInd,@rate,@ind)        
            END        
                   
           ---*************** 3 Get currRate for asOfDate2  *******-----------------         
               set @asofDate = @iAsOfDate2 --TodaysDate        
                    
            IF @effDate > @asofDate BEGIN  SET @estFinalInd = 'E' END        
            ELSE BEGIN SET @estFinalInd = 'F' END        
                    
            IF NOT EXISTS (select 1 from #currConvFinalTable where CAST(asof_date as DATE) = @asofDate and  CAST(eff_date as DATE) = @effDate and price_curr_code = @frmCurrCode)        
            BEGIN        
            delete from #currConvResultTable          
            insert into #currConvResultTable(Rate,divide_multiply_ind) exec usp_currency_exch_rate @asofDate, @frmCurrCode , @iToCurr,@effDate,@estFinalInd        
                    
                   
         select top 1 @rate =  Rate,@ind = divide_multiply_ind from #currConvResultTable        
              
            INSERT into #currConvFinalTable(asof_date ,eff_date,price_curr_code,estFinalInd,Rate ,divide_multiply_ind ) values (@asofDate,@effDate,@frmCurrCode, @estFinalInd,@rate,@ind)        
            END                     
                     
            SET @z = @z - 1        
        END        
        
        
--select * from #currConvFinalTable        
        
---select * from #RealPortChildren        
        
        
---drop table #currConvTable        
        
--sp_help usp_currency_exch_rate        
        
        
--********* GET MARKET Values for asOFDates (1) && (2) ***********-------------        
create table #invHisMTMValueFinalTable (ID1 int IDENTITY(1,1) PRIMARY KEY,invNum int,posNum int,costEffOrActualDate date,asOfDate1MtmValue float,
asOfDate2MtmValue float,priceUomCodeForDate1 char(8) ,priceCurrCodeForDate1 char(8),
priceUomCodeForDate2 char(8) ,priceCurrCodeForDate2 char(8),Date1_estFinalInd char(1),Date1_Rate
     
 float(53),Date1_divide_multiply_ind char(4),Date2_estFinalInd char(1),Date2_Rate float(53),Date2_divide_multiply_ind char(4))        
        
----create table #invPosTable (ID1 int IDENTITY(1,1) PRIMARY KEY,invNum int,posNum int,costEffOrActualDate date)        
        
insert into #invHisMTMValueFinalTable( invNum, posNum,costEffOrActualDate,
priceCurrCodeForDate1,priceUomCodeForDate1,priceCurrCodeForDate2,
priceUomCodeForDate2)         
(        
 select distinct inventoryNum,  invPosNum,costEffOrActualDate,
 invCostCurrCode,invCostUomCode,invCostCurrCode,
 invCostUomCode from #invCostTbl        
) 
---select * from #invHisMTMValueFinalTable       
DECLARE @x int = (select MAX(ID1) from #invHisMTMValueFinalTable)        
  DECLARE @asofDate1MTMValue float = null        
  DECLARE @asofDate2MTMValue float = null        
  DECLARE @priceUomCodeForDate1 char(8) = null        
  DECLARE @priceCurrCodeForDate1 char(8) = null        
  DECLARE @priceUomCodeForDate2 char(8) = null        
  DECLARE @priceCurrCodeForDate2 char(8) = null        
  DECLARE @invNum int = null        
          
  --DECLARE @asofDate Date = null        
  --DECLARE @effDate Date = null        
  DECLARE @Date1_rate float(53) = null        
  DECLARE @Date2_rate float(53) = null        
  DECLARE @Date1_est_final_ind char(4) = null        
  DECLARE @Date2_est_final_ind char(4) = null        
  DECLARE @Date1_div_mul_ind char(4) = null        
  DECLARE @Date2_div_mul_ind char(4) = null        
  --DECLARE @toDayDate date = GETDATE()        
  --DECLARE @estFinalInd char(1)= 'F';        
          
  DECLARE @invPosNum int = null        
          
        WHILE @x > 0        
        BEGIN        
            select @invNum = invNum,@invPosNum =posNum, @effDate = costEffOrActualDate,@asofDate1MTMValue = asOfDate1MtmValue,
            @asofDate2MTMValue = asOfDate2MtmValue,
            @priceUomCodeForDate1 = priceUomCodeForDate1,
			@priceCurrCodeForDate1 = priceCurrCodeForDate1,
			@priceUomCodeForDate2 = priceUomCodeForDate2,
			@priceCurrCodeForDate2 = priceCurrCodeForDate2,
			@Date1_est_final_ind = Date1_estFinalInd,
            @Date2_est_final_ind = Date2_estFinalInd,
			@Date1_rate = Date1_Rate,
			@Date2_rate = Date2_Rate,
			@Date1_div_mul_ind = Date1_divide_multiply_ind ,
			@Date2_div_mul_ind = Date2_divide_multiply_ind  
			from #invHisMTMValueFinalTable ip where ip.ID1 = @x        
                    
   IF ISNULL(@asofDate1MTMValue,0) = 0 or ISNULL(@asofDate2MTMValue,0) = 0         
            BEGIN        
           
            select top 1 @asofDate1MTMValue = r_cost_amt from inventory_history ih where ih.inv_num = @invNum and CAST(ih.asof_date as DATE) = @iAsOfDate1 and cost_num = 0 and rcpt_alloc_num=0         
            select top 1 @asofDate2MTMValue = r_cost_amt from inventory_history ih where ih.inv_num = @invNum and CAST(ih.asof_date as DATE) = @iAsOfDate2 and cost_num = 0 and rcpt_alloc_num=0 

			                   
            IF ISNULL(@asofDate1MTMValue,0) = 0         
            BEGIN        
                      
              select top 1   
              @asofDate1MTMValue =   
              (case when ISNULL(@asofDate1MTMValue,0) = 0 then  p.avg_closed_price else @asofDate1MTMValue end),        
              @priceUomCodeForDate1 =(case when m.mkt_type = 'P' then  cmpa.commkt_price_uom_code  --physical        
         else  cmfa.commkt_price_uom_code end ), --future ,        
     @priceCurrCodeForDate1 = (case when m.mkt_type = 'P' then  cmpa.commkt_curr_code  --physical        
           else  cmfa.commkt_curr_code end ) --future        
    from position pos        
              inner join commodity_market ck on ck.commkt_key = pos.commkt_key        
              inner join market m on m.mkt_code = ck.mkt_code        
              Left outer join commkt_physical_attr cmpa on cmpa.commkt_key = pos.commkt_key        
              Left outer join commkt_future_attr cmfa on cmfa.commkt_key = pos.commkt_key        
              inner join price p on p.commkt_key = pos.commkt_key and p.trading_prd = pos.trading_prd and p.price_source_code = ck.mtm_price_source_code and CAST(p.price_quote_date as DATE)  <=@iAsOfDate1        
              where pos.pos_num = @invPosNum        
              order by price_quote_date desc        
                    
            END        
                    
            IF ISNULL(@asofDate2MTMValue,0) = 0        
            BEGIN        
                      
              select top 1   
              @asofDate2MTMValue =   
              (case when ISNULL(@asofDate2MTMValue,0) = 0 then  p.avg_closed_price else @asofDate2MTMValue end),        
              @priceUomCodeForDate2 =(case when m.mkt_type = 'P' then  cmpa.commkt_price_uom_code  --physical        
         else  cmfa.commkt_price_uom_code end ), --future ,        
     @priceCurrCodeForDate2 = (case when m.mkt_type = 'P' then  cmpa.commkt_curr_code  --physical        
           else  cmfa.commkt_curr_code end ) --future        
     from position pos        
              inner join commodity_market ck on ck.commkt_key = pos.commkt_key        
              inner join market m on m.mkt_code = ck.mkt_code        
              Left outer join commkt_physical_attr cmpa on cmpa.commkt_key = pos.commkt_key        
              Left outer join commkt_future_attr cmfa on cmfa.commkt_key = pos.commkt_key        
              inner join price p on p.commkt_key = pos.commkt_key and p.trading_prd = pos.trading_prd and p.price_source_code = ck.mtm_price_source_code and CAST(p.price_quote_date as DATE) <=@iAsOfDate2        
              where pos.pos_num = @invPosNum        
              order by price_quote_date desc        
                    
            END        
                   
        
--insert into #invHisMTMValueFinalTable(invNum,asOfDate1MtmValue,asOfDate2MtmValue,posPriceUomCode ,posPriceCurrCode) values (@invNum,@asofDate1MTMValue,@asofDate2MTMValue,@posPriceUomCode,@posPriceCurrCode)        
        
update #invHisMTMValueFinalTable set asOfDate1MtmValue =@asofDate1MTMValue ,asOfDate2MtmValue=@asofDate2MTMValue ,        
priceUomCodeForDate1 = @priceUomCodeForDate1,priceCurrCodeForDate1 =@priceCurrCodeForDate1,         
priceUomCodeForDate2 = @priceUomCodeForDate2,priceCurrCodeForDate2 =@priceCurrCodeForDate2 
        
where posNum = @invPosNum        
        
END        
        
IF @Date1_est_final_ind is null        
BEGIN        
 set @asofDate = @iAsOfDate1 --TodaysDate        
                    
            IF @effDate > @asofDate BEGIN  SET @estFinalInd = 'E' END        
            ELSE BEGIN SET @estFinalInd = 'F' END        
                    
            set @Date1_est_final_ind = @estFinalInd                 
            delete from #currConvResultTable          
            insert into #currConvResultTable(Rate,divide_multiply_ind) exec usp_currency_exch_rate @asofDate, @priceCurrCodeForDate1 , @iToCurr,@effDate,@estFinalInd        
                    
                   
            select top 1 @Date1_rate =  Rate,@Date1_div_mul_ind = divide_multiply_ind from #currConvResultTable           
                    
        
END        
        
IF @Date2_est_final_ind is null        
BEGIN        
 set @asofDate = @iAsOfDate2 --TodaysDate        
                    
            IF @effDate > @asofDate BEGIN  SET @estFinalInd = 'E' END        
            ELSE BEGIN SET @estFinalInd = 'F' END        
            set @Date2_est_final_ind = @estFinalInd        
                              
            delete from #currConvResultTable          
            insert into #currConvResultTable(Rate,divide_multiply_ind) exec usp_currency_exch_rate @asofDate, @priceCurrCodeForDate2 , @iToCurr,@effDate,@estFinalInd        
                    
                   
            select top 1 @Date2_rate =  Rate,@Date2_div_mul_ind = divide_multiply_ind from #currConvResultTable                     
END        
        
update #invHisMTMValueFinalTable set  Date1_estFinalInd = @Date1_est_final_ind,Date2_estFinalInd = @Date2_est_final_ind,Date1_Rate = @Date1_rate,Date2_Rate = @Date2_rate, Date1_divide_multiply_ind =@Date1_div_mul_ind  ,
Date2_divide_multiply_ind = @Date2_div_mul_ind where ID1 = @x        
        
SET @x = @x - 1        
        
END        
        
--select * from #invHisMTMValueFinalTable        
        
select invCostFinalTbl.*,        
        
UnitPriceCurr as fromCurr ,         
@iToCurr as ToCurr ,        
--(select distinct top 1 case         
--when isnull(cc.Rate,0) = 0 then 1        
--when cc.Rate = 0 then 0        
--when cc.divide_multiply_ind = 'M' then round(cc.Rate,6)         
--else round(1/cc.Rate ,6)        
--end         
--from #currConvFinalTable cc where cc.price_curr_code = invCostFinalTbl.UnitPriceCurr and cc.eff_date =invCostFinalTbl.costEffOrActualDate and cc.asof_date = @toDayDate) as ConvFactorForToday,        
        
        
(select distinct top 1 case when isnull(cc.Rate,0) = 0 then 1        
when cc.Rate = 0 then 0        
when cc.divide_multiply_ind = 'M' then round(cc.Rate,6)         
else round(1/cc.Rate ,6)        
end         
  from #currConvFinalTable cc where cc.price_curr_code = invCostFinalTbl.UnitPriceCurr and cc.eff_date =invCostFinalTbl.costEffOrActualDate and CAST(cc.asof_date as DATE) = @iAsOfDate1) as ConvFactorForAsOfDay1,        
          
(select distinct top 1 case when isnull(cc.Rate,0) = 0 then 1        
when cc.Rate = 0 then 0        
when cc.divide_multiply_ind = 'M' then round(cc.Rate,6)         
else round(1/cc.Rate ,6)        
end         
 from #currConvFinalTable cc where cc.price_curr_code = invCostFinalTbl.UnitPriceCurr and cc.eff_date =invCostFinalTbl.costEffOrActualDate and CAST(cc.asof_date as DATE) = @iAsOfDate2) as ConvFactorForAsOfDay2,        
        
        
--@iToUom as ToUOM ,        
@iAsOfDate1 as fromDateAsAsofDate1,        
@iAsOfDate2 as fromDateAsAsofDate2,        
(select top 1 asOfDate1MtmValue from #invHisMTMValueFinalTable ih where  ih.invNum = invCostFinalTbl.inventoryNum) as MarketValueForAsOfDate1,        
(select top 1 asOfDate2MtmValue from #invHisMTMValueFinalTable ih where  ih.invNum = invCostFinalTbl.inventoryNum)  as MarketValueForAsOfDate2,        
(select top 1 priceUomCodeForDate1 from #invHisMTMValueFinalTable ih where  ih.invNum = invCostFinalTbl.inventoryNum) as MarketValuePriceUomCodeForDate1,        
(select top 1 priceCurrCodeForDate1 from #invHisMTMValueFinalTable ih where  ih.invNum = invCostFinalTbl.inventoryNum) as MarketValueCurrCodeForDate1, 
(select top 1 priceUomCodeForDate2 from #invHisMTMValueFinalTable ih where  ih.invNum = invCostFinalTbl.inventoryNum) as MarketValuePriceUomCodeForDate2,        
(select top 1 priceCurrCodeForDate2 from #invHisMTMValueFinalTable ih where  ih.invNum = invCostFinalTbl.inventoryNum) as MarketValueCurrCodeForDate2,        
        
(select distinct top 1 case when isnull(ih.Date1_Rate,0) = 0 then 1        
when ih.Date1_Rate = 0 then 0        
when ih.Date1_divide_multiply_ind = 'M' then round(ih.Date1_Rate,6)         
else round(1/ih.Date1_Rate ,6)        
end from #invHisMTMValueFinalTable ih where  ih.invNum = invCostFinalTbl.inventoryNum and ih.costEffOrActualDate = invCostFinalTbl.costEffOrActualDate ) as MVConvRateForDate1,        
        
(select distinct top 1 case when isnull(ih.Date2_Rate,0) = 0 then 1        
when ih.Date2_Rate = 0 then 0        
when ih.Date2_divide_multiply_ind = 'M' then round(ih.Date2_Rate,6)         
else round(1/ih.Date2_Rate ,6)        
end from #invHisMTMValueFinalTable ih where  ih.invNum = invCostFinalTbl.inventoryNum and ih.costEffOrActualDate = invCostFinalTbl.costEffOrActualDate ) as MVConvRateForDate2        
        
         
from #invCostTbl invCostFinalTbl        
        
--select * from #currConvFinalTable        
drop table #currConvResultTable        
drop table #invCostTbl        
drop table #currConvFinalTable        
drop table #effPriceTable        
drop table #invHisMTMValueFinalTable        
        
drop table #RealPortChildren       
end   
GO
GRANT EXECUTE ON  [dbo].[usp_include_curr_conv_and_marketvalue] TO [next_usr]
GO
