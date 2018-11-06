SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[cost_code_search_view] 
(
	 cmdty_code,
	 cmdty_tradeable_ind,
	 cmdty_type,	
	 cmdty_status,
	 cmdty_short_name,
	 cmdty_full_name,
	 country_code,
	 cmdty_loc_desc,
	 prim_curr_code,		
	 prim_curr_conv_rate,
   trans_id
)
as
select 
	 ct.cmdty_code,
	 ct.cmdty_tradeable_ind,
	 ct.cmdty_type,	
	 ct.cmdty_status,
	 ct.cmdty_short_name,
	 ct.cmdty_full_name,
	 ct.country_code,				
	 ct.cmdty_loc_desc,
	 ct.prim_curr_code,				
	 ct.prim_curr_conv_rate,
   ct.trans_id
from dbo.commodity ct, 
     dbo.cost c
where ct.cmdty_code = c.cost_code
GO
GRANT SELECT ON  [dbo].[cost_code_search_view] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[cost_code_search_view] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'cost_code_search_view', NULL, NULL
GO
