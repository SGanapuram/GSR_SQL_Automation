SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[locate_getime]
as
begin
set nocount on
   
   select convert(varchar, getdate(), 109)
end
GO
GRANT EXECUTE ON  [dbo].[locate_getime] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[locate_getime] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'locate_getime', NULL, NULL
GO
