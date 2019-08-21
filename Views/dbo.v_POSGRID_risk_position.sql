SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create view [dbo].[v_POSGRID_risk_position] (currdate) as select getdate()
GO
GRANT SELECT ON  [dbo].[v_POSGRID_risk_position] TO [next_usr]
GO
