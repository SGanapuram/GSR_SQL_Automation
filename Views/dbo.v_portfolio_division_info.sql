SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create view [dbo].[v_portfolio_division_info] (currdate) as select getdate()
GO
GRANT SELECT ON  [dbo].[v_portfolio_division_info] TO [next_usr]
GO
