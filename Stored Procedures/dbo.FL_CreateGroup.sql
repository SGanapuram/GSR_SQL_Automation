SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[FL_CreateGroup]
	@group varchar(50),
	@description nvarchar(100) = null
AS
BEGIN
--SET NOCOUNT ON
    -- Insert statements for procedure here
	INSERT INTO FL_GROUPS (groupName, description) VALUES (@group, @description)
END
GO
GRANT EXECUTE ON  [dbo].[FL_CreateGroup] TO [next_usr]
GO
