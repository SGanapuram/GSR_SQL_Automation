SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create VIEW [dbo].[v_uic_report] as select 1 as n
GO
GRANT SELECT ON  [dbo].[v_uic_report] TO [next_usr]
GO
