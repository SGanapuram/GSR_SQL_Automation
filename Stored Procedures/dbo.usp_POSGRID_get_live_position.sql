SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[usp_POSGRID_get_live_position] as select getdate()
GO
GRANT EXECUTE ON  [dbo].[usp_POSGRID_get_live_position] TO [next_usr]
GO
