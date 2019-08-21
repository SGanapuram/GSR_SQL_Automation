SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_voucher_cost_all_rs]
(
   voucher_num,
   cost_num,
   prov_price,
   prov_price_curr_code,
   prov_qty,
   prov_qty_uom_code,
   prov_amt,
   trans_id,
   resp_trans_id,
   line_num,
   voucher_cost_status,
   trans_type,
   trans_user_init,
   tran_date,
   app_name,
   workstation_id,
   sequence
)
as
select
   maintb.voucher_num,
   maintb.cost_num,
   maintb.prov_price,
   maintb.prov_price_curr_code,
   maintb.prov_qty,
   maintb.prov_qty_uom_code,
   maintb.prov_amt,
   maintb.trans_id,
   null,
   maintb.line_num,
   maintb.voucher_cost_status,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.voucher_cost maintb
        left outer join dbo.icts_transaction it
           on maintb.trans_id = it.trans_id
union
select
   audtb.voucher_num,
   audtb.cost_num,
   audtb.prov_price,
   audtb.prov_price_curr_code,
   audtb.prov_qty,
   audtb.prov_qty_uom_code,
   audtb.prov_amt,
   audtb.trans_id,
   audtb.resp_trans_id,
   audtb.line_num,
   audtb.voucher_cost_status,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.aud_voucher_cost audtb
        left outer join dbo.icts_transaction it
           on audtb.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_voucher_cost_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_voucher_cost_all_rs] TO [next_usr]
GO
