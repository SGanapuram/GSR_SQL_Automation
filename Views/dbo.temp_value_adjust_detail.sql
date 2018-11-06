SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[temp_value_adjust_detail]
(
	 acct_num,
	 acct_name,
	 loc_code,
	 loc_name,
	 cmdty_code,
	 cmdty_name,
	 date_from,
	 date_to,
	 delta,
	 trans_id
)
as
select 
	 t.acct_num,
	 a.acct_short_name,
	 t.loc_code,
	 l.loc_name,
	 t.cmdty_code,
   c.cmdty_short_name,
	 t.begin_date,
	 t.end_date,
	 t.price_delta,
	 t.trans_id
from dbo.temp_value_adjust t,
	   dbo.account a,
	   dbo.location l,
	   dbo.commodity c
where t.acct_num = a.acct_num and
	    t.loc_code = l.loc_code and
	    t.cmdty_code = c.cmdty_code
GO
GRANT SELECT ON  [dbo].[temp_value_adjust_detail] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[temp_value_adjust_detail] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'temp_value_adjust_detail', NULL, NULL
GO
