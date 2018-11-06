SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[usp_mercuria_conc_m2m_report]  
(  
   @port_num            int,  
   @debugon             bit = 0  
)  
as  
set nocount on  
  
if object_id('tempdb..#children', 'U') is not null  
   exec('drop table tempdb..#children')  
  
create table #children  
(  
     port_num int,   
     port_type char(2)  
)  
  
  
exec usp_get_child_port_nums @top_port_num = @port_num , @real_only_ind=1  
  
  
if object_id('tempdb..#SelectedTI', 'U') is not null  
   exec('drop table #SelectedTI')  
  
  
select ti1.trade_num,  
  
       ti1.order_num,  
  
       ti1.item_num,  
      
    ti1.item_type,  
  
       ti1.p_s_ind,  
  
       ti1.real_port_num,  
  
       ti1.contr_qty,  
  
       ti1.cmdty_code,   
  
       ti1.risk_mkt_code,  
      
    ti1.booking_comp_num  
  
into #SelectedTI  
  
from dbo.trade_item ti1 inner join dbo.trade_order tor1  
  
on ti1.trade_num=tor1.trade_num and   
  
   ti1.order_num=tor1.order_num and   
  
   tor1.strip_summary_ind='N'  
  
inner join #children c   
  
on ti1.real_port_num=c.port_num  
  
where cmdty_code in ('CONCCUAG','CONCCUAU','CONCPBAG','CONCSZN')  
  
  
  
--and not exists (select 1 from allocation_item ai  
  
--where ai.trade_num=ti1.trade_num and ai.order_num=ti1.order_num and ai.item_num=ti1.item_num)  
  
--where ti1.trade_num in (2601532, 2606921, 2653130, 2662174)  
  
  
  
declare @WMTQtyETKey int,  
  
 @MoistureETKey int,  
  
 @FranchiseETKey int  
  
  
  
select @WMTQtyETKey=oid  
  
from dbo.entity_tag_definition etd   
  
where etd.entity_id in (select oid from icts_entity_name where entity_name='TradeItem')  
  
and etd.entity_tag_name='WMTQuantity'  
  
  
  
select @MoistureETKey=oid  
  
from dbo.entity_tag_definition etd   
  
where etd.entity_id in (select oid from icts_entity_name where entity_name='TradeItem')  
  
and etd.entity_tag_name='Moisture'  
  
  
  
select @FranchiseETKey=oid  
  
from dbo.entity_tag_definition etd   
  
where etd.entity_id in (select oid from icts_entity_name where entity_name='TradeItem')  
  
and etd.entity_tag_name='Franchise'  
  
  
  
if object_id('tempdb..#TIToReport', 'U') is not null  
  
   exec('drop table #TIToReport')  
  
  
  
--- basic list of trade items  
  
select   
  
 convert(varchar(12),tr.contr_date, 6) as 'TradeDate',  
  
 ti.real_port_num as 'Portfolio',  
  
 ti.trade_num,  
  
 ti.order_num,  
  
 ti.item_num,  
   
 ti.item_type,  
  
 case ti.p_s_ind when 'P' then 'Buy' else 'Sell' end as 'Buy_Sell',  
  
 a.acct_short_name as Counterparty,  
   
 bc.acct_short_name as BookingCompany,  
  
 cmdty.cmdty_short_name as Concentrate,  
  
 mkt.mkt_short_name as 'Strategy',  
  
 case ti.item_type when 'W' then  
 isnull(wmtQtyTag.target_key1, 0)   
 else tidp.wet_qty end as 'WMT',  
  
 case ti.item_type when 'W' then   
 case charindex('%',moistureTag.target_key1,0) when 0 then CONVERT(float, isnull(moistureTag.target_key1,0))  
  
 else ISNULL(substring(moistureTag.target_key1, 0, charindex('%',moistureTag.target_key1,0)-1),0) end   
 else isnull(tispec.spec_typical_val, 0) end as Moisture,  
  
 --isnull(moistureTag.target_key1, 0) as Moisture,  
  
 case item_type when 'W' then 0 else tidp.dry_qty end as DMT,  
  
 --isnull(franchiseTag.target_key1, 0) as Franchise,  
    case item_type when 'W' then   
 case charindex('%', franchiseTag.target_key1,0) when 0 then convert(float, isnull(franchiseTag.target_key1,0))  
  
 else ISNULL(substring(franchiseTag.target_key1, 0, charindex('%', franchiseTag.target_key1,0)-1),0) end  
 else tidp.franchise_charge end as Franchise,  
  
 ti.contr_qty as NDMT  
  
into #TIToReport  
  
from --trade_item ti  
  
#SelectedTI ti   
  
left outer join trade_item_dry_phy tidp  
on ti.trade_num = tidp.trade_num and ti.order_num=tidp.order_num and ti.item_num=tidp.item_num  
  
left outer join trade_item_spec tispec  
on ti.trade_num = tispec.trade_num and ti.order_num=tispec.order_num and ti.item_num=tispec.item_num and tispec.spec_code='MOISTURE'  
  
left outer join dbo.trade_order tor   
  
on ti.trade_num=tor.trade_num and ti.order_num=tor.order_num  
  
left outer join dbo.trade tr   
  
on tr.trade_num=ti.trade_num  
  
left outer join dbo.account a   
  
on a.acct_num=tr.acct_num  
  
left outer join dbo.account bc  
  
on bc.acct_num = ti.booking_comp_num  
  
left outer join dbo.commodity cmdty   
  
on cmdty.cmdty_code=ti.cmdty_code  
  
left outer join dbo.market mkt   
  
on mkt.mkt_code=ti.risk_mkt_code  
  
left outer join dbo.entity_tag wmtQtyTag   
  
