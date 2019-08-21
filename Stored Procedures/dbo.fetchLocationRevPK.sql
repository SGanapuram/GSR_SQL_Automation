SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchLocationRevPK]
(
   @asof_trans_id      bigint,
   @loc_code           char(8)
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.location
where loc_code = @loc_code
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      del_loc_ind,
      inv_loc_ind,
      latitude,
      loc_code,
      loc_name,
      loc_num,
      loc_status,
      longitude,
      office_loc_ind,
      resp_trans_id = null,
      trans_id,
      warehouse_agp_num
   from dbo.location
   where loc_code = @loc_code
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      del_loc_ind,
      inv_loc_ind,
      latitude,
      loc_code,
      loc_name,
      loc_num,
      loc_status,
      longitude,
      office_loc_ind,
      resp_trans_id,
      trans_id,
      warehouse_agp_num
   from dbo.aud_location
   where loc_code = @loc_code and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchLocationRevPK] TO [next_usr]
GO
