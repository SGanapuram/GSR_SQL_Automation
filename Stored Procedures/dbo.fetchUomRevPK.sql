SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchUomRevPK]
(
   @asof_trans_id      bigint,
   @uom_code           char(4)
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.uom
where uom_code = @uom_code
 
if @trans_id <= @asof_trans_id
begin
   select
      adj1_mult_div_ind,
      adj2_mult_div_ind,
      asof_trans_id = @asof_trans_id,
	  conv_factor,
      resp_trans_id = null,
	  spec_code_adj1,
      spec_code_adj2,
      trans_id,
      uom_code,
	  uom_convert_to,
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
      adj1_mult_div_ind,
      adj2_mult_div_ind,
      asof_trans_id = @asof_trans_id,
	  conv_factor,
      resp_trans_id,
	  spec_code_adj1,
      spec_code_adj2,
      trans_id,
      uom_code,
	  uom_convert_to,
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
