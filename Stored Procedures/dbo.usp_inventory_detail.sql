SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_inventory_detail]  
(  
   @PortNum            int = null,    
   @IncludeRolledInv   char(1) = 'N',    
   @IncludeZeroBalance char(1) = 'N',    
   @AsofDate           datetime = NULL,    
   @ShowMSDSDetail     char(1) = 'N'    
)  
AS     
BEGIN    
    
 SELECT @AsofDate=max(pl_asof_date) from v_BI_cob_date    
     
 SELECT @IncludeRolledInv='%',@IncludeZeroBalance='%' where @IncludeRolledInv='Y'    
 SELECT @IncludeRolledInv='O',@IncludeZeroBalance='%' where @IncludeRolledInv ='N'    
     
    
     
 CREATE TABLE #children(port_num int, port_type char(2))    
 exec dbo.usp_get_child_port_nums @PortNum, 1      
    
    
 CREATE TABLE #inv_det    
 (    
 CreationDate datetime null ,    
 TYPE varchar(30) null,    
 INVStatus varchar(30) null,    
 ZeroInventory char(1) null,    
 inv_num  int null,    
 InvKey varchar(100) null,    
 BuildFrom varchar(100) null,    
 Commodity varchar(100) null,    
 Location varchar(100) null,    
 Tank varchar(20) null,    
 RiskMarket varchar(100) null,    
 RiskPrd varchar(20) null,    
 RiskPrdQtr varchar(2) null,    
 RiskPrdYear varchar(4) null,    
 RiskPrdDate datetime null,    
 FinancingBank varchar(100) null,    
 BDQty float null,    
 AvgCost float null,    
 BDUom varchar(10) null,    
 GoodsCostQty  float null,    
 BuildKey varchar(10) null,    
 AllocNum varchar(10) null,    
 GoodsCost float null,    
 ServiceAmt float null,    
 ServiceCurr varchar(10) null,    
 TotalBDCost float null,    
 GoodsStatus varchar(10) null,    
 Counterpart varchar(100) null,    
 MOT varchar(100) null,    
 GoodsPRInd char(1) null,    
 GoodsCurr varchar(10) null,    
 Portfolio int null,    
 UndCmdty varchar(100) null,     
 UndMkt varchar(100) null,    
 UndSource varchar(100) null,    
 UndTradingPrd varchar(100) null,    
 MTMQuoteDiff float null,    
 inv_b_d_num int null,    
 InvAllocNum int null,    
 InvAllocItemNum int null,    
 BuildDrawAllocNum int null,    
 BuildDrawAllocItemNum int null,    
 CasNumPhysicalSide nvarchar(1000) null,    
 ReachImportedFlag nvarchar(100) NULL,    
 CasNumPhysicalSideOther varchar(5) null,    
 CasNumStorageSide nvarchar(1000) null,    
 )    
    
