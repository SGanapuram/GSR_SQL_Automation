SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[FL_CreateRole]
	@role        varchar(30),
	@description nvarchar(50) = null
AS
BEGIN
	INSERT INTO FL_ROLES(roleName , description) 
	   VALUES (@role, @description)
END
GO
GRANT EXECUTE ON  [dbo].[FL_CreateRole] TO [next_usr]
GO
