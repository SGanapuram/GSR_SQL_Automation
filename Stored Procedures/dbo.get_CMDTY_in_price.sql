SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[get_CMDTY_in_price]
as
begin
set nocount on

   select cmdty_code, cmdty_short_name
   from dbo.commodity
   where cmdty_type = 'P' and 
         cmdty_status in ('A', 'N')
   order by cmdty_short_name
end
return
GO
GRANT EXECUTE ON  [dbo].[get_CMDTY_in_price] TO [next_usr]
GO
