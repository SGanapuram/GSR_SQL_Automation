SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[FL_RemoveGroup]
   @group varchar(20)
AS
BEGIN
   --Rimuovo solo i gruppi non di sistema
   BEGIN TRAN     
   if (exists(SELECT * FROM FL_GROUPS WHERE groupName = @group AND builtin=0)) 
   BEGIN
      DELETE FL_GROUPS_USERS WHERE groupName = @group
      DELETE FL_GROUPS_ROLES WHERE groupName = @group
      DELETE FL_GROUPS WHERE groupName = @group
   END
               
   IF (@@ERROR <> 0)
      ROLLBACK TRAN
   ELSE
      COMMIT TRAN                 
END
GO
GRANT EXECUTE ON  [dbo].[FL_RemoveGroup] TO [next_usr]
GO
