SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[quickfill_find_bsi] 
(
   @portfolioNum    int = null,
   @bsi             varchar(8) output
)
as
set nocount on
declare @status int
declare @rows int

   /* check if we have an alias for this portfolio */
   select @bsi = null
   select @bsi = port_alias_name 
   from dbo.portfolio_alias 
   where alias_source_code = 'BSI' and 
         port_num = @portfolioNum
   select @rows = @@rowcount
   if (@rows = 0) 
      return -549
   else if (@rows > 1)
      return -550
   else return 0
GO
GRANT EXECUTE ON  [dbo].[quickfill_find_bsi] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'quickfill_find_bsi', NULL, NULL
GO
