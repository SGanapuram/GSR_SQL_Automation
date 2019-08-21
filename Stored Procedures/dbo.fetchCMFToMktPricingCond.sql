SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchCMFToMktPricingCond]
(
   @asof_trans_id      bigint,
   @cmf_num            int
)
as
set nocount on
 
   select asof_trans_id = @asof_trans_id,
          cmf_num,
          mkt_cond_date,
          mkt_cond_last_next_ind,
          mkt_cond_quote_range,
          mkt_cond_type,
          mkt_pricing_cond_num,
          resp_trans_id = NULL,
          trans_id
   from dbo.market_pricing_condition
   where cmf_num = @cmf_num and
         trans_id <= @asof_trans_id
   union
   select asof_trans_id = @asof_trans_id,
          cmf_num,
          mkt_cond_date,
          mkt_cond_last_next_ind,
          mkt_cond_quote_range,
          mkt_cond_type,
          mkt_pricing_cond_num,
          resp_trans_id,
          trans_id
   from dbo.aud_market_pricing_condition
   where cmf_num = @cmf_num and
         (trans_id <= @asof_trans_id and
          resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchCMFToMktPricingCond] TO [next_usr]
GO
