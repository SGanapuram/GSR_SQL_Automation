SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[sp_ICTS_eventinfo] 
(
   @mydate datetime = null
)
as
set nocount on

   if @mydate is null
   begin   /* trim off this current time's hours and minutes */
      select @mydate = dateadd (dd, -1, convert(datetime, convert(char(10), getdate(), 101)))
   end

   select 'GMT-Time' = substring(convert(char(19), event_time), 13, 7),
          'Controller' = event_controller,
          'Owner' = event_owner,
          'Code' = event_code,
          'Desc' = event_description
   from dbo.event
   where event_asof_date = @mydate
   order by event_time, event_description
return 0
GO
GRANT EXECUTE ON  [dbo].[sp_ICTS_eventinfo] TO [ictspass]
GO
GRANT EXECUTE ON  [dbo].[sp_ICTS_eventinfo] TO [next_usr]
GO