on wmtQtyTag.key1=convert(varchar(17), ti.trade_num) and   
  
   wmtQtyTag.key2=convert(varchar(17), ti.order_num) and   
  
   wmtQtyTag.key3=convert(varchar(17), ti.item_num) and   
  
   wmtQtyTag.entity_tag_id = @WMTQtyETKey  
  
left outer join dbo.entity_tag moistureTag   
  
on moistureTag.key1=convert(varchar(17), ti.trade_num) and   
  
   moistureTag.key2=convert(varchar(17), ti.order_num) and   
  
   moistureTag.key3=convert(varchar(17), ti.item_num) and   
  
   moistureTag.entity_tag_id = @MoistureETKey  
  
left outer join dbo.entity_tag franchiseTag   
  
on franchiseTag.key1=convert(varchar(17), ti.trade_num) and  
  
franchiseTag.key2=convert(varchar(17), ti.order_num) and  
  
   franchiseTag.key3=convert(varchar(17), ti.item_num) and  
  
   franchiseTag.entity_tag_id = @FranchiseETKey  
  
  
  
if object_id('tempdb..#TIWithSpecReport', 'U') is not null  
  
   exec('drop table #TIWithSpecReport')  
  
  
  
-- add columns for trade item specification  
  
  
  
select ti1.*,  
  
       piv.[COPPER],  
  
       piv.[LEAD],  
  
       piv.[ZINC],  
  
       piv.[SILVER],  
  
       piv.[GOLD]  
  
into #TIWithSpecReport  
  
from #TIToReport ti1  
  
left outer join   
  
( select   
  
       ti.trade_num,  
  
       ti.order_num,  
  
       ti.item_num,  
  
       tis.spec_code,  
  
       tis.spec_typical_val  
  
  from #TIToReport ti  
  
       left outer join dbo.trade_item_spec tis   
  
       on tis.trade_num=ti.trade_num and   
  
          tis.order_num=ti.order_num and   
  
   tis.item_num=ti.item_num  
  
       left outer join dbo.trade_formula tf  
  
       on ti.trade_num=tf.trade_num and  
  
          ti.order_num=tf.order_num and  
  
   ti.item_num=tf.item_num  
  
       left outer join dbo.formula_component fc   
  
       on fc.formula_num=tf.formula_num and  
  
          fc.formula_comp_type='S'  
  
       left outer join fb_modular_info fbi   
  
       on fbi.formula_num=fc.formula_num and   
  
          fbi.formula_body_num=fc.formula_body_num and   
  
   fbi.pay_deduct_ind='P'  
  
  where tis.spec_code=fc.formula_comp_name )src  
  
pivot (max(spec_typical_val) for spec_code in ([COPPER],[LEAD],[ZINC],[SILVER],[GOLD])) piv  
  
on ti1.trade_num=piv.trade_num and  
  
   ti1.order_num=piv.order_num and  
  
   ti1.item_num=piv.item_num  
  
  
  
if object_id('tempdb..#TIWithRCTradeReport', 'U') is not null  
  
   exec('drop table #TIWithRCTradeReport')  
  
  
  
-- add columns for trade formula RC   
  
  
  
select ti1.*,   
  
       piv.[CuRfcUnit_Trade],   
  
       piv.[PbRfcUnit_Trade],  
  
       piv.[ZnRfcUnit_Trade],   
  
       piv.[AgRfcUnit_Trade],   
  
       piv.[AuRfcUnit_Trade]  
  
into #TIWithRCTradeReport  
  
from #TIWithSpecReport ti1  
  
left outer join   
  
(  
  
   select   
  
        ti.trade_num,   
  
 ti.order_num,   
  
 ti.item_num,  
  
 fc.formula_comp_name+'_Trade' as TradeRC,   
  
 fc.formula_comp_val  
  
from   
  
#TIWithSpecReport ti   
  
left outer join trade_formula tf  
  
on ti.trade_num=tf.trade_num and  
  
   ti.order_num=tf.order_num and   
  
   ti.item_num=tf.item_num and   
  
   tf.fall_back_ind='N'  
  
left join formula_component fc   
  
on fc.formula_num=tf.formula_num and   
  
   fc.formula_comp_name like '%RfcUnit' )src  
  
pivot (max(formula_comp_val) for TradeRC in ([CuRfcUnit_Trade], [PbRfcUnit_Trade],[ZnRfcUnit_Trade],[AgRfcUnit_Trade],[AuRfcUnit_Trade]))piv   
  
on ti1.trade_num=piv.trade_num and   
  
   ti1.order_num=piv.order_num and   
  
   ti1.item_num=piv.item_num  
  
  
  
  
  
if object_id('tempdb..#TIWithRCMktReport', 'U') is not null  
  
   exec('drop table #TIWithRCMktReport')  
  
  
  
-- add columns for market formula RC  
  
  
  
select ti1.*,  
  
       piv.[CuRfcUnit_Market],  
  
       piv.[PbRfcUnit_Market],  
  
       piv.[ZnRfcUnit_Market],  
  
       piv.[AgRfcUnit_Market],  
  
       piv.[AuRfcUnit_Market]  
  
into #TIWithRCMktReport  
  
from #TIWithRCTradeReport ti1  
  
left outer join   
  
(  
  
  select   
  
      ti.trade_num,   
  
      ti.order_num,   
  
      ti.item_num,  
  
      fc.formula_comp_name+'_Market' as TradeRC,   
  
      fc.formula_comp_val  
  
  from #TIWithRCTradeReport ti  
  
  left outer join trade_formula tf   
  
     on ti.trade_num=tf.trade_num and   
  
        ti.order_num=tf.order_num and   
  
 ti.item_num=tf.item_num and   
  
 tf.fall_back_ind='M'  
  
  left join dbo.formula_component fc   
  
     on fc.formula_num=tf.formula_num and   
  
        fc.formula_comp_name like '%RfcUnit' )src  
  
