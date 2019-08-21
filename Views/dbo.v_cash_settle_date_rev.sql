SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_cash_settle_date_rev]
(
   trade_num,
   order_num,
   cash_settle_num,
   cash_settle_date,
   cash_settle_status,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   trade_num,
   order_num,
   cash_settle_num,
   cash_settle_date,
   cash_settle_status,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_cash_settle_date
GO
GRANT SELECT ON  [dbo].[v_cash_settle_date_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_cash_settle_date_rev] TO [next_usr]
GO
