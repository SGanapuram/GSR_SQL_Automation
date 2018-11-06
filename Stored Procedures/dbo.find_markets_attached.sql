SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[find_markets_attached]
(
   @by_type0 	varchar(40) = null,
   @by_ref0	  varchar(40) = null,
   @by_type1 	varchar(40) = null,
   @by_ref1	  varchar(40) = null
)
as 
begin
set nocount on
declare @rowcount int

   if @by_type0 = 'all'
   begin
      select * 
      from dbo.markets_attached ma
			order by ma.mkt_short_name
   end
   else if ((@by_type0 in ('cmdty_code')) and
            (@by_type1 in ('attached')) and
            (@by_ref1 in ('y', 'Y')))
   begin
      select
         ma.mkt_code,
         ma.mkt_short_name,
         ma.commkt_key,
         ma.cmdty_code,
         ma.cmdty_short_name
      from dbo.markets_attached  ma
      where ma.cmdty_code = @by_ref0
      order by ma.mkt_short_name
   end
   else if ((@by_type0 in ('cmdty_code')) and
            (@by_type1 in ('attached')) and
            (@by_ref1 in ('n', 'N')))
   begin
      select
         m.mkt_code,
         m.mkt_short_name,
         null,
         null,
         null
      from dbo.market m
      where m.mkt_code not in (select ma.mkt_code 
                               from dbo.markets_attached ma
                               where ma.cmdty_code = @by_ref0) and   
            m.mkt_status in ('A', 'N')
      order by m.mkt_short_name
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
GRANT EXECUTE ON  [dbo].[find_markets_attached] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'find_markets_attached', NULL, NULL
GO
