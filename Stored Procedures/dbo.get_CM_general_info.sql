SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[get_CM_general_info]
(
   @by_commkt_key          int = null
)
as
begin
set nocount on
declare @cmdty_code                    char(8),
        @cmdty_short_name              varchar(15),
        @mkt_code                      char(8),
        @mkt_short_name                varchar(15),
        @mkt_type                      char(1),
        @commkt_spot_prd               char(8),
        @commkt_num_mth_out            smallint,
        @commkt_support_price_type     varchar(2),
        @commkt_price_series           char(1),
        @commkt_curr_code              char(8),
        @commkt_price_uom_code         char(4)

        
   select @cmdty_code = NULL,
          @cmdty_short_name = NULL,
          @mkt_code = NULL,
          @mkt_short_name = NULL,
          @mkt_type = 'P',
          @commkt_spot_prd = NULL,
          @commkt_num_mth_out = 0,
          @commkt_support_price_type = NULL,
          @commkt_price_series = NULL,
          @commkt_curr_code = NULL,
          @commkt_price_uom_code = NULL

   if (@by_commkt_key is null) 
      return 4

   if NOT exists (select 1 
                  from dbo.commodity_market with (nolock)
                  where commkt_key = @by_commkt_key)
      return

   select @cmdty_code = cmdty_code,
          @mkt_code = mkt_code
   from dbo.commodity_market
   where commkt_key = @by_commkt_key

   if exists (select 1 
              from dbo.commodity with (nolock)
              where cmdty_code = @cmdty_code)
   begin
      select @cmdty_short_name = cmdty_short_name
      from dbo.commodity
      where cmdty_code = @cmdty_code
   end

   if exists (select 1 
              from dbo.market with (nolock)
              where mkt_code = @mkt_code)
   begin
      select @mkt_short_name = mkt_short_name,
             @mkt_type = mkt_type
      from dbo.market
      where mkt_code = @mkt_code
   end

   if @mkt_type = 'P' 
   begin
      if exists (select 1 
                 from dbo.commkt_physical_attr with (nolock)
                 where commkt_key = @by_commkt_key)
         select @commkt_spot_prd = commkt_spot_prd,
                @commkt_num_mth_out = commkt_num_mth_out,
                @commkt_support_price_type = commkt_support_price_type,
                @commkt_price_series = commkt_price_series,
                @commkt_curr_code = commkt_curr_code,
                @commkt_price_uom_code = commkt_price_uom_code
         from dbo.commkt_physical_attr
         where commkt_key = @by_commkt_key
   end
   else
   begin
      if exists (select 1 
                 from dbo.commkt_future_attr with (nolock)
                 where commkt_key = @by_commkt_key)
         select @commkt_spot_prd = commkt_spot_prd,
                @commkt_num_mth_out = commkt_num_mth_out,
                @commkt_support_price_type = commkt_support_price_type,
                @commkt_price_series = commkt_price_series,
                @commkt_curr_code = commkt_curr_code,
                @commkt_price_uom_code = commkt_price_uom_code
         from dbo.commkt_future_attr
         where commkt_key = @by_commkt_key
   end

   select @cmdty_code,
          @cmdty_short_name,
          @mkt_code,
          @mkt_short_name,
          @mkt_type,
          @commkt_spot_prd,
          @commkt_num_mth_out,
          @commkt_support_price_type,
          @commkt_price_series,
          @commkt_curr_code,
          @commkt_price_uom_code
end
return
GO
GRANT EXECUTE ON  [dbo].[get_CM_general_info] TO [next_usr]
GO
