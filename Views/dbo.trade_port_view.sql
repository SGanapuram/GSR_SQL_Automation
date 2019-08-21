SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[trade_port_view]
(
	 real_port_num,
	 trade_num
)
as
select distinct
	 real_port_num,
	 trade_num
from dbo.trade_item
GO
GRANT SELECT ON  [dbo].[trade_port_view] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[trade_port_view] TO [next_usr]
GO
