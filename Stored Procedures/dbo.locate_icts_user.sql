SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[locate_icts_user]
(
   @by_type0    varchar(40) = null,
   @by_ref0     varchar(255) = null
)
as
begin
set nocount on
declare @rowcount int

   if @by_type0 = 'user_init'
   begin
      select
	       u.user_init,                           
         u.user_last_name,                     
         u.user_first_name,                    
         u.desk_code,                          
         u.loc_code,                           
         u.user_logon_id,                      
         u.us_citizen_ind,                     
         u.user_job_title,                     
         u.user_status,                        
         u.user_employee_num,
         u.email_address,
         u.trans_id
      from dbo.icts_user u with (nolock)
      where u.user_init = @by_ref0
   end
   else if @by_type0 = 'user_logon_id'
   begin
      select
         u.user_init,                         
         u.user_last_name,                     
         u.user_first_name,                    
         u.desk_code,                          
         u.loc_code,                           
         u.user_logon_id,                      
         u.us_citizen_ind,                     
         u.user_job_title,                     
         u.user_status,                        
         u.user_employee_num,
         u.email_address,
         u.trans_id
      from dbo.icts_user u with (nolock)
      where u.user_logon_id = @by_ref0
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
GRANT EXECUTE ON  [dbo].[locate_icts_user] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[locate_icts_user] TO [next_usr]
GO