pivot  
  
(max(formula_comp_val) for TradeRC in ([CuRfcUnit_Market], [PbRfcUnit_Market],[ZnRfcUnit_Market],[AgRfcUnit_Market],[AuRfcUnit_Market]))piv   
  
on ti1.trade_num=piv.trade_num and  
  
   ti1.order_num=piv.order_num and  
  
   ti1.item_num=piv.item_num  
  
  
  
if object_id('tempdb..#TIWithTradePayPcntReport', 'U') is not null  
  
   exec('drop table #TIWithTradePayPcntReport')  
  
  
  
-- add trade payable percentage  
  
  
  
select ti1.*,   
  
       piv.[COPPER_TradePcnt],   
  
       piv.[LEAD_TradePcnt],   
  
       piv.[ZINC_TradePcnt],   
  
       piv.[SILVER_TradePcnt],   
  
       piv.[GOLD_TradePcnt]  
  
into #TIWithTradePayPcntReport  
  
from #TIWithRCMktReport ti1  
  
left outer join   
  
(  
  
   select   
  
        ti.trade_num,   
  
 ti.order_num,   
  
 ti.item_num,  
  
 RTRIM(fbi.basis_cmdty_code)+'_TradePcnt' as TradePayable,   
  
 fbi.price_pcnt_value  
  
   from #TIWithRCMktReport ti   
  
   left outer join dbo.trade_formula tf   
  
       on ti.trade_num=tf.trade_num and   
  
          ti.order_num=tf.order_num and   
  
   ti.item_num=tf.item_num and   
  
   tf.fall_back_ind='N'  
  
   left join dbo.fb_modular_info fbi   
  
       on fbi.formula_num=tf.formula_num and   
  
          fbi.pay_deduct_ind='P'  
  
)src  
  
pivot  
  
(max(price_pcnt_value) for TradePayable in ([COPPER_TradePcnt], [LEAD_TradePcnt],[ZINC_TradePcnt],[SILVER_TradePcnt],[GOLD_TradePcnt]))piv  
  
on ti1.trade_num=piv.trade_num and   
  
   ti1.order_num=piv.order_num and   
  
   ti1.item_num=piv.item_num  
  
  
  
if object_id('tempdb..#TIWithMarketPayPcntReport', 'U') is not null  
  
   exec('drop table #TIWithMarketPayPcntReport')  
  
  
  
-- add market price pcnt  
  
  
  
select ti1.*,  
  
       piv.[COPPER_MarketPcnt],  
  
       piv.[LEAD_MarketPcnt],  
  
       piv.[ZINC_MarketPcnt],  
  
       piv.[SILVER_MarketPcnt],  
  
       piv.[GOLD_MarketPcnt]  
  
into #TIWithMarketPayPcntReport  
  
from #TIWithTradePayPcntReport ti1  
  
left outer join  
  
(  
  
   select   
  
       ti.trade_num,  
  
       ti.order_num,  
  
       ti.item_num,  
  
       RTRIM(fbi.basis_cmdty_code)+'_MarketPcnt' as MarketPayable,  
  
       fbi.price_pcnt_value  
  
   from #TIWithTradePayPcntReport ti  
  
     left outer join dbo.trade_formula tf  
  
        on ti.trade_num=tf.trade_num and  
  
    ti.order_num=tf.order_num and  
  
    ti.item_num=tf.item_num and  
  
    tf.fall_back_ind='M'  
  
     left join fb_modular_info fbi  
  
        on fbi.formula_num=tf.formula_num and  
  
    fbi.pay_deduct_ind='P'  
  
)src  
  
pivot  
  
(max(price_pcnt_value) for MarketPayable in ([COPPER_MarketPcnt], [LEAD_MarketPcnt],[ZINC_MarketPcnt],[SILVER_MarketPcnt],[GOLD_MarketPcnt]))piv   
  
on ti1.trade_num=piv.trade_num and  
  
   ti1.order_num=piv.order_num and  
  
   ti1.item_num=piv.item_num  
  
  
  
  
  
if object_id('tempdb..#TIWithTreatmentChargeReport', 'U') is not null  
  
   exec('drop table #TIWithTreatmentChargeReport')  
  
  
  
-- add TC  
  
  
  
select ti1.*,   
  
       piv.[TC]  
  
into #TIWithTreatmentChargeReport  
  
from #TIWithMarketPayPcntReport ti1  
  
left outer join   
  
(  
  
   select   
  
      ti.trade_num,  
  
      ti.order_num,  
  
      ti.item_num,  
  
      fbi.basis_cmdty_code,   
  
      isnull(cpd.fb_value ,0) as charge  
  
   from #TIWithMarketPayPcntReport ti   
  
      left outer join dbo.trade_formula tf   
  
         on ti.trade_num=tf.trade_num and   
  
     ti.order_num=tf.order_num and   
  
     ti.item_num=tf.item_num and   
  
     tf.fall_back_ind='N'  
  
      left join dbo.fb_modular_info fbi   
  
         on fbi.formula_num=tf.formula_num and   
  
     fbi.pay_deduct_ind='P'  
  
      left outer join dbo.cost c   
  
         on c.cost_owner_key6=ti.trade_num and   
  
     cost_owner_key7=ti.order_num and   
  
     c.cost_owner_key8=ti.item_num and   
  
     c.cost_type_code in ('WPP', 'DPP') and   
  
     c.cost_owner_code='TI'  
  
      left outer join dbo.cost_price_detail cpd   
  
         on cpd.cost_num=c.cost_num and  
  
       cpd.formula_num = fbi.formula_num and   
  
     cpd.formula_body_num=fbi.formula_body_num  
  
    where fbi.basis_cmdty_code='TC'  
  
)src  
  
