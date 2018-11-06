SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[find_commodity_market_sources]
(
   @by_type0    varchar(40) = null,
   @by_ref0     varchar(255) = null,
   @by_type1    varchar(40) = null,
   @by_ref1     varchar(255) = null
)
as
begin
set nocount on
declare @rowcount int
declare @ref_num0 int

	 if @by_type0 = 'all'
	 begin
	    select
		     cms.commkt_key,
         cms.price_source_code,
         cms.dflt_alias_source_code,
         cms.calendar_code,
         cms.tvm_use_ind,
         cms.option_eval_use_ind,
         cms.financial_borrow_use_ind,
         cms.financial_lend_use_ind,
         cms.quote_price_precision,
         cms.trans_id 
	    from dbo.commodity_market_source cms
	 end
   else
	 if ((@by_type0 in ('commkt_key')) and
		   (@by_type1 is null))
	 begin
		  set @ref_num0 = convert(int, @by_ref0)
		  select
		     cms.commkt_key,
		     cms.price_source_code,
		     cms.dflt_alias_source_code,
		     cms.calendar_code,
		     cms.tvm_use_ind,
		     cms.option_eval_use_ind,
		     cms.financial_borrow_use_ind,
		     cms.financial_lend_use_ind,
		     cms.quote_price_precision,
		     cms.trans_id 
		  from dbo.commodity_market_source cms
		  where cms.commkt_key = @ref_num0
	 end
   else
	 if ((@by_type0 in ('commkt_key')) and
		   (@by_type1 in ('price_source_code')))
	 begin
		  set @ref_num0 = convert(int, @by_ref0)
		  select
		     cms.commkt_key,
		     cms.price_source_code,
		     cms.dflt_alias_source_code,
		     cms.calendar_code,
		     cms.tvm_use_ind,
		     cms.option_eval_use_ind,
		     cms.financial_borrow_use_ind,
		     cms.financial_lend_use_ind,
		     cms.quote_price_precision,
		     cms.trans_id 
		  from dbo.commodity_market_source cms
		  where cms.commkt_key = @ref_num0 and   
		        cms.price_source_code = @by_ref1
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
GRANT EXECUTE ON  [dbo].[find_commodity_market_sources] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'find_commodity_market_sources', NULL, NULL
GO
