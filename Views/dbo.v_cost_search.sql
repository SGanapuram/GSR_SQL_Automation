SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_cost_search]                 
(                  
   cost_num,                  
   cost_code,                  
   cost_status,                  
   cost_prim_sec_ind,                  
   cost_est_final_ind,                  
   cost_pay_rec_ind,                  
   cost_type_code,                  
   cost_owner_code,                  
   cost_owner_key1,                  
   cost_owner_key2,                  
   cost_owner_key3,                  
   cost_owner_key4,                  
   cost_owner_key5,                  
   cost_owner_key6,                  
   cost_owner_key7,                  
   cost_owner_key8,                  
   port_num,                  
   acct_num,                  
   cost_qty,                  
   cost_qty_uom_code,                  
   cost_qty_est_actual_ind,                  
   cost_unit_price,                  
   cost_price_curr_code,                  
   cost_price_uom_code,                  
   cost_price_est_actual_ind,                  
   cost_amt,                  
   cost_amt_type,                  
   cost_vouchered_amt,                  
   cost_drawn_bal_amt,                  
   pay_method_code,                  
   pay_term_code,                  
   cost_pay_days,                  
   credit_term_code,                  
   cost_book_comp_num,                  
   cost_book_comp_short_name,                  
   cost_book_curr_code,                  
   cost_book_exch_rate,                  
   cost_xrate_conv_ind,                  
   creation_date,                  
   creator_init,                  
   cost_eff_date,                  
   cost_due_date,                  
   cost_due_date_mod_date,                  
   cost_due_date_mod_init,                  
   cost_short_cmnt,                  
   cost_price_mod_date,                  
   cost_price_mod_init,                  
   cost_pl_code,                  
   cost_paid_date,                  
   voucher_paid_date,                  
   vc_acct_num,                  
   cash_date,                  
   po_number,                  
   trans_id,                  
   finance_bank_num,                  
   counterparty,                   
   booking_comp_short_name,                  
   voucher,                  
   del_term_code,                  
   alloc_num,                  
   alloc_item_num,                  
   actual_date,                  
   title_tran_date,                  
   disch_compl_date,                  
   trade_num,                  
   order_num,                  
   item_num,      
   pr_cost_num,    
   prepayment_ind,    
   cost_pl_contribution_ind,    
   fx_exp_num,    
   profit_center_code,                   
   group_code,                  
   legal_entity_code,                   
   division_code,                  
   strategy_code,                  
   voyage_code,                   
   voucher_cust_ref_num,                   
   order_type_code,                  
   mot_type_code,      
   mot_full_name,                  
   loc_name,                  
   exch_brkr_num,                  
   exch_brkr_name,                  
   contr_qty,                  
   port_full_name,                  
   load_port,                  
   discharge_port,                  
   Trader,                  
   voucher_type_code,                  
   voucher_pay_recv_ind,                  
   voucher_creation_date,                  
   voucher_creator_init,                  
   voucher_due_date,                  
   voucher_expected_pay_date,                  
   voucher_tot_amt,                  
   voucher_paid_amt,                  
   voucher_unpaid_amt,                  
   voucher_short_cmnt,                  
   voucher_full_cmnt,                  
   bc_bank_name,                  
   bc_bank_acct_no,
   cp_bank_name,                  
   risk_cover_num,    
   lc_num,                  
   lc_exp_date,                  
   lc_issuing_bank_name,                  
   credit_analyst,            
   invoice_status,          
   issuing_bank_acct_num,          
   voucher_acct_bank_id,          
   voucher_book_comp_bank_num,          
   book_comp_bank_short_name,          
   book_comp_bank_full_name,  
   zytax_text,  
   zytax_text_id  
)                  
AS                  
select                   
   c.cost_num,                  
   c.cost_code,                  
   c.cost_status,                  
   c.cost_prim_sec_ind,                  
   c.cost_est_final_ind,                  
   c.cost_pay_rec_ind,                  
   c.cost_type_code,                  
   c.cost_owner_code,                  
   c.cost_owner_key1,                  
   c.cost_owner_key2,                  
   c.cost_owner_key3,                  
   c.cost_owner_key4,                  
   c.cost_owner_key5,                  
   c.cost_owner_key6,                  
   c.cost_owner_key7,                  
   c.cost_owner_key8,                  
   c.port_num,                  
   c.acct_num,                  
   c.cost_qty,                  
   c.cost_qty_uom_code,                  
   c.cost_qty_est_actual_ind,                  
   c.cost_unit_price,                  
   c.cost_price_curr_code,                  
   c.cost_price_uom_code,                  
   c.cost_price_est_actual_ind,                  
   c.cost_amt,                  
   c.cost_amt_type,                  
   c.cost_vouchered_amt,                  
   c.cost_drawn_bal_amt,                  
   c.pay_method_code,                  
   c.pay_term_code,                  
   c.cost_pay_days,                  
   c.credit_term_code,                  
   c.cost_book_comp_num,                  
   ba.acct_short_name as cost_book_comp_short_name,                  
   c.cost_book_curr_code,                  
   c.cost_book_exch_rate,                  
   c.cost_xrate_conv_ind,                  
   c.creation_date,                  
   c.creator_init,                  
   c.cost_eff_date,                  
   c.cost_due_date,                  
   c.cost_due_date_mod_date,                  
   c.cost_due_date_mod_init,                  
   c.cost_short_cmnt,                  
   c.cost_price_mod_date,                  
   c.cost_price_mod_init,                  
   c.cost_pl_code,                  
   c.cost_paid_date,                  
   voucher_paid_date,                
   c.vc_acct_num,                  
   c.cash_date,                  
   c.po_number,                  
   c.trans_id,                  
   c.finance_bank_num,                  
   ca.acct_short_name as counterparty,                   
   ba.acct_short_name as booking_comp_short_name,                  
   vc.voucher_num as voucher,                  
   tiwp.del_term_code,                  
   tiwp.alloc_num,                  
   tiwp.alloc_item_num,                  
   ai_est_actual_date actual_date,                  
   title_tran_date,                  
   disch_compl_date,                  
   tiwp.trade_num,                  
   tiwp.order_num,                  
   tiwp.item_num,     
   cei.pr_cost_num,    
   cei.prepayment_ind,    
   cei.cost_pl_contribution_ind,    
   cei.fx_exp_num,    
   profit_center_code as ProfitCntr, 
   group_code,
   legal_entity_code, 
   division_code,
   strategy_code,                  
   cei.voyage_code,                   
   voucher_cust_ref_num as CPTYInvNum,                   
   tro.order_type_code as OrderType,           
   isnull(tiwp.mot_type_code, tiwp1.mot_type_code) 'mot_type_code',             
   isnull(tiwp.mot_full_name, tiwp1.mot_full_name) 'mot_full_name',                  
   isnull(tiwp.loc_name, tiwp1.loc_name) as Location,                  
   ti.exch_brkr_num,                  
   ti.exch_brkr_name,contr_qty,                  
   p.port_full_name,                  
   load_port,                  
   discharge_port,                  
   iu.user_first_name + ' ' + iu.user_last_name 'Trader',                   
   voucher_type_code,                  
   voucher_pay_recv_ind,                  
   voucher_creation_date,                  
   voucher_creator_init,                  
   voucher_due_date,                  
   voucher_expected_pay_date,                  
   voucher_tot_amt,                  
   isnull(voch_tot_paid_amt,0) voucher_paid_amt,                  
   isnull(voucher_tot_amt,0) - isnull(voch_tot_paid_amt,0) voucher_unpaid_amt,                   
   voucher_short_cmnt,                  
   vcmnt.cmnt_text voucher_full_cmnt,                  
   bcbi.bank_name bc_bank_name,                  
   bcbi.bank_acct_no,
   cpbi.bank_name cp_bank_name,          
   cei.risk_cover_num,    
   l.lc_num,                  
   l.lc_exp_date,                  
   lib.acct_short_name,                  
   ciu.user_first_name + ' ' + ciu.user_last_name 'credit_analyst',            
   isnull(vstat.target_key1, 'DRAFT') 'invoice_status',          
   lc_issuing_bank 'IssuingBankAcctNum',          
   bcbi.acct_bank_id 'VoucherBankAcctNum',          
   bnkinfo.acct_num 'BookCompBankNum',          
   bnkinfo.acct_short_name 'BookCompBankShortName',          
   bnkinfo.acct_full_name 'BookCompBankFullName',      
   zytax_text,  
   zytax_text_id   
