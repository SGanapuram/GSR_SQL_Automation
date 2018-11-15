SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_allocation_detail]              
(              
  alloc_type_desc,               
   alloc_num,               
   alloc_item_num,              
   ai_est_actual_num,              
   alloc_item_type,              
   alloc_item_status,              
   creation_date,              
   sch_init,              
   alloc_mod_date,              
   alloc_mod_init,              
   sch_prd,               
   deemed_bl_date,     
   title_tran_date,           
   alloc_pay_date,              
   trade_num,              
   order_num,              
   item_num,              
   acct_num,              
   cmdty_code,              
   mot_type_code,        
   mot_full_name,            
   sch_qty,              
   sch_qty_uom_code,              
   nomin_date_from,              
   nomin_date_to,              
   nomin_qty_max,              
   nomin_qty_max_uom_code,              
   title_tran_loc_code,              
   state_code,              
   country_code,              
   origin_loc_code,              
   dest_loc_code,              
   acct_ref_num,              
   final_dest_loc_code,              
   lc_num,              
   load_port_loc_code,              
   finance_bank_num,              
   ai_est_actual_date,              
   ai_est_actual_gross_qty,              
   ai_est_actual_net_qty,              
   ai_net_qty_uom_code,              
   ai_est_actual_ind,              
   ticket_num,              
   bol_code,              
   owner_code,              
   secondary_actual_gross_qty,              
   secondary_actual_net_qty,              
   secondary_qty_uom_code,              
   manual_input_sec_ind,              
   spec_code,              
   spec_desc,              
   spec_actual_value,              
   eta_date,              
   bl_date,              
   nor_date,              
   load_cmnc_date,              
   load_compl_date,              
   disch_cmnc_date,              
   disch_compl_date,              
   cas_num,          
   date_of_msds,          
   msds_reach_imp_flag,          
   registration_num,           
   origin_country_code,              
   title_transfer_country_code,              
   destination_country_code,              
   vat_country_code,              
   booking_comp_vat_number_id,              
   booking_comp_fiscal_rep,              
   counterparty_vat_number_id,              
   counterparty_fiscal_rep,              
   vat_trans_nature_code,              
   vat_declaration_id,              
   cmdty_nomenclature_id,              
   aad,              
   warehouse_permit_holder,              
   wph_vat_number_id,              
   vat_type_code,              
   excise_num,              
   ready_for_accounting_ind,              
   vat_applies_ind,              
   warehouse_permit_loc_code,              
   excise_number_id,              
   tank_num,              
   wph_excise_num,    
   origin_loc_name,    
   origin_state,              
   origin_country,              
   dest_loc_name,    
   dest_state,              
   dest_country,              
   final_dest_loc_name,    
   final_dest_state,              
   final_dest_country,              
   load_port_loc_name,        
   load_port_state,              
   load_port_country,
   del_term_code          
)              
AS                           
select 
   alloc_type_desc,               
   a.alloc_num,               
   ai.alloc_item_num,              
   ai_est_actual_num,              
   ai.alloc_item_type,              
   ai.alloc_item_status,              
   a.creation_date,              
   sch_init,              
   i.tran_date alloc_mod_date,              
   i.user_init alloc_mod_init,              
   sch_prd, deemed_bl_date,  
   ai.title_tran_date,  
   alloc_pay_date,              
   ai.trade_num,              
   ai.order_num,    
   ai.item_num,              
   ai.acct_num,              
   ai.cmdty_code,        
   m.mot_type_code,             
   m.mot_full_name,             
   ai.sch_qty,              
   ai.sch_qty_uom_code,              
   ai.nomin_date_from,              
   ai.nomin_date_to,              
   ai.nomin_qty_max,              
   ai.nomin_qty_max_uom_code,              
   isnull(tl.loc_name, ai.title_tran_loc_code) 'Location',              
   le.state_code,              
   cntr.country_name,              
   ai.origin_loc_code,              
   ai.dest_loc_code,              
   acct_ref_num,              
   final_dest_loc_code,              
   lc_num,              
   load_port_loc_code,              
   finance_bank_num,              
   ai_est_actual_date,              
   ai_est_actual_gross_qty,         
   ai_est_actual_net_qty,              
   ai_net_qty_uom_code,              
   ai_est_actual_ind,              
   ticket_num,              
   bol_code,              
   owner_code,              
   secondary_actual_gross_qty,              
   secondary_actual_net_qty,              
   secondary_qty_uom_code,              
   aia.manual_input_sec_ind,              
   ais.spec_code,              
   spec.spec_desc,              
   spec_actual_value,              
   eta_date,              
   bl_date,              
   nor_date,              
   load_cmnc_date,              
   load_compl_date,              
   disch_cmnc_date,              
   disch_compl_date,           
   et1.target_key1 'cas_num',          
   et2.target_key1 'date_of_msds',          
   et3.target_key1 'msds_reach_imp_flag',          
   et4.target_key1 'registration_num',                 
   aiv.origin_country_code,              
   aiv.title_transfer_country_code,              
   aiv.destination_country_code,              
   aiv.vat_country_code,              
   aiv.booking_comp_vat_number_id,              
   aiv.booking_comp_fiscal_rep,              
   aiv.counterparty_vat_number_id,              
   aiv.counterparty_fiscal_rep,              
   aiv.vat_trans_nature_code,              
   aiv.vat_declaration_id,              
   aiv.cmdty_nomenclature_id,              
   aiv.aad,              
   aiv.warehouse_permit_holder,              
   aiv.wph_vat_number_id,              
   aiv.vat_type_code,              
   aiv.excise_num,              
   aiv.ready_for_accounting_ind,              
   aiv.vat_applies_ind,              
   aiv.warehouse_permit_loc_code,              
   aiv.excise_number_id,              
   aiv.tank_num,              
   aiv.wph_excise_num,    
   orig.loc_name origin_loc_name,    
   origle.state_code origin_state,              
   origcntr.country_name origin_country,              
   dest.loc_name dest_loc_name,    
   destle.state_code dest_state,              
   destcntr.country_name dest_country,              
   fin_dest.loc_name final_dest_loc_name,    
   fin_destle.state_code final_dest_state,              
   fin_destcntr.country_name final_dest_country,              
   ldport.loc_name  load_port_loc_name,        
   ldportle.state_code load_port_state,              
   ldportcntr.country_name load_port_country,
   ai.del_term_code
