SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[update_commodity_specification]
(
   @cmdty_code                     char(8),
   @spec_code                      char(8),
   @cmdty_spec_min_val             numeric(20, 8),
   @cmdty_spec_max_val             numeric(20, 8),
   @cmdty_spec_typical_val         numeric(20, 8),
   @spec_type		                   char(1),   
   @typical_string_value           varchar(40),
   @dflt_spec_test_code	           char(8),
   @standard_ind	                 char(1),
   @trans_id                       int,
   @old_trans_id                   int
)
as
declare @rowcount  int

   update dbo.commodity_specification
   set cmdty_spec_min_val      = @cmdty_spec_min_val,
       cmdty_spec_max_val      = @cmdty_spec_max_val,
       cmdty_spec_typical_val  = @cmdty_spec_typical_val,
       spec_type	             = @spec_type,   
       typical_string_value    = @typical_string_value,
       dflt_spec_test_code     = @dflt_spec_test_code,
       standard_ind	           = @standard_ind,       
       trans_id                = @trans_id
   where trans_id = @old_trans_id and
         cmdty_code = @cmdty_code and
         spec_code = @spec_code
   set @rowcount = @@rowcount
   if (@rowcount = 1)
      return 0     /* success */

   if @rowcount > 1
      return 2      /* multiple rows updated */

   if not exists (select 1
                  from dbo.commodity_specification
                  where cmdty_code = @cmdty_code and
                        spec_code = @spec_code)
      return 1
   else
      return -100
GO
GRANT EXECUTE ON  [dbo].[update_commodity_specification] TO [next_usr]
GO
