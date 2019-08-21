SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create view [dbo].[v_BI_portfolio] as select 1 as n
GO
GRANT SELECT ON  [dbo].[v_BI_portfolio] TO [next_usr]
GO
