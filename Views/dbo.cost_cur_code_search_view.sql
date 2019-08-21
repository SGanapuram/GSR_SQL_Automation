SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[cost_cur_code_search_view] 
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
from dbo.commodity
where cmdty_type = 'C'
GO
GRANT SELECT ON  [dbo].[cost_cur_code_search_view] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[cost_cur_code_search_view] TO [next_usr]
GO
