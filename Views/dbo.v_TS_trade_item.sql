SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_TS_trade_item]  
(
   trade_num,
   order_num,
   item_num,
   trade_key,
   order_type_code,
   item_type,
   cmdty_code,
   cmdty_short_name,
   cmdty_group,
   risk_mkt_code,
   mkt_short_name,
   commkt_key,
   p_s_ind,
   trading_prd,
   exch_brkr_num, 
   exchbrkr_acct_short_name,
   real_port_num,
   contr_qty_uom_code,
   contr_qty,
   contr_qty_periodicity,
   open_qty,
   total_sch_qty,
   price_curr_code,
   price_uom_code,
   avg_price,
   brkr_num,
   brkr_acct_short_name,
   brkr_comm_amt,
   brkr_comm_curr_code,
   brkr_comm_uom_code,
   brkr_ref_num,
   formula_ind,
   title_mkt_code,
   booking_comp_num,
   book_acct_short_name,    
   sched_status,
   tiny_cmnt,
   short_cmnt,
   cmnt_text,
   product,
   mtm_price_source_code,
   gtc_code,
   principle_cost_amt,
   accum_start_date,
   accum_end_date,
   prin_cost_vouch_paid_ind,
   finance_bank_num,
   is_rc_assigned,
   is_lc_assigned,   
   trans_id
) 
as
select
   ti.trade_num,
   ti.order_num,
   ti.item_num,
   cast(ti.trade_num as varchar) + '/' + cast(ti.order_num as varchar) + '/' + cast(ti.item_num as varchar), 
   trdord.order_type_code,
   ti.item_type,
   ti.cmdty_code,
   cm.cmdty_short_name,
   cg.parent_cmdty_code,
   ti.risk_mkt_code,
   cm.mkt_short_name,
   cm.commkt_key,
   ti.p_s_ind,
   ti.trading_prd,
   ti.exch_brkr_num, 
   exchbrkr.acct_short_name,
   ti.real_port_num,
   ti.contr_qty_uom_code,
   case when ti.p_s_ind = 'S' 
           then ti.contr_qty * -1 
        else ti.contr_qty  
   end,
   ti.contr_qty_periodicity,
   ti.open_qty,
   ti.total_sch_qty,
   ti.price_curr_code,
   ti.price_uom_code,
   ti.avg_price,
   ti.brkr_num,
   brkr.acct_short_name,
   ti.brkr_comm_amt,
   ti.brkr_comm_curr_code,
   ti.brkr_comm_uom_code,
   ti.brkr_ref_num,
   ti.formula_ind,
   ti.title_mkt_code,
   ti.booking_comp_num,
   book.acct_short_name,
   ti.sched_status,    
   cmnt.tiny_cmnt,
   cmnt.short_cmnt,
   cmnt.cmnt_text,
   case when trdord.order_type_code in ('SWAP', 'SWAPFLT')
           then isnull(ti.idms_acct_alloc, cmnt.tiny_cmnt)
        else null
   end,
   cm.mtm_price_source_code,
   ti.gtc_code,
   c.principle_cost_amt,
   acc.accum_start_date,
   acc.accum_end_date,
   case when c1.no_paid_vouched_cost_ind is not null 
           then 'N'
        else 'Y'
   end,
   ti.finance_bank_num,
   ti.is_rc_assigned,
   ti.is_lc_assigned,   
   ti.trans_id
from dbo.trade_item ti
        JOIN dbo.trade_order trdord
           on trdord.trade_num = ti.trade_num and
              trdord.order_num = ti.order_num and
              trdord.strip_summary_ind = 'N'
        LEFT OUTER JOIN dbo.v_TS_commkt_info cm
           ON cm.cmdty_code = ti.cmdty_code and
              cm.mkt_code = ti.risk_mkt_code
        LEFT OUTER JOIN dbo.account exchbrkr with (nolock)
           on exchbrkr.acct_num = ti.exch_brkr_num
        LEFT OUTER JOIN dbo.account brkr with (nolock)
           on brkr.acct_num = ti.brkr_num
        LEFT OUTER JOIN dbo.account book with (nolock)
           on book.acct_num = ti.booking_comp_num
        LEFT OUTER JOIN dbo.commodity_group cg with (nolock)
           on cg.cmdty_group_type_code = 'CREDIT' and
              cg.cmdty_code = ti.cmdty_code
        LEFT OUTER JOIN dbo.comment cmnt
           on ti.cmnt_num = cmnt.cmnt_num
        LEFT OUTER JOIN dbo.v_TS_accumulation_info acc
           ON ti.trade_num = acc.trade_num and
              ti.order_num = acc.order_num and
              ti.item_num = acc.item_num
        LEFT OUTER JOIN dbo.v_TS_trade_cost_info c
           ON c.cost_owner_key6 = ti.trade_num and
              c.cost_owner_key7 = ti.order_num and
              c.cost_owner_key8 = ti.item_num
        LEFT OUTER JOIN (select distinct 
                            cost_owner_key6,
                            cost_owner_key7,
                            cost_owner_key8,
                            'Y' as no_paid_vouched_cost_ind
                         from dbo.cost cst
                         where exists (select 1
                                       from dbo.v_TS_trade_cost_info c
                                       where cst.cost_owner_key6 = c.cost_owner_key6 and
                                             cst.cost_owner_key7 = c.cost_owner_key7 and
                                             cst.cost_owner_key8 = c.cost_owner_key8) and
                               isnull(cost_status, 'CLOSED') in ('OPEN', 'HELD')) c1
           ON c1.cost_owner_key6 = ti.trade_num and
              c1.cost_owner_key7 = ti.order_num and
              c1.cost_owner_key8 = ti.item_num
GO
GRANT SELECT ON  [dbo].[v_TS_trade_item] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_TS_trade_item] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_TS_trade_item', NULL, NULL
GO
