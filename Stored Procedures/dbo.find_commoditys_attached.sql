SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[find_commoditys_attached]
(
   @by_type0       varchar(40) = null,
   @by_ref0        varchar(40) = null,
   @by_type1       varchar(40) = null,
   @by_ref1        varchar(40) = null
)
as 
begin
set nocount on
declare @rowcount int

   if @by_type0 = 'all'
   begin
      select * 
      from dbo.commoditys_attached
      order by cmdty_short_name
   end
   else if ((@by_type0 in ('mkt_code')) and
            (@by_type1 in ('attached')) and
            (@by_ref1  in ('y', 'Y')))
   begin
      select
         ca.cmdty_code,
         ca.cmdty_short_name,
         ca.commkt_key,
         ca.mkt_code,
         ca.mkt_short_name
      from dbo.commoditys_attached  ca
      where ca.mkt_code = @by_ref0
      order by ca.cmdty_short_name
   end
   else if ((@by_type0 in ('mkt_code')) and
            (@by_type1 in ('attached')) and
            (@by_ref1 in ('n', 'N')))
   begin
      select
         c.cmdty_code,
         c.cmdty_short_name,
         null,
         null,
         null
      from dbo.commodity c with (nolock)
      where c.cmdty_code not in (select ca.cmdty_code 
                                 from dbo.commoditys_attached ca
                                 where ca.mkt_code = @by_ref0) and   
            c.cmdty_status in ('A', 'N')
      order by c.cmdty_short_name
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
GRANT EXECUTE ON  [dbo].[find_commoditys_attached] TO [next_usr]
GO
