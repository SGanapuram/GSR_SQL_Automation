SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[FL_GetOperatorsForRole]
@role varchar(30)
as
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON

    -- Insert statements for procedure here
	SELECT fleetimeUser FROM FL_USERS_ROLES WHERE roleName = @role
	UNION
	SELECT fleetimeUser FROM FL_GROUPS_USERS, FL_GROUPS_ROLES WHERE FL_GROUPS_USERS.groupName = FL_GROUPS_ROLES.groupName AND FL_GROUPS_ROLES.roleName = @role

END
GO
GRANT EXECUTE ON  [dbo].[FL_GetOperatorsForRole] TO [next_usr]
GO
