SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[FL_AddOperatorToGroup]
	@user char(3),
	@group varchar(50)
AS
BEGIN
	INSERT INTO FL_GROUPS_USERS (fleetimeUser, groupName) 
	   VALUES (@user, @group)	
END
GO
GRANT EXECUTE ON  [dbo].[FL_AddOperatorToGroup] TO [next_usr]
GO
