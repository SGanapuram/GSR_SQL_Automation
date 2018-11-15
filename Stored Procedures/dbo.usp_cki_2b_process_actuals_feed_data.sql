SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[usp_cki_2b_process_actuals_feed_data]      
@workingGuid varchar(40)      
as            
set nocount on      
declare @JDEetId int      
      
-- entity_tag INTERNAL      
      
select @JDEetId = isnull(etd.oid,-1)      
from entity_tag_definition etd      
where entity_tag_name='JDE'       
 and entity_id in (select entity_id       
 from icts_entity_name       
 where entity_name='TradeItem')      
      
  
-- first update the internal sale parcel in the table      
      
if object_id('tempdb..#delParcels') is not null        
 drop table #delParcels       
      
select cki.record_id as recId,      
 p.shipment_num as shipNum,      
 p.oid as deliveryParcel,      
 null as receiptParcel      
into #delParcels       
from cki_upload_actuals_feed_data cki      
  inner join       
  parcel p      
  on cki.cmdty_code=p.cmdty_code       
  --and cki.loc_code=p.location_code      
   inner join       
   allocation_item ai      
   on p.alloc_num=ai.alloc_num       
   and p.alloc_item_num=ai.alloc_item_num      
    inner join       
    entity_tag et      
    on et.entity_tag_id=@JDEetId       
    and et.key1=convert(varchar(17),ai.trade_num)      
    and et.key2=convert(varchar(17),ai.order_num)       
    and et.key3=convert(varchar(17),ai.item_num)       
    and et.target_key1='INTERNAL'      
     inner join       
     trade trd      
     on trd.trade_num=ai.trade_num      
  inner join trade_item ti on ti.trade_num=convert(varchar(17),ai.trade_num)      
    and ti.order_num=convert(varchar(17),ai.order_num)       
    and ti.item_num =convert(varchar(17),ai.item_num)   
    --and ti.item_type = 'W' ADSO-8695  
      inner join       
      account act      
      on act.acct_num=trd.acct_num      
    where cki.guid=@workingGuid       
     and error is null      
     and cki.cp_short_name = act.acct_short_name      
     and datediff (dd,cki.actual_date,ai.nomin_date_from) <=0      
     and datediff(dd,cki.actual_date,ai.nomin_date_to) >=0      
     and p.type='D'      
     and cki.loc_code= case when cki.record_type = 'F'
								then ai.load_port_loc_code
							else p.location_code
							end
							
