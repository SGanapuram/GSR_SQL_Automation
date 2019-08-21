SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create view [dbo].[v_trade_detail] as select 1 as n
GO
GRANT SELECT ON  [dbo].[v_trade_detail] TO [next_usr]
GO
