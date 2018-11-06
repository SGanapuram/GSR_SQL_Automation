SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchCalendarDetailRevPK]
(
   @asof_trans_id      int,
   @calendar_code      char(8),
   @calendar_date      datetime
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.calendar_detail
where calendar_code = @calendar_code and
      calendar_date = @calendar_date
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      calendar_code,
      calendar_date,
      calendar_date_desc,
      calendar_date_type,
      resp_trans_id = null,
      trans_id
   from dbo.calendar_detail
   where calendar_code = @calendar_code and
         calendar_date = @calendar_date
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      calendar_code,
      calendar_date,
      calendar_date_desc,
      calendar_date_type,
      resp_trans_id,
      trans_id
   from dbo.aud_calendar_detail
   where calendar_code = @calendar_code and
         calendar_date = @calendar_date and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchCalendarDetailRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchCalendarDetailRevPK', NULL, NULL
GO
