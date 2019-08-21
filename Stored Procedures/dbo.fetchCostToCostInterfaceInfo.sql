SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchCostToCostInterfaceInfo]
(
   @asof_trans_id      bigint,
   @cost_num           int
)
as
set nocount on
 
   select aot_status,
          aot_status_mod_date,
          aot_status_mod_init,
          asof_trans_id = @asof_trans_id,
          cost_num,
          resp_trans_id = NULL,
          sent_on_date,
          tax_rate,
          trans_id
   from dbo.cost_interface_info
   where cost_num = @cost_num and
         trans_id <= @asof_trans_id
   union
   select aot_status,
          aot_status_mod_date,
          aot_status_mod_init,
          asof_trans_id = @asof_trans_id,
          cost_num,
          resp_trans_id,
          sent_on_date,
          tax_rate,
          trans_id
   from dbo.aud_cost_interface_info
   where cost_num = @cost_num and
         (trans_id <= @asof_trans_id and
          resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchCostToCostInterfaceInfo] TO [next_usr]
GO
