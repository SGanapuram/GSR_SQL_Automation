SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_realized_pl_by_shipment] 
(
   @realPortNum         int,
   @shipmentId          int = null,
   @mot                 varchar(25) = null,
   @riskTransferDate1   datetime = null,
   @riskTransferDate2   datetime = null,
   @LCIssueDate1        datetime = null,
   @LCIssueDate2        datetime = null,
   @creditApprovedDate1 datetime = null,
   @creditApprovedDate2 datetime = null,
   @realizedOrOpen      varchar(10) = null
)   
AS        
BEGIN      
set nocount on
      
create table #resultTable(ID INT IDENTITY(1,1) NOT NULL,shipmentID int,parcelNum int,allocation varchar(25),costTypeCode varchar(25),portNum int,cmdty varchar(25),delLoc varchar(25),MOT varchar(25),parcelQuantity decimal(20,8),parcelQtyUOM varchar(25),isRiskTransfer varchar(10),
riskTransferDate datetime,isSalesPerfGuarantee varchar(10),isCreditApproved varchar(10),hasWorkableLC varchar(25),LCNum varchar(25), LCIssueDate varchar(25),LCExpirydate varchar(25),AttributionState varchar(25),realizationDate datetime,
PL decimal(20,8),TOI varchar(25),tradeType varchar(25),counterparty varchar(25),direction varchar(25),riskMkt varchar(25),riskPrd varchar(25),costNum int,costAmt decimal(20,8),currency varchar(25),costUom varchar(25),isFullyActualized char(1),actualGrossQty decimal(20,8),
actualQtyUom varchar(25),secActualGrossQty decimal(20,8),secActualQtyUom varchar(25),actualDate datetime,tagName varchar(25),CATranDate datetime,pclType char(1),secActualGrossQtySum decimal(20,8),actualNum int,ownerCode varchar(25),costUnitPrice decimal(20,8),assignPcnt float(53),Quantity decimal(20,8))      
      
declare @sql  varchar(max)      
declare @select1  varchar(max)      
declare @select2  varchar(max)      
declare @select3  varchar(max)      
declare @where  varchar(max)=' where 1=1'      
select @select1 = 'SELECT ship.oid
	,pcl.oid
	,convert(VARCHAR, aa.alloc_num) + ''/'' + convert(VARCHAR, aa.alloc_item_num) + ''/'' + convert(VARCHAR, aa.ai_est_actual_num)
	,cst.cost_type_code
	,CASE 
		WHEN pcl.type = ''D''
			THEN ti.real_port_num
		ELSE NULL
		END
	,CASE 
		WHEN pcl.type =''D''
			THEN pcl.cmdty_code
		ELSE NULL
		END
	,CASE 
		WHEN pcl.type =''D''
			THEN pcl.location_code
		ELSE NULL
		END
	,CASE 
		WHEN pcl.type =''D''
			THEN mt.mot_type_short_name +''/''+ ait.transportation
		ELSE NULL
		END
	,pcl.sch_qty
	,pcl.sch_qty_uom_code
	,NULL
	,ship.risk_transfer_date
	,NULL
	,et.target_key1
	,NULL
	,convert(VARCHAR, lc.lc_num)
	,convert(VARCHAR, lc.lc_issue_date)
	,convert(VARCHAR, lc.lc_exp_date)
	,NULL
	,NULL
	,NULL
	,convert(VARCHAR, ti.trade_num) +''/''+ convert(VARCHAR, ti.order_num) +''/''+ convert(VARCHAR, ti.item_num)
	,tor.order_type_code
	,cst.acct_num
	,CASE 
		WHEN ti.p_s_ind =''P''
			THEN''PURCHASE''
		ELSE''SALE''
		END
	,ti.risk_mkt_code
	,(
		SELECT trading_prd_desc
		FROM trading_period
		WHERE trading_prd = ti.trading_prd
			AND commkt_key = tid.commkt_key
		)
	,cst.cost_num
	,CASE 
		WHEN cst.cost_pay_rec_ind =''P''
			THEN (- 1 * cst.cost_amt)
		ELSE cst.cost_amt
		END
	,cst.cost_price_curr_code
	,cst.cost_price_uom_code
	,ai.fully_actualized
	,aa.ai_est_actual_gross_qty
	,aa.ai_gross_qty_uom_code
	,aa.secondary_actual_gross_qty
	,aa.secondary_qty_uom_code
	,aa.ai_est_actual_date
	,etd.entity_tag_name
	,it.tran_date
	,pcl.type
	,NULL
	,aa.ai_est_actual_num
	,cst.cost_owner_code
	,cst.cost_unit_price
	,NULL
	,aa.secondary_actual_gross_qty
