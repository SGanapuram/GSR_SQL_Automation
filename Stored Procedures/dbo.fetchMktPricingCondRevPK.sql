SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchMktPricingCondRevPK]
(
   @asof_trans_id             bigint,
   @cmf_num                   int,
   @mkt_pricing_cond_num      smallint
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.market_pricing_condition
where cmf_num = @cmf_num and
      mkt_pricing_cond_num = @mkt_pricing_cond_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      cmf_num,
      mkt_cond_date,
      mkt_cond_last_next_ind,
      mkt_cond_quote_range,
      mkt_cond_type,
      mkt_pricing_cond_num,
      resp_trans_id = null,
      trans_id
   from dbo.market_pricing_condition
   where cmf_num = @cmf_num and
         mkt_pricing_cond_num = @mkt_pricing_cond_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
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
         mkt_pricing_cond_num = @mkt_pricing_cond_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchMktPricingCondRevPK] TO [next_usr]
GO
