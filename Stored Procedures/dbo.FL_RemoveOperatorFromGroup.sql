SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[FL_RemoveOperatorFromGroup]
	 @user char(3),
	 @group varchar(50)
AS
BEGIN
 	 DELETE FL_GROUPS_USERS 
	 WHERE fleetimeUser = @user AND 
	       groupName = @group
END
GO
GRANT EXECUTE ON  [dbo].[FL_RemoveOperatorFromGroup] TO [next_usr]
GO
