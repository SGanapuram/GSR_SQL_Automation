SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_trade_order_bunker_rev]
(
   trade_num,
   order_num,
   bunker_type,
   duty_ind,
   vat_ind,
   auto_alloc_ind,
   not_to_vouch_ind,
   brkr_num,
   brkr_cont_num,
   brkr_ref_num,
   brkr_tel_num,
   comm_amt,
   comm_curr_code,
   comm_uom_code,
   transp_price_comp_ind,
   transp_price_type,
   transp_price_amt,
   transp_price_curr_code,
   fiscal_class_code,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   trade_num,
   order_num,
   bunker_type,
   duty_ind,
   vat_ind,
   auto_alloc_ind,
   not_to_vouch_ind,
   brkr_num,
   brkr_cont_num,
   brkr_ref_num,
   brkr_tel_num,
   comm_amt,
   comm_curr_code,
   comm_uom_code,
   transp_price_comp_ind,
   transp_price_type,
   transp_price_amt,
   transp_price_curr_code,
   fiscal_class_code,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_trade_order_bunker
GO
GRANT SELECT ON  [dbo].[v_trade_order_bunker_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_trade_order_bunker_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_trade_order_bunker_rev', NULL, NULL
GO