FROM ai_est_actual aa
INNER JOIN cost cst ON cst.cost_owner_key1 = aa.alloc_num
	AND cst.cost_owner_key2 = aa.alloc_item_num
	AND cst.cost_owner_key3 = aa.ai_est_actual_num
	AND cst.cost_owner_code IN (''AA'')
	AND (
		cst.cost_type_code IN (''DPP'')
		OR cst.cost_type_code NOT IN (
			''WPP''
			,''RINPP''
			,''BPP''
			,''RPP''
			,''OPP''
			,''OTC''
			,''PDO''
			,''P OC''
			,''TPP''
			,''SPP''
			,''SWAP''
			,''SWPR''
			,''BO''
			,''NO''
			,''BOAI''
			,''CPP''
			,''CPR''
			)
		)
	AND cst.cost_status NOT IN (
		''CLOSED''
		,''HELD''
		)
INNER JOIN allocation_item ai ON ai.alloc_num = aa.alloc_num
	AND ai.alloc_item_num = aa.alloc_item_num
INNER JOIN parcel pcl ON pcl.alloc_num = aa.alloc_num
	AND pcl.alloc_item_num = aa.alloc_item_num
INNER JOIN shipment ship ON ship.oid = pcl.shipment_num
INNER JOIN trade_item ti ON ti.trade_num = pcl.trade_num
	AND ti.order_num = pcl.order_num
	AND ti.item_num = pcl.item_num
INNER JOIN trade_order tor ON tor.trade_num = ti.trade_num
	AND tor.order_num = ti.order_num
INNER JOIN trade t ON t.trade_num = tor.trade_num
	AND t.trade_status_code <>''

DELETE''
LEFT OUTER JOIN trade_item_dist tid ON tid.trade_num = ti.trade_num
	AND tid.order_num = ti.order_num
	AND tid.item_num = ti.item_num
	AND tid.dist_type =''D''
LEFT OUTER JOIN allocation_item_transport ait ON ait.alloc_num = pcl.alloc_num
	AND ait.alloc_item_num = pcl.alloc_item_num
LEFT OUTER JOIN assign_trade at ON at.trade_num = ti.trade_num
	AND at.order_num = ti.order_num
	AND at.item_num = ti.item_num
LEFT OUTER JOIN lc ON lc.lc_num = at.ct_doc_num
LEFT OUTER JOIN entity_tag et ON et.key1 = convert(VARCHAR, ai.alloc_num)
	AND et.key2 = convert(VARCHAR, ai.alloc_item_num)
INNER JOIN entity_tag_definition etd ON etd.oid = et.entity_tag_id
	AND etd.entity_id = (
		SELECT oid
		FROM icts_entity_name
		WHERE entity_name =''AllocationItem''
		)
	AND etd.entity_tag_name =''OkToLoad''
