SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[FL_AddGroupToRole]
	@group varchar(50),
	@role varchar(30)
AS
BEGIN
	INSERT INTO FL_GROUPS_ROLES (roleName ,groupName) VALUES (@role, @group)
END
GO
GRANT EXECUTE ON  [dbo].[FL_AddGroupToRole] TO [next_usr]
GO
