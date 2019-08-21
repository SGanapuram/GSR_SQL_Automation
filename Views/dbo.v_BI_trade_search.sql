SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create view [dbo].[v_BI_trade_search] as select 1 as n
GO
GRANT SELECT ON  [dbo].[v_BI_trade_search] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_BI_trade_search] TO [next_usr]
GO