INNER JOIN icts_transaction it ON it.trans_id = et.trans_id
INNER JOIN commodity cmdty ON cmdty.cmdty_code = pcl.cmdty_code
INNER JOIN mot_type mt ON mt.mot_type_code = ship.mot_type_code'
  
      
select @select2 ='select ship.oid,
					  pcl.oid,
					  convert(varchar,aa.alloc_num)+''/''+convert(varchar,aa.alloc_item_num)+''/''+ convert(varchar,aa.ai_est_actual_num),
					  cst.cost_type_code,
					  case when pcl.type=''D'' then ti.real_port_num else null end,
					  case when pcl.type=''D'' then pcl.cmdty_code else null end,
					  case when pcl.type=''D'' then pcl.location_code else null end ,
					  case when pcl.type=''D'' then mt.mot_type_short_name+''/''+ait.transportation else null end,
					  pcl.sch_qty,
					  pcl.sch_qty_uom_code,
					  null,
					  ship.risk_transfer_date,
					  null,
					  et.target_key1,
					  null,
					  convert(varchar,lc.lc_num),
					  convert(varchar,lc.lc_issue_date),
					  convert(varchar,lc.lc_exp_date),
					  null,
					  null,
					  null,
					  convert(varchar,ti.trade_num)+''/''+convert(varchar,ti.order_num)+''/''+ convert(varchar,ti.item_num),
					  tor.order_type_code,
					  cst.acct_num,
					  case when ti.p_s_ind=''P'' then ''PURCHASE'' else ''SALE'' end,
					  ti.risk_mkt_code,
					  (select trading_prd_desc from trading_period where trading_prd=ti.trading_prd and commkt_key=tid.commkt_key),
					  cst.cost_num,
					  case when cst.cost_pay_rec_ind =''P'' then (-1*cst.cost_amt) else cst.cost_amt end,    
					  cst.cost_price_curr_code,
					  cst.cost_price_uom_code,
					  ai.fully_actualized,
					  aa.ai_est_actual_gross_qty,
					  aa.ai_gross_qty_uom_code,
					  aa.secondary_actual_gross_qty,
					  aa.secondary_qty_uom_code,
					  aa.ai_est_actual_date,
					  etd.entity_tag_name,
					  it.tran_date,
					  pcl.type,null,aa.ai_est_actual_num,
					  cst.cost_owner_code,
					  cst.cost_unit_price,
					  null,
					  aa.secondary_actual_gross_qty      
			from allocation_item ai       
			inner join  cost cst 
				on cst.cost_owner_key1=ai.alloc_num and cst.cost_owner_key2=ai.alloc_item_num and cst.cost_owner_code in(''AI'') and (cst.cost_type_code in(''DPP'') or cst.cost_type_code not in(''WPP'',''RINPP'', ''BPP'' , ''RPP'' , ''OPP'' , ''OTC'', ''PDO'' , ''POC'' , ''TPP'' , ''SPP'' , ''SWAP'' , ''SWPR'' , ''BO'' , ''NO'' , ''BOAI'' , ''CPP'' , ''CPR'')) and cst.cost_status not in(''CLOSED'',''HELD'')      
			inner join parcel pcl 
				on pcl.alloc_num= ai.alloc_num and pcl.alloc_item_num=ai.alloc_item_num       
			inner join shipment ship 
				on ship.oid=pcl.shipment_num       
			inner join trade_item ti 
				on ti.trade_num=pcl.trade_num and ti.order_num=pcl.order_num and ti.item_num=pcl.item_num      
			inner join trade_order tor 
				on tor.trade_num= ti.trade_num and tor.order_num=ti.order_num       
			inner join trade t 
				on t.trade_num=tor.trade_num and t.trade_status_code <>''DELETE''      
			left outer join trade_item_dist tid 
				on tid.trade_num=ti.trade_num and tid.order_num=ti.order_num and tid.item_num=ti.item_num and tid.dist_type=''D''      
			left outer join ai_est_actual aa 
				on cst.cost_owner_key1=aa.alloc_num and cst.cost_owner_key2=aa.alloc_item_num and cst.cost_owner_key3=aa.ai_est_actual_num      
			left outer join allocation_item_transport ait 
				on ait.alloc_num= pcl.alloc_num and ait.alloc_item_num= pcl.alloc_item_num      
			left outer join assign_trade at 
				on at.trade_num=ti.trade_num and at.order_num=ti.order_num and at.item_num=ti.item_num       
			left outer join lc 
				on lc.lc_num= at.ct_doc_num       
			left outer join entity_tag et 
				on et.key1=convert(varchar,ai.alloc_num) and et.key2=convert(varchar,ai.alloc_item_num) inner join entity_tag_definition etd on etd.oid=et.entity_tag_id and etd.entity_id =(select oid from icts_entity_name where entity_name=''AllocationItem'') and etd.entity_tag_name=''OkToLoad'' inner join icts_transaction it on it.trans_id=et.trans_id      
			join commodity cmdty 
				on cmdty.cmdty_code=pcl.cmdty_code      
			inner join mot_type mt 
				on mt.mot_type_code=ship.mot_type_code'      
      
      