-- update error for which no parcel found      
update cki_upload_actuals_feed_data       
set error='No delivery parcel found.'       
from cki_upload_actuals_feed_data cki      
where cki.guid=@workingGuid       
 and cki.error is null       
 and not exists (select 1 from #delParcels dp where dp.recId=cki.record_id)      
      
-- update error message for the ones with multiple parcels      
      
update cki_upload_actuals_feed_data       
set error='Multiple delivery parcels found: '+delParcels       
from cki_upload_actuals_feed_data cki      
  inner join       
  (select distinct ST2.recId,      
   (select convert(varchar(8),ST1.deliveryParcel) + ',' as [text()]      
   from #delParcels ST1      
   where recId in (select recId       
    from #delParcels       
    group by recId      
    having (count(*) > 1)    )       
    and ST1.recId = ST2.recId      
   order by recId      
   for xml PATH ('')) [delParcels]      
  from #delParcels ST2) [Main]      
  on [Main].recId = cki.record_id       
  and cki.guid=@workingGuid       
  and error is null      
      
-- remove rows from #delParcels which have multiple parcels      
      
delete #delParcels       
where recId in (select recId       
 from #delParcels       
 group by recId      
 having (count(*) > 1))      
      
-- check if the sale parcel found is fully_actualized, then update error message      
      
update cki_upload_actuals_feed_data       
set error='Delivery parcel '+convert(varchar(8),fullActParcel.deliveryParcel) +' is fully actualized.'       
from cki_upload_actuals_feed_data cki      
  inner join       
  (select dp.recId,      
   dp.deliveryParcel,      
   ai.fully_actualized      
  from cki_upload_actuals_feed_data cki      
    inner join       
    #delParcels dp      
    on cki.record_id=dp.recId      
     inner join       
     parcel p      
     on p.oid=dp.deliveryParcel      
      inner join       
      allocation_item ai      
      on p.alloc_num=ai.alloc_num       
      and p.alloc_item_num=ai.alloc_item_num      
    where cki.guid=@workingGuid       
     and error is null      
     and ai.fully_actualized='Y') fullActParcel      
    on fullActParcel.recId=cki.record_id      
  where cki.guid=@workingGuid       
   and error is null      
      
      
-- remove rows from #delParcels which have errors      
      
delete #delParcels       
where recId in (select record_id       
 from cki_upload_actuals_feed_data       
 where guid=@workingGuid       
  and error is not null)      
      
-- check if an actual exists(has same actual_date as the record being loaded), and if so, then its cost is not vouched      
      
update cki_upload_actuals_feed_data       
set error='Delivery parcel ' +convert(varchar(8),vouchedCost.deliveryParcel) +' has cost '       
+ convert(varchar(10),vouchedCost.cost_num) + ' on actual num '       
+ convert(varchar(10),vouchedCost.ai_est_actual_num) + 'for date: '       
+ convert(varchar(15),vouchedCost.ai_est_actual_date,106) + ' which is ' + vouchedCost.cost_status + '.'       
from cki_upload_actuals_feed_data cki      
  inner join       
  (select dp.recId,      
   dp.deliveryParcel,      
   c.cost_num,      
   c.cost_type_code,      
   aa.ai_est_actual_num,      
   aa.ai_est_actual_date,      
   c.cost_status      
  from #delParcels dp      
    inner join       
    cki_upload_actuals_feed_data cki      
    on cki.record_id=dp.recId      
     inner join       
     parcel p      
     on p.oid=dp.deliveryParcel      
      inner join       
      ai_est_actual aa      
      on aa.alloc_num = p.alloc_num       
      and aa.alloc_item_num=p.alloc_item_num       
      and aa.ai_est_actual_date=cki.actual_date      
       inner join       
       cost c      
       on c.cost_owner_key1=aa.alloc_num       
       and c.cost_owner_key2=aa.alloc_item_num       
       and c.cost_owner_key3=aa.ai_est_actual_num      
       and c.cost_type_code in ('WPP','DPP')      
     where cki.guid=@workingGuid       
      and cki.error is null      
      and aa.ai_est_actual_num > 0       
      and cost_owner_code='AA'       
      and c.cost_status in ('VOUCHED','PAID')) vouchedCost      
     on vouchedCost.recId=cki.record_id      
   where cki.guid=@workingGuid       
    and error is null      
      
-- remove rows from #delParcels which have errors      
      
delete #delParcels       
where recId in (select record_id       
 from cki_upload_actuals_feed_data       
 where guid=@workingGuid       
  and error is not null)      
      
-- look for receipt parcel with the same shipment      
      
if object_id('tempdb..#rcptParcels') is not null        
 drop table #rcptParcels      
      
select dp.recId,      
 dp.shipNum,      
 p.oid as reciptParcel      
into #rcptParcels       
from #delParcels dp      
  inner join       
  parcel p      
  on p.shipment_num=dp.shipNum      
   inner join       
   cki_upload_actuals_feed_data cki      
   on cki.record_id=dp.recId      
    inner join       
    allocation_item ai      
    on p.alloc_num=ai.alloc_num       
    and p.alloc_item_num=ai.alloc_item_num      
     --inner join #ADSO-8695      
     --entity_tag et #ADSO-8695     
     --on et.entity_tag_id=@JDEetId #ADSO-8695      
     --and et.key1=convert(varchar(17),ai.trade_num) #ADSO-8695     
     --and et.key2=convert(varchar(17),ai.order_num) #ADSO-8695      
     --and et.key3=convert(varchar(17),ai.item_num) #ADSO-8695      
     --and et.target_key1='INTERNAL' #ADSO-8695     
      --inner join     trade trd    on trd.trade_num=ai.trade_num        
   --inner join     account act    on act.acct_num=trd.acct_num      
     where cki.guid=@workingGuid       
      and error is null      
    --  and p.cmdty_code=cki.cmdty_code       
    --and p.location_code=cki.loc_code      
    -- and cki.cp_short_name = act.acct_short_name      
    --  and datediff (dd,cki.actual_date,ai.nomin_date_from) <=0      
    --  and datediff(dd,cki.actual_date,ai.nomin_date_to) >=0      
      and p.type='R'      
      
-- update error for which no parcel found      
      
update cki_upload_actuals_feed_data set error='Delivery parcel '       
+ convert(varchar(8),dp.deliveryParcel)   
+ ', but no receipt parcel found on shipment '      
+ convert(varchar(8), dp.shipNum) + '.'      
from cki_upload_actuals_feed_data cki       
inner join #delParcels dp on dp.recId = cki.record_id      
where cki.guid=@workingGuid and cki.error is null and       
not exists (select 1 from #rcptParcels rp where rp.recId=dp.recId)      
      
/*      
update #delParcels set receiptParcel=rp.oid      
from #delParcels dp      
inner join      
(select dp.recId, p.oid      
from #delParcels dp      
inner join parcel p on p.shipment_num=dp.shipNum      
inner join cki_upload_actuals_feed_data cki on cki.record_id=dp.recId      
left outer join allocation_item ai on p.alloc_num=ai.alloc_num and p.alloc_item_num=ai.alloc_item_num      
left outer join trade trd on trd.trade_num=ai.trade_num       
left outer join account act on act.acct_num=trd.acct_num      
where cki.guid=@workingGuid and error is null      
and p.type='R' and p.cmdty_code=cki.cmdty_code and p.location_code=cki.loc_code      
and cki.cp_short_name = act.acct_short_name      
and datediff (dd,cki.actual_date, ai.nomin_date_from) <=0      
and datediff(dd, cki.actual_date, ai.nomin_date_to) >=0) rp on rp.recId=dp.recId      
*/      
      
-- update error message for the ones with multiple receipt parcels      
      
update cki_upload_actuals_feed_data       
set error='Multiple receipt parcels found: '+rcptParcels       
from cki_upload_actuals_feed_data cki      
  inner join       
  (select distinct ST2.recId,      
   (select convert(varchar(8),ST1.reciptParcel) + ',' as [text()]      
   from #rcptParcels ST1      
   where recId in (select recId       
    from #rcptParcels       
    group by recId      
    having (count(*) > 1))       
    and ST1.recId = ST2.recId      
   order by recId      
   for xml PATH ('')  ) [rcptParcels]      
  from #rcptParcels ST2) [Main]      
  on [Main].recId = cki.record_id       
  and cki.guid=@workingGuid       
  and error is null      
      
-- remove rows from #rcptParcels which have multiple parcels      
      
delete #rcptParcels        
where recId in (select recId       
 from #rcptParcels       
 group by recId      
 having (count(*) > 1))      
      
-- check if the receipt parcel is fully_actualized, and add error message      
      
update cki_upload_actuals_feed_data       
set error='Receipt parcel '+convert(varchar(8),fullActParcel.reciptParcel) +' is fully actualized.'        
from cki_upload_actuals_feed_data cki      
  inner join       
  (select rp.recId,      
   rp.reciptParcel,      
   ai.fully_actualized      
  from cki_upload_actuals_feed_data cki      
    inner join       
    #rcptParcels rp      
    on cki.record_id=rp.recId      
     inner join       
     parcel p      
     on p.oid=rp.reciptParcel      
      inner join       
      allocation_item ai      
      on p.alloc_num=ai.alloc_num       
      and p.alloc_item_num=ai.alloc_item_num      
    where cki.guid=@workingGuid       
     and error is null      
     and ai.fully_actualized='Y') fullActParcel      
    on fullActParcel.recId=cki.record_id      
  where cki.guid=@workingGuid       
   and error is null      
      
      
      
-- remove rows from #delParcels which have errors      
delete #rcptParcels       
where recId in  (select record_id       
 from cki_upload_actuals_feed_data       
 where guid=@workingGuid       
  and error is not null)      
      
      
-- check if an actual exists (has same actual_date as the record being loaded), and if so, then its cost is not vouched      
      
update cki_upload_actuals_feed_data       
set error='Receipt parcel '+convert(varchar(8),vouchedCost.reciptParcel) +' has cost '  + convert(varchar(10),      
vouchedCost.cost_num) + ' on actual num ' + convert(varchar(10),vouchedCost.ai_est_actual_num)  + 'for date: ' + convert(varchar(15),      
vouchedCost.ai_est_actual_date,106) + ' which is ' + vouchedCost.cost_status + '.'        
from cki_upload_actuals_feed_data cki      
  inner join       
  ( select rp.recId,      
   rp.reciptParcel,      
   c.cost_num,      
   c.cost_type_code,      
   aa.ai_est_actual_num,      
   aa.ai_est_actual_date,      
   c.cost_status      
  from #rcptParcels rp      
    inner join       
    cki_upload_actuals_feed_data cki      
    on cki.record_id=rp.recId      
     inner join       
     parcel p      
     on p.oid=rp.reciptParcel      
      inner join       
      ai_est_actual aa      
      on aa.alloc_num = p.alloc_num       
      and aa.alloc_item_num=p.alloc_item_num       
      and aa.ai_est_actual_date=cki.actual_date      
       inner join       
       cost c      
       on c.cost_owner_key1=aa.alloc_num       
       and c.cost_owner_key2=aa.alloc_item_num       
       and c.cost_owner_key3=aa.ai_est_actual_num       
       and c.cost_type_code in ('WPP','DPP')      
     where cki.guid=@workingGuid       
      and cki.error is null      
      and aa.ai_est_actual_num > 0       
      and cost_owner_code='AA'       
      and c.cost_status in ('VOUCHED','PAID') ) vouchedCost      
     on vouchedCost.recId=cki.record_id      
   where cki.guid=@workingGuid       
    and error is null      
      
-- remove rows from #delParcels which have errors      
      
delete #rcptParcels       
where recId in  (select record_id       
 from cki_upload_actuals_feed_data       
 where guid=@workingGuid       
  and error is not null)      
      
      
-- update the internal delivery and receipt parcel data      
      
update cki_upload_actuals_feed_data   set internal_del_parcel_id=dp.deliveryParcel,internal_rpt_parcel_id=rp.reciptParcel        
from cki_upload_actuals_feed_data cki      
  inner join       
  #delParcels dp      
  on dp.recId = cki.record_id      
   inner join       
   #rcptParcels rp      
   on rp.recId = cki.record_id      
 where cki.guid=@workingGuid       
  and error is null      
      
      
-- entity_tag EXTERNAL      
      
if object_id('tempdb..#delParcels') is not null        
 delete #delParcels      
      
if object_id('tempdb..#rcptParcels') is not null        
 delete #rcptParcels      
      
      
--- first update the external sale parcel in the table      
      
insert into #delParcels      
select cki.record_id as recId,      
 p.shipment_num as shipNum,      
 p.oid as deliveryParcel,      
 null as receiptParcel      
from cki_upload_actuals_feed_data cki      
  inner join       
  parcel p      
  on cki.cmdty_code=p.cmdty_code       
  --and cki.loc_code=p.location_code      
   inner join       
   allocation_item ai      
   on p.alloc_num=ai.alloc_num       
   and p.alloc_item_num=ai.alloc_item_num      
    inner join       
    entity_tag et      
    on et.entity_tag_id=@JDEetId       
    and et.key1=convert(varchar(17),ai.trade_num)      
    and et.key2=convert(varchar(17),ai.order_num)       
    and et.key3=convert(varchar(17),ai.item_num)       
    and et.target_key1='EXTERNAL'      
     inner join       
     trade trd      
     on trd.trade_num=ai.trade_num      
  inner join trade_item ti on ti.trade_num=convert(varchar(17),ai.trade_num)      
    and ti.order_num=convert(varchar(17),ai.order_num)       
    and ti.item_num =convert(varchar(17),ai.item_num)   
    --and ti.item_type = 'W' ADSO-8695 
      inner join       
      account act      
      on act.acct_num=trd.acct_num      
    where cki.guid=@workingGuid       
     and error is null      
     and cki.cp_short_name = act.acct_short_name      
     and datediff (dd,cki.actual_date,ai.nomin_date_from) <=0      
     and datediff(dd,cki.actual_date,ai.nomin_date_to) >=0      
     and p.type='D'      
	 and cki.loc_code= case when cki.record_type = 'F'
							then ai.load_port_loc_code
						else p.location_code
						end
      
-- update error for which no parcel found      
--update cki_upload_actuals_feed_data set error='No delivery parcel found.'      
--from cki_upload_actuals_feed_data cki       
--where cki.guid=@workingGuid and cki.error is null and       
--not exists (select 1 from #delParcels)      
-- update error message for the ones with multiple parcels      
--update cki_upload_actuals_feed_data set error='Multiple delivery parcels found: '+delParcels      
--from cki_upload_actuals_feed_data cki      
--inner join     (      
--        Select distinct ST2.recId,       
--            (      
--                Select convert(varchar(8),ST1.deliveryParcel) + ',' AS [text()]      
--                From #delParcels ST1      
--                Where recId in (select recId from #delParcels group by recId      
--having (count(*) > 1))      
--    and ST1.recId = ST2.recId      
--    order by recId      
--                For XML PATH ('')      
--            ) [delParcels]      
--        From #delParcels ST2      
--    ) [Main] on [Main].recId = cki.record_id and cki.guid=@workingGuid and error is null      
      
      
-- remove rows from #delParcels which have multiple parcels      
      
delete #delParcels        
where recId in (select recId       
 from #delParcels       
 group by recId      
 having (count(*) > 1))      
      
      
/*      
-- check if the sale parcel found is fully_actualized, then update error message      
update cki_upload_actuals_feed_data set error='Delivery parcel '+convert(varchar(8),fullActParcel.deliveryParcel) +' is fully actualized.'      
from cki_upload_actuals_feed_data cki      
inner join (      
select dp.recId, dp.deliveryParcel, ai.fully_actualized       
from cki_upload_actuals_feed_data cki      
inner join #delParcels dp on cki.record_id=dp.recId      
inner join parcel p on p.oid=dp.deliveryParcel      
inner join allocation_item ai on p.alloc_num=ai.alloc_num and p.alloc_item_num=ai.alloc_item_num      
where cki.guid=@workingGuid and error is null      
and ai.fully_actualized='Y') fullActParcel on fullActParcel.recId=cki.record_id      
where cki.guid=@workingGuid and error is null      
      
-- remove rows from #delParcels which have errors      
delete #delParcels where recId in      
(select record_id from cki_upload_actuals_feed_data where guid=@workingGuid and error is not null)      
*/      
      
      
      
-- do not set error message, just remove the delivery parcels which are fully actualized      
      
delete #delParcels       
where recId in (select dp.recId      
 from cki_upload_actuals_feed_data cki      
   inner join       
   #delParcels dp      
   on cki.record_id=dp.recId      
    inner join       
    parcel p      
    on p.oid=dp.deliveryParcel      
     inner join       
     allocation_item ai      
     on p.alloc_num=ai.alloc_num       
     and p.alloc_item_num=ai.alloc_item_num      
   where cki.guid=@workingGuid       
    and error is null      
    and ai.fully_actualized='Y')      
      
      
-- do not set error message, just remove the delivery parcels whose costs are vouched or paid      
      
delete #delParcels       
where recId in (  select dp.recId      
 from #delParcels dp      
   inner join       
   cki_upload_actuals_feed_data cki      
   on cki.record_id=dp.recId      
    inner join       
    parcel p      
    on p.oid=dp.deliveryParcel      
     inner join       
     ai_est_actual aa      
     on aa.alloc_num = p.alloc_num       
     and aa.alloc_item_num=p.alloc_item_num       
     and aa.ai_est_actual_date=cki.actual_date      
      inner join       
      cost c      
      on c.cost_owner_key1=aa.alloc_num       
      and c.cost_owner_key2=aa.alloc_item_num       
      and c.cost_owner_key3=aa.ai_est_actual_num      
      and c.cost_type_code in ('WPP','DPP')      
    where cki.guid=@workingGuid       
     and cki.error is null      
     and aa.ai_est_actual_num > 0       
     and cost_owner_code='AA'       
     and c.cost_status in ('VOUCHED','PAID'))      
      
      
-- look for receipt parcel with the same shipment      
      
insert into #rcptParcels      
select dp.recId,      
 dp.shipNum,      
 p.oid as reciptParcel      
from #delParcels dp      
  inner join       
  parcel p      
  on p.shipment_num=dp.shipNum      
   inner join       
   cki_upload_actuals_feed_data cki      
   on cki.record_id=dp.recId      
    inner join       
    allocation_item ai      
    on p.alloc_num=ai.alloc_num       
    and p.alloc_item_num=ai.alloc_item_num      
     --inner join   #ADSO-8695    
     --entity_tag et #ADSO-8695   
     --on et.entity_tag_id=@JDEetId  #ADSO-8695     
     --and et.key1=convert(varchar(17),ai.trade_num) #ADSO-8695     
     --and et.key2=convert(varchar(17),ai.order_num) #ADSO-8695      
     --and et.key3=convert(varchar(17),ai.item_num) #ADSO-8695      
     --and et.target_key1='EXTERNAL' #ADSO-8695     
     -- inner join        trade trd    on trd.trade_num=ai.trade_num        
   --inner join     account act    on act.acct_num=trd.acct_num      
     where cki.guid=@workingGuid       
      and error is null      
      --and p.cmdty_code=cki.cmdty_code       
      --and p.location_code=cki.loc_code      
      --and cki.cp_short_name = act.acct_short_name      
      --and datediff (dd,cki.actual_date,ai.nomin_date_from) <=0      
      --and datediff(dd,cki.actual_date,ai.nomin_date_to) >=0      
      and p.type='R'      
      
/*      
-- update error for which no parcel found      
update cki_upload_actuals_feed_data set error='Delivery parcel ' + convert(varchar(8),dp.deliveryParcel) + ', but no receipt parcel found on shipment ' + convert(varchar(8), dp.shipNum) + '.'      
from cki_upload_actuals_feed_data cki       
inner join #delParcels dp on dp.recId = cki.record_id      
where cki.guid=@workingGuid and cki.error is null and       
not exists (select 1 from #rcptParcels rp where rp.recId=dp.recId)      
*/      
      
-- delete the delParcels for which the receipt parcel does not exist      
      
delete #delParcels       
from #delParcels dp      
where not exists (select 1       
 from #rcptParcels rp      
 where rp.recId=dp.recId)      
      
/*      
-- update error message for the ones with multiple receipt parcels      
update cki_upload_actuals_feed_data set error='Multiple receipt parcels found: '+rcptParcels      
from cki_upload_actuals_feed_data cki      
inner join     (      
        Select distinct ST2.recId,       
            (      
                Select convert(varchar(8),ST1.reciptParcel) + ',' AS [text()]      
                From #rcptParcels ST1      
                Where recId in (select recId from #rcptParcels group by recId      
having (count(*) > 1))      
    and ST1.recId = ST2.recId      
    order by recId      
                For XML PATH ('')      
            ) [rcptParcels]      
        From #rcptParcels ST2      
    ) [Main] on [Main].recId = cki.record_id and cki.guid=@workingGuid and error is null      
*/      
      
-- remove rows from #rcptParcels which have multiple parcels      
      
delete #rcptParcels        
where recId in (select recId       
 from #rcptParcels       
 group by recId      
 having (count(*) > 1))      
      
/*      
-- check if the receipt parcel is fully_actualized, and add error message      
update cki_upload_actuals_feed_data set error='Receipt parcel '+convert(varchar(8),fullActParcel.reciptParcel) +' is fully actualized.'      
from cki_upload_actuals_feed_data cki      
inner join (      
select rp.recId, rp.reciptParcel, ai.fully_actualized       
from #rcptParcels rp on cki.record_id=rp.recId      
inner join parcel p on p.oid=rp.reciptParcel      
inner join allocation_item ai on p.alloc_num=ai.alloc_num and p.alloc_item_num=ai.alloc_item_num      
where ai.fully_actualized='Y') fullActParcel on fullActParcel.recId=cki.record_id      
where cki.guid=@workingGuid and error is null      
      
-- remove rows from #delParcels which have errors      
delete #rcptParcels where recId in      
(select record_id from cki_upload_actuals_feed_data where guid=@workingGuid and error is not null)      
*/      
      
-- remove rcptParcels which are fully actualized      
      
delete #rcptParcels       
where recId in (select rp.recId      
 from #rcptParcels rp      
   inner join       
   parcel p      
   on p.oid=rp.reciptParcel      
    inner join       
    allocation_item ai      
    on p.alloc_num=ai.alloc_num       
    and p.alloc_item_num=ai.alloc_item_num      
  where ai.fully_actualized='Y')      
      
-- remove receipt parcels which have actuals whose costs are vouched or paid      
      
delete #rcptParcels       
where recId in (  select rp.recId   
 from #rcptParcels rp      
   inner join       
   cki_upload_actuals_feed_data cki      
   on cki.record_id=rp.recId      
    inner join       
    parcel p      
    on p.oid=rp.reciptParcel      
     inner join       
     ai_est_actual aa      
     on aa.alloc_num = p.alloc_num       
     and aa.alloc_item_num=p.alloc_item_num       
     and aa.ai_est_actual_date=cki.actual_date      
      inner join       
      cost c      
      on c.cost_owner_key1=aa.alloc_num       
      and c.cost_owner_key2=aa.alloc_item_num       
      and c.cost_owner_key3=aa.ai_est_actual_num       
      and c.cost_type_code in ('WPP','DPP')      
    where cki.guid=@workingGuid       
     and cki.error is null      
     and aa.ai_est_actual_num > 0       
     and cost_owner_code='AA'       
     and c.cost_status in ('VOUCHED','PAID'))      
      
-- update the external delivery and receipt parcel data      
      
update cki_upload_actuals_feed_data       
set external_del_parcel_id=dp.deliveryParcel,external_rpt_parcel_id=rp.reciptParcel        
from cki_upload_actuals_feed_data cki      
  inner join       
  #delParcels dp      
  on dp.recId = cki.record_id      
   inner join       
   #rcptParcels rp      
   on rp.recId = cki.record_id      
 where cki.guid=@workingGuid         
  and error is null      
GO
GRANT EXECUTE ON  [dbo].[usp_cki_2b_process_actuals_feed_data] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_cki_2b_process_actuals_feed_data', NULL, NULL
GO
