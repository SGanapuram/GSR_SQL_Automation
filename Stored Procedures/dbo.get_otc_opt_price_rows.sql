SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[get_otc_opt_price_rows]
(
   @by_price_quote_date    datetime = null
)
as
begin
set nocount on

   if (@by_price_quote_date is null) 
      return 4   /* bad arguments */

   create table #price_temp 
   (       
      otc_opt_code            char(8)      NOT NULL,
      otc_opt_desc            varchar(255) NULL,
      otc_opt_price           float        NULL,
      otc_opt_delta           float        NULL,
      otc_opt_price_curr_code char(8)      NULL,
      otc_opt_price_uom_code  char(4)      NULL,
      trans_id                int          NULL
   )


   insert into #price_temp
   select otc_opt_code, 
          otc_opt_desc, 
          NULL, 
          NULL, 
          otc_opt_price_curr_code, 
          otc_opt_price_uom_code,
          trans_id
   from dbo.otc_option
    
   update #price_temp
   set otc_opt_price = otc_option_value.otc_opt_price,
       otc_opt_delta = otc_option_value.otc_opt_delta
   from dbo.otc_option_value
   where #price_temp.otc_opt_code = otc_option_value.otc_opt_code and
         convert(varchar(30), otc_option_value.otc_opt_quote_date, 101) = convert(varchar(30), @by_price_quote_date, 101)
   
   select
      otc_opt_code,
      otc_opt_desc,
      otc_opt_price,
      otc_opt_delta,
      otc_opt_price_curr_code,
      otc_opt_price_uom_code,
      trans_id
   from #price_temp
   order by otc_opt_code
end
return
GO
GRANT EXECUTE ON  [dbo].[get_otc_opt_price_rows] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'get_otc_opt_price_rows', NULL, NULL
GO
