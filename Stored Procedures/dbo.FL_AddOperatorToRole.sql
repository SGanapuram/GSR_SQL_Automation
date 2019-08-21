SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[FL_AddOperatorToRole]
	@user char(3),
	@role varchar(30)
AS
BEGIN
	INSERT INTO FL_USERS_ROLES (roleName ,fleetimeUser) 
	   VALUES (@role, @user)
END
GO
GRANT EXECUTE ON  [dbo].[FL_AddOperatorToRole] TO [next_usr]
GO
