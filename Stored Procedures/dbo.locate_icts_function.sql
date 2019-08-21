SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[locate_icts_function]
(
   @by_type0    varchar(40),
   @by_ref0     varchar(255),
   @by_type1    varchar(40),
   @by_ref1     varchar(255)
)
as
begin
set nocount on
declare @rowcount int
declare @ref_num0 int

   if @by_type0 = 'function_num' and
      @by_type1 is null
   begin
      set @ref_num0 = convert(int, @by_ref0)
      select
         /* :LOCATE: ICTS_Function */
         f.function_num,                           /* :IS_KEY: 1 */
         f.app_name,                            
         f.function_name,                       
         f.trans_id 
      from dbo.icts_function f with (nolock)
      where f.function_num = @ref_num0 
   end
   else if @by_type0 = 'app_name' and
           @by_type1 = 'function_name'
   begin
      select
         f.function_num,
         f.app_name,
         f.function_name,
         f.trans_id 
      from dbo.icts_function f with (nolock)
      where f.app_name = @by_ref0 and   
            f.function_name = @by_ref1
   end
   else
	    return 4

   set @rowcount = @@rowcount
   if @rowcount = 1
	    return 0
   else if @rowcount = 0
	    return 1
	 else
	    return 2
end
GO
GRANT EXECUTE ON  [dbo].[locate_icts_function] TO [next_usr]
GO