insert into #inv_det    
 ---BUILDS    
 select     
 distinct     
 convert (char,a.creation_date,106) as CreationDate,    
 case when ibd.inv_b_d_type = 'B' then 'BUILD' when ibd.inv_b_d_type = 'D' then 'DRAW' end as TYPE,    
 case when i.open_close_ind   = 'O' then 'OPEN' else 'ROLLED' end as INVStatus,    
 case when  sum (i.inv_open_prd_proj_qty+i.inv_open_prd_actual_qty + i.inv_cnfrmd_qty + i.inv_adj_qty) > 0.01 then 'N' else 'Y' end as ZeroInventory,    
 i.inv_num,     
 convert (varchar,i.trade_num)+'-'+convert (varchar,i.order_num)+'-'+convert (varchar,i.sale_item_num) as InvKey,    
 convert (varchar,ih.cost_trade_num)+'-'+convert (varchar,ih.cost_order_num)+'-'+convert (varchar,ih.cost_item_num)+'-'+convert (varchar,ih.rcpt_alloc_num)+'-'+convert (varchar,ih.rcpt_alloc_item_num) as BuildFrom,    
 cmdty.cmdty_short_name as Commodity,     
 l.loc_name as Location,    
 t.cargo_id_number as Tank,    
 mkt.mkt_short_name as RiskMarket,    
 pos.trading_prd as RiskPrd,    
 'Q'+convert(char,datename(q,tp.last_trade_date)) 'RiskPrdQtr',    
 datename(yyyy,tp.last_trade_date) RiskPrdYear,    
 tp.last_trade_date as RiskPrdDate,    
 min(finbnk.acct_short_name) FinancingBank,    
 c.cost_qty* cost_amt_ratio as BDQty,    
 c.cost_unit_price as AvgCost,    
 ibd.inv_b_d_cost_uom_code as BDUom,     
 sum (c.cost_qty) as GoodsCostQty,     
 convert (varchar,ibd.alloc_num)+'-'+convert (varchar,ibd.alloc_item_num) as BuildKey ,    
 convert (varchar,ibd.alloc_num)+'-'+convert (varchar,ibd.alloc_item_num) as AllocNum ,    
 sum (isnull(ih.r_cost_amt,0) + isnull(ih.unr_cost_amt,0))*-1 * cost_amt_ratio as GoodsCost,    
 /*case when c1.cost_num is not null then sum (c1.cost_amt)*-1* cost_amt_ratio 
	when c1.cost_num is null and  ih.cost_type_code in ('ADDLAA','ADDLAI','ADDLTI','WAP','WS') then  sum(isnull(r_cost_amt,unr_cost_amt)) end */
 sum (c1.cost_amt)*-1* cost_amt_ratio as ServiceAmt,    
 max(isnull(c1.cost_price_curr_code,'')) as ServiceCurr,    
 (sum (isnull(ih.r_cost_amt,0) + isnull(ih.unr_cost_amt,0))*-1 * cost_amt_ratio) + (sum (c1.cost_amt)*-1* cost_amt_ratio )as TotalBDCost,     
 case when  count(c.cost_status)>1 then '' else min(c.cost_status) end as GoodsStatus,    
 case when  count(acct.acct_short_name)>1 then 'MULTIPLE' else min(acct.acct_short_name) end as Counterpart,    
 case when count(mot.mot_full_name)>1 then 'MULTIPLE' else min(mot.mot_full_name) end as MOT,    
 'P' as GoodsPRInd,    
 c.cost_price_curr_code as GoodsCurr,    
 i.port_num as Portfolio,    
 UndCmdty,    
 UndMkt,    
 UndSource,     
 UndTradingPrd,     
 MTMQuoteDiff,    
 ibd.inv_b_d_num,    
 ibd.alloc_num 'InvAllocNum',    
 ibd.alloc_item_num 'InvAllocItemNum',    
 ih.rcpt_alloc_num 'BuildDrawAllocNum',    
 ih.rcpt_alloc_item_num 'BuildDrawAllocItemNum',    
 NULL,NULL,NULL,NULL    
 from trade_item ti    
 join trade t on ti.trade_num = t.trade_num     
 join commodity cmdty on cmdty.cmdty_code = ti.cmdty_code    
 join market mkt on mkt.mkt_code = ti.risk_mkt_code    
 join inventory i on i.trade_num=ti.trade_num and i.order_num=ti.order_num and i.sale_item_num=ti.item_num ---and i.open_close_ind = 'O'    
 join inventory_history ih on ih.real_port_num = ti.real_port_num and ih.inv_num = i.inv_num    
 join position pos on pos.pos_num = i.pos_num    
 join inventory_build_draw ibd on ibd.inv_num=i.inv_num    
 join location l on l.loc_code = i.del_loc_code    
 join allocation_item ai on ibd.alloc_num =ai.alloc_num and  ai.alloc_item_num = ibd.alloc_item_num and ai.alloc_item_type in ('R','C','T', 'I') and ai.alloc_num=ih.rcpt_alloc_num    
 join allocation_item_transport ait on  ait.alloc_num =ai.alloc_num and ait.alloc_item_num =  ai.alloc_item_num    
 join allocation a on a.alloc_num = ai.alloc_num    
 join trading_period tp on tp.commkt_key=pos.commkt_key and tp.trading_prd=pos.trading_prd    
 join cost c on c.cost_num = ih.cost_num and c.cost_type_code = 'WPP' and c.cost_status !='CLOSED'    
 left outer join  inventory previnv on previnv.inv_num = i.prev_inv_num     
 left outer join allocation_item ai2 on ih.rcpt_alloc_num =ai2.alloc_num and  ai2.alloc_item_num = ih.rcpt_alloc_item_num    
 left outer join allocation_item_transport ait2 on ih.rcpt_alloc_num =ait2.alloc_num and  ait2.alloc_item_num = ih.rcpt_alloc_item_num    
 left outer join trade t2 on ih.cost_trade_num = t2.trade_num     
       
 left outer join account acct on acct.acct_num = t2.acct_num    
 left outer join cost c1 on c1.cost_owner_key1=ih.cost_num    
  and c1.cost_status != 'CLOSED'     
  and c1.cost_type_code != 'WPP'    
 left outer join mot mot on mot.mot_code = ait2.transportation    
 left outer join account finbnk ON finbnk.acct_num=ti.finance_bank_num      
     
 left outer join     
  (select cmf.commkt_key, cmf.trading_prd ,cmf.price_source_code, c.cmdty_short_name 'UndCmdty',m.mkt_short_name 'UndMkt', quote_price_source_code 'UndSource', quote_trading_prd 'UndTradingPrd', quote_price_type,quote_diff 'MTMQuoteDiff'    
  from commodity_market_formula cmf, simple_formula sf, commodity_market cm, commodity c, market m    
  where cmf.avg_closed_simple_formula_num=sf.simple_formula_num    
  and cm.cmdty_code=c.cmdty_code    
  and cm.mkt_code=m.mkt_code    
  and cm.commkt_key=quote_commkt_key    
  ) frm ON frm.commkt_key=pos.commkt_key and frm.price_source_code='INTERNAL' and pos.trading_prd=frm.trading_prd    
  ----@AdditionalTables    
 where ibd.inv_num in (select inv_num from inventory where pos_num in (select pos_num from position     
 where pos_type='I' ) )     
 and inv_b_d_type='B'    
 and ibd.adj_qty is null     
 and i.port_num in (select port_num from #children)     
 and asof_date=@AsofDate    
 and i.open_close_ind like @IncludeRolledInv    
 --and i.inv_num=13294    
 --@invstatus    
 --@zeroinv    
 group by    
 convert (char,a.creation_date,106),    
 case when ibd.inv_b_d_type = 'B' then 'BUILD' when ibd.inv_b_d_type = 'D' then 'DRAW' end ,    
 c.cost_qty,    
 i.open_close_ind ,    
 i.inv_num, convert (varchar,i.trade_num)+'-'+convert (varchar,i.order_num)+'-'+convert (varchar,i.sale_item_num) ,    
 cmdty.cmdty_short_name ,     
 l.loc_name ,    
 c.cost_unit_price,    
 mkt.mkt_short_name ,    
 pos.trading_prd ,    
 'Q'+convert(char,datename(q,tp.last_trade_date)) ,    
 datename(yyyy,tp.last_trade_date) ,    
 tp.last_trade_date ,    
 ibd.inv_b_d_qty ,    
 ibd.inv_b_d_cost_uom_code ,     
 convert (varchar,ibd.alloc_num)+'-'+convert (varchar,ibd.alloc_item_num) ,    
 ibd.inv_b_d_cost ,     
 c.cost_price_curr_code ,    
 i.port_num ,    --c1.cost_num,ih.cost_type_code,
 t.cargo_id_number,    
 UndCmdty,    
 UndMkt,    
 UndSource,     
 UndTradingPrd,     
 MTMQuoteDiff,    
 convert (varchar,ibd.alloc_num)+'-'+convert (varchar,ibd.alloc_item_num),    
 ibd.inv_b_d_num,    
 ih.cost_amt_ratio,    
 ih.cost_trade_num,    
 ih.cost_order_num,    
 ih.cost_item_num,    
 ih.rcpt_alloc_num,    
 ih.rcpt_alloc_item_num,    
  ibd.alloc_num ,    
 ibd.alloc_item_num     
    
     
 union    
    
 ---OPENINGINV    
 select     
 null as CreationDate,    
 'START BALANCE' as TYPE,    
 case when i.open_close_ind   = 'O' then 'OPEN' else 'ROLLED' end as INVStatus,    
 case when  sum (i.inv_open_prd_proj_qty+i.inv_open_prd_actual_qty + i.inv_cnfrmd_qty + i.inv_adj_qty) >= 0.01 then 'N' else 'Y' end as ZeroInventory,    
 i.inv_num,     
 convert (varchar,i.trade_num)+'-'+convert (varchar,i.order_num)+'-'+convert (varchar,i.sale_item_num) as InvKey,    
 null as BuildFrom,    
 cmdty.cmdty_short_name as Commodity,     
 l.loc_name as Location,    
 t.cargo_id_number as Tank,    
 mkt.mkt_short_name as RiskMarket,    
 pos.trading_prd as RiskPrd,    
 'Q'+convert(char,datename(q,tp.last_trade_date)) 'RiskPrdQtr',    
 datename(yyyy,tp.last_trade_date) RiskPrdYear,    
 convert(char,getdate(),106) as RiskPrdDate,    
 min(finbnk.acct_short_name) FinancingBank,    
 case when previnv.open_close_ind='O' then 0 else sum (i.inv_open_prd_proj_qty + i.inv_open_prd_actual_qty) end as BDQty,    
 i.inv_avg_cost as AvgCost,    
 i.inv_qty_uom_code as BDUom,     
 null as GoodsCostQty,     
 case when i.prev_inv_num is null then 'NEW' else convert (varchar,i.prev_inv_num) end as BuildKey,    
 null as AllocNum,    
 null as GoodsCost,    
 null  as ServiceAmt,    
 null as ServiceCurr,    
 null as TotalBDCost,     
 null as GoodsStatus,    
 null as Counterpart,    
 null as MOT,    
 null as GoodsPRInd,    
 null as GoodsCurr,    
 i.port_num as Portfolio,    
 UndCmdty,    
 UndMkt,    
 UndSource,     
 UndTradingPrd,     
 MTMQuoteDiff,    
 null,    
 Null 'InvAllocNum',    
 NULL 'InvAllocItemNum',    
 NULL 'BuildDrawAllocNum',    
 NULL 'BuildDrawAllocItemNum',    
 NULL,NULL,NULL,NULL    
 from trade_item ti    
 join trade t on ti.trade_num = t.trade_num    
 join commodity cmdty on cmdty.cmdty_code = ti.cmdty_code    
 join market mkt on mkt.mkt_code = ti.risk_mkt_code    
 join inventory i on i.trade_num=ti.trade_num and i.order_num=ti.order_num and i.sale_item_num=ti.item_num and i.prev_inv_num > 0    
 join position pos on pos.pos_num = i.pos_num    
 join location l on l.loc_code = i.del_loc_code    
 left outer join  inventory previnv on previnv.inv_num = i.prev_inv_num     
 join trading_period tp on tp.commkt_key=pos.commkt_key and tp.trading_prd=pos.trading_prd    
 left outer join account finbnk ON finbnk.acct_num=ti.finance_bank_num      
  left outer join     
    (select cmf.commkt_key, cmf.trading_prd ,cmf.price_source_code, c.cmdty_short_name 'UndCmdty',m.mkt_short_name 'UndMkt', quote_price_source_code 'UndSource', quote_trading_prd 'UndTradingPrd', quote_price_type,quote_diff 'MTMQuoteDiff'    
    from commodity_market_formula cmf, simple_formula sf, commodity_market cm, commodity c, market m    
    where cmf.avg_closed_simple_formula_num=sf.simple_formula_num    
    and cm.cmdty_code=c.cmdty_code    
    and cm.mkt_code=m.mkt_code    
    and cm.commkt_key=quote_commkt_key    
    ) frm ON frm.commkt_key=pos.commkt_key and frm.price_source_code='INTERNAL' and pos.trading_prd=frm.trading_prd    
 --@AdditionalTables    
 where     
 1=1    
 and i.port_num in (select port_num from #children)     
 --and i.inv_num=13294    
 and i.open_close_ind like @IncludeRolledInv    
 --@zeroinv    
 group by     
 i.inv_num,     
 t.cargo_id_number,    
 i.open_close_ind ,    
 i.trade_num,    
 i.order_num,    
 i.sale_item_num,    
 i.cmdty_code,     
 l.loc_name,    
 ti.risk_mkt_code,     
 i.inv_qty_uom_code,    
 i.inv_avg_cost,    
 i.port_num,    
 pos.trading_prd,    
 cmdty.cmdty_short_name,    
 mkt.mkt_short_name,    
 i.prev_inv_num,    
 UndCmdty,    
 t.cargo_id_number,    
 UndMkt,    
 UndSource,     
 UndTradingPrd,     
 MTMQuoteDiff,tp.last_trade_date,previnv.open_close_ind    
    
 union    
    
 ---DRAWS    
     
 select distinct    
 convert (char,ai.title_tran_date,106) as CreationDate,    
 case when ibd.inv_b_d_type = 'B' then 'BUILD' when ibd.inv_b_d_type = 'D' then 'DRAW' end as TYPE,    
 case when i.open_close_ind   = 'O' then 'OPEN' else 'ROLLED' end as INVStatus,    
 case when  sum (i.inv_open_prd_proj_qty+i.inv_open_prd_actual_qty + i.inv_cnfrmd_qty + i.inv_adj_qty) >= 0.01 then 'N' else 'Y' end as ZeroInventory,    
 i.inv_num,     
 convert (varchar,i.trade_num)+'-'+convert (varchar,i.order_num)+'-'+convert (varchar,i.sale_item_num) as InvKey,    
 convert (varchar,ibd.alloc_num)+'-'+convert (varchar,ibd.alloc_item_num) as BuildFrom,    
 cmdty.cmdty_short_name as Commodity,     
 l.loc_name as Location,    
 t.cargo_id_number as Tank,    
 mkt.mkt_short_name as RiskMarket,    
 pos.trading_prd as RiskPrd,    
 'Q'+convert(char,datename(q,tp.last_trade_date)) 'RiskPrdQtr',    
 datename(yyyy,tp.last_trade_date) as RiskPrdYear,    
 getdate() as RiskPrdDate,     
 min(finbnk.acct_short_name) FinancingBank,    
 case when ibd.inv_b_d_type = 'D' then ibd.inv_b_d_qty*-1 else ibd.inv_b_d_qty end as BDQty,    
 i.inv_avg_cost as AvgCost,    
 ibd.inv_b_d_cost_uom_code as BDUom,     
 null as GoodsCostQty,     
 convert (varchar,ibd.alloc_num)+'-'+convert (varchar,ibd.alloc_item_num) as BuildKey ,    
 convert (varchar,ibd.alloc_num)+'-'+convert (varchar,ibd.alloc_item_num) as AllocNum,    
 null as GoodsCost,    
 null as ServiceAmt,    
 null as ServiceCurr,    
 ibd.inv_b_d_cost as TotalBDCost,     
 null as GoodsStatus,    
 case when  count(acct.acct_short_name)>1 then 'MULTIPLE' else min(acct.acct_short_name) end as Counterpart,    
 case when count(mot.mot_full_name)>1 then 'MULTIPLE' else min(mot.mot_full_name) end as MOT,    
 null as GoodsPRInd,    
 null as GoodsCurr,    
 i.port_num as Portfolio,    
 UndCmdty,    
 UndMkt,    
 UndSource,     
 UndTradingPrd,     
 MTMQuoteDiff,    
 ibd.inv_b_d_num,    
 ibd.alloc_num 'InvAllocNum',    
 ibd.alloc_item_num 'InvAllocItemNum',    
 NULL 'BuildDrawAllocNum',    
 NULL 'BuildDrawAllocItemNum',    
 NULL,NULL,NULL,NULL    
 from trade_item ti    
 join trade t on ti.trade_num = t.trade_num    
 join commodity cmdty on cmdty.cmdty_code = ti.cmdty_code    
 join market mkt on mkt.mkt_code = ti.risk_mkt_code    
 join inventory i on i.trade_num=ti.trade_num and i.order_num=ti.order_num and i.sale_item_num=ti.item_num    
 join position pos on pos.pos_num = i.pos_num    
 join inventory_build_draw ibd on ibd.inv_num=i.inv_num and inv_b_d_type='D'    
 join location l on l.loc_code = i.del_loc_code    
 join allocation_item ai on ibd.alloc_num =ai.alloc_num and ibd.alloc_item_num =ai.alloc_item_num    
 join allocation_item ai2 on ibd.alloc_num =ai2.alloc_num and ibd.alloc_item_num != ai2.alloc_item_num    
 join trading_period tp on tp.commkt_key=pos.commkt_key and tp.trading_prd=pos.trading_prd    
 left outer join  inventory previnv on previnv.inv_num = i.prev_inv_num     
 left outer join trade_item ti2 on ti2.trade_num = ai2.trade_num and ti2.order_num = ai2.order_num and ti2.item_num = ai2.item_num and ti2.p_s_ind = 'S'    
 left outer join account a2 on ai2.acct_num = a2.acct_num    
 left outer join allocation_item_transport ait2 on ait2.alloc_num = ai2.alloc_num and ait2.alloc_item_num = ai2.alloc_item_num    
 left outer join mot mot on mot.mot_code = ait2.transportation    
  left outer join trade t2 on ai2.trade_num = t2.trade_num     
  left outer join account acct on acct.acct_num = t2.acct_num    
  left outer join account finbnk ON finbnk.acct_num=ti.finance_bank_num      
 left outer join     
    (select cmf.commkt_key, cmf.trading_prd ,cmf.price_source_code, c.cmdty_short_name 'UndCmdty',m.mkt_short_name 'UndMkt', quote_price_source_code 'UndSource', quote_trading_prd 'UndTradingPrd', quote_price_type,quote_diff 'MTMQuoteDiff'    
    from commodity_market_formula cmf, simple_formula sf, commodity_market cm, commodity c, market m    
    where cmf.avg_closed_simple_formula_num=sf.simple_formula_num    
    and cm.cmdty_code=c.cmdty_code    
    and cm.mkt_code=m.mkt_code    
    and cm.commkt_key=quote_commkt_key    
    ) frm ON frm.commkt_key=pos.commkt_key and frm.price_source_code='INTERNAL' and pos.trading_prd=frm.trading_prd    
 --@AdditionalTables    
 where ibd.inv_num in (select inv_num from inventory where pos_num in (select pos_num from position     
 where pos_type='I' ) )     
 and ibd.adj_qty is null    
 and i.port_num in (select port_num from #children)     
 --and i.inv_num=13294    
 and i.open_close_ind like @IncludeRolledInv    
 --@zeroinv    
 group by    
 i.open_close_ind,    
 t.cargo_id_number,    
 ai.title_tran_date ,    
 ibd.inv_b_d_type ,    
 i.inv_num, convert (varchar,i.trade_num)+'-'+convert (varchar,i.order_num)+'-'+convert (varchar,i.sale_item_num) ,    
 cmdty.cmdty_short_name ,     
 l.loc_name ,    
 mkt.mkt_short_name ,    
 pos.trading_prd ,    
 case when ibd.inv_b_d_type = 'D' then ibd.inv_b_d_qty*-1 else ibd.inv_b_d_qty end ,    
 i.inv_avg_cost ,    
 ibd.inv_b_d_cost_uom_code ,     
 convert (varchar,ibd.alloc_num)+'-'+convert (varchar,ibd.alloc_item_num) ,    
 ibd.inv_b_d_cost ,     
 i.port_num ,    
 convert (varchar,ibd.alloc_num)+'-'+convert (varchar,ibd.alloc_item_num) ,    
 ibd.inv_b_d_num,    
 UndCmdty,    
 UndMkt,    
 UndSource,     
 UndTradingPrd,     
 MTMQuoteDiff,tp.last_trade_date, ibd.alloc_num ,    
 ibd.alloc_item_num     
 --ai2.alloc_num ,    
 --ai2.alloc_item_num     
    
 union    
     
 select     
 convert (char,ibd.inv_b_d_date ,106) as CreationDate,    
 'ADJUSTMENT' as TYPE,    
 case when i.open_close_ind   = 'O' then 'OPEN' else 'ROLLED' end as INVStatus,    
 case when  sum (i.inv_open_prd_proj_qty+i.inv_open_prd_actual_qty + i.inv_cnfrmd_qty + i.inv_adj_qty) >= 0.01 then 'N' else 'Y' end as ZeroInventory,    
 i.inv_num,     
 convert (varchar,i.trade_num)+'-'+convert (varchar,i.order_num)+'-'+convert (varchar,i.sale_item_num) as InvKey,    
 convert (varchar,ibd.alloc_num)+'-'+convert (varchar,ibd.alloc_item_num) as BuildFrom,    
 cmdty.cmdty_short_name as Commodity,     
 l.loc_name as Location,    
 t.cargo_id_number as Tank,    
 mkt.mkt_short_name as RiskMarket,    
 pos.trading_prd as RiskPrd,    
 'Q'+convert(char,datename(q,tp.last_trade_date)) 'RiskPrdQtr',    
 datename(yyyy,tp.last_trade_date) RiskPrdYear,    
 getdate() as RiskPrdDate,     
 min(finbnk.acct_short_name) FinancingBank,    
 case when ibd.inv_b_d_type = 'D' then ibd.inv_b_d_qty*-1 else ibd.inv_b_d_qty end as BDQty,    
 i.inv_avg_cost as AvgCost,    
 ibd.inv_b_d_cost_uom_code as BDUom,     
 null as GoodsCostQty,     
 convert (varchar,ibd.alloc_num)+'-'+convert (varchar,ibd.alloc_item_num) as BuildKey ,    
 convert (varchar,ibd.alloc_num)+'-'+convert (varchar,ibd.alloc_item_num) as AllocNum ,    
 null as GoodsCost,    
 null as ServiceAmt,    
 null as ServiceCurr,    
 ibd.inv_b_d_cost as TotalBDCost,     
 null as GoodsStatus,    
 null as Counterpart,    
 'ADJUSTMENT' as MOT,    
 null as GoodsPRInd,    
 null as GoodsCurr,    
 i.port_num as Portfolio,    
 UndCmdty,    
 UndMkt,    
 UndSource,     
 UndTradingPrd,     
 MTMQuoteDiff,    
 ibd.inv_b_d_num,    
 NULL 'InvAllocNum',    
 NULL  'InvAllocItemNum',    
 NULL  'BuildDrawAllocNum',    
 NULL  'BuildDrawAllocItemNum',    
 NULL,NULL,NULL,NULL    
 from trade_item ti    
 join trade t on ti.trade_num = t.trade_num    
 join commodity cmdty on cmdty.cmdty_code = ti.cmdty_code    
 join market mkt on mkt.mkt_code = ti.risk_mkt_code    
 join inventory i on i.trade_num=ti.trade_num and i.order_num=ti.order_num and i.sale_item_num=ti.item_num     
 join position pos on pos.pos_num = i.pos_num    
 join inventory_build_draw ibd on ibd.inv_num=i.inv_num and ibd.adj_qty_uom_code = i.inv_qty_uom_code    
 join location l on l.loc_code = i.del_loc_code    
 join allocation alloc on alloc.alloc_num = ibd.alloc_num and alloc.alloc_type_code  in ('J')    
 join allocation_item ai on ibd.alloc_num =ai.alloc_num and ibd.alloc_item_num = ai.alloc_item_num    
    join trading_period tp on tp.commkt_key=pos.commkt_key and tp.trading_prd=pos.trading_prd    
 left outer join  inventory previnv on previnv.inv_num = i.prev_inv_num     
 left outer join account finbnk ON finbnk.acct_num=ti.finance_bank_num      
 left outer join     
    (select cmf.commkt_key, cmf.trading_prd ,cmf.price_source_code, c.cmdty_short_name 'UndCmdty',m.mkt_short_name 'UndMkt', quote_price_source_code 'UndSource', quote_trading_prd 'UndTradingPrd', quote_price_type,quote_diff 'MTMQuoteDiff'    
    from commodity_market_formula cmf, simple_formula sf, commodity_market cm, commodity c, market m    
    where cmf.avg_closed_simple_formula_num=sf.simple_formula_num    
    and cm.cmdty_code=c.cmdty_code    
    and cm.mkt_code=m.mkt_code    
    and cm.commkt_key=quote_commkt_key    
    ) frm ON frm.commkt_key=pos.commkt_key and frm.price_source_code='INTERNAL' and pos.trading_prd=frm.trading_prd    
 --@AdditionalTables    
 where    
 i.port_num in (select port_num from #children)     
 --and i.inv_num=13294    
 and i.open_close_ind like @IncludeRolledInv    
 --@zeroinv    
 group by    
 i.inv_avg_cost ,    
 t.cargo_id_number,    
 i.open_close_ind ,    
 ibd.inv_b_d_date,    
 ibd.inv_b_d_type,    
 i.inv_num,i.trade_num,i.order_num,i.sale_item_num,    
 l.loc_name,    
 cmdty.cmdty_short_name,    
 mkt.mkt_short_name,    
 ti.risk_mkt_code,     
 ibd.inv_b_d_qty,    
 ibd.inv_b_d_cost,    
 ibd.inv_b_d_qty,    
 ibd.inv_b_d_cost_uom_code,     
 ibd.alloc_num,ibd.alloc_item_num,    
 ibd.inv_b_d_cost,     
 i.port_num,    
 pos.trading_prd,    
 ibd.inv_b_d_num,i.cmdty_code,i.open_close_ind,    
 ibd.alloc_num,    
 ibd.alloc_item_num,    
 UndCmdty,    
 UndMkt,    
 UndSource,     
 UndTradingPrd,     
 MTMQuoteDiff,    
 tp.last_trade_date    
     
  If (@ShowMSDSDetail='Y')    
  BEGIN    
  
 update i    
 set CasNumPhysicalSide=cas_num1    
 from #inv_det i,    
  (SELECT BuildDrawAllocNum, BuildDrawAllocItemNum,    
   stuff((     
    select distinct ',' + cas_num_desc1    
    from (SELECT distinct alloc_num, alloc_item_num ,cas_num_desc1    
   FROM v_allocation_reach_detail v, #inv_det i    
   WHERE v.alloc_num=i.BuildDrawAllocNum    
   and v.alloc_item_num=i.BuildDrawAllocItemNum    
   and v.ai_est_actual_num<>0      
   and TYPE='BUILD'      
   --and v.alloc_num=69310  
  ) ibd    
  WHERE ibd.alloc_num=i.BuildDrawAllocNum    
  and ibd.alloc_item_num=i.BuildDrawAllocItemNum  
  for xml path('')                              
   ),1,1,'') as cas_num1      
   from #inv_det i    
   group by BuildDrawAllocNum  ,BuildDrawAllocItemNum  
  ) id    
  WHERE i.BuildDrawAllocNum=id.BuildDrawAllocNum    
  AND i.BuildDrawAllocItemNum=id.BuildDrawAllocItemNum    
 and TYPE='BUILD'  
  
  
      
    
 update i    
 set CasNumPhysicalSideOther=OtherCasNumFlag    
 from #inv_det i,    
  (SELECT BuildDrawAllocNum, BuildDrawAllocItemNum,    
   stuff((     
    select distinct ',' + case when cas_num_desc2 is not null then 'Y' else 'N' end     
    from (SELECT distinct alloc_num,   alloc_item_num ,cas_num_desc2    
   FROM v_allocation_reach_detail v, #inv_det i    
   WHERE v.alloc_num=i.BuildDrawAllocNum    
   and v.alloc_item_num=i.BuildDrawAllocItemNum    
   and v.ai_est_actual_num<>0      
   and TYPE='BUILD'      
   --and v.alloc_num=69310  
     ) ibd    
  WHERE ibd.alloc_num=i.BuildDrawAllocNum    
    and ibd.alloc_item_num=i.BuildDrawAllocItemNum  
  for xml path('')                              
   ),1,1,'') as OtherCasNumFlag      
   from #inv_det i    
   group by BuildDrawAllocNum  ,BuildDrawAllocItemNum    
  ) id    
  WHERE i.BuildDrawAllocNum=id.BuildDrawAllocNum    
  AND i.BuildDrawAllocItemNum=id.BuildDrawAllocItemNum    
  and TYPE='BUILD'  
    
 update i    
 set ReachImportedFlag=ReachImpFlag    
 from #inv_det i,    
  (SELECT BuildDrawAllocNum,    BuildDrawAllocItemNum,   
   stuff((     
    select distinct ',' + msds_reach_imp_flag    
    from (SELECT distinct alloc_num,alloc_item_num,  msds_reach_imp_flag    
   FROM v_allocation_reach_detail v, #inv_det i    
   WHERE v.alloc_num=i.BuildDrawAllocNum    
   and v.alloc_item_num=i.BuildDrawAllocItemNum    
   and v.ai_est_actual_num<>0      
   and TYPE='BUILD'      
   --and v.alloc_num=69310   
  ) ibd    
  WHERE ibd.alloc_num=i.BuildDrawAllocNum   
 and ibd.alloc_item_num=i.BuildDrawAllocItemNum   
  for xml path('')                              
   ),1,1,'') as ReachImpFlag      
   from #inv_det i    
   group by BuildDrawAllocNum  ,BuildDrawAllocItemNum    
  ) id    
  WHERE i.BuildDrawAllocNum=id.BuildDrawAllocNum    
  AND i.BuildDrawAllocItemNum=id.BuildDrawAllocItemNum      
 and TYPE='BUILD'  
  
  
---Draw --  
  
  
 update i    
 set CasNumPhysicalSide=cas_num1    
 from #inv_det i,    
  (SELECT InvAllocNum, InvAllocItemNum,    
   stuff((     
    select distinct ',' + cas_num_desc1    
    from (SELECT distinct i.InvAllocNum,i.InvAllocItemNum, cas_num_desc1    
     FROM v_allocation_reach_detail v, #inv_det i  , inventory inv, trade_item ti, allocation_item ai  
     WHERE  ai.alloc_num=v.alloc_num    
     and ai.alloc_item_num=v.alloc_item_num    
     and ai.trade_num=ti.trade_num  
     and ai.order_num=ti.order_num  
     and ai.item_num=ti.item_num  
     and ti.p_s_ind='S'  
     and v.ai_est_actual_num<>0      
     and ai.trade_num<>inv.trade_num  
     and inv.inv_num=i.inv_num  
     and i.InvAllocNum=v.alloc_num  
     and TYPE='DRAW'      
     --and v.alloc_num=69310  
  ) ibd    
  WHERE ibd.InvAllocNum=i.InvAllocNum    
  and ibd.InvAllocItemNum=i.InvAllocItemNum  
  for xml path('')                              
   ),1,1,'') as cas_num1      
   from #inv_det i    
   group by InvAllocNum  ,InvAllocItemNum  
  ) id    
  WHERE i.InvAllocNum=id.InvAllocNum    
  AND i.InvAllocItemNum=id.InvAllocItemNum    
 and TYPE='DRAW'   
  
  
      
    
 update i    
 set CasNumPhysicalSideOther=OtherCasNumFlag    
 from #inv_det i,    
  (SELECT InvAllocNum, InvAllocItemNum,      
   stuff((     
    select distinct ',' + case when cas_num_desc2 is not null then 'Y' else 'N' end     
    from (   
   SELECT distinct i.InvAllocNum,i.InvAllocItemNum, cas_num_desc2    
     FROM v_allocation_reach_detail v, #inv_det i  , inventory inv, trade_item ti, allocation_item ai  
     WHERE  ai.alloc_num=v.alloc_num    
     and ai.alloc_item_num=v.alloc_item_num    
     and ai.trade_num=ti.trade_num  
     and ai.order_num=ti.order_num  
     and ai.item_num=ti.item_num  
     and ti.p_s_ind='S'  
     and v.ai_est_actual_num<>0      
     and ai.trade_num<>inv.trade_num  
     and inv.inv_num=i.inv_num  
     and i.InvAllocNum=v.alloc_num  
     and TYPE='DRAW'      
     --and v.alloc_num=69310  
  ) ibd    
  WHERE ibd.InvAllocNum=i.InvAllocNum    
  and ibd.InvAllocItemNum=i.InvAllocItemNum  
  for xml path('')                              
   ),1,1,'') as OtherCasNumFlag      
   from #inv_det i    
   group by InvAllocNum  ,InvAllocItemNum  
  ) id    
  WHERE i.InvAllocNum=id.InvAllocNum    
  AND i.InvAllocItemNum=id.InvAllocItemNum    
 and TYPE='DRAW'   
  
  
  
    
 update i    
 set ReachImportedFlag=ReachImpFlag    
 from #inv_det i,    
  (SELECT InvAllocNum, InvAllocItemNum,      
   stuff((     
    select distinct ',' + msds_reach_imp_flag   
    from (   
   SELECT distinct i.InvAllocNum,i.InvAllocItemNum, msds_reach_imp_flag    
     FROM v_allocation_reach_detail v, #inv_det i  , inventory inv, trade_item ti, allocation_item ai  
     WHERE  ai.alloc_num=v.alloc_num    
     and ai.alloc_item_num=v.alloc_item_num    
     and ai.trade_num=ti.trade_num  
     and ai.order_num=ti.order_num  
     and ai.item_num=ti.item_num  
     and ti.p_s_ind='S'  
     and v.ai_est_actual_num<>0      
     and ai.trade_num<>inv.trade_num  
     and inv.inv_num=i.inv_num  
     and i.InvAllocNum=v.alloc_num  
     and TYPE='DRAW'      
     --and v.alloc_num=69310  
  ) ibd    
  WHERE ibd.InvAllocNum=i.InvAllocNum    
  and ibd.InvAllocItemNum=i.InvAllocItemNum  
  for xml path('')                              
   ),1,1,'') as ReachImpFlag      
   from #inv_det i    
   group by InvAllocNum  ,InvAllocItemNum  
  ) id    
  WHERE i.InvAllocNum=id.InvAllocNum    
  AND i.InvAllocItemNum=id.InvAllocItemNum    
 and TYPE='DRAW'   
  
-- Storage Side Works--  
    
 update i    
 set CasNumStorageSide=CasNumStorage    
 from #inv_det i,    
  (SELECT InvAllocNum,InvAllocItemNum,     
   stuff((     
    select distinct ',' + cas_num_desc1    
    from (SELECT distinct v.alloc_num,v.alloc_item_num,  cas_num_desc1    
   FROM v_allocation_reach_detail v, #inv_det i,allocation_item ai,  trade_item ti    
   WHERE ai.alloc_num=v.alloc_num    
   and ai.alloc_item_num=v.alloc_item_num    
   and ai.trade_num=ti.trade_num    
   and ai.order_num=ti.order_num    
   and ai.item_num=ti.item_num    
   and v.ai_est_actual_num<>0    
  ---and v.alloc_num=66921    
  ) ibd    
  WHERE ibd.alloc_num=i.InvAllocNum    
  AND ibd.alloc_item_num=i.InvAllocItemNum    
  for xml path('')                              
   ),1,1,'') as CasNumStorage     
   from #inv_det i    
   group by InvAllocNum,InvAllocItemNum   
  ) id    
  WHERE i.InvAllocNum=id.InvAllocNum    
  AND i.InvAllocItemNum=id.InvAllocItemNum  
    
  END  
    
select * from #inv_det      
END    
GO
GRANT EXECUTE ON  [dbo].[usp_inventory_detail] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_inventory_detail', NULL, NULL
GO
