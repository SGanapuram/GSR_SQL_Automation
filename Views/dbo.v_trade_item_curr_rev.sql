SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_trade_item_curr_rev]
(
   trade_num,
   order_num,
   item_num,
   payment_date,
   credit_term_code,
   ref_spot_rate,
   pay_curr_amt,
   pay_curr_code,
   rec_curr_amt,
   rec_curr_code,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   trade_num,
   order_num,
   item_num,
   payment_date,
   credit_term_code,
   ref_spot_rate,
   pay_curr_amt,
   pay_curr_code,
   rec_curr_amt,
   rec_curr_code,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_trade_item_curr
GO
GRANT SELECT ON  [dbo].[v_trade_item_curr_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_trade_item_curr_rev] TO [next_usr]
GO
