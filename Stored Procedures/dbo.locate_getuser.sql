SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[locate_getuser]
(
   @user_logon_id		varchar(40) = null
)
as 
begin
set nocount on
declare @rowcount int

   set rowcount 1
   select
      usr.user_init,
      loc.loc_num
   from dbo.icts_user usr with (nolock),
        dbo.location loc with (nolock)
   where usr.user_logon_id = @user_logon_id and
         usr.user_job_title != 'DUP' and
         loc.loc_code = usr.loc_code
   set @rowcount = @@rowcount
   if @rowcount = 1
      return 0
   else if @rowcount = 0
   begin
      select
         usr.user_init,
         loc.loc_num
      from dbo.icts_user usr with (nolock),
           dbo.location loc with (nolock)
      where usr.user_logon_id = @user_logon_id and
            usr.user_job_title IS NULL and
            loc.loc_code = usr.loc_code
      set @rowcount = @@rowcount
      if @rowcount = 1
         return 0
      else if @rowcount = 0
         return 1
      else
         return 2
   end
   else 
      return 2

   set rowcount 0
end
GO
GRANT EXECUTE ON  [dbo].[locate_getuser] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[locate_getuser] TO [next_usr]
GO