from dbo.allocation a              
        LEFT OUTER JOIN dbo.icts_transaction i 
           ON i.trans_id = a.trans_id              
        LEFT OUTER JOIN dbo.comment cmnt 
           ON a.cmnt_num = cmnt.cmnt_num              
        INNER JOIN allocation_type atp 
           ON atp.alloc_type_code = a.alloc_type_code              
        INNER JOIN allocation_item ai 
           ON ai.alloc_num = a.alloc_num              
        LEFT OUTER JOIN dbo.location tl 
           ON ai.title_tran_loc_code = tl.loc_code              
        LEFT OUTER JOIN dbo.location_ext_info le 
           ON ai.title_tran_loc_code = le.loc_code              
        LEFT OUTER JOIN dbo.country cntr 
           ON cntr.country_code = le.country_code    
        LEFT OUTER JOIN dbo.ai_est_actual aia 
           ON aia.alloc_num = ai.alloc_num and 
              aia.alloc_item_num = ai.alloc_item_num               
        LEFT OUTER JOIN dbo.entity_tag et1 
           ON et1.key1 = convert(varchar,aia.alloc_num) and 
              et1.key2 = convert(varchar,aia.alloc_item_num) and 
              et1.key3 = convert(varchar,aia.ai_est_actual_num) and 
              et1.entity_tag_id = (select isnull(oid, 0)
                                   from dbo.entity_tag_definition 
                                   where entity_id = (select oid
                                                      from dbo.icts_entity_name
                                                      where entity_name = 'AiEstActual') and
                                         entity_tag_name = 'CASNUM')  
        LEFT OUTER JOIN dbo.entity_tag et2 
           ON et2.key1 = convert(varchar,aia.alloc_num) and 
              et2.key2 = convert(varchar,aia.alloc_item_num) and 
              et2.key3 = convert(varchar,aia.ai_est_actual_num) and 
              et2.entity_tag_id = (select isnull(oid, 0)
                                   from dbo.entity_tag_definition 
                                   where entity_id = (select oid
                                                      from dbo.icts_entity_name
                                                      where entity_name = 'AiEstActual') and
                                         entity_tag_name = 'DATEOFMSDS')  
        LEFT OUTER JOIN dbo.entity_tag et3 
           ON et3.key1 = convert(varchar,aia.alloc_num) and 
              et3.key2 = convert(varchar,aia.alloc_item_num) and 
              et3.key3 = convert(varchar,aia.ai_est_actual_num) and 
              et3.entity_tag_id = (select isnull(oid, 0)
                                   from dbo.entity_tag_definition 
                                   where entity_id = (select oid
                                                      from dbo.icts_entity_name
                                                      where entity_name = 'AiEstActual') and
                                         entity_tag_name = 'MSDSREACHIMPFLG')  
        LEFT OUTER JOIN dbo.entity_tag et4 
           ON et4.key1 = convert(varchar,aia.alloc_num) and 
              et4.key2 = convert(varchar,aia.alloc_item_num) and 
              et4.key3 = convert(varchar,aia.ai_est_actual_num) and 
              et3.entity_tag_id = (select isnull(oid, 0)
                                   from dbo.entity_tag_definition 
                                   where entity_id = (select oid
                                                      from dbo.icts_entity_name
                                                      where entity_name = 'AiEstActual') and
                                         entity_tag_name = 'CASRESNUM')  
        LEFT OUTER JOIN dbo.allocation_item_spec ais 
           ON ais.alloc_num = ai.alloc_num and 
              ais.alloc_item_num = ai.alloc_item_num              
        LEFT OUTER JOIN dbo.specification spec 
           ON spec.spec_code = ais.spec_code              
        LEFT OUTER JOIN dbo.allocation_item_transport ait 
           ON ait.alloc_num = ai.alloc_num and 
              ait.alloc_item_num = ai.alloc_item_num              
        LEFT OUTER JOIN dbo.mot m 
           ON ait.transportation = m.mot_code              
        LEFT OUTER JOIN dbo.allocation_item_vat aiv 
           ON aiv.alloc_num = ai.alloc_num and 
              aiv.alloc_item_num = ai.alloc_item_num               
        LEFT OUTER JOIN dbo.location orig 
           ON orig.loc_code = ai.origin_loc_code    
        LEFT OUTER JOIN dbo.location_ext_info origle 
           ON ai.origin_loc_code = origle.loc_code              
        LEFT OUTER JOIN dbo.country origcntr 
           ON origcntr.country_code = origle.country_code    
        LEFT OUTER JOIN dbo.location dest 
           ON dest.loc_code = ai.dest_loc_code             
        LEFT OUTER JOIN dbo.location_ext_info destle 
           ON ai.dest_loc_code = destle.loc_code              
        LEFT OUTER JOIN dbo.country destcntr 
           ON destcntr.country_code = destle.country_code    
        LEFT OUTER JOIN dbo.location fin_dest 
           ON fin_dest.loc_code= final_dest_loc_code    
        LEFT OUTER JOIN dbo.location_ext_info fin_destle 
           ON final_dest_loc_code = fin_destle.loc_code              
        LEFT OUTER JOIN dbo.country fin_destcntr 
           ON fin_destcntr.country_code = fin_destle.country_code    
        LEFT OUTER JOIN dbo.location ldport 
           ON ldport.loc_code = load_port_loc_code              
        LEFT OUTER JOIN dbo.location_ext_info ldportle 
           ON load_port_loc_code = ldportle.loc_code              
        LEFT OUTER JOIN dbo.country ldportcntr 
           ON ldportcntr.country_code = ldportle.country_code 
GO
GRANT SELECT ON  [dbo].[v_allocation_detail] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_allocation_detail', NULL, NULL
GO
