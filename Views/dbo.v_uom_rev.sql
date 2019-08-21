SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_uom_rev]
(
   uom_code,
   uom_type,
   uom_status,
   uom_short_name,
   uom_full_name,
   uom_num,
   uom_convert_to,
   conv_factor,
   spec_code_adj1,
   adj1_mult_div_ind,
   spec_code_adj2,
   adj2_mult_div_ind,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   uom_code,
   uom_type,
   uom_status,
   uom_short_name,
   uom_full_name,
   uom_num,
   uom_convert_to,
   conv_factor,
   spec_code_adj1,
   adj1_mult_div_ind,
   spec_code_adj2,
   adj2_mult_div_ind,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_uom
GO
GRANT SELECT ON  [dbo].[v_uom_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_uom_rev] TO [next_usr]
GO
