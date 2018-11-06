SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchCMFToMktPriceQuoDates]
(
   @asof_trans_id      int,
   @cmf_num            int
)
as
set nocount on
 
   select asof_trans_id = @asof_trans_id,
          calendar_date,
          cmf_num,
          end_of_period_ind,
          fiscal_month,
          priced_ind,
          quote_date,
          resp_trans_id = NULL,
          trans_id
   from dbo.market_price_quote_dates
   where cmf_num = @cmf_num and
         trans_id <= @asof_trans_id
   union
   select asof_trans_id = @asof_trans_id,
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
         (trans_id <= @asof_trans_id and
          resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchCMFToMktPriceQuoDates] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchCMFToMktPriceQuoDates', NULL, NULL
GO
