SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[get_simple_formula_path]
(
   @by_commkt_key          int = null,
   @by_trading_prd         char(8) = null,
   @by_price_source_code   char(8) = null,
   @by_price_type          char(1) = null,
   @formulapath1           varchar(255) output,
   @formulapath2           varchar(255) output
)
as
begin
set nocount on
declare @cmdty_short_name              varchar(15),
        @mkt_short_name                varchar(15),
        @price_source_name             varchar(40),
        @trading_prd_desc              varchar(40),
        @cmdty_code                    char(8),
        @mkt_code                      char(8)
        
   set @formulapath1 = NULL
   set @formulapath2 = NULL
   if (@by_commkt_key is null) or 
      (@by_price_source_code is null) or 
      (@by_trading_prd is null) or
      (@by_price_type is null)
      return 4

   if not exists (select 1 
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
      select @cmdty_short_name = cmdty_short_name
      from dbo.commodity
      where cmdty_code = @cmdty_code
   else
      select @cmdty_short_name = '?' + @cmdty_code + '?'

   if exists (select 1 
              from dbo.market with (nolock)
              where mkt_code = @mkt_code)
      select @mkt_short_name = mkt_short_name
      from dbo.market
      where mkt_code = @mkt_code
   else
      select @mkt_short_name = '?' + @mkt_code + '?'
      
   if exists (select 1 
              from dbo.trading_period with (nolock)
              where commkt_key = @by_commkt_key and
                    trading_prd = @by_trading_prd)
      select @trading_prd_desc = trading_prd_desc
      from dbo.trading_period
      where commkt_key = @by_commkt_key and
            trading_prd = @by_trading_prd
   else
      select @trading_prd_desc = '?' + Rtrim(@by_trading_prd) + '?'

   if exists (select 1 
              from dbo.price_source with (nolock)
              where price_source_code = @by_price_source_code)
      select @price_source_name = price_source_name
      from dbo.price_source
      where price_source_code = @by_price_source_code
   else
      select @price_source_name = '?' + Rtrim(@by_price_source_code) + '?'

   select @formulapath2 = Rtrim(@cmdty_code) + '/' 
   select @formulapath2 = @formulapath2 + RTrim(@mkt_code) + '/'
   select @formulapath2 = @formulapath2 + RTrim(@by_price_source_code) + '/'
   select @formulapath2 = @formulapath2 + RTrim(@by_trading_prd) + '/'
   select @formulapath2 = @formulapath2 + RTrim(@by_price_type)

   select @formulapath1 = @cmdty_short_name + '/' 
   select @formulapath1 = @formulapath1 + @mkt_short_name + '/'
   select @formulapath1 = @formulapath1 + @price_source_name + '/'
   select @formulapath1 = @formulapath1 + @trading_prd_desc
   if @by_price_type = 'H' 
      select @formulapath1 = @formulapath1 + '/High'
   if @by_price_type = 'L' 
      select @formulapath1 = @formulapath1 + '/Low'
   if @by_price_type = 'C' 
      select @formulapath1 = @formulapath1 + '/Closed'
   if @by_price_type = 'O' 
      select @formulapath1 = @formulapath1 + '/Open'
   if @by_price_type = 'A' 
      select @formulapath1 = @formulapath1 + '/Average'
end
return
GO
GRANT EXECUTE ON  [dbo].[get_simple_formula_path] TO [next_usr]
GO
