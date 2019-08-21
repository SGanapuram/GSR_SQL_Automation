SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_cost_interface_info_rev]
(
   cost_num,
   aot_status,
   aot_status_mod_date,
   aot_status_mod_init,
   tax_rate,
   sent_on_date,
   trans_id,
   asof_trans_id,                     
   resp_trans_id 
)
as
select
   cost_num,
   aot_status,
   aot_status_mod_date,
   aot_status_mod_init,
   tax_rate,
   sent_on_date,
   trans_id,
   trans_id,                      
   resp_trans_id 
from dbo.aud_cost_interface_info
GO
GRANT SELECT ON  [dbo].[v_cost_interface_info_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_cost_interface_info_rev] TO [next_usr]
GO
