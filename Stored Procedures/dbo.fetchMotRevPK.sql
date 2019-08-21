SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchMotRevPK]
(
   @asof_trans_id      bigint,
   @mot_code           char(8)
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.mot
where mot_code = @mot_code
 
if @trans_id <= @asof_trans_id
begin
   select
      acct_num,
      asof_trans_id = @asof_trans_id,
      imo_num,
      mot_code,
      mot_full_name,
      mot_short_name,
      mot_status,
      mot_type_code,
      ppl_basis_loc_code,
      ppl_cycle_freq,
      ppl_enforce_loc_seq_ind,
      ppl_loss_allowance,
      ppl_num_of_cycles,
      ppl_split_cycle_ind,
      ppl_tariff_type,
      resp_trans_id = null,
      ship_reg,
      trans_id,
      transport_item_num,
      transport_order_num,
      transport_trade_num
   from dbo.mot
   where mot_code = @mot_code
end
else
begin
   select top 1
      acct_num,
      asof_trans_id = @asof_trans_id,
      imo_num,
      mot_code,
      mot_full_name,
      mot_short_name,
      mot_status,
      mot_type_code,
      ppl_basis_loc_code,
      ppl_cycle_freq,
      ppl_enforce_loc_seq_ind,
      ppl_loss_allowance,
      ppl_num_of_cycles,
      ppl_split_cycle_ind,
      ppl_tariff_type,
      resp_trans_id,
      ship_reg,
      trans_id,
      transport_item_num,
      transport_order_num,
      transport_trade_num
   from dbo.aud_mot
   where mot_code = @mot_code and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchMotRevPK] TO [next_usr]
GO