pivot  
  
(max(charge) for basis_cmdty_code in ([TC])) piv   
  
on ti1.trade_num=piv.trade_num and   
  
   ti1.order_num=piv.order_num and   
  
   ti1.item_num=piv.item_num  
  
  
  
if object_id('tempdb..#TIWithPenaltyReport', 'U') is not null  
  
   exec('drop table #TIWithPenaltyReport')  
  
  
  
--- add penaltyPL -- fix for mkt-trade and vice versa based on buy or sell  
  
  
  
select ti.*,  
  
       isnull(mktPenalty,0)-isnull(tradePenalty,0) as penaltyPL  
  
into #TIWithPenaltyReport  
  
from #TIWithTreatmentChargeReport ti  
  
left outer join  
  
( select ti1.trade_num,   
  
        ti1.order_num,   
  
 ti1.item_num,   
  
 sum(isnull(cpd.fb_value,0)) as tradePenalty  
  
  from #TIWithTreatmentChargeReport ti1  
  
      inner join dbo.cost c   
  
          on ti1.trade_num=c.cost_owner_key6 and   
  
      ti1.order_num=c.cost_owner_key7 and   
  
      ti1.item_num=c.cost_owner_key8 and   
  
      c.cost_owner_code='TI' and   
  
      c.cost_type_code in ('WPP', 'DPP')  
  
      inner join dbo.cost_price_detail cpd   
  
          on c.cost_num=cpd.cost_num  
  
      inner join dbo.fb_modular_info fbi   
  
      on fbi.formula_num=cpd.formula_num and   
  
         fbi.formula_body_num=cpd.formula_body_num and   
  
  fbi.pay_deduct_ind='D' and  fbi.basis_cmdty_code like 'PEN%' --  fbi.basis_cmdty_code <> 'TC'  
  
         group by ti1.trade_num, ti1.order_num, ti1.item_num) as tpenalty  
  
     on tpenalty.trade_num=ti.trade_num and   
  
        tpenalty.order_num=ti.order_num and   
  
 tpenalty.item_num=ti.item_num  
  
  left outer join  
  
  (  select ti2.trade_num,   
  
            ti2.order_num,   
  
     ti2.item_num,   
  
     sum(isnull(fbi.last_computed_value,0)) as mktPenalty  
  
    from #TIWithTreatmentChargeReport ti2   
  
      inner join dbo.trade_formula tf   
  
         on ti2.trade_num=tf.trade_num and   
  
     ti2.order_num=tf.order_num and   
  
     ti2.item_num=tf.item_num and   
  
     tf.fall_back_ind='M'  
  
      inner join dbo.fb_modular_info fbi   
  
        on fbi.formula_num=tf.formula_num and   
  
    fbi.pay_deduct_ind='D' and fbi.basis_cmdty_code like 'PEN%'   
  
        group by ti2.trade_num, ti2.order_num, ti2.item_num) mkt  
  
        on mkt.trade_num=ti.trade_num and   
  
    mkt.order_num=ti.order_num and   
  
    mkt.item_num=ti.item_num  
  
  
  
if object_id('tempdb..#TIWithRCTradeCompReport', 'U') is not null  
  
   exec('drop table #TIWithRCTradeCompReport')  
  
  
  
select ti1.*,  
  
       piv.[RCCU_Trade],  
  
       piv.[RCPB_Trade],  
  
       piv.[RCZN_Trade],  
  
       piv.[RCAG_Trade],  
  
       piv.[RCAU_Trade]  
  
into #TIWithRCTradeCompReport  
  
from #TIWithPenaltyReport ti1  
  
left outer join   
  
(  select ti.trade_num,   
  
          ti.order_num,   
  
   ti.item_num,RTRIM(fbi.basis_cmdty_code)+'_Trade' as RCCmdty,   
  
   (isnull(cpd.fb_value,0)) as RCAmt  
  
   from #TIWithPenaltyReport ti  
  
     inner join cost c   
  
         on ti.trade_num=c.cost_owner_key6 and   
  
     ti.order_num=c.cost_owner_key7 and   
  
     ti.item_num=c.cost_owner_key8 and   
  
     c.cost_owner_code='TI' and   
  
     c.cost_type_code in ('WPP', 'DPP')  
  
     inner join dbo.cost_price_detail cpd   
  
        on c.cost_num=cpd.cost_num  
  
     inner join dbo.fb_modular_info fbi   
  
        on fbi.formula_num=cpd.formula_num and   
  
    fbi.formula_body_num=cpd.formula_body_num and   
  
    fbi.pay_deduct_ind='D' and   
  
    fbi.basis_cmdty_code <>'TC' )src  
  
pivot  
  
(max(RCAmt) for RCCmdty in ([RCCU_Trade],[RCPB_Trade],[RCZN_Trade],[RCAG_Trade],[RCAU_Trade]))piv  
  
on ti1.trade_num=piv.trade_num and  
  
   ti1.order_num=piv.order_num and  
  
   ti1.item_num=piv.item_num  
  
  
  
if object_id('tempdb..#TIWithRCMktCompReport', 'U') is not null  
  
   exec('drop table #TIWithRCMktCompReport')  
  
  
  
select ti1.*,   
  
       piv.[RCCU_Market],   
  
       piv.[RCPB_Market],   
  
       piv.[RCZN_Market],   
  
       piv.[RCAG_Market],   
  
       piv.[RCAU_Market]  
  
into #TIWithRCMktCompReport  
  
from #TIWithRCTradeCompReport ti1  
  
left outer join   
  