select @select3 = 'SELECT DISTINCT ship.oid
	,ship.PrclOid
	,convert(VARCHAR, ship.alloc_num) + ''/'' + convert(VARCHAR, ship.alloc_item_num) + ''/'' + convert(VARCHAR, ship.ai_est_actual_num)
	,NULL
	,CASE 
		WHEN ship.type = ''D''
			THEN ti.real_port_num
		ELSE NULL
		END
	,CASE 
		WHEN ship.type =''D''
			THEN ship.cmdty_code
		ELSE NULL
		END
	,CASE 
		WHEN ship.type =''D''
			THEN ship.location_code
		ELSE NULL
		END
	,CASE 
		WHEN ship.type =''D''
			THEN mt.mot_type_short_name +''/''+ ship.transportation
		ELSE NULL
		END
	,ship.sch_qty
	,ship.sch_qty_uom_code
	,NULL
	,ship.risk_transfer_date
	,NULL
	,et.target_key1
	,NULL
	,convert(VARCHAR, lc.lc_num)
	,convert(VARCHAR, lc.lc_issue_date)
	,convert(VARCHAR, lc.lc_exp_date)
	,NULL
	,NULL
	,NULL
	,convert(VARCHAR, ti.trade_num) +''/''+ convert(VARCHAR, ti.order_num) +''/''+ convert(VARCHAR, ti.item_num)
	,tor.order_type_code
	,t.acct_num
	,CASE 
		WHEN ti.p_s_ind =''P''
			THEN''PURCHASE''
		ELSE''SALE''
		END
	,ti.risk_mkt_code
	,(
		SELECT trading_prd_desc
		FROM trading_period
		WHERE trading_prd = ti.trading_prd
			AND commkt_key = tid.commkt_key
		)
	,NULL
	,CASE 
		WHEN ti.p_s_ind =''P''
			THEN - 1 * ((ti.contr_qty * (ta.assign_pcnt / 100)) * ti.avg_price * cfa.commkt_lot_size)
		ELSE ((ti.contr_qty * (ta.assign_pcnt / 100)) * ti.avg_price * cfa.commkt_lot_size)
		END
	,ti.price_curr_code
	,ti.price_uom_code
	,ship.fully_actualized
	,ship.ai_est_actual_gross_qty
	,ship.ai_gross_qty_uom_code
	,0
	,ship.secondary_qty_uom_code
	,ship.ai_est_actual_date
	,etd.entity_tag_name
	,it.tran_date
	,ship.type
	,NULL
	,ship.ai_est_actual_num
	,NULL
	,ti.avg_price
	,ta.assign_pcnt
	,ti.contr_qty * cfa.commkt_lot_size
FROM tripartite_assignment ta
INNER JOIN (
	SELECT ship1.oid
		,pcl.oid AS PrclOid
		,aa.ai_est_actual_num
		,ai.alloc_num
		,ai.alloc_item_num
		,pcl.cmdty_code
		,ship1.mot_type_code
		,pcl.type
		,pcl.location_code
		,pcl.sch_qty
		,ait.transportation
		,pcl.sch_qty_uom_code
		,ship1.risk_transfer_date
		,ai.fully_actualized
		,aa.ai_est_actual_gross_qty
		,aa.ai_gross_qty_uom_code
		,aa.secondary_actual_gross_qty
		,aa.secondary_qty_uom_code
		,aa.ai_est_actual_date
	FROM shipment ship1
	INNER JOIN parcel pcl ON pcl.shipment_num = ship1.oid
	INNER JOIN allocation_item ai ON ai.alloc_num = pcl.alloc_num
		AND ai.alloc_item_num = pcl.alloc_item_num
	LEFT OUTER JOIN allocation_item_transport ait ON ait.alloc_num = pcl.alloc_num
		AND ait.alloc_item_num = pcl.alloc_item_num
	INNER JOIN ai_est_actual aa ON aa.alloc_num = ai.alloc_num
		AND aa.alloc_item_num = ai.alloc_item_num
	) ship ON ta.shipment_num = ship.oid
	AND ta.parcel_num = ship.PrclOid
	AND ta.actual_num = ship.ai_est_actual_num
