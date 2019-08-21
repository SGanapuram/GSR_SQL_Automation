SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchPlHistoryRevPK]
(
   @asof_trans_id      bigint,
   @pl_asof_date       datetime,
   @pl_owner_code      char(8),
   @pl_record_key      int,
   @pl_type            char(8)
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.pl_history
where pl_asof_date = @pl_asof_date and
      pl_record_key = @pl_record_key and
      pl_owner_code = @pl_owner_code and
      pl_type = @pl_type
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      currency_fx_rate,
      pl_amt,
      pl_asof_date,
      pl_category_type,
      pl_cost_prin_addl_ind,
      pl_cost_status_code,
      pl_mkt_price,
      pl_owner_code,
      pl_owner_sub_code,
      pl_primary_owner_key1,
      pl_primary_owner_key2,
      pl_primary_owner_key3,
      pl_primary_owner_key4,
      pl_realization_date,
      pl_record_key,
      pl_record_owner_key,
      pl_record_qty,
      pl_record_qty_uom_code,
      pl_secondary_owner_key1,
      pl_secondary_owner_key2,
      pl_secondary_owner_key3,
      pl_type,
      pos_num,
      real_port_num,
      resp_trans_id = null,
      trans_id
   from dbo.pl_history
   where pl_asof_date = @pl_asof_date and
         pl_record_key = @pl_record_key and
         pl_owner_code = @pl_owner_code and
         pl_type = @pl_type
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      currency_fx_rate,
      pl_amt,
      pl_asof_date,
      pl_category_type,
      pl_cost_prin_addl_ind,
      pl_cost_status_code,
      pl_mkt_price,
      pl_owner_code,
      pl_owner_sub_code,
      pl_primary_owner_key1,
      pl_primary_owner_key2,
      pl_primary_owner_key3,
      pl_primary_owner_key4,
      pl_realization_date,
      pl_record_key,
      pl_record_owner_key,
      pl_record_qty,
      pl_record_qty_uom_code,
      pl_secondary_owner_key1,
      pl_secondary_owner_key2,
      pl_secondary_owner_key3,
      pl_type,
      pos_num,
      real_port_num,
      resp_trans_id,
      trans_id
   from dbo.aud_pl_history
   where pl_asof_date = @pl_asof_date and
         pl_record_key = @pl_record_key and
         pl_owner_code = @pl_owner_code and
         pl_type = @pl_type and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchPlHistoryRevPK] TO [next_usr]
GO
