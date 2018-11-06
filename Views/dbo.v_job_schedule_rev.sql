SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_job_schedule_rev]
(
   job_schedule_num,
   job_name,
   job_status,
   recur_ind,
   trigger_event_code,
   trigger_event_status_list,
   drop_dead_date,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   job_schedule_num,
   job_name,
   job_status,
   recur_ind,
   trigger_event_code,
   trigger_event_status_list,
   drop_dead_date,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_job_schedule
GO
GRANT SELECT ON  [dbo].[v_job_schedule_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_job_schedule_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_job_schedule_rev', NULL, NULL
GO
