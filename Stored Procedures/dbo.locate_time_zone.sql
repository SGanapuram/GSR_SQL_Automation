SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[locate_time_zone]
(
   @by_type0  varchar(40) = null,
   @by_ref0   varchar(255) = null
)
as 
begin
set nocount on
declare @rowcount int

   if @by_type0 = 'time_zone_code'
   begin
      select
         /* :LOCATE: TimeZone */
         tz.time_zone_code,		/* :IS_KEY: 1 */
         tz.time_zone_offset,
         tz.time_zone_desc,
         tz.trans_id
      from dbo.time_zone tz with (nolock)
      where tz.time_zone_code = @by_ref0
   end
   else 
      return 4

   set @rowcount = @@rowcount
   if (@rowcount = 1)
      return 0
   else if (@rowcount = 0)
      return 1
   else 
      return 2
end
GO
GRANT EXECUTE ON  [dbo].[locate_time_zone] TO [next_usr]
GO