(   select ti.trade_num,   
  
           ti.order_num,   
  
    ti.item_num,  
  
    RTRIM(fbi.basis_cmdty_code)+'_Market' as RCCmdty,   
  
    (isnull(fbi.last_computed_value,0)) as RCAmt  
  
    from #TIWithRCTradeCompReport ti   
  
       left outer join dbo.trade_formula tf   
  
            on ti.trade_num=tf.trade_num and   
  
        ti.order_num=tf.order_num and   
  
        ti.item_num=tf.item_num and   
  
        tf.fall_back_ind='M'  
  
       left outer join dbo.fb_modular_info fbi   
  
          on fbi.formula_num=tf.formula_num and  
  
          fbi.pay_deduct_ind='D' and   
  
      fbi.basis_cmdty_code<>'TC'  
  
)src  
  
pivot  
  
(max(RCAmt) for RCCmdty in ([RCCU_Market],[RCPB_Market],[RCZN_Market],[RCAG_Market],[RCAU_Market])) piv   
  
on ti1.trade_num=piv.trade_num and   
  
   ti1.order_num=piv.order_num and   
  
   ti1.item_num=piv.item_num  
  
  
  
if object_id('tempdb..#TIWithTotalPayablesRCReport', 'U') is not null  
  
   exec('drop table #TIWithTotalPayablesRCReport')  
  
  
  
select ti.*,  
  
       isnull(TradePayables,0) as TradePayables,   
  
       isnull(MarketPayables,0) as MarketPayables,  
  
       isnull(RCCU_Trade,0)+isnull(RCAG_Trade,0)+isnull(RCAU_Trade,0) as RC_Total_Trade,  
  
       isnull(RCCU_Market,0)+isnull(RCAG_Market,0)+isnull(RCAU_Market,0) as RC_Total_Market  
  
into #TIWithTotalPayablesRCReport  
  
from #TIWithRCMktCompReport ti  
  
left outer join  
  
(  select ti1.trade_num,   
  
          ti1.order_num,   
  
   ti1.item_num,   
  
   sum(isnull(cpd.fb_value,0)) as TradePayables  
  
   from #TIWithRCMktCompReport ti1   
  
      inner join dbo.cost c   
  
          on ti1.trade_num=c.cost_owner_key6 and   
  
      ti1.order_num=c.cost_owner_key7 and   
  
      ti1.item_num=c.cost_owner_key8 and   
  
      c.cost_owner_code='TI' and   
  
      c.cost_type_code in ('WPP','DPP')  
  
      inner join dbo.cost_price_detail cpd   
  
         on c.cost_num=cpd.cost_num  
  
      inner join dbo.fb_modular_info fbi   
  
         on fbi.formula_num=cpd.formula_num and   
  
     fbi.formula_body_num=cpd.formula_body_num and   
  
     fbi.pay_deduct_ind='P' and   
  
     fbi.basis_cmdty_code <>'TC'  
  
            group by ti1.trade_num, ti1.order_num, ti1.item_num) as tradePayables  
  
 on tradePayables.trade_num=ti.trade_num and tradePayables.order_num=ti.order_num and tradePayables.item_num=ti.item_num  
  
      left outer join (select ti2.trade_num, ti2.order_num, ti2.item_num, sum(isnull(fbi.last_computed_value,0)) as MarketPayables  
  
   from #TIWithRCMktCompReport ti2   
  
   inner join trade_formula tf   
  
        on ti2.trade_num=tf.trade_num and   
  
    ti2.order_num=tf.order_num and   
  
    ti2.item_num=tf.item_num and   
  
    tf.fall_back_ind='M'  
  
   inner join dbo.fb_modular_info fbi   
  
       on fbi.formula_num=tf.formula_num and  
  
   fbi.pay_deduct_ind='P' and   
  
   fbi.basis_cmdty_code<>'TC'  
  
       group by ti2.trade_num, ti2.order_num, ti2.item_num) mkt  
  
     on mkt.trade_num=ti.trade_num and   
  
        mkt.order_num=ti.order_num and   
  
 mkt.item_num=ti.item_num  
  
  
  
if object_id('tempdb..#TIWithTradePriceReport', 'U') is not null  
  
   exec('drop table #TIWithTradePriceReport')  
  
  
  
select ti1.*,  
  
       piv.[FREIGHT_UnitPrice],   
  
       piv.[RESERVE COST_UnitPrice],   
  
       piv.[HANDLING FEE_UnitPrice],   
  
       piv.[OPERATIONAL FEE_UnitPrice],  
  
       piv.Other_UnitPrice,  
  
       isnull(ti1.MarketPayables,0)-isnull(TradePayables,0) + (isnull(RC_Total_Market,0) - isnull(RC_Total_Trade,0))  
  
          - isnull(TC,0) - isnull([FREIGHT_UnitPrice],0) - isnull([RESERVE COST_UnitPrice],0) - isnull([HANDLING FEE_UnitPrice],0)  
  
          - isnull([OPERATIONAL FEE_UnitPrice],0) - isnull([Other_UnitPrice],0) as TradePrice  
  
into #TIWithTradePriceReport  
  
from #TIWithTotalPayablesRCReport ti1   
  
left outer join  
  
