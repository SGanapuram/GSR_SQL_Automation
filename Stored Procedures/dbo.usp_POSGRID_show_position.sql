SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[usp_POSGRID_show_position] as select getdate()
GO
GRANT EXECUTE ON  [dbo].[usp_POSGRID_show_position] TO [next_usr]
GO
