SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[quickfill_find_curr_uom] 
(
   @itemNum1    smallint = null,
   @cmdty1      varchar(8) = null,
   @mkt1        varchar(8) = null,
   @itemNum2    smallint = null,
   @cmdty2      varchar(8) = null,
   @mkt2        varchar(8) = null,
   @itemNum3    smallint = null,
   @cmdty3      varchar(8) = null,
   @mkt3        varchar(8) = null,
   @itemNum4    smallint = null,
   @cmdty4      varchar(8) = null,
   @mkt4        varchar(8) = null,
   @uom1        char(4) output,
   @curr1       char(4) output,
   @uom2        char(4) output,
   @curr2       char(4) output,
   @uom3        char(4) output,
   @curr3       char(4) output,
   @uom4        char(4) output,
   @curr4       char(4) output
)
as
set nocount on

   if @itemNum1 is not null
   begin
      select @uom1 = commkt_price_uom_code,
             @curr1 = commkt_curr_code 
      from dbo.commkt_option_attr 
      where commkt_key = (select commkt_key 
                          from dbo.commodity_market 
                          where cmdty_code = @cmdty1 and 
                                mkt_code = @mkt1)
   end

   if @itemNum2 is not null
   begin
      select @uom2 = commkt_price_uom_code,
             @curr2 = commkt_curr_code 
      from dbo.commkt_option_attr 
      where commkt_key = (select commkt_key 
                          from dbo.commodity_market 
                          where cmdty_code = @cmdty2 and 
                                mkt_code = @mkt2)
   end

   if @itemNum3 is not null
   begin
      select @uom3 = commkt_price_uom_code,
             @curr3 = commkt_curr_code 
      from dbo.commkt_option_attr 
      where commkt_key = (select commkt_key 
                          from dbo.commodity_market 
                          where cmdty_code = @cmdty3 and 
                                mkt_code = @mkt3)
   end

   if @itemNum4 is not null
   begin
      select @uom4 = commkt_price_uom_code,
             @curr4 = commkt_curr_code 
      from dbo.commkt_option_attr 
      where commkt_key = (select commkt_key 
                          from dbo.commodity_market 
                          where cmdty_code = @cmdty4 and 
                                mkt_code = @mkt4)
   end
return 0
GO
GRANT EXECUTE ON  [dbo].[quickfill_find_curr_uom] TO [next_usr]
GO