LEFT OUTER JOIN entity_tag et ON et.key1 = convert(VARCHAR, ship.alloc_num)
	AND et.key2 = convert(VARCHAR, ship.alloc_item_num)
INNER JOIN entity_tag_definition etd ON etd.oid = et.entity_tag_id
	AND etd.entity_id = (
		SELECT oid
		FROM icts_entity_name
		WHERE entity_name =''AllocationItem''
		)
	AND etd.entity_tag_name =''OkToLoad''
INNER JOIN icts_transaction it ON it.trans_id = et.trans_id
INNER JOIN trade_item ti ON ta.trade_num = ti.trade_num
	AND ta.order_num = ti.order_num
	AND ta.item_num = ti.item_num
INNER JOIN trade_order tor ON tor.trade_num = ti.trade_num
	AND tor.order_num = ti.order_num
INNER JOIN trade t ON t.trade_num = tor.trade_num
	AND t.trade_status_code <>''

DELETE''
LEFT OUTER JOIN trade_item_dist tid ON tid.trade_num = ti.trade_num
	AND tid.order_num = ti.order_num
	AND tid.item_num = ti.item_num
	AND tid.dist_type =''D''
LEFT OUTER JOIN assign_trade at ON at.trade_num = ti.trade_num
	AND at.order_num = ti.order_num
	AND at.item_num = ti.item_num
LEFT OUTER JOIN lc ON lc.lc_num = at.ct_doc_num
JOIN commodity cmdty ON cmdty.cmdty_code = ship.cmdty_code
INNER JOIN mot_type mt ON mt.mot_type_code = ship.mot_type_code
LEFT OUTER JOIN commkt_future_attr cfa ON cfa.commkt_key = tid.commkt_key'     
      
      
if @realPortNum is not null      
 set @where = @where + ' and ti.real_port_num='+ cast(@realPortNum as varchar)      
if @shipmentId is not null      
 set @where = @where + ' and ship.oid='+ cast(@shipmentId as varchar)      
