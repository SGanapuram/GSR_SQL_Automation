SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[find_prices]
(
   @by_type0	varchar(40) = null,
   @by_ref0	varchar(40) = null,
   @by_type1	varchar(40) = null,
   @by_ref1	varchar(40) = null,
   @by_type2	varchar(40) = null,
   @by_ref2	varchar(40) = null,
   @by_type3	varchar(40) = null,
   @by_ref3	varchar(40) = null,
   @by_type4	varchar(40) = null,
   @by_ref4	varchar(40) = null
)
as 
begin
set nocount on
declare @rowcount     int
declare @ref_num0     int
declare @mkt_type     char(1)
declare @start_date   datetime
declare @end_date     datetime
declare @source_code  varchar(8)

   if @by_type0 = 'all'
   begin
      select p.commkt_key,
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
          from dbo.price p
   end
   else if ((@by_type0 in ('MC','mkt_code')) and
            (@by_type1 in ('CC', 'cmdty_code')) and
            (@by_type2 in ('TP', 'trading_prd')) and
            (@by_type3 is null) and
            (@by_ref3 is null) and
            (@by_type4 is null) and
            (@by_ref4 is null))
   begin
      select p.commkt_key,
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
            tp.last_quote_date = p.price_quote_date
   end
   -- stuff for backwards compatibility
   else if ((@by_type0 in ('commkt_key')) and
   	        (@by_type1 in ('trading_prd')) and
   	        (@by_type2 in ('start_date')) and
   	        (@by_type3 in ('end_date')) and
  	        (@by_type4 is null) and
   	        (@by_ref4 is null))
   begin
      set @ref_num0 = convert (int, @by_ref0)
      set @start_date = convert (datetime, @by_ref2)

      select @source_code = price_source_code
      from dbo.commodity_market_source cms
      where cms.commkt_key = @ref_num0

      set @end_date = convert (datetime, @by_ref3)

      select @mkt_type = mkt_type
      from dbo.commodity_market cm with (nolock), 
           dbo.market m with (nolock)
      where cm.commkt_key = @ref_num0 and 
            cm.mkt_code = m.mkt_code

      if (@mkt_type = 'P')
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
         where p.commkt_key = @ref_num0 and 
               p.commkt_key = cpa.commkt_key and 
               p.price_source_code = @source_code and 
               p.trading_prd = @by_ref1 and 
               p.price_quote_date between @start_date and @end_date
         set @rowcount = @@rowcount
      end
      else if(@mkt_type  =  'E')
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
         where p.commkt_key = @ref_num0 and 
               p.price_source_code = @source_code and 
               p.commkt_key = cfa.commkt_key and 
               p.trading_prd = @by_ref1 and 
               p.price_quote_date between @start_date and @end_date
         set @rowcount = @@rowcount
      end
   end
   -- Graphs Requirement (need price Source)
   else if ((@by_type0 in ('commkt_key')) and
   	        (@by_type1 in ('trading_prd')) and
   	        (@by_type2 in ('start_date')) and
   	        (@by_type3 in ('end_date')) and
  	        (@by_type4 in ('price_source_code')))
   begin
      set @ref_num0 = convert(int, @by_ref0)
      set @start_date = convert(datetime, @by_ref2)
		  set @end_date = convert(datetime, @by_ref3)

      select @mkt_type = m.mkt_type
      from dbo.commodity_market cm with (nolock),
           dbo.market m with (nolock)
      where cm.commkt_key = @ref_num0 and 
            cm.mkt_code = m.mkt_code
      if (@mkt_type = 'P')
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
         where p.commkt_key = @ref_num0 and 
               p.commkt_key = cpa.commkt_key and 
               p.price_source_code = @by_ref4 and 
               p.trading_prd = @by_ref1 and 
               p.price_quote_date between @start_date and @end_date
         set @rowcount = @@rowcount
      end
      else if (@mkt_type = 'E')
      begin
         select p.commkt_key,
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
         where p.commkt_key = @ref_num0 and 
               p.price_source_code = @by_ref4 and 
               p.commkt_key = cfa.commkt_key and 
               p.trading_prd = @by_ref1 and 
               p.price_quote_date between @start_date and @end_date
         set @rowcount = @@rowcount
      end
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
GRANT EXECUTE ON  [dbo].[find_prices] TO [next_usr]
GO
