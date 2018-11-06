SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[delete_commodity_specification]
(
	 @by_type0       varchar(40),
   @by_ref0        varchar(255),
	 @by_type1       varchar(40),
	 @by_ref1        varchar(255)
)
as
begin
set nocount on
set xact_abort on

declare @rowcount int

	if ( (@by_type0 in ('cmdty_code')) and
		   (@by_type1 in ('spec_code'))
	   )
	begin
		 delete dbo.commodity_specification
		 where cmdty_code = @by_ref0 and
		       spec_code = @by_ref1
	end
	else
	   return 4

	select @rowcount = @@rowcount

	if (@rowcount = 1)
		 return 0
	else
	   if (@rowcount = 0)
		    return 1
	   else
		    return 2
end
GO
GRANT EXECUTE ON  [dbo].[delete_commodity_specification] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'delete_commodity_specification', NULL, NULL
GO
