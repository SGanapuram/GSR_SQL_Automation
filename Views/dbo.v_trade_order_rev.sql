SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_trade_order_rev]
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
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
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
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_trade_order
GO
GRANT SELECT ON  [dbo].[v_trade_order_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_trade_order_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_trade_order_rev', NULL, NULL
GO
