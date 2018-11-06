SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchAiEstActualRevPK]
(
   @ai_est_actual_num   int,
   @alloc_item_num      int,
   @alloc_num           int,
   @asof_trans_id       int
)
as
set nocount on
declare @trans_id        int

   select @trans_id = trans_id
   from dbo.ai_est_actual
   where alloc_num = @alloc_num and
         alloc_item_num = @alloc_item_num and
         ai_est_actual_num = @ai_est_actual_num

if @trans_id <= @asof_trans_id
begin
   select 
       accum_num,
       actual_tax_m315_qty,
       actual_tax_mt_qty,
       ai_est_actual_date,
       ai_est_actual_gross_qty,
       ai_est_actual_ind,
       ai_est_actual_net_qty,
       ai_est_actual_num,
       ai_est_actual_short_cmnt,
       ai_gross_qty_uom_code,
       ai_net_qty_uom_code,
       alloc_item_num,
       alloc_num,
       asof_trans_id = @asof_trans_id,
       assay_final_ind,
       bol_code,
       del_loc_code,
       dest_trade_num,
       fixed_swing_qty_ind,
       insert_sequence,
       lease_num,
       manual_input_sec_ind,
       mot_code,
       owner_code,
       resp_trans_id = null,
       sap_position_num,
       scac_carrier_code,
       secondary_actual_gross_qty,
       secondary_actual_net_qty,
       secondary_qty_uom_code,
       start_load_date,
       stop_load_date,
       tertiary_gross_qty,
       tertiary_net_qty,
       tertiary_uom_code,
       ticket_num,
       trans_id,
       transporter_code
   from dbo.ai_est_actual
   where alloc_num = @alloc_num and
         alloc_item_num = @alloc_item_num and
         ai_est_actual_num = @ai_est_actual_num
end
else
begin
   select top 1
       accum_num,
       actual_tax_m315_qty,
       actual_tax_mt_qty,
       ai_est_actual_date,
       ai_est_actual_gross_qty,
       ai_est_actual_ind,
       ai_est_actual_net_qty,
       ai_est_actual_num,
       ai_est_actual_short_cmnt,
       ai_gross_qty_uom_code,
       ai_net_qty_uom_code,
       alloc_item_num,
       alloc_num,
       asof_trans_id = @asof_trans_id,
       assay_final_ind,
       bol_code,
       del_loc_code,
       dest_trade_num,
       fixed_swing_qty_ind,
       insert_sequence,
       lease_num,
       manual_input_sec_ind,
       mot_code,
       owner_code,
       resp_trans_id,
       sap_position_num,
       scac_carrier_code,
       secondary_actual_gross_qty,
       secondary_actual_net_qty,
       secondary_qty_uom_code,
       start_load_date,
       stop_load_date,
       tertiary_gross_qty,
       tertiary_net_qty,
       tertiary_uom_code,
       ticket_num,
       trans_id,
       transporter_code
   from dbo.aud_ai_est_actual
   where alloc_num = @alloc_num and
         alloc_item_num = @alloc_item_num and
         ai_est_actual_num = @ai_est_actual_num and
         trans_id <= @asof_trans_id and
	       resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchAiEstActualRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchAiEstActualRevPK', NULL, NULL
GO
