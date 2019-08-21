SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[cost_owner_search_view] 
(
	 cost_owner_code,
	 bc_owner_code,
	 bc_owner_full_name,
	 bc_owner_desc,
	 cost_owner_table_name,
	 cost_owner_key1_name,
	 cost_owner_key2_name,
	 cost_owner_key3_name,
	 cost_owner_key4_name,
	 cost_owner_key5_name,
	 cost_owner_key6_name,
	 cost_owner_key7_name,
	 cost_owner_key8_name,
   trans_id
)
as
select 
	 co.cost_owner_code,
	 co.bc_owner_code,
	 co.bc_owner_full_name,
	 co.bc_owner_desc,
	 co.cost_owner_table_name,
	 co.cost_owner_key1_name,
	 co.cost_owner_key2_name,
	 co.cost_owner_key3_name,
	 co.cost_owner_key4_name,
	 co.cost_owner_key5_name,
	 co.cost_owner_key6_name,
	 co.cost_owner_key7_name,
	 co.cost_owner_key8_name,
   co.trans_id
from dbo.cost_owner co, 
     dbo.cost c
where co.cost_owner_code = c.cost_owner_code
GO
GRANT SELECT ON  [dbo].[cost_owner_search_view] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[cost_owner_search_view] TO [next_usr]
GO