(  select ti.trade_num,   
  
          ti.order_num,   
  
   ti.item_num,  
  
   RTRIM(cmdty.cmdty_short_name) +'_UnitPrice' as secCostCode,   
  
          --signed unit price case cost_pay_rec_ind when 'P' then -c.cost_unit_price else c.cost_unit_price end as costUnitPrice  
  
          c.cost_unit_price  as costUnitPrice  
  
   from #TIWithTotalPayablesRCReport ti   
  
      left outer join dbo.cost c   
  
          on c.cost_owner_key6=ti.trade_num and   
  
      c.cost_owner_key7=ti.order_num and   
  
      c.cost_owner_key8=ti.item_num  
  
      left outer join dbo.commodity cmdty   
  
          on cmdty.cmdty_code=c.cost_code  
  
      where cost_owner_code='TI' and cost_type_code not in ('WPP','DPP') and cost_status<>'CLOSED'  
  
 union  
  
   select ti.trade_num,   
  
          ti.order_num,   
  
   ti.item_num,  
  
   'Other_UnitPrice' as secCostCode,   
  
          --signed unit price case cost_pay_rec_ind when 'P' then -c.cost_unit_price else c.cost_unit_price end as costUnitPrice  
  
          sum(isnull(c.cost_unit_price,0))  as costUnitPrice  
  
   from #TIWithTotalPayablesRCReport ti   
  
     left outer join dbo.cost c   
  
         on c.cost_owner_key6=ti.trade_num and   
  
     c.cost_owner_key7=ti.order_num and   
  
     c.cost_owner_key8=ti.item_num  
  
     left outer join dbo.commodity cmdty   
  
        on cmdty.cmdty_code=c.cost_code  
  
        where cost_owner_code='TI' and   
  
       cost_type_code not in ('WPP','DPP') and   
  
       cost_status<>'CLOSED' and   
  
       cost_code not in ('FREIGHT', 'RESERVE COST', 'HANDLING FEE', 'OPERATIONAL FEE')  
  
        group by ti.trade_num, ti.order_num, ti.item_num  
  
)src  
  
pivot  
  
(max(costUnitPrice) for secCostCode in ([FREIGHT_UnitPrice],[RESERVE COST_UnitPrice],[HANDLING FEE_UnitPrice], [OPERATIONAL FEE_UnitPrice],[Other_UnitPrice]   
  
--[ASSAY FEE_UnitPrice], [INSPECTION FEE_UnitPrice], [VAT RF PERU_UnitPrice], [VAT DET PERU_UnitPrice],[VAT RF MEXICO_UnitPrice],[BANK COMM_UnitPrice], [INTERCO BANKCHG_UnitPrice]  
  
))piv   
  
on ti1.trade_num=piv.trade_num and   
  
   ti1.order_num=piv.order_num and   
  
   ti1.item_num=piv.item_num  
  
  
  
if object_id('tempdb..#TIWithMarketPriceReport', 'U') is not null  
  
   exec('drop table #TIWithMarketPriceReport')  
  
  
  
-- lookup PRICE -- no prices in DB so hardcoding...  
  
  
  
select ti.*,   
  
       isnull(pr.avg_closed_price, 0) as MarketPrice  
  
into #TIWithMarketPriceReport  
  
from #TIWithTradePriceReport ti  
  
inner join dbo.trade_order tor   
  
   on tor.trade_num=ti.trade_num and   
  
      tor.order_num=ti.order_num and   
  
      tor.strip_summary_ind='N'  
  
left outer join trade_item_dist tid   
  
   on ti.trade_num=tid.trade_num and   
  
      ti.order_num=tid.order_num and   
  
      ti.item_num=tid.item_num and   
  
      tid.dist_type='D' and   
  
      is_equiv_ind='N'  
  
left outer join position p   
  
   on p.pos_num=tid.pos_num  
  
left outer join commodity_market cmkt   
  
   on cmkt.commkt_key=p.commkt_key  
  
left outer join price pr   
  
   on pr.commkt_key=p.commkt_key and   
  
   (pr.trading_prd=p.trading_prd or pr.trading_prd='SPOT') and   
  
   pr.price_source_code=cmkt.mtm_price_source_code  
  
and pr.price_quote_date = (select MAX(price_quote_date) from price p2  
  
where p2.commkt_key=pr.commkt_key and p2.trading_prd=pr.trading_prd and p2.price_source_code=pr.price_source_code  
  
and p2.price_quote_date < getdate())  
  
  
  
if object_id('tempdb..#TIWithEscalatorPriceReport', 'U') is not null  
  
   exec('drop table #TIWithEscalatorPriceReport')  
  
  
  
select ti1.*,  
  
       piv.[CopperBasisPrice],  
  
       piv.[CopperEscIncBy],   
  
       piv.[CopperScale],   
  
       piv.[LeadBasisPrice],   
  
       piv.[LeadEscIncBy],   
  
       piv.[LeadScale],  
  
       piv.[ZincBasisPrice],   
  
       piv.[ZincEscIncBy],   
  
       piv.[ZincScale],   
  
       piv.[SilverBasisPrice],   
  
       piv.[SilverEscIncBy],   
  
       piv.[SilverScale],  
  
       piv.[GoldBasisPrice],   
  
       piv.[GoldEscIncBy],   
  
       piv.[GoldScale]  
  
into #TIWithEscalatorPriceReport  
  
from #TIWithMarketPriceReport ti1   
  
left outer join  
  
