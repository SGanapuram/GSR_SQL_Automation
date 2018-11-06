SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_fx_exposure_dist_rev]
(
    oid,
    fx_owner_code,
    fx_exp_num,
    fx_owner_key1,
    fx_owner_key2,
    fx_owner_key3,
    fx_owner_key4,
    fx_owner_key5,
    fx_owner_key6,
    trade_num,
    order_num,
    item_num,
    fx_qty,
    fx_price,
    fx_amt,
    fx_qty_uom_code,
    fx_price_curr_code,
    fx_price_uom_code,
    fx_drop_date,
    fx_priced_amt,
    fx_real_port_num,
    fx_custom_column1,
    fx_custom_column2,
    fx_custom_column3,
    fx_custom_column4,
    trans_id,
    asof_trans_id,
    resp_trans_id
)
as
select
    oid,
    fx_owner_code,
    fx_exp_num,
    fx_owner_key1,
    fx_owner_key2,
    fx_owner_key3,
    fx_owner_key4,
    fx_owner_key5,
    fx_owner_key6,
    trade_num,
    order_num,
    item_num,
    fx_qty,
    fx_price,
    fx_amt,
    fx_qty_uom_code,
    fx_price_curr_code,
    fx_price_uom_code,
    fx_drop_date,
    fx_priced_amt,
    fx_real_port_num,
    fx_custom_column1,
    fx_custom_column2,
    fx_custom_column3,
    fx_custom_column4,
    trans_id,
    trans_id,
    resp_trans_id
from dbo.aud_fx_exposure_dist
GO
GRANT SELECT ON  [dbo].[v_fx_exposure_dist_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_fx_exposure_dist_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_fx_exposure_dist_rev', NULL, NULL
GO
