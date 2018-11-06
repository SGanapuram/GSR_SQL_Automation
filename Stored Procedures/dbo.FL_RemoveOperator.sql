SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[FL_RemoveOperator]

	@user char(3)
AS
BEGIN
--SET NOCOUNT ON
	BEGIN TRAN
    
    -- Delete the roles and unlink the user as a fleetime user
	DELETE FL_USERS_ROLES WHERE fleetimeUser = @user
	DELETE FL_GROUPS_USERS WHERE fleetimeUser = @user
	DELETE FL_USERS WHERE user_init = @user
	
	IF (@@ERROR<>0)
		ROLLBACK TRAN
	ELSE
		COMMIT TRAN
		
END
GO
GRANT EXECUTE ON  [dbo].[FL_RemoveOperator] TO [next_usr]
GO
