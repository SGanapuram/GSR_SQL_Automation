SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchJobScheduleRevPK]
(
   @asof_trans_id         bigint,
   @job_schedule_num      int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.job_schedule
where job_schedule_num = @job_schedule_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      drop_dead_date,
      job_name,
      job_schedule_num,
      job_status,
      recur_ind,
      resp_trans_id = null,
      trans_id,
      trigger_event_code,
      trigger_event_status_list
   from dbo.job_schedule
   where job_schedule_num = @job_schedule_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      drop_dead_date,
      job_name,
      job_schedule_num,
      job_status,
      recur_ind,
      resp_trans_id,
      trans_id,
      trigger_event_code,
      trigger_event_status_list
   from dbo.aud_job_schedule
   where job_schedule_num = @job_schedule_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchJobScheduleRevPK] TO [next_usr]
GO
