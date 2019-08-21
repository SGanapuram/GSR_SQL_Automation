SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_calendar_detail_rev]
(
   calendar_code,
   calendar_date,
   calendar_date_type,
   calendar_date_desc,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   calendar_code,
   calendar_date,
   calendar_date_type,
   calendar_date_desc,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_calendar_detail
GO
GRANT SELECT ON  [dbo].[v_calendar_detail_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_calendar_detail_rev] TO [next_usr]
GO
