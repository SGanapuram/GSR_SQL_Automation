SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[locate_price]
(
   @by_type0	   varchar(40) = null,
   @by_ref0	     varchar(40) = null,
   @by_type1	   varchar(40) = null,
   @by_ref1	     varchar(40) = null,
   @by_type2	   varchar(40) = null,
   @by_ref2	     varchar(40) = null,
   @by_type3	   varchar(40) = null,
   @by_ref3	     varchar(40) = null,
   @by_type4	   varchar(40) = null,
   @by_ref4	     varchar(40) = null,
   @by_type5	   varchar(40) = null,
   @by_ref5	     varchar(40) = null
)
as
begin
set nocount on
declare @rowcount        int
declare @mkt_type        char(1)
declare @dt              datetime
declare @commkt_key      int
declare @last_quote_date datetime

   if ((@by_type0 in ('MC', 'mkt_code')) and
       (@by_type1 in ('CC', 'cmdty_code')) and
       (@by_type2 in ('TP', 'trading_prd')) and
       (@by_type3 in ('PSC', 'price_source_code')) and
       (@by_type4 is null) and
       (@by_ref4 is null))   				/* case (a) */
   begin
      select
         p.commkt_key,
         p.price_source_code,
         p.trading_prd,
         p.price_quote_date,
         p.low_bid_price,
         p.high_asked_price,
         p.avg_closed_price,
         p.open_interest,
         p.vol_traded,
         p.creation_type,
         p.trans_id,
         p.low_bid_creation_ind,
         p.high_asked_creation_ind,
         p.avg_closed_creation_ind
      from dbo.commodity_market cm with (nolock),
           dbo.trading_period tp with (nolock),
           dbo.price p
      where cm.mkt_code = @by_ref0 and 
            cm.cmdty_code = @by_ref1 and
            cm.commkt_key = tp.commkt_key and
            tp.commkt_key = p.commkt_key and
            tp.trading_prd = @by_ref2 and
            tp.trading_prd = p.trading_prd and
            tp.last_quote_date = p.price_quote_date and
            p.price_source_code = @by_ref3
      set @rowcount = @@rowcount
   end
   else if ((@by_type0 in ('MC', 'mkt_code')) and
   	        (@by_type1 in ('CC', 'cmdty_code')) and
   	        (@by_type2 in ('TP', 'trading_prd')) and
   	        (@by_type3 in ('PSC', 'price_source_code' )) and
   	        (@by_type4 in ('CT', 'cmdty_type')) and
	          (@by_type5 in ('PQD', 'price_quote_date')))	/* case (b) */
   begin
      select @mkt_type = m.mkt_type
      from dbo.market m with (nolock)
      where m.mkt_code = @by_ref0

      if (@by_ref5 in ('last', 'Last', 'LAST')) /* get the last quote */
      begin
         select @commkt_key = cm.commkt_key 
         from dbo.commodity_market cm with (nolock)
         where cm.mkt_code = @by_ref0 and 
               cm.cmdty_code = @by_ref1

         select @last_quote_date = max(p.price_quote_date)
         from dbo.price p
         where p.commkt_key = @commkt_key and 
               p.trading_prd = @by_ref2 and 
               p.price_source_code = @by_ref3

         if (@mkt_type = 'P')
         begin
            select
               /* :LOCATE: DatedCommodityPrice */
               p.commkt_key,		/* :IS_KEY: 1 */
               p.price_source_code,	/* :IS_KEY: 2 */
               p.trading_prd,	 	/* :IS_KEY: 3 */
               p.price_quote_date,	/* :IS_KEY: 4 */
               p.low_bid_price,	    /* :IS_PRICE_AMOUNT: lowBidPrice */
               p.high_asked_price,	/* :IS_PRICE_AMOUNT: highAskedPrice */
               p.avg_closed_price,	/* :IS_PRICE_AMOUNT: avgClosedPrice */
               p.open_interest,
               p.vol_traded,
               p.creation_type,
               cpa.commkt_price_uom_code,
               cpa.commkt_curr_code,	/* :IS_PRICE_CURRENCY: lowBidPrice, highAskedPrice, avgClosedPrice */
               p.trans_id,
               p.low_bid_creation_ind,
               p.high_asked_creation_ind,
               p.avg_closed_creation_ind
            from dbo.price p,
                 dbo.commkt_physical_attr cpa with (nolock)
            where cpa.commkt_key = @commkt_key and
                  p.commkt_key = @commkt_key and
                  p.trading_prd = @by_ref2 and
                  p.price_source_code = @by_ref3 and
                  p.price_quote_date = @last_quote_date
            set @rowcount = @@rowcount
	       end
         else if (@mkt_type = 'E')
	       begin
            select
               p.commkt_key,
               p.price_source_code,
               p.trading_prd,
               p.price_quote_date,
               p.low_bid_price,
               p.high_asked_price,
               p.avg_closed_price,
               p.open_interest,
               p.vol_traded,
               p.creation_type,
               ca.commkt_price_uom_code,
               ca.commkt_curr_code,
               p.trans_id,
               p.low_bid_creation_ind,
               p.high_asked_creation_ind,
               p.avg_closed_creation_ind
            from dbo.price p,
                 dbo.commkt_future_attr ca with (nolock)
            where ca.commkt_key = @commkt_key and
                  p.commkt_key = @commkt_key and
                  p.trading_prd = @by_ref2 and
                  p.price_source_code = @by_ref3 and
                  p.price_quote_date = @last_quote_date
            set @rowcount = @@rowcount
	       end
      end
      else	/* get the price with the specified quote date */
      begin
         if @mkt_type = 'P'
         begin
            select
               p.commkt_key,
               p.price_source_code,
               p.trading_prd,
               p.price_quote_date,
               p.low_bid_price,
               p.high_asked_price,
               p.avg_closed_price,
               p.open_interest,
               p.vol_traded,
               p.creation_type,
               cpa.commkt_price_uom_code,
               cpa.commkt_curr_code,
               p.trans_id,
               p.low_bid_creation_ind,
               p.high_asked_creation_ind,
               p.avg_closed_creation_ind
            from dbo.commodity_market cm with (nolock),
		             dbo.price p,
		             dbo.commkt_physical_attr cpa with (nolock)
            where cpa.commkt_key = cm.commkt_key and
                  cm.mkt_code = @by_ref0 and
                  cm.cmdty_code = @by_ref1 and
                  cm.commkt_key = p.commkt_key and
                  p.trading_prd = @by_ref2 and
                  p.price_source_code = @by_ref3 and
                  p.price_quote_date = convert(datetime, @by_ref5)
            set @rowcount = @@rowcount
	       end
         else if @mkt_type = 'E'
	       begin
            select
               p.commkt_key,
               p.price_source_code,
               p.trading_prd,
               p.price_quote_date,
               p.low_bid_price,
               p.high_asked_price,
               p.avg_closed_price,
               p.open_interest,
               p.vol_traded,
               p.creation_type,
               ca.commkt_price_uom_code,
               ca.commkt_curr_code,
               p.trans_id,
               p.low_bid_creation_ind,
               p.high_asked_creation_ind,
               p.avg_closed_creation_ind
	          from dbo.commodity_market cm with (nolock),
		             dbo.price p,
		             dbo.commkt_future_attr ca with (nolock)
            where ca.commkt_key = cm.commkt_key and
                  cm.mkt_code = @by_ref0 and
                  cm.cmdty_code = @by_ref1 and
                  cm.commkt_key = p.commkt_key and
                  p.trading_prd = @by_ref2 and
                  p.price_source_code = @by_ref3 and
                  p.price_quote_date = convert(datetime, @by_ref5)
            set @rowcount = @@rowcount
	       end
      end
   end
   else if ((@by_type0 in ('MC', 'mkt_code')) and
   	        (@by_type1 in ('CC', 'cmdty_code')) and
   	        (@by_type2 in ('TP', 'trading_prd')) and
   	        (@by_type3 in ('PSC', 'price_source_code' )) and
   	        (@by_type4 in ('CT', 'cmdty_type')) and
	          (@by_type5 in ('RPQD', 'ref_price_quote_date')))	/* case (b) */
   begin
      select @commkt_key = cm.commkt_key
      from dbo.commodity_market cm with (nolock)
      where cm.mkt_code = @by_ref0 and 
            cm.cmdty_code = @by_ref1

      select @dt = max(p.price_quote_date)
      from dbo.price p
      where p.commkt_key = @commkt_key and
            p.price_source_code = @by_ref3 and
            p.trading_prd = @by_ref2 and
            p.price_quote_date < @by_ref5

      select @mkt_type = m.mkt_type
      from dbo.market m with (nolock)
      where m.mkt_code = @by_ref0

      if @mkt_type = 'P'
      begin
         select
            p.commkt_key,
            p.price_source_code,
            p.trading_prd,
            p.price_quote_date,
            p.low_bid_price,
            p.high_asked_price,
            p.avg_closed_price,
            p.open_interest,
            p.vol_traded,
            p.creation_type,
            cpa.commkt_price_uom_code,
            cpa.commkt_curr_code,
            p.trans_id,
            p.low_bid_creation_ind,
            p.high_asked_creation_ind,
            p.avg_closed_creation_ind
         from dbo.price p,
              dbo.commkt_physical_attr cpa with (nolock)
         where p.commkt_key = @commkt_key and
               p.trading_prd = @by_ref2 and
               p.price_quote_date = @dt and
               p.price_source_code = @by_ref3 and
               cpa.commkt_key = p.commkt_key
         set @rowcount = @@rowcount
      end
      else if @mkt_type = 'E'
      begin
         select
            p.commkt_key,
            p.price_source_code,
            p.trading_prd,
            p.price_quote_date,
            p.low_bid_price,
            p.high_asked_price,
            p.avg_closed_price,
            p.open_interest,
            p.vol_traded,
            p.creation_type,
            cfa.commkt_price_uom_code,
            cfa.commkt_curr_code,
            p.trans_id,
            p.low_bid_creation_ind,
            p.high_asked_creation_ind,
            p.avg_closed_creation_ind
	       from dbo.price p,
              dbo.commkt_future_attr cfa with (nolock)
         where p.commkt_key = @commkt_key and
               p.trading_prd = @by_ref2 and
               p.price_quote_date = @dt and
               p.price_source_code = @by_ref3 and
               cfa.commkt_key = p.commkt_key
         set @rowcount = @@rowcount
	    end
   end
   else
	    return 4

   if (@rowcount = 1)
      return 0
   else if(@rowcount = 0)
      return 1
   else 
      return 2
end
GO
GRANT EXECUTE ON  [dbo].[locate_price] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'locate_price', NULL, NULL
GO
