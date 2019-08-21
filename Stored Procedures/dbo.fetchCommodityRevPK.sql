SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[fetchCommodityRevPK]
   @asof_trans_id   bigint,
   @cmdty_code      char(8)
as
declare @trans_id   bigint

   select @trans_id = trans_id
   from dbo.commodity
   where cmdty_code = @cmdty_code
 
if @trans_id <= @asof_trans_id
begin
   select 
       asof_trans_id = @asof_trans_id,
       cmdty_category_code,
       cmdty_code,
       cmdty_full_name,
       cmdty_loc_desc,
       cmdty_short_name,
       cmdty_status,
       cmdty_tradeable_ind,
       cmdty_type,
       country_code,
       grade,
	     is_composite,
	     movements_require_specific_actuals,
       prim_curr_code,
       prim_curr_conv_rate,
       prim_uom_code,
       resp_trans_id = null,
       sec_uom_code,
       trans_id
   from dbo.commodity
   where cmdty_code = @cmdty_code
end
else
begin
   set rowcount 1
   select 
       asof_trans_id = @asof_trans_id,
       cmdty_category_code,
       cmdty_code,
       cmdty_full_name,
       cmdty_loc_desc,
       cmdty_short_name,
       cmdty_status,
       cmdty_tradeable_ind,
       cmdty_type,
       country_code,
       grade,
	     is_composite,
	     movements_require_specific_actuals,
       prim_curr_code,
       prim_curr_conv_rate,
       prim_uom_code,
       resp_trans_id,
       sec_uom_code,
       trans_id
   from dbo.aud_commodity
   where cmdty_code = @cmdty_code and
         trans_id <= @asof_trans_id and
	       resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchCommodityRevPK] TO [next_usr]
GO
