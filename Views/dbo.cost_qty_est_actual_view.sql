SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[cost_qty_est_actual_view]
(
	 cost_qty_est_actual_ind
)
as
select
	 cost_qty_est_actual_ind 
from dbo.cost
where cost_qty_est_actual_ind in ('E', 'A') 

GO
GRANT SELECT ON  [dbo].[cost_qty_est_actual_view] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[cost_qty_est_actual_view] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'cost_qty_est_actual_view', NULL, NULL
GO
