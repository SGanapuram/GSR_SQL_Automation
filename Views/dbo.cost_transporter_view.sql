SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[cost_transporter_view] 
(
	 transporter_code,	 
   trans_id
)
as 
select 
	 transporter_code, 
   trans_id
from dbo.ai_est_actual
where transporter_code IS NOT NULL
GO
GRANT SELECT ON  [dbo].[cost_transporter_view] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[cost_transporter_view] TO [next_usr]
GO
