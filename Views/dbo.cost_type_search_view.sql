SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[cost_type_search_view] 
(
   cost_type_code,
   cost_type_desc,
   trans_id
)
as
select 
   ct.cost_type_code,
   ct.cost_type_desc,
   ct.trans_id
from cost_type ct, 
     cost c
where ct.cost_type_code = c.cost_type_code
GO
GRANT SELECT ON  [dbo].[cost_type_search_view] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[cost_type_search_view] TO [next_usr]
GO
