SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
    
CREATE procedure [dbo].[usp_get_trade_operations_data_cpo_temp] (              
 @tradeNum int,              
 @executor varchar(50),              
 @orderNum int,              
 @itemNum int,              
 @shipmentNum int = null,              
 @parcelNum int = null              
 )              
as              
if (              
  @shipmentNum is null              
  and @parcelNum is null              
  )              
begin              
 set nocount on              
              
 declare @StripCountTOI int              
              
 select @StripCountTOI = count(strip_summary_ind)              
 from dbo.trade_order              
 where strip_summary_ind = 'Y'              
  and trade_num = @tradeNum              
              
 select distinct cp.acct_full_name as CounterpartyFullName,              
  cmdty.cmdty_full_name as CommodityFullName,              
  ti.amend_num as AmendNum,              
  ti.contr_qty as ContractQty,              
  ti.contr_qty_uom_code as ContrQtyUomCode,        
   (convert(VARCHAR, ti.trade_num)+'/'+                                                    
                                                   
  convert(VARCHAR,ti.order_num) +'/'+                                                    
                                                   
  convert(VARCHAR,ti.item_num ))         AS RefNR,              
  '' as ETADate,              
  tiwp.tol_sign as TolSign,              
  isnull(tiwp.tol_qty, 0) as TolQty,              
  tiwp.tol_qty_uom_code as TolQtyUomCode,              
  tiwp.tol_opt as TolOpt,              
  tiwp.min_qty_uom_code as MinTolQtyUomCode,              
  tiwp.max_qty_uom_code as MaxTolQtyUomCode,              
  tiwp.density_ind as DensityIndicator,              
  (DATENAME(month, tiwp.del_date_from)+' '+                                                              
                                                 
 DATENAME(day, tiwp.del_date_from)+', '+                                                              
                                                 
 DATENAME(year, tiwp.del_date_from) )        AS DelDateFrom,            
             
 (DATENAME(month, tiwp.del_date_to)+' '+                                                              
                                                 
 DATENAME(day, tiwp.del_date_to)+', '+                                                              
                             
 DATENAME(year, tiwp.del_date_to) )        AS DelDateTo,            
  isnull(tiwp.min_qty, 0) as MinTolQty,              
  isnull(tiwp.max_qty, 0) as MaxTolQty,              
  (              
   case               
    when tispec.spec_code <> 'BDENSITY'              
     and tispec.spec_code <> 'EDENSITY'              
     then tispec.spec_typical_val              
    else (              
      select titspec.spec_typical_val              
      from trade_item_spec titspec              
      where titspec.trade_num = ti.trade_num              
       and titspec.order_num = ti.order_num              
       and titspec.item_num = ti.item_num              
       and titspec.spec_code = 'BDENSITY'              
      )              
    end              
   ) as SpecTypicalVal,              
  '' as InspectionCompany,              
  (DATENAME(month, alit.lay_days_start_date) + ' ' + DATENAME(day, alit.lay_days_start_date) + '-' + DATENAME(day, alit.lay_days_end_date) + ', ' + DATENAME(year, alit.lay_days_start_date)) as LayDays,              
  (              
   select top 1 Upper(target_key1)              
   from entity_tag et              
   where et.key1 = Convert(varchar, @tradeNum)              
    and et.entity_tag_id = (              
     select top 1 etd.oid              
     from entity_tag_definition etd              
     where etd.entity_tag_name = 'MOHGuarSpecTI'              
      and etd.tag_status = 'A'              
      and etd.entity_id = (              
       select oid              
       from icts_entity_name              
       where entity_name = 'TradeItem'       
       )              
     )              
   ) as GuaranteedSpec,              
  m.mot_full_name as MotFullName              
 from trade t              
 left outer join icts_user iu on t.trader_init = iu.user_init              
 --BELOW FOR PMI                       
 left outer join (              
  select top 1 mn.*              
  from icts_user mn              
  where mn.user_init in (              
    select d.manager_init              
    from icts_user iu              
    join department d on iu.desk_code = d.dept_code              
    join trade trd on iu.user_init = trd.trader_init              
    where trd.trade_num = @tradeNum              
    )              
  ) as mngr on t.trade_num = @tradeNum              
 left outer join account cp on t.acct_num = cp.acct_num              
 left outer join (              
  select top 1 ad.*              
  from trade tr              
  left outer join account_address ad on tr.acct_num = ad.acct_num              
  where ad.acct_addr_status = 'A'              
   and tr.trade_num = @tradeNum              
  ) as cpa -------------trade_num Input                              
  on t.acct_num = cpa.acct_num              
 left outer join (              
  select top 1 ad.*              
  from trade tr              
  left outer join account_contact ad on tr.acct_num = ad.acct_num              
  where ad.acct_cont_status = 'A'              
   and tr.trade_num = @tradeNum              
  ) cpac -------------trade_num Input                                                      
  on t.acct_num = cpac.acct_num              
 left outer join trade_order tro on t.trade_num = tro.trade_num              
 left outer join trade_item ti on t.trade_num = ti.trade_num              
  and ti.order_num = tro.order_num              
 left outer join trade_comment tc on t.trade_num = tc.trade_num              
  and tc.trade_cmnt_type = 'T'              
 left outer join comment cmt on tc.cmnt_num = cmt.cmnt_num              
 left outer join cost secc on secc.cost_owner_key6 = ti.trade_num              
  and secc.cost_owner_key7 = ti.order_num              
  and secc.cost_owner_key8 = ti.item_num              
  and secc.cost_status = 'OPEN'              
  and secc.cost_prim_sec_ind = 'S'              
  and secc.cost_owner_code in (              
   'A',              
   'AI'              
   )              
 left outer join cost_code ccode on ccode.cost_code = secc.cost_code              
 --AND secc.cost_type_code NOT IN                                           
 --('WPP', 'RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR')                                                     
 --LEFT OUTER JOIN comment trcmt                                                      
 --ON trcmt.cmnt_num = (SELECT ti1.cmnt_num FROM trade_item ti1 WHERE ti1.order_num=1 AND ti1.item_num =1 AND ti1.trade_num=@tradeNum)                                                      
 left outer join account bp on ti.booking_comp_num = bp.acct_num              
 left outer join (              
  select top 1 aa.*              
  from trade t1              
  right outer join trade_order tr1 on t1.trade_num = tr1.trade_num              
  left outer join trade_item ti1 on tr1.order_num = ti1.order_num              
   and t1.trade_num = ti1.trade_num              
  left outer join account_address aa on ti1.booking_comp_num = aa.acct_num              
  where t1.trade_num = @tradeNum              
   and aa.acct_addr_status = 'A'              
  ) bpa on ti.booking_comp_num = bpa.acct_num --AND bpa.acct_addr_num = 1-- (SELECT TOP 1 bpa.acct_addr_num WHERE bpa.acct_num = bp.acct_num )                                                      
 left outer join (              
  select top 1 ac.*              
  from trade t1              
  left outer join trade_order tr1 on t1.trade_num = tr1.trade_num              
  left outer join trade_item ti1 on tr1.order_num = ti1.order_num              
   and t1.trade_num = ti1.trade_num              
  left outer join account_contact ac on ti1.booking_comp_num = ac.acct_num              
  where t1.trade_num = @tradeNum              
   and ac.acct_cont_status = 'A'              
  ) bpac -------------trade_num Input                  
  on ti.booking_comp_num = bpac.acct_num              
 left outer join (              
  select top 1 ac.*              
  from trade t1              
  left outer join trade_order tr1 on t1.trade_num = tr1.trade_num              
  left outer join trade_item ti1 on tr1.order_num = ti1.order_num              
   and t1.trade_num = ti1.trade_num              
  left outer join account_contact ac on ti1.brkr_num = ac.acct_num              
  where t1.trade_num = @tradeNum              
   and ac.acct_cont_status = 'A'              
  ) brkrac -------------trade_num Input                                             
  on ti.brkr_num = brkrac.acct_num              
 left outer join account brkr on ti.brkr_num = brkr.acct_num              
 left outer join commodity cmdty on ti.cmdty_code = cmdty.cmdty_code              
 left outer join trade_item_wet_phy tiwp on ti.trade_num = tiwp.trade_num              
  and ti.order_num = tiwp.order_num              
  and ti.item_num = tiwp.item_num              
 left outer join location dl on tiwp.del_loc_code = dl.loc_code              
 left outer join mot m on tiwp.mot_code = m.mot_code              
 left outer join mot_type mt on m.mot_type_code = mt.mot_type_code              
 left outer join payment_term pt on tiwp.pay_term_code = pt.pay_term_code              
 left outer join trade_formula tf on ti.trade_num = tf.trade_num              
  and ti.order_num = tf.order_num           
  and ti.item_num = tf.item_num              
  and tf.fall_back_ind = 'N'              
  and ti.formula_ind = 'Y'              
 left outer join formula f on tf.formula_num = f.formula_num              
 left outer join avg_buy_sell_price_term apt on f.formula_num = apt.formula_num              
 --LEFT OUTER JOIN temp_docgen_data tdd                                       
 --ON tdd.key1 = convert(VARCHAR(15),ti.trade_num) AND tdd.key2 = convert(VARCHAR(15),ti.order_num) AND tdd.key3 = convert(VARCHAR(15),ti.item_num)                                                       
 --LEFT OUTER JOIN formula_condition fcnd                                                      
 --ON f.formula_num = fcnd.formula_num                                             
 left outer join uom qtyuom on ti.contr_qty_uom_code = qtyuom.uom_code              
 left outer join uom priceuom on ti.price_uom_code = priceuom.uom_code              
 left outer join allocation_item ali on ali.trade_num = ti.trade_num              
  and ali.order_num = ti.order_num              
  and ali.item_num = ti.item_num              
 left outer join account acctinsp on acctinsp.acct_num = ali.insp_acct_num              
 left outer join allocation_item_transport alit on alit.alloc_num = ali.alloc_num              
  and alit.alloc_item_num = ali.alloc_item_num --parcel                                          
 left outer join parcel p on p.trade_num = @tradeNum              
  and p.alloc_num = ali.alloc_num              
  and p.alloc_item_num = ali.alloc_item_num              
 left outer join shipment s on s.oid = p.shipment_num              
 left outer join location loadloc on loadloc.loc_code = ali.origin_loc_code              
 left outer join uom u on u.uom_code = ti.contr_qty_uom_code              
 --LEFT OUTER JOIN delivery_term delt                                            
 --ON delt.del_term_code = tiwp.del_term_code                                            
 left outer join location titleloc on titleloc.loc_code = ali.title_tran_loc_code              
 left outer join allocation_item_vat alivat on alivat.alloc_num = ali.alloc_num              
  and alivat.alloc_item_num = ali.alloc_item_num              
 left outer join country titletranscountryloc on titletranscountryloc.country_code = alivat.title_transfer_country_code              
 --LEFT OUTER JOIN formula_component fc                                            
 --ON fc.formula_num = tf.formula_num                                            
 left outer join trade_item_spec tispec on tispec.trade_num = ti.trade_num              
  and tispec.order_num = ti.order_num              
  and tispec.item_num = ti.item_num              
  and tispec.spec_code = 'BDENSITY'              
 --LEFT OUTER JOIN trade_item_spec tiBDspec                                            
 --ON tiBDspec.trade_num = ti.trade_num AND tibdspec.order_num = ti.order_num AND tibdspec.item_num = ti.item_num AND tibdspec.spec_code='BDENSITY'               
 left outer join specification spec on spec.spec_code = tispec.spec_code              
 left outer join exceptions_additions excp on excp.excp_addns_code = ti.excp_addns_code              
 left outer join location tiwploc on tiwploc.loc_code = tiwp.del_loc_code              
 left outer join credit_term ct on ct.credit_term_code = tiwp.credit_term_code              
 left outer join allocation_item_insp aiinsp on aiinsp.alloc_num = alit.alloc_num              
  and aiinsp.alloc_item_num = alit.alloc_item_num              
 left outer join location lploc on lploc.loc_code = ti.load_port_loc_code              
 left outer join location lloc on lloc.loc_code = s.start_loc_code              
 --left outer join cost c                                                  
 --on   c.cost_owner_key6= ti.trade_num AND c.cost_owner_key7= ti.order_num AND c.cost_owner_key8 = ti.item_num                                           
 left outer join payment_method pm on pm.pay_method_code = (              
   select top 1 c1.pay_method_code              
   from cost c1              
   where c1.cost_owner_key6 = ti.trade_num              
    and c1.cost_owner_key7 = ti.order_num              
    and c1.cost_owner_key8 = ti.item_num              
   )              
 left outer join account_bank_info bookComp on bookComp.acct_num = ti.booking_comp_num              
  and bookComp.book_comp_num = ti.booking_comp_num              
 left outer join trade_term_info ttinfo on ttinfo.trade_num = @tradeNum              
 left outer join uom termuom on ttinfo.trade_num = @tradeNum              
  and ttinfo.trade_num = ti.trade_num              
  and ti.contr_qty_uom_code = termuom.uom_code              
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
 left outer join location disport on disport.loc_code = ti.disch_port_loc_code              
 left outer join country countr on countr.country_code = (              
   select top 1 country_code              
   from location_ext_info              
   where loc_code = (              
     select top 1 disch_port_loc_code              
     from trade_item              
     where trade_num = @tradeNum              
     )              
   )              
 left outer join country loadPortcountr on loadPortcountr.country_code = (              
   select top 1 country_code              
   from location_ext_info              
   where loc_code = (              
     select top 1 load_port_loc_code              
     from trade_item              
     where trade_num = @tradeNum              
     )              
   )              
 left outer join commodity cmdtyprice on cmdtyprice.cmdty_code = ti.price_curr_code              
 left outer join location_ext_info locExt on locExt.loc_code = ti.disch_port_loc_code              
 left outer join account cpt on t.acct_num = cpt.acct_num              
 left outer join gtc gtco on ti.gtc_code = gtco.gtc_code            
 where t.trade_num = @tradeNum              
  and tro.order_num = @orderNum              
  and ti.item_num = @itemNum              
              
 delete temp_docgen_data              
 where key1 = convert(varchar(20), @tradeNum)              
  and executor = @executor              
