SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create view [dbo].[v_POSGRID_inv_position_info] (currdate) as select getdate()
GO
GRANT SELECT ON  [dbo].[v_POSGRID_inv_position_info] TO [next_usr]
GO
