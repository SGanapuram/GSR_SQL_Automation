SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchUomRevPK]
(
   @asof_trans_id      int,
   @uom_code           char(4)
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.uom
where uom_code = @uom_code
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      resp_trans_id = null,
      trans_id,
      uom_code,
      uom_full_name,
      uom_num,
      uom_short_name,
      uom_status,
      uom_type
   from dbo.uom
   where uom_code = @uom_code
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      resp_trans_id,
      trans_id,
      uom_code,
      uom_full_name,
      uom_num,
      uom_short_name,
      uom_status,
      uom_type
   from dbo.aud_uom
   where uom_code = @uom_code and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchUomRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchUomRevPK', NULL, NULL
GO