from dbo.cost c                   
        left join (select ti1.trade_num, 
                          ti1.order_num,
                          ti1.item_num,
                          ti1.exch_brkr_num, 
                          be.acct_short_name 'exch_brkr_name',
                          contr_qty                  
                   from dbo.trade_item ti1                   
                           LEFT OUTER JOIN dbo.account be 
                              ON ti1.exch_brkr_num = be.acct_num) ti 
           on c.cost_owner_key6 = ti.trade_num and    
              c.cost_owner_key7 = ti.order_num and    
              c.cost_owner_key8 = ti.item_num                   
        left join (select distinct 
                      ai.alloc_num,
                      ai.alloc_item_num,
                      ai_est_actual_num,  
                      mot_type_code,      
                      mot_full_name,
                      ai_est_actual_date,
                      trade_num, 
                      order_num,         
                      item_num,
                      title_tran_loc_code,
                      title_tran_date,
                      origin_loc_code,         
                      dest_loc_code, 
                      del_term_code,
                      nor_date,
                      bl_date, 
                      l.loc_name, 
                      disch_compl_date,         
                      ld.loc_name 'load_port', 
                      dis.loc_name 'discharge_port'                  
                   from dbo.allocation_item ai                  
                           LEFT OUTER JOIN dbo.allocation_item_transport ait 
                              ON ai.alloc_num = ait.alloc_num and 
                                 ai.alloc_item_num = ait.alloc_item_num                  
                           LEFT OUTER JOIN dbo.mot m 
                              ON ait.transportation = m.mot_code                  
                           LEFT OUTER JOIN dbo.location l 
                              ON title_tran_loc_code = l.loc_code                  
                           LEFT OUTER JOIN dbo.ai_est_actual aia 
                              ON aia.alloc_num = ai.alloc_num and 
                                 aia.alloc_item_num = ai.alloc_item_num and 
                                 aia.ai_est_actual_num <> 0                  
                           LEFT OUTER JOIN dbo.location ld 
                              ON ld.loc_code = ai.load_port_loc_code                  
                           LEFT OUTER JOIN dbo.location dis 
                              ON dis.loc_code = ai.final_dest_loc_code) tiwp 
           on c.cost_owner_key6 = tiwp.trade_num and    
              c.cost_owner_key7 = tiwp.order_num and    
              c.cost_owner_key8 = tiwp.item_num and 
              tiwp.alloc_num = c.cost_owner_key1 and 
              tiwp.alloc_item_num = c.cost_owner_key2 and 
              ISNULL(tiwp.ai_est_actual_num, 0) = ISNULL(c.cost_owner_key3, 0)              
        left join (select distinct 
                      trade_num, 
                      order_num, 
                      item_num,
                      del_loc_code,
                      del_term_code,
                      mot_type_code,
                      mot_full_name,
                      l.loc_name                  
                   from dbo.trade_item_wet_phy wet, 
                        dbo.mot m, 
                        dbo.location l                  
                   where del_loc_code = l.loc_code and 
                         wet.mot_code = m.mot_code) tiwp1 
           on c.cost_owner_key6 = tiwp1.trade_num and    
              c.cost_owner_key7 = tiwp1.order_num and    
              c.cost_owner_key8 = tiwp1.item_num                   
        left join dbo.trade_order tro 
           on ti.trade_num = tro.trade_num and 
              ti.order_num = tro.order_num                  
        left join dbo.trade t 
           on ti.trade_num = t.trade_num                   
        left join dbo.icts_user iu 
           on iu.user_init = t.trader_init                  
        left join dbo.account ca 
           on c.acct_num = ca.acct_num                  
        left join dbo.account ba 
           on c.cost_book_comp_num = ba.acct_num                  
        left join dbo.account fa 
           on c.finance_bank_num = fa.acct_num                  
        left join dbo.voucher_cost vc 
           on c.cost_num = vc.cost_num                  
        left join dbo.voucher v 
           on vc.voucher_num = v.voucher_num                  
        left outer join dbo.account_bank_info cpbi 
           on cpbi.acct_bank_id = cp_acct_bank_id                  
        left outer join dbo.account_bank_info bcbi 
           on bcbi.acct_bank_id = book_comp_acct_bank_id                  
        left outer join dbo.account bnkinfo 
           on bnkinfo.acct_num = bcbi.bank_acct_num          
        left outer join dbo.comment vcmnt 
           on vcmnt.cmnt_num = v.cmnt_num                  
        left outer join (select cmnt_num,
                                short_cmnt 'zytax_text',
                                substring(short_cmnt, CHARINDEX('<TEXTID>',short_cmnt)+8, (CHARINDEX('<TEXTID>',short_cmnt)+8 -CHARINDEX('</TEXTID>',short_cmnt) )*-1) 'zytax_text_id'  
                         from dbo.comment cmnt  
                         where cmnt.short_cmnt like '%TEXTID%') ccmnt 
           on ccmnt.cmnt_num = c.cmnt_num   
        left join dbo.cost_ext_info cei 
           on c.cost_num = cei.cost_num                  
        left join dbo.portfolio p 
           on c.port_num = p.port_num                  
        left join dbo.jms_reports jr 
           on c.port_num = jr.port_num                  
        left outer join (select max(ct_doc_num) ct_doc_num,
                                trade_num,
                                order_num, 
                                item_num         
                         from dbo.assign_trade at1         
                         where not exists(select 1         
                                          from dbo.assign_trade at2         
                                          where at1.trade_num = at2.trade_num and 
                                                at1.order_num = at2.order_num and 
                                                at1.item_num = at2.item_num and 
                                                alloc_num is not null) 
                         group by trade_num, order_num, item_num) at          
           on c.cost_owner_key6 = at.trade_num and    
              c.cost_owner_key7 = at.order_num and 
              c.cost_owner_key8 = at.item_num          
        left outer join dbo.assign_trade at10          
           on c.cost_owner_key6 = at10.trade_num and    
              c.cost_owner_key7 = at10.order_num and 
              c.cost_owner_key8 = at10.item_num and
              c.cost_owner_key1 = at10.alloc_num and    
              c.cost_owner_key2 = at10.alloc_item_num                            
        left outer join dbo.lc l 
           on isnull(at.ct_doc_num, at10.ct_doc_num) = l.lc_num                 
        left join dbo.icts_user ciu 
           on ciu.user_init = l.lc_cr_analyst_init                  
        left join dbo.account lib 
           on l.lc_issuing_bank = lib.acct_num               
        left join dbo.entity_tag vstat 
           on vstat.entity_tag_id = 78 and 
              vstat.key1 = v.voucher_num                 
where cost_status != 'CLOSED'                   
GO
GRANT SELECT ON  [dbo].[v_cost_search] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_cost_search', NULL, NULL
GO
