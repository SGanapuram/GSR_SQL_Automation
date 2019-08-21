SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[find_commodity_specifications]
(
   @by_type0    varchar(40) = null,
   @by_ref0	    varchar(255) = null
)
as 
begin
set nocount on
declare @rowcount int

   if @by_type0 = 'all'
   begin
      select cs.cmdty_code,
		         cs.spec_code,
		         cs.cmdty_spec_min_val,
		         cs.cmdty_spec_max_val,
		         cs.cmdty_spec_typical_val,
		         cs.spec_type,
		         cs.trans_id,
             cs.typical_string_value,
             cs.dflt_spec_test_code,
             cs.standard_ind
      from dbo.commodity_specification cs
   end
   else
   if (@by_type0 = 'cmdty_code')
   begin
      select cs.cmdty_code,
		         cs.spec_code,
		         cs.cmdty_spec_min_val,
		         cs.cmdty_spec_max_val,
		         cs.cmdty_spec_typical_val,
		         cs.spec_type,
		         cs.trans_id,
             cs.typical_string_value,
             cs.dflt_spec_test_code,
             cs.standard_ind
      from dbo.commodity_specification cs
      where cmdty_code = @by_ref0
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
GRANT EXECUTE ON  [dbo].[find_commodity_specifications] TO [next_usr]
GO
