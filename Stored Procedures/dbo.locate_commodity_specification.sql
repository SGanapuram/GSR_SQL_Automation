SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[locate_commodity_specification]
(
   @by_type0	varchar(40) = null,
   @by_ref0	  varchar(255) = null,
   @by_type1	varchar(40) = null,
   @by_ref1   varchar(255) = null
)		
as 
begin
set nocount on
declare @rowcount int

   if @by_type0 = 'cmdty_code' and 
      @by_type1 = 'spec_code'
   begin
	    select
         /* :LOCATE: CommoditySpecification */
		     c.cmdty_code,		/* :IS_KEY: 1 */
		     c.spec_code,		/* :IS_KEY: 2 */
		     c.cmdty_spec_min_val,
		     c.cmdty_spec_max_val,
		     c.cmdty_spec_typical_val,
		     c.spec_type,
		     c.trans_id,
         c.typical_string_value,
         c.dflt_spec_test_code,
         c.standard_ind
      from dbo.commodity_specification c with (nolock)
      where c.cmdty_code = @by_ref0 and
		        c.spec_code = @by_ref1
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
GRANT EXECUTE ON  [dbo].[locate_commodity_specification] TO [next_usr]
GO
