SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[getDBDatetime]
as
set nocount on

   select getdate()
GO
GRANT EXECUTE ON  [dbo].[getDBDatetime] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[getDBDatetime] TO [next_usr]
GO
