SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_mot_rev]
(
   mot_code,
   mot_type_code,
   mot_short_name,
   mot_full_name,
   ppl_basis_loc_code,
   ppl_loss_allowance,
   ppl_cycle_freq,
   ppl_num_of_cycles,
   ppl_split_cycle_ind,
   acct_num,
   ppl_tariff_type,
   ppl_enforce_loc_seq_ind,
   transport_trade_num,
   transport_order_num,
   transport_item_num,
   mot_status,
   ship_reg,
   imo_num,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   mot_code,
   mot_type_code,
   mot_short_name,
   mot_full_name,
   ppl_basis_loc_code,
   ppl_loss_allowance,
   ppl_cycle_freq,
   ppl_num_of_cycles,
   ppl_split_cycle_ind,
   acct_num,
   ppl_tariff_type,
   ppl_enforce_loc_seq_ind,
   transport_trade_num,
   transport_order_num,
   transport_item_num,
   mot_status,
   ship_reg,
   imo_num,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_mot
GO
GRANT SELECT ON  [dbo].[v_mot_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_mot_rev] TO [next_usr]
GO
