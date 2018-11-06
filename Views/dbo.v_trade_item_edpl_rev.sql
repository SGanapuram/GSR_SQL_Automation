SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_trade_item_edpl_rev]
(
    trade_num,
    order_num,
    item_num,
    open_trade_value,
    closed_trade_value,
    market_value,
    trade_qty,
    latest_pl,
    day_pl,
    trade_modified_after_pass,
    asof_date,
    trans_id,
    asof_trans_id,
    resp_trans_id,
    addl_cost_sum
)
as
select
    trade_num,
    order_num,
    item_num,
    open_trade_value,
    closed_trade_value,
    market_value,
    trade_qty,
    latest_pl,
    day_pl,
    trade_modified_after_pass,
    asof_date,
    trans_id,
    trans_id,
    resp_trans_id,
    addl_cost_sum
from dbo.aud_trade_item_edpl
GO
GRANT SELECT ON  [dbo].[v_trade_item_edpl_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_trade_item_edpl_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_trade_item_edpl_rev', NULL, NULL
GO
