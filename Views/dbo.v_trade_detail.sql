SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_trade_detail]                                    
(                                       
   trader,                                       
   contr_date,                                       
   trade_num,                                       
   trade_key,                                       
   trade_status_code,                                     
   counterparty,                                       
   clearing_broker,                                       
   order_type_code,                                       
   inhouse_ind,                                       
   real_port_num,                                       
   portfolio_booking_company,                                       
   port_group,                                       
   cmdty_group,                                       
   cmdty_code,                                       
   cmdty_short_name,                                       
   mkt_code,                                       
   mkt_short_name,                                       
   commkt_key,                                       
   trading_prd,                                       
   delivery_start_date,                                       
   delivery_end_date,                                       
   pricing_start_date,                                       
   pricing_end_date,                                       
   contract_p_s_ind,                                       
   contr_qty_uom_code,                                       
   lifetime_qty,                                     
   contract_qty,                                     
   contr_qty_periodicity,                                       
   open_qty,                                       
   total_sch_qty,                                       
   price_curr_code,                                       
   price_uom_code,                                       
   price,                                       
   put_call,                                       
   strike_price,                                       
   premium,                                       
   premium_uom,                                       
   premium_curr,                                       
   options_exp_date,                                       
   credit_term_code,                                       
   pay_days,                                       
   pay_term_code,                                       
   del_term_code,                                       
   mot_code,                                       
   del_loc_code,                                       
   transportation,                                       
   cfd_swap_ind,                                       
   efs_ind,                                       
   all_quotes_reqd_ind,                                       
   roll_days,                                       
   formula_precision,                                       
   formula_rounding_level,                                       
   mtm_price_source_code,                                       
   title_mkt_code,                                       
   formula_ind,                                       
   brkr_num,                                       
   broker,                                       
   brkr_comm_amt,                                      
   brkr_comm_curr_code,                                       
   brkr_comm_uom_code,                                       
   brkr_ref_num,                                       
   booking_comp_num,                                       
   booking_company,                                       
   trading_prd_month,                                       
   trading_prd_qtr,                                       
   trading_prd_year,                                       
   trading_prd_desc,                                       
   trading_prd_date,                                       
   credit_approved,                                       
   lc_required,                                       
   tolerance,                                       
   tol_uom,                                       
  tol_sign,                  
   tol_opt,                  
   tol_min_qty,                                       
   tol_max_qty,       
   density_ind,                                       
   trade_mod_date,                                       
   creation_date,                                       
 trans_id,                                             
   trade_trans_id,                                         
   product,                                       
   tiny_cmnt,                        
   short_cmnt,                                       
   comments,                                       
   acct_ref_num,                                       
   payment_date,                                
   ref_spot_rate,                                       
   pay_curr_amt,                                       
   pay_curr_code,                                       
   rec_curr_amt,                            
   rec_curr_code,                                       
   order_num,                                      
   item_num,                                     
   profit_center,                                     
   lc_num,                               
   lc_issue_date,                                     
   lc_exp_date,                                     
   lc_issuing_bank_num,                                     
   lc_issuing_bank_name,                                     
   bank_lc_num,                                    
   lc_cap_amount,                                     
   inter_company_ind,                                     
   conclusion_type,                                           
   item_type,                                           
   sched_status,                                       
   contract_anly_user,                                       
   roll,                                      
   credit_approval_date,                                          
   exchange_broker_short_name,                                      
   gtc_code,                                      
   lc_type_code,                                      
   mot_full_name,                                      
   credit_approver_init,                                  
   principle_cost_amt,                                    
   accum_start_date,                                    
   accum_end_date,                                       
   nominal_start_date,
   nominal_end_date,
   del_loc_name,                                     
   prin_cost_vouch_paid_ind,                                    
   counterparty_id,                                       
   exchange_brkr_num,                                       
   clearing_broker_id,                                     
   contr_status_code,                                     
   finance_bank_num,                                     
   lc_comment,                                     
   contr_anly_init,                            
   contr_load_port_name,                            
   contr_disch_port_name                            
)                                    
AS                                    
select distinct                                     
   trd.trader_init,                                      
   trd.contr_date,                                      
   trd.trade_num,                                        
   ti.trade_key,                                      
   trd.trade_status_code,                                       
   case when trd.inhouse_ind = 'Y'         
           then 'Inhouse' + '-' + convert(varchar, trd.port_num)                                           
        when trd.inhouse_ind = 'I'         
           then 'Internal' + '-' + convert(varchar, trd.port_num)                                           
        else isnull(trd.acct_short_name, trd.port_num)                                      
   end,                                        
   case when ti.order_type_code in ('SWAP','SWAPFLT')                                                
           then ti.exchbrkr_acct_short_name                                            
        else isnull(tif.clearing_broker, tieo.clearing_broker)                                        
   end,                    
   ti.order_type_code,                                        
   trd.inhouse_ind,                                      
   ti.real_port_num,                                       
   te.bookingcomp,                                     
   tid.group_code,                  
   ti.cmdty_group,                                      
   ti.cmdty_code,                                     
   ti.cmdty_short_name,                                      
   ti.risk_mkt_code,                                        
   ti.mkt_short_name,                                     
   ti.commkt_key,                           
   ti.trading_prd,                                       
   case when bunk.del_date is not null         
           then bunk.del_date         
        else         
           isnull(tiwp.del_date_from, isnull(tidp.del_date_from, isnull(tis.storage_start_date,tit.load_date_from)))         
   end,                                      
   case when bunk.del_date is not null         
           then bunk.del_date         
        else isnull(tiwp.del_date_to, isnull(tidp.del_date_to, isnull(tis.storage_end_date,tit.load_date_to)))         
   end,                                      
   case when bunk.pricing_exp_date is not null         
           then bunk.pricing_exp_date         
        else ti.nominal_start_date   
   end,                                        
   case when bunk.pricing_exp_date is not null         
           then bunk.pricing_exp_date         
        else ti.nominal_end_date   
   end,                                      
   ti.p_s_ind 'contract_p_s_ind',                                    
   ti.contr_qty_uom_code,                                     
   tid.lifetime_qty,                                     
   ti.contr_qty,                                     
   ti.contr_qty_periodicity,                                        
   ti.open_qty,                                      
   ti.total_sch_qty,                                        
   ti.price_curr_code,                                       
   ti.price_uom_code,                                       
   case when ti.order_type_code in ('SWAP')                        
           then                               
              case when isnumeric (isnull(fixprice.fix_price, '0')) = 1                                                           
                      then convert(float, replace( isnull(fixprice.fix_price, '0'),' ','')) * -1                                                        
                   else 0                                                   
              end                                            
        when ti.order_type_code in ('SWAPFLT')                                
           then case when isnumeric(isnull(fltprice.float_price, '0')) = 1                                                           
                        then convert(float, replace(isnull(fltprice.float_price, '0'),' ',''))                                                        
                     else 0                                                   
                end                                             
        else ti.avg_price                                        
   end,                                        
   isnull(tioo.put_call_ind, tieo.put_call_ind),                                        
   isnull(tioo.strike_price, tieo.strike_price),                                       
   isnull(tioo.premium, tieo.premium),                                        
   isnull(tioo.premium_uom_code, tieo.premium_uom_code),                                        
   isnull(tioo.premium_curr_code, tieo.premium_curr_code),                                        
   isnull(tioo.exp_date, tieo.exp_date),                                        
   case when bunk.credit_term_code is not null         
           then bunk.credit_term_code          
        else isnull(tiwp.credit_term_code, isnull( tidp.credit_term_code, ticp.credit_term_code))         
   end,                                         
   isnull(tiwp.pay_days, isnull(tidp.pay_days,ticp.pay_days)),                           
   isnull(tiwp.pay_term_code,isnull(tidp.pay_term_code, ticp.pay_term_code)),                                      
   isnull(tiwp.del_term_code, isnull( tidp.del_term_code, bunk.del_term_code)),                                       
   isnull(tiwp.mot_code, tidp.mot_code),                                      
   isnull(tiwp.del_loc_code, isnull( tidp.del_loc_code, bunk.storage_loc_code)),            
   isnull(tiwp.transportation,tidp.transportation),                                      
   ticp.cfd_swap_ind,                                      
   ticp.efs_ind,                                      
   all_quotes_reqd_ind,                                      
   roll_days,                                      
   formula_precision,                                     
   formula_rounding_level,                                       
   ti.mtm_price_source_code,                                        
   ti.title_mkt_code,                                       
   ti.formula_ind,                                      
   ti.brkr_num,                                      
   ti.brkr_acct_short_name,                                       
   ti.brkr_comm_amt,                                       
   ti.brkr_comm_curr_code,                                       
   ti.brkr_comm_uom_code,                                       
   ti.brkr_ref_num,                                       
   ti.booking_comp_num,                                       
   ti.book_acct_short_name,                                       
   substring(datename(mm, isnull(tp.last_issue_date, fixprice.price_term_end_date)), 1, 3),                                       
   'Q' + convert(char, datename(q, isnull(tp.last_issue_date, fixprice.price_term_end_date))),                                       
   datename(yyyy, isnull(tp.last_issue_date, fixprice.price_term_end_date)),                                       
   tp.trading_prd_desc,                                       
   isnull(tp.last_issue_date, fixprice.price_term_end_date),                                      
   case ti.sched_status & 4096 when 4096 then 'Y'                                                                 
                               else 'N'                                     
   end,                                     
   isnull(tiwp.lc_required,tidp.lc_required) ,                                      
   isnull(tiwp.tol_qty,tidp.tol_qty),                                      
   isnull(tiwp.tol_qty_uom_code,tidp.tol_qty_uom_code),                                 
   isnull(tiwp.tol_sign,tidp.tol_sign),                  
   isnull(tiwp.tol_opt, tidp.tol_opt),                 
   isnull(tiwp.min_qty, tidp.min_qty),                                       
   isnull(tiwp.max_qty,tidp.max_qty),                                        
   isnull(tiwp.density_ind,tidp.density_ind),                                       
   trd.trade_mod_date,                                        
   trd.creation_date,                                     
   ti.trans_id,                                      
   trd.trans_id,                                     
   ti.product,                                       
   ti.tiny_cmnt,                                        
   ti.short_cmnt,                                        
   ti.cmnt_text,                                        
   trd.acct_ref_num,                            
   tic.payment_date,                                       
   tic.ref_spot_rate,                                       
   tic.pay_curr_amt,                                       
   tic.pay_curr_code,                                   
   tic.rec_curr_amt,                                       
   tic.rec_curr_code,                                       
   ti.order_num,                                       
   ti.item_num,                                     
   pt.tag_value profit_center,                                     
   la.lc_num,                                     
   la.lc_issue_date,                                     
   la.lc_exp_date,                                     
   la.lc_issuing_bank_num,                       
   la.lc_issuing_bank_name,                                     
   la.bank_lc_num,                                     
   la.lc_cap_amount,                                     
   trd.inter_company_ind,                                     
   trd.conclusion_type,                                           
   ti.item_type,                                           
   ti.sched_status,                                       
   trd.contract_anly_user,                                       
   case when r.trade_num is not null then 'Y'                                          
        else 'N'                                     
   end,   /* roll */                                       
   isnull(tiwp.credit_approval_date,tidp.credit_approval_date),                                          
   ti.exchbrkr_acct_short_name,                                       
   ti.gtc_code,                                       
   la.lc_type_code,                                       
   isnull(tiwp.mot_full_name,tidp.mot_full_name),                                       
   isnull(tiwp.credit_approver_init, tidp.credit_approver_init),                                      
   ti.principle_cost_amt,                                       
   ti.accum_start_date,                                       
   ti.accum_end_date,                                       
   ti.nominal_start_date,
   ti.nominal_end_date,
   isnull(tiwp.del_loc_name, tidp.del_loc_name),                                    
   ti.prin_cost_vouch_paid_ind,                                     
   trd.acct_num,                                       
   ti.exch_brkr_num,                                       
   case when ti.order_type_code in ('SWAP','SWAPFLT')            
           then ti.exch_brkr_num                                              
        else isnull(tif.clr_brkr_num, tieo.clr_brkr_num)                                          
   end,                                     
   trd.contr_status_code,                                     
   ti.finance_bank_num,                                     
   case when agn.lc_comment is null then 0                                          
        else 1                                     
   end,                                     
   trd.contr_anly_init    ,                            
   ti.contr_load_port,                            
   ti.contr_disch_port                            
