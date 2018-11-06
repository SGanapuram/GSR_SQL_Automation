SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[FL_RemoveOperatorFromRole]
	@user char(3),
	@role varchar(30)

AS
BEGIN

	DELETE FL_USERS_ROLES WHERE roleName = @role AND fleetimeUser = @user
	
END
GO
GRANT EXECUTE ON  [dbo].[FL_RemoveOperatorFromRole] TO [next_usr]
GO
