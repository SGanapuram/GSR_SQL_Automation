SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[locate_user_permission]
(
   @by_type0     varchar(40),
   @by_ref0      varchar(255),
   @by_type1     varchar(40),
   @by_ref1      varchar(255)
)
as
begin
set nocount on
declare @rowcount int
declare @ref_num0 int

	 if @by_type0 = 'user_init' and
		  @by_type1 = 'function_num'
	 begin
		  set @ref_num0 = convert(int, @by_ref1)

		  select
			   /* :LOCATE: UserPermission */
		     user_init,                              /* :IS_KEY: 1 */
		     function_num,                           /* :IS_KEY: 2 */
		     perm_level,
		     trans_id
		  from dbo.user_permission
		  where user_init = @by_ref0 and
            function_num = @ref_num0
	 end
	 else
		  return 4

	 set @rowcount = @@rowcount
	 if @rowcount = 1
		  return 0
	 else if @rowcount = 0
		  return 1
	 else
		  return 2
end
GO
GRANT EXECUTE ON  [dbo].[locate_user_permission] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'locate_user_permission', NULL, NULL
GO
