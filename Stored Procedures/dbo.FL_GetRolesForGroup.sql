SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[FL_GetRolesForGroup]
	@group varchar(50)
AS
BEGIN
	SELECT roleName  FROM FL_GROUPS_ROLES WHERE groupName = @group
END
GO
GRANT EXECUTE ON  [dbo].[FL_GetRolesForGroup] TO [next_usr]
GO
