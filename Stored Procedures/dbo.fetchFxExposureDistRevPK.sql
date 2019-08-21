SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchFxExposureDistRevPK]
(
   @asof_trans_id      bigint,
   @oid                int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.fx_exposure_dist
where oid = @oid
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      fx_amt,
      fx_custom_column1,
      fx_custom_column2,
      fx_custom_column3,
      fx_custom_column4,
      fx_drop_date,
      fx_exp_num,
      fx_owner_code,
      fx_owner_key1,
      fx_owner_key2,
      fx_owner_key3,
      fx_owner_key4,
      fx_owner_key5,
      fx_owner_key6,
      fx_price,
      fx_price_curr_code,
      fx_price_uom_code,
      fx_priced_amt,
      fx_qty,
      fx_qty_uom_code,
      fx_real_port_num,
      item_num,
      oid,
      order_num,
      resp_trans_id = null,
      trade_num,
      trans_id
   from dbo.fx_exposure_dist
   where oid = @oid
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      fx_amt,
      fx_custom_column1,
      fx_custom_column2,
      fx_custom_column3,
      fx_custom_column4,
      fx_drop_date,
      fx_exp_num,
      fx_owner_code,
      fx_owner_key1,
      fx_owner_key2,
      fx_owner_key3,
      fx_owner_key4,
      fx_owner_key5,
      fx_owner_key6,
      fx_price,
      fx_price_curr_code,
      fx_price_uom_code,
      fx_priced_amt,
      fx_qty,
      fx_qty_uom_code,
      fx_real_port_num,
      item_num,
      oid,
      order_num,
      resp_trans_id,
      trade_num,
      trans_id
   from dbo.aud_fx_exposure_dist
   where oid = @oid and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchFxExposureDistRevPK] TO [next_usr]
GO
