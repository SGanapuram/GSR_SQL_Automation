SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_trade_order_all_rs]
(
   trade_num,
   order_num,
   order_type_code,
   order_status_code,
   parent_order_ind,
   parent_order_num,
   order_strategy_num,
   order_strategy_name,
   order_strip_num,
   strip_summary_ind,
   strip_detail_order_count,
   strip_periodicity,
   strip_order_status,
   term_evergreen_ind,
   bal_ind,
   margin_amt,
   margin_amt_curr_code,
   cmnt_num,
   efp_last_post_date,
   cash_settle_type,
   cash_settle_saturdays,
   cash_settle_sundays,
   cash_settle_holidays,
   cash_settle_prd_freq,
   cash_settle_prd_start_date,
   commitment_ind,
   max_item_num,
   trans_id,
   resp_trans_id,
   internal_parent_trade_num,
   internal_parent_order_num,
   trans_type,
   trans_user_init,
   tran_date,
   app_name,
   workstation_id,
   sequence
)
as
select
   maintb.trade_num,
   maintb.order_num,
   maintb.order_type_code,
   maintb.order_status_code,
   maintb.parent_order_ind,
   maintb.parent_order_num,
   maintb.order_strategy_num,
   maintb.order_strategy_name,
   maintb.order_strip_num,
   maintb.strip_summary_ind,
   maintb.strip_detail_order_count,
   maintb.strip_periodicity,
   maintb.strip_order_status,
   maintb.term_evergreen_ind,
   maintb.bal_ind,
   maintb.margin_amt,
   maintb.margin_amt_curr_code,
   maintb.cmnt_num,
   maintb.efp_last_post_date,
   maintb.cash_settle_type,
   maintb.cash_settle_saturdays,
   maintb.cash_settle_sundays,
   maintb.cash_settle_holidays,
   maintb.cash_settle_prd_freq,
   maintb.cash_settle_prd_start_date,
   maintb.commitment_ind,
   maintb.max_item_num,
   maintb.trans_id,
   null,
   maintb.internal_parent_trade_num,
   maintb.internal_parent_order_num,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.trade_order maintb
        left outer join dbo.icts_transaction it
           on maintb.trans_id = it.trans_id
union
select
   audtb.trade_num,
   audtb.order_num,
   audtb.order_type_code,
   audtb.order_status_code,
   audtb.parent_order_ind,
   audtb.parent_order_num,
   audtb.order_strategy_num,
   audtb.order_strategy_name,
   audtb.order_strip_num,
   audtb.strip_summary_ind,
   audtb.strip_detail_order_count,
   audtb.strip_periodicity,
   audtb.strip_order_status,
   audtb.term_evergreen_ind,
   audtb.bal_ind,
   audtb.margin_amt,
   audtb.margin_amt_curr_code,
   audtb.cmnt_num,
   audtb.efp_last_post_date,
   audtb.cash_settle_type,
   audtb.cash_settle_saturdays,
   audtb.cash_settle_sundays,
   audtb.cash_settle_holidays,
   audtb.cash_settle_prd_freq,
   audtb.cash_settle_prd_start_date,
   audtb.commitment_ind,
   audtb.max_item_num,
   audtb.trans_id,
   audtb.resp_trans_id,
   audtb.internal_parent_trade_num,
   audtb.internal_parent_order_num,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.aud_trade_order audtb
        left outer join dbo.icts_transaction it
           on audtb.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_trade_order_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_trade_order_all_rs] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[v_trade_order_all_rs] TO [public]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_trade_order_all_rs', NULL, NULL
GO