(  select ti.trade_num,  
  
          ti.order_num,  
  
   ti.item_num,  
  
          substring(fc.formula_comp_name,0,CHARINDEX('BasisPrice',fc.formula_comp_name,0)+CHARINDEX('BasePrice',fc.formula_comp_name,0))  
  
              + 'BasisPrice' as compName,   
  
          fc.formula_comp_val as compVal  
  
   from #TIWithMarketPriceReport ti   
  
       left outer join trade_formula tf   
  
            on ti.trade_num= tf.trade_num and   
  
        ti.order_num=tf.order_num and   
  
        ti.item_num=tf.item_num and   
  
        tf.fall_back_ind='N'  
  
       left outer join dbo.formula_component fc   
  
            on fc.formula_num=tf.formula_num  
  
       left outer join dbo.fb_modular_info fbi   
  
            on fbi.formula_num=fc.formula_num and   
  
        fbi.formula_body_num=fc.formula_body_num  
  
            where fbi.basis_cmdty_code='ESCALATR' and   
  
     (fc.formula_comp_name like '%BasisPrice'  or fc.formula_comp_name like '%BasePrice')  
  
  union  
  
   select ti.trade_num,  
  
          ti.order_num,  
  
   ti.item_num,  
  
          substring(fc2.formula_comp_name,0,CHARINDEX('BasisPrice',fc2.formula_comp_name,0)+CHARINDEX('BasePrice',fc2.formula_comp_name,0))  
  
                + fc.formula_comp_name as compName, fc.formula_comp_val as compVal  
  
   from #TIWithMarketPriceReport ti   
  
       left outer join dbo.trade_formula tf   
  
            on ti.trade_num= tf.trade_num and   
  
        ti.order_num=tf.order_num and   
  
        ti.item_num=tf.item_num and   
  
        tf.fall_back_ind='N'  
  
       left outer join dbo.formula_component fc   
  
            on fc.formula_num=tf.formula_num  
  
       left outer join dbo.fb_modular_info fbi   
  
            on fbi.formula_num=fc.formula_num and   
  
        fbi.formula_body_num=fc.formula_body_num  
  
       left outer join formula_component fc2   
  
            on fc2.formula_num=fbi.formula_num and   
  
        fc2.formula_body_num=fbi.formula_body_num and   
  
        (fc2.formula_comp_name like '%BasisPrice'  or fc2.formula_comp_name like '%BasePrice')  
  
           where fbi.basis_cmdty_code='ESCALATR' and   
  
          fc.formula_comp_name = 'EscIncBy'  
  
 union  
  
   select ti.trade_num,  
  
          ti.order_num,  
  
   ti.item_num,  
  
          substring(fc2.formula_comp_name,0,CHARINDEX('BasisPrice',fc2.formula_comp_name,0)+CHARINDEX('BasePrice',fc2.formula_comp_name,0))  
  
              +'Scale' as compName,  
  
          cpd.fb_value as comp_value  
  
   from #TIWithMarketPriceReport ti  
  
     inner join dbo.cost c   
  
          on c.cost_owner_key1=ti.trade_num and   
  
      c.cost_owner_key2=ti.order_num and   
  
      c.cost_owner_key3=ti.item_num and   
  
      c.cost_owner_code='TI' and   
  
      c.cost_type_code in ('WPP','DPP')  
  
     left outer join cost_price_detail cpd   
  
          on c.cost_num=cpd.cost_num   
  
     inner join fb_modular_info fbi   
  
          on fbi.formula_num=cpd.formula_num and   
  
      fbi.formula_body_num=cpd.formula_body_num and   
  
      fbi.basis_cmdty_code='ESCALATR'  
  
     left outer join formula_component fc2   
  
          on fc2.formula_num=fbi.formula_num and   
  
      fc2.formula_body_num=fbi.formula_body_num and   
  
      (fc2.formula_comp_name like '%BasisPrice'  or fc2.formula_comp_name like '%BasePrice')  
  
) src  
  
pivot  
  
(max(compVal) for compName in ([CopperBasisPrice],[CopperEscIncBy],[CopperScale], [LeadBasisPrice],[LeadEscIncBy],[LeadScale],  
  
[ZincBasisPrice],[ZincEscIncBy],[ZincScale], [SilverBasisPrice],[SilverEscIncBy],[SilverScale],  
  
[GoldBasisPrice],[GoldEscIncBy],[GoldScale]))piv   
  
on ti1.trade_num=piv.trade_num and   
  
   ti1.order_num=piv.order_num and   
  
   ti1.item_num=piv.item_num  
  
  
  
if object_id('tempdb..#TIWithQPeriodsPriceReport', 'U') is not null  
  
   exec('drop table #TIWithQPeriodsPriceReport')  
  
  
  
select ti1.*,  
  
       piv.[CuPqQP1],   
  
       piv.[LeadPqQP1],   
  
       piv.[ZnPqQP1],   
  
       piv.[AgPqQP1],   
  
       piv.[AuPqQP1]  
  
into #TIWithQPeriodsPriceReport  
  
from #TIWithEscalatorPriceReport ti1   
  
left outer join  
  
( select ti.trade_num,   
  
         ti.order_num,   
  
  ti.item_num,   
  
         fc.formula_comp_name + 'QP1' as qp1,   
  
         tprd.trading_prd_desc as QP  
  
 from #TIWithEscalatorPriceReport ti   
  
    left outer join trade_formula tf   
  
        on ti.trade_num= tf.trade_num and   
  
    ti.order_num=tf.order_num and   
  
    ti.item_num=tf.item_num and   
  
    tf.fall_back_ind='N'  
  
    left outer join formula_component fc   
  
        on fc.formula_num=tf.formula_num  
  
    left outer join fb_modular_info fbi   
  
        on fbi.formula_num=fc.formula_num and   
  
    fbi.formula_body_num=fc.formula_body_num  
  
    left outer join trading_period tprd   
  
        on tprd.commkt_key=fc.commkt_key and   
  
    tprd.trading_prd=fc.trading_prd  
  
        where fbi.pay_deduct_ind='P' and fc.formula_comp_type='G'  
  
)src  
  
pivot  
  
( max(QP) for qp1 in ([CuPqQP1], [LeadPqQP1], [ZnPqQP1], [AgPqQP1], [AuPqQP1]))piv   
  
on ti1.trade_num=piv.trade_num and   
  
   ti1.order_num=piv.order_num and   
  
   ti1.item_num=piv.item_num  
  
  
  
if object_id('tempdb..#TIWithQuotePriceReport', 'U') is not null  
  
   exec('drop table #TIWithQuotePriceReport')  
  
  
  
