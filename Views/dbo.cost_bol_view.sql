SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[cost_bol_view] 
(
	 bol_code,	 
   trans_id
)
as 
select
	 bol_code, 
   trans_id
from dbo.ai_est_actual 
where bol_code IS NOT NULL
GO
GRANT SELECT ON  [dbo].[cost_bol_view] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[cost_bol_view] TO [next_usr]
GO
