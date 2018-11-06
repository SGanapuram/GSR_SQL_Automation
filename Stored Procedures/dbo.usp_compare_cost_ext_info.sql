SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_compare_cost_ext_info] 
(  
   @resp_trans_id_NEW      int,    
   @resp_trans_id_OLD      int,    
   @portnum                int = null,    
   @digits_for_scale4      tinyint = 4,    
   @digits_for_scale7      tinyint = 7
)      
as    
set nocount on    
    
   print ' '    
   print '==================================================='    
   print ' DATA : cost_ext_info'    
   print '==================================================='    
   print ' '    
    
   select resp_trans_id,   
          cost_num,  
          pr_cost_num,  
          prepayment_ind,  
          voyage_code,  
          qty_adj_rule_num,  
          str(qty_adj_factor, 38, @digits_for_scale7) as qty_adj_factor,  
          orig_voucher_num,  
          pay_term_override_ind,  
          str(vat_rate, 38, @digits_for_scale4) as vat_rate,  
          str(discount_rate, 38, @digits_for_scale7) as discount_rate,  
          cost_pl_contribution_ind,  
          material_code,  
          related_cost_num,  
          fx_exp_num,  
          str(creation_fx_rate, 38, @digits_for_scale7) as creation_fx_rate,  
          creation_rate_m_d_ind,  
          fx_link_oid,  
          fx_locking_status,  
          fx_compute_ind,  
          fx_real_port_num,  
          str(reserve_cost_amt, 38, @digits_for_scale7) as reserve_cost_amt,  
          pl_contrib_mod_transid,  
          manual_input_pl_contrib_ind,  
          cost_desc,  
          risk_cover_num,  
          prelim_type_override_ind,  
          lc_num,  
          trans_id  
      into #costei  
   from dbo.aud_cost_ext_info    
   where resp_trans_id in (@resp_trans_id_NEW, @resp_trans_id_OLD)     
       
   select     
      min(resp_trans_id) as resp_trans_id,     
      cost_num,  
      pr_cost_num,  
      prepayment_ind,  
      voyage_code,  
      qty_adj_rule_num,  
      qty_adj_factor,  
      orig_voucher_num,  
      pay_term_override_ind,  
      vat_rate,  
      discount_rate,  
      cost_pl_contribution_ind,  
      material_code,  
      related_cost_num,  
      fx_exp_num,  
      creation_fx_rate,  
      creation_rate_m_d_ind,  
      fx_link_oid,  
      fx_locking_status,  
      fx_compute_ind,  
      fx_real_port_num,  
      reserve_cost_amt,  
      pl_contrib_mod_transid,  
      manual_input_pl_contrib_ind,  
      cost_desc,  
      risk_cover_num,  
      prelim_type_override_ind,  
      lc_num,  
      min(trans_id) as trans_id1    
        into #costei1    
   from #costei    
   group by cost_num,pr_cost_num,prepayment_ind,voyage_code,
            qty_adj_rule_num,qty_adj_factor,orig_voucher_num,  
            pay_term_override_ind,vat_rate,discount_rate,
            cost_pl_contribution_ind,material_code,related_cost_num,  
            fx_exp_num,creation_fx_rate,creation_rate_m_d_ind,
            fx_link_oid,fx_locking_status,fx_compute_ind,  
            fx_real_port_num,reserve_cost_amt,pl_contrib_mod_transid,
            manual_input_pl_contrib_ind,cost_desc,  
            risk_cover_num,prelim_type_override_ind,lc_num  
   having count(*) = 1    
   order by cost_num, resp_trans_id        
   drop table #costei     
    
   select     
      'NEW' as PASS,    
      resp_trans_id,     
      cost_num,  
      str(pr_cost_num) as pr_cost_num,  
      prepayment_ind,  
      voyage_code,  
      str(qty_adj_rule_num) as qty_adj_rule_num,  
      qty_adj_factor,  
      str(orig_voucher_num) as orig_voucher_num,  
      pay_term_override_ind,  
      vat_rate,  
      discount_rate,  
      cost_pl_contribution_ind,  
      material_code,  
      str(related_cost_num) as related_cost_num,  
      str(fx_exp_num) as fx_exp_num,  
      creation_fx_rate,  
      creation_rate_m_d_ind,  
      str(fx_link_oid) as fx_link_oid,  
      fx_locking_status,  
      fx_compute_ind,  
      str(fx_real_port_num) as fx_real_port_num,  
      reserve_cost_amt,  
      str(pl_contrib_mod_transid) as pl_contrib_mod_transid,  
      manual_input_pl_contrib_ind,  
      cost_desc,  
      str(risk_cover_num) as risk_cover_num,  
      prelim_type_override_ind,  
      str(lc_num) as lc_num,  
      trans_id1    
   from #costei1    
   where resp_trans_id = @resp_trans_id_NEW    
   union          
   select     
      'OLD' as PASS,    
      b.resp_trans_id,    
      b.cost_num,    
      case when isnull(a.pr_cost_num, -1) <> isnull(b.pr_cost_num, -1)     
              then b.pr_cost_num    
           else ' '    
      end as pr_cost_num,   
      case when isnull(a.prepayment_ind, '@@@') <> isnull(b.prepayment_ind, '@@@')     
              then b.prepayment_ind    
           else ' '    
      end as prepayment_ind,   
      case when isnull(a.voyage_code, '@@@') <> isnull(b.voyage_code, '@@@')     
              then b.voyage_code    
           else ' '    
      end as voyage_code,   
      case when isnull(a.qty_adj_rule_num, -1) <> isnull(b.qty_adj_rule_num, -1)     
              then b.qty_adj_rule_num    
           else ' '    
      end as qty_adj_rule_num,   
      case when isnull(a.qty_adj_factor, '@@@') <> isnull(b.qty_adj_factor, '@@@')     
              then b.qty_adj_factor    
           else ' '    
      end as qty_adj_factor,   
      case when isnull(a.orig_voucher_num, -1) <> isnull(b.orig_voucher_num, -1)     
              then b.orig_voucher_num    
           else ' '    
      end as orig_voucher_num,   
      case when isnull(a.pay_term_override_ind, '@@@') <> isnull(b.pay_term_override_ind, '@@@')     
              then b.pay_term_override_ind    
           else ' '    
      end as pay_term_override_ind,   
      case when isnull(a.vat_rate, '@@@') <> isnull(b.vat_rate, '@@@')     
              then b.vat_rate    
           else ' '    
      end as vat_rate,   
      case when isnull(a.discount_rate, '@@@') <> isnull(b.discount_rate, '@@@')     
              then b.discount_rate    
           else ' '    
      end as discount_rate,   
      case when isnull(a.cost_pl_contribution_ind, '@@@') <> isnull(b.cost_pl_contribution_ind, '@@@')     
              then b.cost_pl_contribution_ind    
           else ' '    
      end as cost_pl_contribution_ind,   
      case when isnull(a.material_code, '@@@') <> isnull(b.material_code, '@@@')     
              then b.material_code    
           else ' '    
      end as material_code,   
      case when isnull(a.related_cost_num, -1) <> isnull(b.related_cost_num, -1)     
              then b.related_cost_num    
           else ' '    
      end as related_cost_num,   
      case when isnull(a.fx_exp_num, -1) <> isnull(b.fx_exp_num, -1)     
              then b.fx_exp_num    
           else ' '    
      end as fx_exp_num,   
      case when isnull(a.creation_fx_rate, '@@@') <> isnull(b.creation_fx_rate, '@@@')     
              then b.creation_fx_rate    
           else ' '    
      end as creation_fx_rate,   
      case when isnull(a.creation_rate_m_d_ind, '@@@') <> isnull(b.creation_rate_m_d_ind, '@@@')     
              then b.creation_rate_m_d_ind    
           else ' '    
      end as creation_rate_m_d_ind,   
      case when isnull(a.fx_link_oid, -1) <> isnull(b.fx_link_oid, -1)     
              then b.fx_link_oid    
           else ' '    
      end as fx_link_oid,   
      case when isnull(a.fx_locking_status, '@@@') <> isnull(b.fx_locking_status, '@@@')     
              then b.fx_locking_status    
           else ' '    
      end as fx_locking_status,   
      case when isnull(a.fx_compute_ind, '@@@') <> isnull(b.fx_compute_ind, '@@@')     
              then b.fx_compute_ind    
           else ' '    
      end as fx_compute_ind,   
      case when isnull(a.fx_real_port_num, -1) <> isnull(b.fx_real_port_num, -1)     
              then b.fx_real_port_num    
           else ' '    
      end as fx_real_port_num,   
      case when isnull(a.reserve_cost_amt, '@@@') <> isnull(b.reserve_cost_amt, '@@@')     
              then b.reserve_cost_amt    
           else ' '    
      end as reserve_cost_amt,   
      case when isnull(a.pl_contrib_mod_transid, -1) <> isnull(b.pl_contrib_mod_transid, -1)     
              then b.pl_contrib_mod_transid    
           else ' '    
      end as pl_contrib_mod_transid,   
      case when isnull(a.manual_input_pl_contrib_ind, '@@@') <> isnull(b.manual_input_pl_contrib_ind, '@@@')     
              then b.manual_input_pl_contrib_ind    
           else ' '    
      end as manual_input_pl_contrib_ind,   
      case when isnull(a.cost_desc, '@@@') <> isnull(b.cost_desc, '@@@')     
              then b.cost_desc    
           else ' '    
      end as cost_desc,   
      case when isnull(a.risk_cover_num, -1) <> isnull(b.risk_cover_num, -1)     
              then b.risk_cover_num    
           else ' '    
      end as risk_cover_num,   
      case when isnull(a.prelim_type_override_ind, '@@@') <> isnull(b.prelim_type_override_ind, '@@@')    
              then b.prelim_type_override_ind    
           else ' '    
      end as prelim_type_override_ind,  
      case when isnull(a.lc_num, -1) <> isnull(b.lc_num, -1)     
              then b.lc_num    
           else ' '    
      end as lc_num,  
      b.trans_id1      
   from (select *    
         from #costei1    
         where resp_trans_id = @resp_trans_id_NEW) a,    
        (select  *    
         from #costei1    
         where resp_trans_id = @resp_trans_id_OLD) b     
   where a.cost_num = b.cost_num  
   order by cost_num, resp_trans_id         
    
  drop table #costei1  
GO
GRANT EXECUTE ON  [dbo].[usp_compare_cost_ext_info] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_compare_cost_ext_info', NULL, NULL
GO