end              
else if (              
  @shipmentNum is not null              
  and @parcelNum is not null              
  )              
begin              
 set nocount on              
              
 declare @StripCountSP int              
              
 select @StripCountSP = count(strip_summary_ind)              
 from dbo.trade_order              
 where strip_summary_ind = 'Y'              
  and trade_num = @tradeNum              
              
 select distinct cp.acct_full_name as CounterpartyFullName,              
  cmdty.cmdty_full_name as CommodityFullName,              
  ti.amend_num as AmendNum,              
  ti.contr_qty as ContractQty,              
  ti.contr_qty_uom_code as ContrQtyUomCode,        
   (convert(VARCHAR, ti.trade_num)+'/'+                                                    
                                                   
  convert(VARCHAR,ti.order_num) +'/'+                                                    
                                                   
  convert(VARCHAR,ti.item_num ))         AS RefNR,              
  case when (alit.eta_date is null)                     
  then                           
  ali.nomin_date_to                          
  else                           
  alit.eta_date    
  end                           
  as ETADate,              
  tiwp.tol_sign as TolSign,              
  isnull(tiwp.tol_qty, 0) as TolQty,              
  tiwp.tol_qty_uom_code as TolQtyUomCode,              
  tiwp.tol_opt as TolOpt,              
  tiwp.min_qty_uom_code as MinTolQtyUomCode,              
  tiwp.max_qty_uom_code as MaxTolQtyUomCode,              
  tiwp.density_ind as DensityIndicator,            
  (DATENAME(month, tiwp.del_date_from)+' '+                                                              
                                                 
 DATENAME(day, tiwp.del_date_from)+', '+                                 
                                                 
 DATENAME(year, tiwp.del_date_from) )        AS DelDateFrom,            
             
 (DATENAME(month, tiwp.del_date_to)+' '+                                                              
                                                 
 DATENAME(day, tiwp.del_date_to)+', '+                                                              
                             
 DATENAME(year, tiwp.del_date_to) )        AS DelDateTo,              
  isnull(tiwp.min_qty, 0) as MinTolQty,              
  isnull(tiwp.max_qty, 0) as MaxTolQty,              
  (              
   case               
    when tispec.spec_code <> 'BDENSITY'              
     and tispec.spec_code <> 'EDENSITY'              
     then tispec.spec_typical_val              
    else (              
      select titspec.spec_typical_val              
      from trade_item_spec titspec              
      where titspec.trade_num = ti.trade_num              
       and titspec.order_num = ti.order_num              
       and titspec.item_num = ti.item_num              
       and titspec.spec_code = 'BDENSITY'              
      )              
    end              
   ) as SpecTypicalVal,              
  acctinsp.acct_short_name as InspectionCompany,              
  (DATENAME(month, alit.lay_days_start_date) + ' ' + DATENAME(day, alit.lay_days_start_date) + '-' + DATENAME(day, alit.lay_days_end_date) + ', ' + DATENAME(year, alit.lay_days_start_date)) as LayDays,              
  (              
   select top 1 Upper(target_key1)              
   from entity_tag et              
   where et.key1 = Convert(varchar, @tradeNum)              
    and et.entity_tag_id = (              
     select top 1 etd.oid              
     from entity_tag_definition etd              
     where etd.entity_tag_name = 'MOHGuarSpecTI'              
      and etd.tag_status = 'A'              
      and etd.entity_id = (              
       select oid              
       from icts_entity_name              
       where entity_name = 'TradeItem'              
       )              
     )              
   ) as GuaranteedSpec,              
  m.mot_full_name as MotFullName              
 from trade t              
 left outer join icts_user iu on t.trader_init = iu.user_init              
 --BELOW FOR PMI                  
 left outer join (              
  select top 1 mn.*              
  from icts_user mn              
  where mn.user_init in (              
    select d.manager_init              
    from icts_user iu              
    join department d on iu.desk_code = d.dept_code              
    join trade trd on iu.user_init = trd.trader_init              
    where trd.trade_num = @tradeNum              
    )              
  ) as mngr on t.trade_num = @tradeNum              
 left outer join account cp on t.acct_num = cp.acct_num              
 left outer join (              
  select top 1 ad.*              
  from trade tr              
  left outer join account_address ad on tr.acct_num = ad.acct_num              
  where ad.acct_addr_status = 'A'              
   and tr.trade_num = @tradeNum              
  ) as cpa -------------trade_num Input                              
  on t.acct_num = cpa.acct_num       
 left outer join (              
  select top 1 ad.*              
  from trade tr              
  left outer join account_contact ad on tr.acct_num = ad.acct_num              
  where ad.acct_cont_status = 'A'              
   and tr.trade_num = @tradeNum              
  ) cpac -------------trade_num Input                              
  on t.acct_num = cpac.acct_num              
 left outer join trade_order tro on t.trade_num = tro.trade_num              
 left outer join trade_item ti on t.trade_num = ti.trade_num              
  and ti.order_num = tro.order_num              
 left outer join trade_comment tc on t.trade_num = tc.trade_num              
  and tc.trade_cmnt_type = 'T'              
 left outer join comment cmt on tc.cmnt_num = cmt.cmnt_num              
 left outer join cost secc on secc.cost_owner_key6 = ti.trade_num              
  and secc.cost_owner_key7 = ti.order_num              
  and secc.cost_owner_key8 = ti.item_num              
  and secc.cost_status = 'OPEN'              
  and secc.cost_prim_sec_ind = 'S'              
  and secc.cost_owner_code in (              
   'A',              
   'AI'              
   )              
 left outer join cost_code ccode on ccode.cost_code = secc.cost_code              
 --AND secc.cost_type_code NOT IN                   
 --('WPP', 'RINPP', 'BPP' , 'RPP' , 'OPP' , 'OTC' , 'PDO' , 'POC' , 'TPP' , 'SPP' , 'SWAP' , 'SWPR' , 'BO' , 'false' , 'BOAI' , 'CPP' , 'CPR')                             
 --LEFT OUTER JOIN comment trcmt                              
 --ON trcmt.cmnt_num = (SELECT ti1.cmnt_num FROM trade_item ti1 WHERE ti1.order_num=1 AND ti1.item_num =1 AND ti1.trade_num=@tradeNum)                              
 left outer join account bp on ti.booking_comp_num = bp.acct_num              
 left outer join (              
  select top 1 aa.*          
  from trade t1              
  right outer join trade_order tr1 on t1.trade_num = tr1.trade_num              
  left outer join trade_item ti1 on tr1.order_num = ti1.order_num              
   and t1.trade_num = ti1.trade_num              
  left outer join account_address aa on ti1.booking_comp_num = aa.acct_num              
  where t1.trade_num = @tradeNum              
   and aa.acct_addr_status = 'A'              
  ) bpa on ti.booking_comp_num = bpa.acct_num --AND bpa.acct_addr_num = 1-- (SELECT TOP 1 bpa.acct_addr_num WHERE bpa.acct_num = bp.acct_num )                              
 left outer join (              
  select top 1 ac.*              
  from trade t1              
  left outer join trade_order tr1 on t1.trade_num = tr1.trade_num              
  left outer join trade_item ti1 on tr1.order_num = ti1.order_num              
   and t1.trade_num = ti1.trade_num              
  left outer join account_contact ac on ti1.booking_comp_num = ac.acct_num              
  where t1.trade_num = @tradeNum              
   and ac.acct_cont_status = 'A'              
  ) bpac -------------trade_num Input                              
  on ti.booking_comp_num = bpac.acct_num              
 left outer join (              
  select top 1 ac.*              
  from trade t1              
  left outer join trade_order tr1 on t1.trade_num = tr1.trade_num              
  left outer join trade_item ti1 on tr1.order_num = ti1.order_num              
   and t1.trade_num = ti1.trade_num              
  left outer join account_contact ac on ti1.brkr_num = ac.acct_num              
  where t1.trade_num = @tradeNum              
   and ac.acct_cont_status = 'A'              
  ) brkrac -------------trade_num Input                              
  on ti.brkr_num = brkrac.acct_num              
 left outer join account brkr on ti.brkr_num = brkr.acct_num              
 left outer join commodity cmdty on ti.cmdty_code = cmdty.cmdty_code              
 left outer join trade_item_wet_phy tiwp on ti.trade_num = tiwp.trade_num              
  and ti.order_num = tiwp.order_num              
  and ti.item_num = tiwp.item_num              
 left outer join location dl on tiwp.del_loc_code = dl.loc_code              
 left outer join mot m on tiwp.mot_code = m.mot_code              
 left outer join mot_type mt on m.mot_type_code = mt.mot_type_code              
 left outer join payment_term pt on tiwp.pay_term_code = pt.pay_term_code              
 left outer join trade_formula tf on ti.trade_num = tf.trade_num              
  and ti.order_num = tf.order_num              
  and ti.item_num = tf.item_num              
  and tf.fall_back_ind = 'N'              
  and ti.formula_ind = 'Y'              
 left outer join formula f on tf.formula_num = f.formula_num              
 left outer join avg_buy_sell_price_term apt on f.formula_num = apt.formula_num              
 --LEFT OUTER JOIN temp_docgen_data tdd                  
 --ON tdd.key1 = convert(VARCHAR(15),ti.trade_num) AND tdd.key2 = convert(VARCHAR(15),ti.order_num) AND tdd.key3 = convert(VARCHAR(15),ti.item_num)                              
 --LEFT OUTER JOIN formula_condition fcnd                              
 --ON f.formula_num = fcnd.formula_num                     
 left outer join uom qtyuom on ti.contr_qty_uom_code = qtyuom.uom_code              
 left outer join uom priceuom on ti.price_uom_code = priceuom.uom_code              
 left outer join allocation_item ali on ali.trade_num = ti.trade_num              
  and ali.order_num = ti.order_num              
  and ali.item_num = ti.item_num              
 left outer join account acctinsp on acctinsp.acct_num = ali.insp_acct_num              
 left outer join allocation_item_transport alit on alit.alloc_num = ali.alloc_num              
  and alit.alloc_item_num = ali.alloc_item_num --parcel                  
 left outer join parcel p on p.trade_num = @tradeNum              
  and p.alloc_num = ali.alloc_num              
  and p.alloc_item_num = ali.alloc_item_num              
 left outer join shipment s on s.oid = p.shipment_num              
 left outer join location loadloc on loadloc.loc_code = ali.origin_loc_code              
 left outer join uom u on u.uom_code = ti.contr_qty_uom_code              
 --LEFT OUTER JOIN delivery_term delt                    
 --ON delt.del_term_code = tiwp.del_term_code                    
 left outer join location titleloc on titleloc.loc_code = ali.title_tran_loc_code              
 left outer join allocation_item_vat alivat on alivat.alloc_num = ali.alloc_num              
  and alivat.alloc_item_num = ali.alloc_item_num              
 left outer join country titletranscountryloc on titletranscountryloc.country_code = alivat.title_transfer_country_code              
 --LEFT OUTER JOIN formula_component fc                    
 --ON fc.formula_num = tf.formula_num                    
 left outer join trade_item_spec tispec on tispec.trade_num = ti.trade_num              
  and tispec.order_num = ti.order_num              
  and tispec.item_num = ti.item_num              
  and tispec.spec_code = 'BDENSITY'              
 --LEFT OUTER JOIN trade_item_spec tiBDspec                    
 --ON tiBDspec.trade_num = ti.trade_num AND tibdspec.order_num = ti.order_num AND tibdspec.item_num = ti.item_num AND tibdspec.spec_code='BDENSITY'                  
 left outer join specification spec on spec.spec_code = tispec.spec_code              
 left outer join exceptions_additions excp on excp.excp_addns_code = ti.excp_addns_code              
 left outer join location tiwploc on tiwploc.loc_code = tiwp.del_loc_code              
 left outer join credit_term ct on ct.credit_term_code = tiwp.credit_term_code              
 left outer join allocation_item_insp aiinsp on aiinsp.alloc_num = alit.alloc_num              
  and aiinsp.alloc_item_num = alit.alloc_item_num              
 left outer join location lploc on lploc.loc_code = ti.load_port_loc_code              
 left outer join location lloc on lloc.loc_code = s.start_loc_code              
 --left outer join cost c                          
 --on   c.cost_owner_key6= ti.trade_num AND c.cost_owner_key7= ti.order_num AND c.cost_owner_key8 = ti.item_num   
 left outer join payment_method pm on pm.pay_method_code = (              
   select top 1 c1.pay_method_code              
   from cost c1              
   where c1.cost_owner_key6 = ti.trade_num              
    and c1.cost_owner_key7 = ti.order_num              
    and c1.cost_owner_key8 = ti.item_num              
   )              
 left outer join account_bank_info bookComp on bookComp.acct_num = ti.booking_comp_num              
  and bookComp.book_comp_num = ti.booking_comp_num              
 left outer join trade_term_info ttinfo on ttinfo.trade_num = @tradeNum              
 left outer join uom termuom on ttinfo.trade_num = @tradeNum              
  and ttinfo.trade_num = ti.trade_num              
  and ti.contr_qty_uom_code = termuom.uom_code              
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
                   
 --LEFT OUTER JOIN entity_tag etqlb                  
                   
 --ON etqlb.key1 = Convert(VARCHAR,@tradeNum) AND etqlb.entity_tag_id=etdqlb.oid                  
                   
 */              
 left outer join location disport on disport.loc_code = ti.disch_port_loc_code              
 left outer join country countr on countr.country_code = (              
   select top 1 country_code              
   from location_ext_info              
   where loc_code = (                   select top 1 disch_port_loc_code              
     from trade_item              
     where trade_num = @tradeNum              
     )              
   )              
 left outer join country loadPortcountr on loadPortcountr.country_code = (              
   select top 1 country_code              
   from location_ext_info              
   where loc_code = (              
     select top 1 load_port_loc_code              
     from trade_item              
     where trade_num = @tradeNum              
     )              
   )              
 left outer join commodity cmdtyprice on cmdtyprice.cmdty_code = ti.price_curr_code              
 left outer join location_ext_info locExt on locExt.loc_code = ti.disch_port_loc_code              
 left outer join account cpt on t.acct_num = cpt.acct_num              
 left outer join gtc gtco on ti.gtc_code = gtco.gtc_code              
 where t.trade_num = @tradeNum              
  and tro.order_num = @orderNum              
  and ti.item_num = @itemNum              
  and s.oid = @shipmentNum              
              
 delete temp_docgen_data              
 where key1 = convert(varchar(20), @tradeNum)              
  and executor = @executor              
end 
GO
GRANT EXECUTE ON  [dbo].[usp_get_trade_operations_data_cpo_temp] TO [next_usr]
GO
