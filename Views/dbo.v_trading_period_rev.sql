SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_trading_period_rev]
(
   commkt_key,
   trading_prd,
   last_trade_date,
   opt_exp_date,
   first_del_date,
   last_del_date,
   first_issue_date,
   last_issue_date,
   last_quote_date,
   trading_prd_desc,
   opt_eval_method,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   commkt_key,
   trading_prd,
   last_trade_date,
   opt_exp_date,
   first_del_date,
   last_del_date,
   first_issue_date,
   last_issue_date,
   last_quote_date,
   trading_prd_desc,
   opt_eval_method,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_trading_period
GO
GRANT SELECT ON  [dbo].[v_trading_period_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_trading_period_rev] TO [next_usr]
GO
