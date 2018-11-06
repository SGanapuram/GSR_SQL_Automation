SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_fx_exposure_dist_all_rs]
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
   resp_trans_id,
   trans_type,
   trans_user_init,
   tran_date,
   app_name,
   workstation_id,
   sequence
)
as
select
   maintb.oid,
   maintb.fx_owner_code,
   maintb.fx_exp_num,
   maintb.fx_owner_key1,
   maintb.fx_owner_key2,
   maintb.fx_owner_key3,
   maintb.fx_owner_key4,
   maintb.fx_owner_key5,
   maintb.fx_owner_key6,
   maintb.trade_num,
   maintb.order_num,
   maintb.item_num,
   maintb.fx_qty,
   maintb.fx_price,
   maintb.fx_amt,
   maintb.fx_qty_uom_code,
   maintb.fx_price_curr_code,
   maintb.fx_price_uom_code,
   maintb.fx_drop_date,
   maintb.fx_priced_amt,
   maintb.fx_real_port_num,
   maintb.fx_custom_column1,
   maintb.fx_custom_column2,
   maintb.fx_custom_column3,
   maintb.fx_custom_column4,
   maintb.trans_id,
   null,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.fx_exposure_dist maintb
        left outer join dbo.icts_transaction it
           on maintb.trans_id = it.trans_id
union
select
   audtb.oid,
   audtb.fx_owner_code,
   audtb.fx_exp_num,
   audtb.fx_owner_key1,
   audtb.fx_owner_key2,
   audtb.fx_owner_key3,
   audtb.fx_owner_key4,
   audtb.fx_owner_key5,
   audtb.fx_owner_key6,
   audtb.trade_num,
   audtb.order_num,
   audtb.item_num,
   audtb.fx_qty,
   audtb.fx_price,
   audtb.fx_amt,
   audtb.fx_qty_uom_code,
   audtb.fx_price_curr_code,
   audtb.fx_price_uom_code,
   audtb.fx_drop_date,
   audtb.fx_priced_amt,
   audtb.fx_real_port_num,
   audtb.fx_custom_column1,
   audtb.fx_custom_column2,
   audtb.fx_custom_column3,
   audtb.fx_custom_column4,
   audtb.trans_id,
   audtb.resp_trans_id,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.aud_fx_exposure_dist audtb
        left outer join dbo.icts_transaction it
           on audtb.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_fx_exposure_dist_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_fx_exposure_dist_all_rs] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[v_fx_exposure_dist_all_rs] TO [public]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_fx_exposure_dist_all_rs', NULL, NULL
GO
