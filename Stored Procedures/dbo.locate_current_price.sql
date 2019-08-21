SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[locate_current_price] 
(
   @by_type0	varchar(40) = null, 
   @by_ref0	  varchar(255) = null,  
   @by_type1	varchar(40) = null, 
   @by_ref1	  varchar(255) = null,  
   @by_type2	varchar(40) = null, 
   @by_ref2	  varchar(255) = null,  
   @by_type3	varchar(40) = null, 
   @by_ref3	  varchar(255) = null  
)
as 
begin 
set nocount on
declare @rowcount int 
declare @ref_num0 int 
declare @ref_num3 datetime 
declare @mkt_type char(1) 
 
   set @ref_num0 = convert(int, @by_ref0) 
   set @ref_num3 = convert(datetime, @by_ref3) 
 
   if @by_type0 in ('commkt_key') and 
      @by_type1 in ('price_source_code') and 
      @by_type2 in ('trading_prd') and 
      @by_type3 in ('price_quote_date')
   begin 
	    select @mkt_type = m.mkt_type 
	    from dbo.market m with (nolock), 
	         dbo.commodity_market cm with (nolock)
	    where cm.commkt_key = @ref_num0 and 
	          m.mkt_code = cm.mkt_code 
 
	    if @mkt_type = 'P' 
	    begin 
	   	   select 
            /* :LOCATE: CurrentPrice */ 
            cp.commkt_key,                             /* :IS_KEY: 1 */ 
            cp.price_source_code,                      /* :IS_KEY: 2 */ 
            cp.trading_prd,                            /* :IS_KEY: 3 */ 
            cp.price_quote_date,                       /* :IS_KEY: 4 */ 
            cp.low_bid_price, 
            cp.high_asked_price, 
            cp.avg_closed_price, 
            cp.open_interest, 
            cp.vol_traded, 
            cp.creation_type, 
            cpa.commkt_price_uom_code, 
            cpa.commkt_curr_code, 
            cp.trans_id 
         from dbo.price cp, 
		          dbo.commkt_physical_attr cpa with (nolock) 
	   	   where cp.commkt_key = @ref_num0 and 
	   	         cp.price_source_code = @by_ref1 and
			         cp.trading_prd = @by_ref2 and
			         cp.price_quote_date = @ref_num3 and 
			         cpa.commkt_key = cp.commkt_key 
	    end 
	    else if @mkt_type = 'E'
	    begin 
	       select 
            cp.commkt_key, 
            cp.price_source_code, 
            cp.trading_prd, 
            cp.price_quote_date, 
            cp.low_bid_price, 
            cp.high_asked_price, 
            cp.avg_closed_price, 
            cp.open_interest, 
            cp.vol_traded, 
            cp.creation_type, 
            cfa.commkt_price_uom_code, 
            cfa.commkt_curr_code, 
            cp.trans_id 
         from dbo.price cp, 
              dbo.commkt_future_attr cfa with (nolock)
         where cp.commkt_key = @ref_num0 and 
               cp.price_source_code = @by_ref1 and 
               cp.trading_prd = @by_ref2 and 
               cp.price_quote_date = @ref_num3 and 
               cfa.commkt_key = cp.commkt_key 
	    end 
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
GRANT EXECUTE ON  [dbo].[locate_current_price] TO [next_usr]
GO
