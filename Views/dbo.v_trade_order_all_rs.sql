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
   internal_parent_trade_num,
   internal_parent_order_num,
   storage_identifier,
   resp_trans_id,
   trans_id,
   trans_type,
   trans_user_init,
   tran_date,
   app_name,
   workstation_id,
   sequence
)
as
select
   trdord.trade_num,
   trdord.order_num,
   trdord.order_type_code,
   trdord.order_status_code,
   trdord.parent_order_ind,
   trdord.parent_order_num,
   trdord.order_strategy_num,
   trdord.order_strategy_name,
   trdord.order_strip_num,
   trdord.strip_summary_ind,
   trdord.strip_detail_order_count,
   trdord.strip_periodicity,
   trdord.strip_order_status,
   trdord.term_evergreen_ind,
   trdord.bal_ind,
   trdord.margin_amt,
   trdord.margin_amt_curr_code,
   trdord.cmnt_num,
   trdord.efp_last_post_date,
   trdord.cash_settle_type,
   trdord.cash_settle_saturdays,
   trdord.cash_settle_sundays,
   trdord.cash_settle_holidays,
   trdord.cash_settle_prd_freq,
   trdord.cash_settle_prd_start_date,
   trdord.commitment_ind,
   trdord.max_item_num,
   trdord.internal_parent_trade_num,
   trdord.internal_parent_order_num,
   trdord.storage_identifier,
   null,
   trdord.trans_id,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.trade_order trdord
    left outer join dbo.icts_transaction it
        on trdord.trans_id = it.trans_id
union
select
   trdord.trade_num,
   trdord.order_num,
   trdord.order_type_code,
   trdord.order_status_code,
   trdord.parent_order_ind,
   trdord.parent_order_num,
   trdord.order_strategy_num,
   trdord.order_strategy_name,
   trdord.order_strip_num,
   trdord.strip_summary_ind,
   trdord.strip_detail_order_count,
   trdord.strip_periodicity,
   trdord.strip_order_status,
   trdord.term_evergreen_ind,
   trdord.bal_ind,
   trdord.margin_amt,
   trdord.margin_amt_curr_code,
   trdord.cmnt_num,
   trdord.efp_last_post_date,
   trdord.cash_settle_type,
   trdord.cash_settle_saturdays,
   trdord.cash_settle_sundays,
   trdord.cash_settle_holidays,
   trdord.cash_settle_prd_freq,
   trdord.cash_settle_prd_start_date,
   trdord.commitment_ind,
   trdord.max_item_num,
   trdord.internal_parent_trade_num,
   trdord.internal_parent_order_num,
   trdord.storage_identifier,
   trdord.resp_trans_id,
   trdord.trans_id,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.aud_trade_order trdord
    left outer join dbo.icts_transaction it
        on trdord.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_trade_order_all_rs] TO [next_usr]
GO