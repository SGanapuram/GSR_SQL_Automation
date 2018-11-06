SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchMktPriceQuoDatesRevPK]
(
   @asof_trans_id      int,
   @calendar_date      datetime,
   @cmf_num            int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.market_price_quote_dates
where cmf_num = @cmf_num and
      calendar_date = @calendar_date
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      calendar_date,
      cmf_num,
      end_of_period_ind,
      fiscal_month,
      priced_ind,
      quote_date,
      resp_trans_id = null,
      trans_id
   from dbo.market_price_quote_dates
   where cmf_num = @cmf_num and
         calendar_date = @calendar_date
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      calendar_date,
      cmf_num,
      end_of_period_ind,
      fiscal_month,
      priced_ind,
      quote_date,
      resp_trans_id,
      trans_id
   from dbo.aud_market_price_quote_dates
   where cmf_num = @cmf_num and
         calendar_date = @calendar_date and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchMktPriceQuoDatesRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchMktPriceQuoDatesRevPK', NULL, NULL
GO