select ti1.*,  
  
       piv.[CuPq-Price],   
      
       piv.[LeadPq-Price],   
      
       piv.[ZnPq-Price],   
      
       piv.[AgPq-Price],   
      
       piv.[AuPq-Price]  
      
into #TIWithQuotePriceReport   
  
from #TIWithQPeriodsPriceReport ti1   
  
left outer join  
  
( select ti.trade_num,   
  
         ti.order_num,   
     
  ti.item_num,   
    
         fc.formula_comp_name +'-Price' as QP,   
     
        case fbi.price_pcnt_value when 0 then 0  
        else (isnull(cpd.unit_price, 0)*100.0/isnull(fbi.price_pcnt_value,1)) end as quotePrice  
     
  from #TIWithQPeriodsPriceReport ti   
    
     left outer join trade_formula tf   
    
        on ti.trade_num= tf.trade_num and   
    
    ti.order_num=tf.order_num and   
      
    ti.item_num=tf.item_num and   
      
    tf.fall_back_ind='N'  
      
     left outer join formula_component fc   
    
        on fc.formula_num=tf.formula_num  
    
     left outer join fb_modular_info fbi   
    
        on fbi.formula_num=fc.formula_num and   
    
    fbi.formula_body_num=fc.formula_body_num  
      
     left outer join dbo.cost c   
    
          on c.cost_owner_key1=ti.trade_num and   
      
      c.cost_owner_key2=ti.order_num and   
     
      c.cost_owner_key3=ti.item_num and   
     
      c.cost_owner_code='TI' and   
     
      c.cost_type_code in ('WPP', 'DPP')  
     
     left outer join cost_price_detail cpd   
    
          on c.cost_num=cpd.cost_num and cpd.formula_num=fbi.formula_num and cpd.formula_body_num=fbi.formula_body_num  
      
        where fbi.pay_deduct_ind='P' and fc.formula_comp_type='G'  
    
)src  
  
pivot  
  
(max(quotePrice) for QP in ([CuPq-Price], [LeadPq-Price], [ZnPq-Price], [AgPq-Price], [AuPq-Price]))piv   
  
on ti1.trade_num=piv.trade_num and   
  
   ti1.order_num=piv.order_num and   
     
   ti1.item_num=piv.item_num  
   
 if object_id('tempdb..#tiAllocStatus', 'U') is not null  
  
   exec('drop table #tiAllocStatus');  
  
   
with allAllocStatus as  
(  
select ai.trade_num, ai.order_num, ai.item_num, ai.alloc_num, convert(varchar(10),ai.alloc_num) + ':' +  
case fully_actualized when 'Y' then 'fullyAct' else   
case alloc_status when 'C' then 'scheduled' else 'allocated' end end as allocStatus  
from  
#TIWithQuotePriceReport ti   
inner join allocation_item ai on ti.trade_num=ai.trade_num and ti.order_num=ai.order_num and ti.item_num=ai.item_num  
inner join allocation a on a.alloc_num=ai.alloc_num   
)  
select trade_num, order_num, item_num,  
SUBSTRING(( select '/' + a1.allocStatus  
from allAllocStatus a1 where a1.trade_num=a2.trade_num  
and a1.order_num=a2.order_num and a1.item_num=a2.item_num  
 for XML PATH('') ) ,2,200000) as fullStatus  
into #tiAllocStatus  
from allAllocStatus a2  
group by trade_num, order_num, item_num  
  
  
select ti.*,   
  
       (isnull(MarketPrice,0)-isnull(TradePrice,0))* ISNULL(ti.NDMT,1) as MTM,  
  
       isnull(TradePayables,0) + isnull(RC_Total_Trade,0)*(1- isnull(Franchise,0)/100.0) -isnull(TC,0) as Conc_Value,   
  
       -isnull(TC,0) - isnull(RC_Total_Trade,0)  as Deductibles,  
  
       (isnull(TradePayables,0) + isnull(RC_Total_Trade,0)*(1- isnull(Franchise,0)/100.0)  -isnull(TC,0))*isnull(NDMT,0) as NotionalValue,  
  
        case ((1- isnull(Franchise,0)/100.0)*isnull(NDMT,1))   
  
          when 0 then (isnull(MarketPrice,0)-isnull(TradePrice,0))   
  
                 else (isnull(MarketPrice,0)-isnull(TradePrice,0))* ISNULL(ti.NDMT,1) /((1- isnull(Franchise,0)/100.0)*isnull(NDMT,1)) end as USD_per_DMT,  
  
    case ti.item_type when 'W' then  
       convert(varchar(12), dateadd( DD, datediff(dd, tiwp.del_date_from, tiwp.del_date_to)/2-1, tiwp.del_date_from),106)  
    else   
    convert(varchar(12), dateadd( DD, datediff(dd, tidp.del_date_from, tidp.del_date_to)/2-1, tidp.del_date_from),106)  
    end as DeliveryMonth,  
      
    ais.fullStatus as fullAllocStatus  
  
from #TIWithQuotePriceReport  ti  
  
left outer join dbo.trade_item_wet_phy tiwp   
  
on tiwp.trade_num=ti.trade_num and   
  
   tiwp.order_num=ti.order_num and   
  
   tiwp.item_num=ti.item_num  
  
left outer join dbo.trade_item_dry_phy tidp   
  
on tidp.trade_num=ti.trade_num and   
  
   tidp.order_num=ti.order_num and   
  
   tidp.item_num=ti.item_num  
     
left outer join #tiAllocStatus ais on ti.trade_num = ais.trade_num and ti.order_num=ais.order_num and ti.item_num=ais.item_num  
  
order by ti.trade_num, ti.order_num, ti.item_num  

GO
GRANT EXECUTE ON  [dbo].[usp_mercuria_conc_m2m_report] TO [next_usr]
GO
