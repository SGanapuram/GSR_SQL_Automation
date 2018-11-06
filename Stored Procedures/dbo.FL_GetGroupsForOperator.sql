SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[FL_GetGroupsForOperator]

@user char(3)

AS

  BEGIN
  
	-- SET NOCOUNT ON added to prevent extra result sets from
	--SET NOCOUNT ON	

	SELECT groupName FROM FL_GROUPS_USERS WHERE fleetimeUser = @user
END
GO
GRANT EXECUTE ON  [dbo].[FL_GetGroupsForOperator] TO [next_usr]
GO
