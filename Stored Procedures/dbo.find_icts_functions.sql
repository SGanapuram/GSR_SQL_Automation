SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[find_icts_functions]
(
	 @by_type0     varchar(40) = null,
	 @by_ref0      varchar(255) = null
)
as
begin
set nocount on
declare @rowcount int

   if @by_type0 = 'all'
   begin
      select
         f.function_num,
         f.app_name,
         f.function_name,
         f.trans_id
      from dbo.icts_function f
   end
   else
      return 4
	
   set @rowcount = @@rowcount

   if (@rowcount = 1)
      return 0
   else
      if (@rowcount = 0)
	       return 1
      else
	       return 2
end
GO
GRANT EXECUTE ON  [dbo].[find_icts_functions] TO [next_usr]
GO
