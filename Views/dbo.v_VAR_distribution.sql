SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_VAR_distribution]
(
   trade_num,
   order_num,
   item_num,
   dist_qty,
   alloc_qty,
   qty_uom_code, 
   qty_uom_code_conv_to, 
   qty_uom_conv_rate, 
   real_port_num,
   real_synth_ind,
   p_s_ind,
   pos_num
)
as
select trade_num,
       order_num,
       item_num,
       dist_qty,
       alloc_qty,
       qty_uom_code, 
       qty_uom_code_conv_to, 
       qty_uom_conv_rate, 
       real_port_num,
       real_synth_ind,
       p_s_ind,
       pos_num
from dbo.trade_item_dist d
where d.dist_type = 'D' and 
      d.is_equiv_ind = 'N' and 
      d.what_if_ind = 'N' and  
      exists (select 1
              from dbo.jms_reports jms
              where jms.classification_code like '[A,a]%' and
                    d.real_port_num = jms.port_num)
GO
GRANT SELECT ON  [dbo].[v_VAR_distribution] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_VAR_distribution] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_VAR_distribution', NULL, NULL
GO
