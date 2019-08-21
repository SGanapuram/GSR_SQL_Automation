SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[get_CM_formula]
(
   @by_commkt_key          int = null,
   @by_trading_prd         char(8) = null,
   @by_price_source_code   char(8) = null
)
as
begin
set nocount on
declare @low_bid_formula_num           int,
        @high_asked_formula_num        int,
        @avg_closed_formula_num        int,
        @low_bid_simple_formula_num    int,
        @high_asked_simple_formula_num int,
        @avg_closed_simple_formula_num int,
        @quote_commkt_key              int,
        @quote_trading_prd             varchar(8),
        @quote_price_source_code       varchar(8),
        @quote_price_type              char(1),
        @high_asked_formula_name       varchar(40),
        @low_bid_formula_name          varchar(40),
        @avg_closed_formula_name       varchar(40),
        @high_asked_formula_path1      varchar(255),
        @low_bid_formula_path1         varchar(255),
        @avg_closed_formula_path1      varchar(255),
        @high_asked_formula_path2      varchar(255),
        @low_bid_formula_path2         varchar(255),
        @avg_closed_formula_path2      varchar(255),
        @cmdty_short_name              varchar(15),
        @mkt_short_name                varchar(15),
        @price_source_name             varchar(40),
        @trading_prd_desc              varchar(40),
        @lb_quote_diff                 float,
        @lb_quote_diff_curr_code       varchar(8),
        @lb_quote_diff_uom_code        char(4),
        @ha_quote_diff                 float,
        @ha_quote_diff_curr_code       varchar(8),
        @ha_quote_diff_uom_code        char(4),
        @ac_quote_diff                 float,
        @ac_quote_diff_curr_code       varchar(8),
        @ac_quote_diff_uom_code        char(4)

        select @low_bid_formula_num = NULL,
               @high_asked_formula_num = NULL,
               @avg_closed_formula_num = NULL,
               @low_bid_simple_formula_num = NULL,
               @high_asked_simple_formula_num = NULL,
               @avg_closed_simple_formula_num = NULL,
               @high_asked_formula_name = NULL,
               @low_bid_formula_name = NULL,
               @avg_closed_formula_name = NULL,
               @high_asked_formula_path1 = NULL,
               @low_bid_formula_path1 = NULL,
               @avg_closed_formula_path1 = NULL,
               @high_asked_formula_path2 = NULL,
               @low_bid_formula_path2 = NULL,
               @avg_closed_formula_path2 = NULL,
               @lb_quote_diff = NULL,
               @lb_quote_diff_curr_code = NULL,
               @lb_quote_diff_uom_code = NULL,
               @ha_quote_diff = NULL,
               @ha_quote_diff_curr_code = NULL,
               @ha_quote_diff_uom_code = NULL,
               @ac_quote_diff = NULL,
               @ac_quote_diff_curr_code = NULL,
               @ac_quote_diff_uom_code = NULL

   if (@by_commkt_key is null) or 
      (@by_price_source_code is null) or 
      (@by_trading_prd is null)
      return 4

   if exists (select 1 
              from dbo.commodity_market_formula with (nolock)
              where commkt_key = @by_commkt_key and
                    price_source_code = @by_price_source_code and
                    trading_prd = @by_trading_prd)
   begin
       select @low_bid_formula_num = low_bid_formula_num,
              @high_asked_formula_num = high_asked_formula_num,
              @avg_closed_formula_num = avg_closed_formula_num,
              @low_bid_simple_formula_num = low_bid_simple_formula_num,
              @high_asked_simple_formula_num = high_asked_simple_formula_num,
              @avg_closed_simple_formula_num = avg_closed_simple_formula_num
       from dbo.commodity_market_formula
       where commkt_key = @by_commkt_key and
             trading_prd = @by_trading_prd and
             price_source_code = @by_price_source_code

       if @low_bid_formula_num > 0 
       begin
          select @low_bid_formula_name = formula_name 
          from dbo.formula
          where formula_num = @low_bid_formula_num
       end
      
       if @high_asked_formula_num > 0 
       begin
          select @high_asked_formula_name = formula_name 
          from dbo.formula
          where formula_num = @high_asked_formula_num
       end

       if @avg_closed_formula_num > 0 
       begin
          select @avg_closed_formula_name = formula_name 
          from dbo.formula
          where formula_num = @avg_closed_formula_num
       end

       if @low_bid_simple_formula_num > 0 
       begin
          select @quote_commkt_key = quote_commkt_key,
                 @quote_trading_prd = quote_trading_prd,
                 @quote_price_source_code = quote_price_source_code,
                 @quote_price_type = quote_price_type,
                 @lb_quote_diff = quote_diff,
                 @lb_quote_diff_curr_code = quote_diff_curr_code,
                 @lb_quote_diff_uom_code = quote_diff_uom_code
          from dbo.simple_formula
          where simple_formula_num = @low_bid_simple_formula_num

          exec dbo.get_simple_formula_path 
                  @quote_commkt_key,
                  @quote_trading_prd,
                  @quote_price_source_code,
                  @quote_price_type,
                  @formulapath1 = @low_bid_formula_path1 output,
                  @formulapath2 = @low_bid_formula_path2 output
       end   

       if @high_asked_simple_formula_num > 0 
       begin
          select @quote_commkt_key = quote_commkt_key,
                 @quote_trading_prd = quote_trading_prd,
                 @quote_price_source_code = quote_price_source_code,
                 @quote_price_type = quote_price_type,
                 @ha_quote_diff = quote_diff,
                 @ha_quote_diff_curr_code = quote_diff_curr_code,
                 @ha_quote_diff_uom_code = quote_diff_uom_code
          from dbo.simple_formula
          where simple_formula_num = @high_asked_simple_formula_num

          exec dbo.get_simple_formula_path 
                  @quote_commkt_key,
                  @quote_trading_prd,
                  @quote_price_source_code,
                  @quote_price_type,
                  @formulapath1 = @high_asked_formula_path1 output,
                  @formulapath2 = @high_asked_formula_path2 output
       end   


       if @avg_closed_simple_formula_num > 0 
       begin
          select @quote_commkt_key = quote_commkt_key,
                 @quote_trading_prd = quote_trading_prd,
                 @quote_price_source_code = quote_price_source_code,
                 @quote_price_type = quote_price_type,
                 @ac_quote_diff = quote_diff,
                 @ac_quote_diff_curr_code = quote_diff_curr_code,
                 @ac_quote_diff_uom_code = quote_diff_uom_code
          from dbo.simple_formula
          where simple_formula_num = @avg_closed_simple_formula_num

          exec dbo.get_simple_formula_path 
                  @quote_commkt_key,
                  @quote_trading_prd,
                  @quote_price_source_code,
                  @quote_price_type,
                  @formulapath1 = @avg_closed_formula_path1 output,
                  @formulapath2 = @avg_closed_formula_path2 output
       end   
   end

   select @low_bid_formula_num,
          @high_asked_formula_num,
          @avg_closed_formula_num,
          @low_bid_simple_formula_num,
          @high_asked_simple_formula_num,
          @avg_closed_simple_formula_num,
          @low_bid_formula_name,
          @high_asked_formula_name,
          @avg_closed_formula_name,
          @low_bid_formula_path1,
          @high_asked_formula_path1,
          @avg_closed_formula_path1,
          @lb_quote_diff,
          @lb_quote_diff_curr_code,
          @lb_quote_diff_uom_code,
          @ha_quote_diff,
          @ha_quote_diff_curr_code,
          @ha_quote_diff_uom_code,
          @ac_quote_diff,
          @ac_quote_diff_curr_code,
          @ac_quote_diff_uom_code,
          @low_bid_formula_path2,
          @high_asked_formula_path2,
          @avg_closed_formula_path2
end
return
GO
GRANT EXECUTE ON  [dbo].[get_CM_formula] TO [next_usr]
GO
