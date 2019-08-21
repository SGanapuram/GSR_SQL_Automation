SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create view [dbo].[v_TS_portfolio_booking_company] as select 1 as n
GO
GRANT SELECT ON  [dbo].[v_TS_portfolio_booking_company] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_TS_portfolio_booking_company] TO [next_usr]
GO
