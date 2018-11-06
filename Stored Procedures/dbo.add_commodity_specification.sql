SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[add_commodity_specification]
(
		@cmdty_code             char(8),
		@spec_code              char(8),
		@cmdty_spec_min_val     float,
		@cmdty_spec_max_val     float,
		@cmdty_spec_typical_val float,
    @spec_type		          char(1),   
		@trans_id               int,
    @typical_string_value   varchar(40),
    @dflt_spec_test_code	  char(8),
    @standard_ind	          char(1)
)
as 
begin
declare @rowcount int

   insert into dbo.commodity_specification
	 (
		  cmdty_code,
		  spec_code,
		  cmdty_spec_min_val,
		  cmdty_spec_max_val,
		  cmdty_spec_typical_val,
		  spec_type,
		  trans_id,
      typical_string_value,
      dflt_spec_test_code,
      standard_ind
	 )	
   values
	 (
		  @cmdty_code,
		  @spec_code,
		  @cmdty_spec_min_val,
		  @cmdty_spec_max_val,
		  @cmdty_spec_typical_val,
		  @spec_type,
		  @trans_id,
      @typical_string_value,
      @dflt_spec_test_code,
      @standard_ind
	 )
   set @rowcount = @@rowcount
   if (@rowcount = 1)
      return 0
   else 
      return 1
end
GO
GRANT EXECUTE ON  [dbo].[add_commodity_specification] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'add_commodity_specification', NULL, NULL
GO
