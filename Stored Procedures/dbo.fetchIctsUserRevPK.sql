SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchIctsUserRevPK]
(
   @asof_trans_id      int,
   @user_init          char(3)
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.icts_user
where user_init = @user_init
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      desk_code,
      email_address,
      loc_code,
      resp_trans_id = null,
      trans_id,
      us_citizen_ind,
      user_employee_num,
      user_first_name,
      user_init,
      user_job_title,
      user_last_name,
      user_logon_id,
      user_status
   from dbo.icts_user
   where user_init = @user_init
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      desk_code,
      email_address,
      loc_code,
      resp_trans_id,
      trans_id,
      us_citizen_ind,
      user_employee_num,
      user_first_name,
      user_init,
      user_job_title,
      user_last_name,
      user_logon_id,
      user_status
   from dbo.aud_icts_user
   where user_init = @user_init and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchIctsUserRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchIctsUserRevPK', NULL, NULL
GO
