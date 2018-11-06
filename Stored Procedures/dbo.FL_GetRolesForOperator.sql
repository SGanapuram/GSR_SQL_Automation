SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[FL_GetRolesForOperator]
	@user char(3)
AS
BEGIN
	--SET NOCOUNT ON
    -- Insert statements for procedure here
	SELECT FL_USERS_ROLES.roleName  "role", cast (0 as bit) "inherited", role_alias_ft1 "alias" FROM FL_USERS_ROLES, FL_ROLES WHERE fleetimeUser = @user AND FL_USERS_ROLES.roleName=FL_ROLES.roleName
	UNION
	SELECT FL_GROUPS_ROLES.roleName  "role", cast (1 as bit) "inherited", role_alias_ft1 "alias" FROM FL_GROUPS_ROLES, FL_GROUPS_USERS, FL_ROLES WHERE FL_GROUPS_ROLES.groupName = FL_GROUPS_USERS.groupName AND FL_GROUPS_USERS.fleetimeUser = @user  AND FL_GROUPS_ROLES.roleName =FL_ROLES.roleName 
		AND FL_GROUPS_ROLES.roleName  NOT IN (SELECT FL_USERS_ROLES.roleName FROM FL_USERS_ROLES WHERE fleetimeUser = @user)
-- tolto l'alias 'role' dalla subselect
END
GO
GRANT EXECUTE ON  [dbo].[FL_GetRolesForOperator] TO [next_usr]
GO
