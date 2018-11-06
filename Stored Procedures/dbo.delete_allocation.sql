SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[delete_allocation]
(
	@by_type0     varchar(40),
	@by_ref0      varchar(255)
)
as
begin
set nocount on
set xact_abort on
declare @rowcount int
declare @ref_num0 int

	if (@by_type0 in ('alloc_num'))
	begin
		set @ref_num0 = convert(int, @by_ref0)

		delete dbo.allocation
		where alloc_num = @ref_num0
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
GRANT EXECUTE ON  [dbo].[delete_allocation] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'delete_allocation', NULL, NULL
GO
