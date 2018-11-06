SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[FL_RemoveGroupFromRole]
@group varchar(20),
@role varchar(30)
AS

BEGIN
	DELETE FL_GROUPS_ROLES WHERE roleName  = @role AND groupName = @group
END
GO
GRANT EXECUTE ON  [dbo].[FL_RemoveGroupFromRole] TO [next_usr]
GO
