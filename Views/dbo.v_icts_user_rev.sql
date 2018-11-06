SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_icts_user_rev]
(
   user_init,
   user_last_name,
   user_first_name,
   desk_code,
   loc_code,
   user_logon_id,
   us_citizen_ind,
   user_job_title,
   user_status,
   user_employee_num,
   email_address,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   user_init,
   user_last_name,
   user_first_name,
   desk_code,
   loc_code,
   user_logon_id,
   us_citizen_ind,
   user_job_title,
   user_status,
   user_employee_num,
   email_address,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_icts_user
GO
GRANT SELECT ON  [dbo].[v_icts_user_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_icts_user_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_icts_user_rev', NULL, NULL
GO
