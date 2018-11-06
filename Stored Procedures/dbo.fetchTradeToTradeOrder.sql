SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchTradeToTradeOrder]
(
   @asof_trans_id  int,
   @trade_num      int
)
as
set nocount on

select
    asof_trans_id = @asof_trans_id,
    bal_ind,
    cash_settle_holidays,
    cash_settle_prd_freq,
    cash_settle_prd_start_date,
    cash_settle_saturdays,
    cash_settle_sundays,
    cash_settle_type,
    cmnt_num,
    commitment_ind,
    efp_last_post_date,
    internal_parent_order_num,
    internal_parent_trade_num,
    margin_amt,
    margin_amt_curr_code,
    max_item_num,
    order_num,
    order_status_code,
    order_strategy_name,
    order_strategy_num,
    order_strip_num,
    order_type_code,
    parent_order_ind,
    parent_order_num,
    resp_trans_id = NULL,
    strip_detail_order_count,
    strip_order_status,
    strip_periodicity,
    strip_summary_ind,
    term_evergreen_ind,
    trade_num,
    trans_id
from dbo.trade_order
where trade_num = @trade_num and 
      trans_id <= @asof_trans_id
union
select
    asof_trans_id = @asof_trans_id,
    bal_ind,
    cash_settle_holidays,
    cash_settle_prd_freq,
    cash_settle_prd_start_date,
    cash_settle_saturdays,
    cash_settle_sundays,
    cash_settle_type,
    cmnt_num,
    commitment_ind,
    efp_last_post_date,
    internal_parent_order_num,
    internal_parent_trade_num,
    margin_amt,
    margin_amt_curr_code,
    max_item_num,
    order_num,
    order_status_code,
    order_strategy_name,
    order_strategy_num,
    order_strip_num,
    order_type_code,
    parent_order_ind,
    parent_order_num,
    resp_trans_id,
    strip_detail_order_count,
    strip_order_status,
    strip_periodicity,
    strip_summary_ind,
    term_evergreen_ind,
    trade_num,
    trans_id
from dbo.aud_trade_order
where trade_num = @trade_num and 
      (trans_id <= @asof_trans_id and 
       resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchTradeToTradeOrder] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchTradeToTradeOrder', NULL, NULL
GO
