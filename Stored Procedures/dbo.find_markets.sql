SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[find_markets]
(
   @by_type0       varchar(40) = null,
   @by_ref0        varchar(255) = null,
   @by_type1       varchar(40) = null,
   @by_ref1        varchar(255) = null,
   @by_type2       varchar(40) = null,
   @by_ref2        varchar(255) = null,
   @by_type3       varchar(40) = null,
   @by_ref3        varchar(255) = null
)
as 
begin
set nocount on
declare @rowcount int

   if @by_type0 = 'all'
   begin
      select
         m.mkt_code,
         m.mkt_type,
         m.mkt_status,
         m.mkt_short_name,
         m.mkt_full_name,
         m.trans_id 
      from dbo.market m
	    order by m.mkt_short_name
   end
   else if (@by_type0 in ('CSN', 'cmdty_short_name')) and
           (@by_type1 in ('MT', 'mkt_type')) and
           (@by_type2 in ('MS', 'mkt_status'))
   begin
      select
         m.mkt_code,
         m.mkt_type,
         m.mkt_status,
         m.mkt_short_name,
         m.mkt_full_name,
         m.trans_id 
      from dbo.commodity c,
           dbo.commodity_market cm,
           dbo.market m
      where c.cmdty_short_name = @by_ref0 and  
            c.cmdty_code = cm.cmdty_code and  
            m.mkt_code = cm.mkt_code and  
            m.mkt_type = @by_ref1 and  
            m.mkt_status = @by_ref2
      order by m.mkt_short_name
   end
   else if (@by_type0 in ('CC', 'cmdty_code')) and
           (@by_type1 is null) and
           (@by_type2 is null)
   begin
      select
         m.mkt_code,
         m.mkt_type,
         m.mkt_status,
         m.mkt_short_name,
         m.mkt_full_name,
         m.trans_id 
      from dbo.commodity_market cm,
           dbo.market m
      where cm.cmdty_code = @by_ref0 and  
            cm.mkt_code = m.mkt_code
      order by m.mkt_short_name
   end
   else if (@by_type0 in ('MT', 'mkt_type')) and
           (@by_type1 in ('MS', 'mkt_status')) and
           (@by_type2 is null) and
           (@by_ref2 is null)
   begin
      select
         m.mkt_code,
         m.mkt_type,
         m.mkt_status,
         m.mkt_short_name,
         m.mkt_full_name,
         m.trans_id 
      from dbo.market m
      where m.mkt_type = @by_ref0 and  
            m.mkt_status = @by_ref1
	    order by m.mkt_short_name
   end
   else if (@by_type0 in ('MS', 'mkt_status'))
   begin
      select
         m.mkt_code,
         m.mkt_type,
         m.mkt_status,
         m.mkt_short_name,
         m.mkt_full_name,
         m.trans_id 
      from dbo.market m
      where m.mkt_status != @by_ref0
	    order by m.mkt_short_name
   end
   else if ((@by_type0 in ('CC', 'cmdty_code')) and
            (@by_type1 in ('included', 'INCLUDED')) and
            (@by_ref1 in ('N', 'n')))
   begin
      select
         m.mkt_code,
         m.mkt_type,
         m.mkt_status,
         m.mkt_short_name,
         m.mkt_full_name,
         m.trans_id 
      from dbo.market m
      where m.mkt_code not in (select cm.mkt_code
                               from dbo.commodity_market cm
	                             where cm.cmdty_code = @by_ref0)
	    order by m.mkt_short_name
   end
   else if ((@by_type0 in ('CC', 'cmdty_code')) and
            (@by_type1 in ('MT', 'mkt_type')) and
            (@by_type2 in ('mkt_status', 'MS')) and
            (@by_type3 in ('mkt_status', 'MS')))
   begin
      select
         m.mkt_code,
         m.mkt_type,
         m.mkt_status,
         m.mkt_short_name,
         m.mkt_full_name,
         m.trans_id 
      from dbo.market m,
           dbo.commodity_market cm
      where cm.cmdty_code = @by_ref0 and 
            m.mkt_code = cm.mkt_code and   
            m.mkt_type = @by_ref1 and 
            m.mkt_status in (@by_ref2, @by_ref3)
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
GRANT EXECUTE ON  [dbo].[find_markets] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'find_markets', NULL, NULL
GO
