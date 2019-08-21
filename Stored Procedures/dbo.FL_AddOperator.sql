SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[FL_AddOperator]
	@user char(3)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON

    -- Insert statements for procedure here
	INSERT INTO FL_USERS (user_init) 
		VALUES (@user)
END
GO
GRANT EXECUTE ON  [dbo].[FL_AddOperator] TO [next_usr]
GO