if @mot is not null      
 set @where = @where + ' and mt.mot_type_short_name='''+  @mot  +''''    
if @riskTransferDate1 is not null and @riskTransferDate2 is not null      
  set @where = @where + ' and convert(varchar,ship.risk_transfer_date,23)>='''+  convert(varchar,@riskTransferDate1,23)+''' and convert(varchar,ship.risk_transfer_date,23)<='''+   convert(varchar,@riskTransferDate2,23)+''''      
else if @riskTransferDate1 is not null      
  set @where = @where + ' and convert(varchar,ship.risk_transfer_date,23)='''+  convert(varchar,@riskTransferDate1,23)+''''      
        
if @LCIssueDate1 is not null and @LCIssueDate2 is not null      
  set @where = @where + ' and convert(varchar,lc.lc_issue_date,23)>='''+  convert(varchar,@LCIssueDate1,23)+''' and convert(varchar,lc.lc_issue_date,23)<='''+      
  convert(varchar,@LCIssueDate2,23)+''''      
else if @LCIssueDate1 is not null      
  set @where = @where + ' and convert(varchar,lc.lc_issue_date,23)='''+  convert(varchar,@LCIssueDate1,23)+''''      
        
if @creditApprovedDate1 is not null and @creditApprovedDate2 is not null      
  set @where = @where + ' and convert(varchar,it.tran_date,23)>='''+  convert(varchar,@creditApprovedDate1,23)+''' and convert(varchar,it.tran_date,23)<='''+      
  convert(varchar,@creditApprovedDate2,121)+''''      
else if @creditApprovedDate1 is not null      
  set @where = @where + ' and convert(varchar,it.tran_date,23)='''+  convert(varchar,@creditApprovedDate1,23)+''''      
      
       
set @select1 = @select1 + @where      
set @select2 = @select2 + @where      
set @select3 = @select3 + @where      
set @sql = @select1 + ' union ' + @select2+ ' union ' + @select3      
print @sql      
insert into #resultTable exec(@sql)      
    
    
update res set res.counterparty= res1.riskMkt      
from #resultTable res inner join #resultTable res1 on res.ID=res1.ID where res.tradeType='FUTURE' and res.counterparty is null      
      
declare @rowId int,@totalRecords int,@riskTranDate datetime,@isfullyActualized int=1,@lcNum varchar(25),@lcIssueDate varchar(25),@lcExpDate varchar(25),      
@isRiskTransfer varchar(5),@isSalesPerfGuarantee varchar(5),@actualDate datetime,@CreditApproved varchar(5),@CATranDate datetime,@parcelType char(1),      
@portNum int,@portCurrency varchar(25),@currency varchar(25),@shipNum int,@costAmt decimal=0.0,@PL decimal=0.0,      
@isSalesPerf int,      
@isMultiCmdty int,      
@isMultiLoc int,      
@isMultiMot int,      
@isMultiLCNum int,      
@isMultiLCIssueDate int,      
@isMultiLCExpDate int,@tempShipNum int=0,@cmdtyCode varchar(25),@acctNum varchar(25),@ownerCode varchar(25),@actualCount int      
      
Select @totalRecords = Count(*) From #resultTable         
set @rowId = 1   --get total number of records      
create table #maxDate(realizationDate datetime)      
      
      
WHILE @rowId <= @totalRecords      
BEGIN      
select @shipNum = shipmentID,@costAmt = costAmt,@PL=PL,@lcNum= LCNum,@lcIssueDate= LCIssueDate, @lcExpDate=LCExpirydate,@CATranDate = CATranDate,@CreditApproved= isCreditApproved,@parcelType=pclType,@portNum=portNum,@currency=currency,@ownerCode=ownerCode
  
    
from #resultTable where ID=@rowId      
      
      
if(@tempShipNum <> @shipNum)      
Begin      
 select @isSalesPerf =  1 from #resultTable where shipmentID=@shipNum and ((LCNum is not null and LCIssueDate < getdate() and LCExpirydate >getdate()) or isCreditApproved='Y' and pclType='D')      
      
 select @isMultiCmdty=1 from #resultTable res inner join #resultTable res1 on res.shipmentID=res1.shipmentID where res.cmdty <> res1.cmdty and res .pclType='D' group by res.shipmentID      
        
 select @isMultiLoc=1 from #resultTable res inner join #resultTable res1 on res.shipmentID=res1.shipmentID where res.delLoc <> res1.delLoc and res .pclType='D' group by res.shipmentID      
      
 select @isMultiMot=1 from #resultTable res inner join #resultTable res1 on res.shipmentID=res1.shipmentID where res.MOT <> res1.MOT and res.  pclType='D' group by res.shipmentID      
      
 select @isMultiLCNum=1 from #resultTable res inner join #resultTable res1 on res.shipmentID=res1.shipmentID where res.LCNum <> res1.LCNum and res .pclType='D' group by res.shipmentID      
      
 select @isMultiLCIssueDate=1 from #resultTable res inner join #resultTable res1 on res.shipmentID=res1.shipmentID where res.LCIssueDate <> res1. LCIssueDate and res.pclType='D' group by res.shipmentID      
      
 select @isMultiLCExpDate=1 from #resultTable res inner join #resultTable res1 on res.shipmentID=res1.shipmentID where res.LCExpirydate <> res1.  LCExpirydate and res.pclType='D' group by res.shipmentID      
       
 select @riskTranDate = riskTransferDate from #resultTable where shipmentID = @shipNum      
 select @actualDate = max(actualDate) from #resultTable where shipmentID= @shipNum and isFullyActualized='Y'      
 select @isfullyActualized = 0 from #resultTable where shipmentID= @shipNum and pclType ='D' and isFullyActualized<>'Y' group by shipmentID      
--select sum(secActualGrossQty) from #resultTable where shipmentID=@shipNum and pclType='D' and actualNum <>0       
select @actualCount = count(*) from #resultTable where shipmentID=@shipNum  and actualNum <>0    
if(@actualCount =0)    
 update #resultTable set secActualGrossQtySum= (select sum(secActualGrossQty) from #resultTable where shipmentID=@shipNum and pclType='D' and actualNum = 0 and costTypeCode='DPP')where shipmentID=@shipNum      
else    
 update #resultTable set secActualGrossQtySum= (select sum(secActualGrossQty) from #resultTable where shipmentID=@shipNum and pclType='D' and actualNum <>0 and costTypeCode='DPP')where shipmentID=@shipNum       
    
update #resultTable set isCreditApproved= case when isCreditApproved='Y' then 'TRUE' else 'FALSE' end where shipmentID=@shipNum       
       
end      
set @tempShipNum = @shipNum      
 insert into #maxDate select @riskTranDate      
 insert into #maxDate select @CATranDate      
 insert into #maxDate select @lcIssueDate      
if(@ownerCode='AI')      
    update #resultTable set secActualQtyUom= (select secActualQtyUom from #resultTable where shipmentID=@shipNum and pclType='D' and actualNum <>0)where ID=@rowId      
if(@isMultiCmdty =1)      
   update #resultTable set cmdty= 'MULTIPLTE' where ID=@rowId      
   else      
   update #resultTable set cmdty= (select distinct cmdty from #resultTable where shipmentID=@shipNum and pclType='D' and cmdty is not null)where shipmentID=@shipNum and cmdty is null      
if(@isMultiLoc =1)      
   update #resultTable set delLoc= 'MULTIPLTE' where ID=@rowId      
   else      
     update #resultTable set delLoc= (select distinct delLoc from #resultTable where shipmentID=@shipNum and pclType='D' and delLoc is not null)where shipmentID=@shipNum and delLoc is null      
 if(@isMultiMot =1)      
   update #resultTable set MOT= 'MULTIPLTE' where ID=@rowId      
   else      
   update #resultTable set MOT= (select distinct MOT from #resultTable where shipmentID=@shipNum and pclType='D' and MOT is not null)where shipmentID=@shipNum and MOT is null      
 if(@isMultiLCNum =1)      
   update #resultTable set LCNum= 'MULTIPLTE' where ID=@rowId      
   else      
   update #resultTable set LCNum= (select distinct LCNum from #resultTable where shipmentID=@shipNum and pclType='D' and LCNum is not null)where shipmentID=@shipNum and LCNum is null      
 if(@isMultiLCIssueDate =1)      
   update #resultTable set LCIssueDate= 'MULTIPLTE' where ID=@rowId      
   else      
   update #resultTable set LCIssueDate=  (select distinct LCIssueDate from #resultTable where shipmentID=@shipNum and pclType='D' and LCIssueDate is not null)where shipmentID=@shipNum and LCIssueDate is null     
 if(@isMultiLCExpDate =1)      
   update #resultTable set LCExpirydate= 'MULTIPLTE' where ID=@rowId      
   else      
   update #resultTable set LCExpirydate= (select distinct LCExpirydate from #resultTable where shipmentID=@shipNum and pclType='D' and LCExpirydate is not null)where shipmentID=@shipNum and LCExpirydate is null      
         
   select @acctNum=counterparty from #resultTable where ID=@rowId     
     
 update #resultTable set counterparty= (select acct_short_name from account where acct_num = convert(int,@acctNum) ) where ID=@rowId and counterparty is not null and tradeType <> 'FUTURE'      
       
    if(@riskTranDate is not null and @riskTranDate < getdate())      
  update #resultTable set isRiskTransfer= 'TRUE' where ID=@rowId      
 else if(@riskTranDate is null and @isfullyActualized = 1)      
  update #resultTable set isRiskTransfer= 'TRUE',riskTransferDate=@actualDate where ID=@rowId      
 else      
  update #resultTable set isRiskTransfer= 'FALSE' where ID=@rowId      
    --if((@lcNum is not null and convert(datetime,@lcIssueDate) < getdate() and convert(datetime,@lcExpDate) > getdate()) or (@CreditApproved = 'Y' and @parcelType ='D'))      
    if(@isSalesPerf =1)      
  update #resultTable set isSalesPerfGuarantee= 'TRUE' where ID=@rowId      
 else      
  update #resultTable set isSalesPerfGuarantee= 'FALSE' where ID=@rowId  
      
  select @lcNum = LCNum from #resultTable where ID=@rowId 

 if(@lcNum is not null)      
  update #resultTable set hasWorkableLC= 'TRUE' where ID=@rowId      
 else      
  update #resultTable set hasWorkableLC= 'FALSE' where ID=@rowId       
        
    select @isRiskTransfer = isRiskTransfer,@isSalesPerfGuarantee=isSalesPerfGuarantee from #resultTable where ID=@rowId      
          
    if(@isRiskTransfer='TRUE' and @isSalesPerfGuarantee='TRUE')      
  update #resultTable set AttributionState= 'REALIZED' where ID=@rowId      
 else      
  update #resultTable set AttributionState= 'OPEN' where ID=@rowId      
 update #resultTable set realizationDate= (select max(realizationDate) from #maxDate)  where ID=@rowId      
 select @portCurrency= desired_pl_curr_code from portfolio where port_num=@portNum      
 if(@portCurrency <> @currency)      
  begin      
   create table #currConvResultTable (Rate float(53),divide_multiply_ind char(4))      
   declare @today datetime= getdate()      
   declare @convRate float,@calcOper char(5)      
   insert into #currConvResultTable(Rate,divide_multiply_ind) exec usp_currency_exch_rate @asof_date= @today ,@curr_code_from=@currency,@curr_code_to=@portCurrency      
  select top 1 @convRate = Rate, @calcOper = divide_multiply_ind from #currConvResultTable      
     if(@calcOper ='M')      
    update #resultTable set PL= costAmt * @convRate where ID=@rowId      
     else      
    update #resultTable set PL= costAmt / @convRate where ID=@rowId      
   print 'shipNum:'+ convert(varchar,@shipNum) +'costAmt:'+ convert(varchar,@costAmt)      
   --update #resultTable set PL= @PL + @costAmt where shipmentID=@shipNum and ID=@rowId      
  end      
  else      
   update #resultTable set PL= costAmt where ID=@rowId      
  print 'shipNum:'+ convert(varchar,@PL)      
 set @rowId = @rowId+1      
END      
set @where = ' where 1=1'    
if(@realizedOrOpen is not null)    
BEGIN    
 set @where = @where + ' and lower(AttributionState) = ''' + lower(@realizedOrOpen) +''''    
END    
select @select1 ='SELECT shipmentID AS [Shipment ID]
	,cmdty AS [Sales  Commodity]
	,delLoc AS [Delivery Location]
	,MOT
	,secActualGrossQtySum AS Quantity
	,secActualQtyUom AS UOM
	,isRiskTransfer AS [Is Risk Transfer]
	,riskTransferDate AS [Risk Transfer Date]
	,isSalesPerfGuarantee AS [Is Sales Performance Guarantee]
	,isCreditApproved AS [Is Credit Approved]
	,hasWorkableLC AS [Has Workable LC]
	,LCNum AS [LC Number]
	,(
		CASE 
			WHEN LCIssueDate IS NULL
				THEN LCIssueDate
			ELSE convert(VARCHAR, LCIssueDate, 107)
			END
		) AS [LC Issue Date]
	,(
		CASE 
			WHEN LCExpirydate IS NULL
				THEN LCExpirydate
			ELSE convert(VARCHAR, LCExpirydate, 107)
			END
		) AS [LC Expiry Date]
	,AttributionState AS [Attribution State]
	,convert(VARCHAR, realizationDate, 107) AS [Realization Date]
	,PL
	,TOI
	,tradeType AS [Trade Type]
	,counterparty AS [Counterparty]
	,direction AS Direction
	,riskMkt AS [Risk Market]
	,riskPrd AS [Risk Period]
	,costTypeCode AS [Cost Type]
	,costAmt AS Cost
	,Quantity AS [Cost Quantity]
	,costUnitPrice AS [Cost Price]
	,currency AS [Price Currency]
	,costUom AS [Price UOM]
	,assignPcnt AS [Assign Percent]
FROM #resultTable'     
 set @sql = @select1 + @where    
 exec(@sql)    
END
GO
GRANT EXECUTE ON  [dbo].[usp_realized_pl_by_shipment] TO [next_usr]
GO