FROM dbo.v_TS_trade trd                                             
        INNER JOIN dbo.v_TS_trade_item ti                                           
           on trd.trade_num = ti.trade_num          
        LEFT OUTER JOIN portfolio_tag pt        
         on ti.real_port_num = pt.port_num and         
              pt.tag_name = 'PRFTCNTR'                          
        LEFT OUTER JOIN dbo.v_TS_roll_indicator r                                             
           on ti.trade_num = r.trade_num and                                                
              ti.order_num = r.order_num and                                                
              ti.item_num = r.item_num                                          
        LEFT OUTER JOIN dbo.v_TS_trade_item_dist tid                                              
           on ti.trade_num = tid.trade_num and               
              ti.order_num = tid.order_num and                                                 
              ti.item_num = tid.item_num                                           
        LEFT OUTER JOIN dbo.trade_formula tf1                                             
           on tf1.trade_num = ti.trade_num and                                                 
              tf1.order_num = ti.order_num and                                                 
              tf1.item_num = ti.item_num and                                                
              ti.order_type_code = 'SWAP'                                          
        LEFT OUTER JOIN dbo.trade_formula tf2                                             
           on tf2.trade_num = ti.trade_num and                                                 
     tf2.order_num = ti.order_num and                                                 
              tf2.item_num = ti.item_num and                                                
              ti.order_type_code = 'SWAPFLT'                                          
        LEFT OUTER JOIN dbo.trade_item_otc_opt tioo                                               
           on ti.trade_num = tioo.trade_num AND                                                 
              ti.order_num = tioo.order_num AND                                                 
              ti.item_num = tioo.item_num                                                 
		LEFT OUTER JOIN dbo.trade_item_curr tic                                               
           on ti.trade_num = tic.trade_num AND                                                 
              ti.order_num = tic.order_num AND                                                 
              ti.item_num = tic.item_num                                             
        LEFT OUTER JOIN dbo.v_TS_trade_item_exch_opt tieo                                             
           on ti.trade_num = tieo.trade_num AND                                                 
              ti.order_num = tieo.order_num AND                                                 
              ti.item_num = tieo.item_num                                             
        LEFT OUTER JOIN dbo.v_TS_trade_item_fut tif                                             
           on ti.trade_num = tif.trade_num and                                                 
              ti.order_num = tif.order_num and                                                 
              ti.item_num = tif.item_num                                             
        LEFT OUTER JOIN dbo.trading_period tp with (nolock)                                             
           on tp.commkt_key = ti.commkt_key and                                  
              tp.trading_prd = ti.trading_prd                                               
        LEFT OUTER JOIN v_TS_portfolio_booking_company te                                             
           on te.port_num = tid.real_port_num                                            
        LEFT OUTER JOIN dbo.v_TS_assign_trade at                                              
           on at.trade_num = ti.trade_num and                                                 
              at.order_num = ti.order_num and                                                 
              at.item_num = ti.item_num                                          
        LEFT OUTER JOIN dbo.v_TS_assign_trade1 agn                                             
           on agn.trade_num = ti.trade_num and                                                
              agn.order_num = ti.order_num and                                                
              agn.item_num = ti.item_num                                          
        LEFT OUTER JOIN dbo.v_TS_lc_allocation la                                              
           on la.lc_num = at.ct_doc_num                                          
        LEFT OUTER JOIN dbo.v_TS_trade_item_wet_phy tiwp                                              
           on ti.trade_num = tiwp.trade_num and                                                 
              ti.order_num = tiwp.order_num and                      
              ti.item_num = tiwp.item_num       
        LEFT OUTER JOIN dbo.v_TS_trade_item_dry_phy tidp                                              
           on ti.trade_num = tidp.trade_num and                                                 
              ti.order_num = tidp.order_num and                                                 
              ti.item_num = tidp.item_num                                               
        LEFT OUTER JOIN dbo.trade_item_bunker bunk                                              
           on ti.trade_num = bunk.trade_num and                                                 
    ti.order_num = bunk.order_num and                                                 
              ti.item_num = bunk.item_num                                            
        LEFT OUTER JOIN dbo.trade_item_cash_phy ticp                                              
           on ti.trade_num = ticp.trade_num and                                                 
              ti.order_num = ticp.order_num and                                                 
              ti.item_num = ticp.item_num                                            
        LEFT OUTER JOIN dbo.v_TS_fix_price fixprice                                              
           on fixprice.formula_num = tf1.formula_num                 
        LEFT OUTER JOIN dbo.v_TS_float_price fltprice                                              
           on fltprice.formula_num = tf2.formula_num                   
        LEFT OUTER JOIN dbo.trade_item_storage tis                                              
           on ti.trade_num = tis.trade_num and                                                 
              ti.order_num = tis.order_num and                                                 
              ti.item_num = tis.item_num                                            
        LEFT OUTER JOIN dbo.trade_item_transport tit                                              
           on ti.trade_num = tit.trade_num and                                      
              ti.order_num = tit.order_num and                                                 
              ti.item_num = tit.item_num
             
GO
GRANT SELECT ON  [dbo].[v_trade_detail] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_trade_detail', NULL, NULL
GO
