SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[commodity_and_group] 
(
   parent_cmdty_code, 		
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
   cg.parent_cmdty_code, 		
   c.cmdty_code,
   c.cmdty_tradeable_ind,
   c.cmdty_type,	
   c.cmdty_status,
   c.cmdty_short_name,
   c.cmdty_full_name,
   c.country_code,				
   c.cmdty_loc_desc,
   c.prim_curr_code,				
   c.prim_curr_conv_rate,
   c.trans_id
from dbo.commodity c
        left outer join dbo.commodity_group cg
           on c.cmdty_code = cg.cmdty_code
GO
GRANT SELECT ON  [dbo].[commodity_and_group] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[commodity_and_group] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'commodity_and_group', NULL, NULL
GO
