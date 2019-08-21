SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchCmdtyMktSourceRevPK]
(
   @asof_trans_id          bigint,
   @commkt_key             int,
   @price_source_code      char(8)
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.commodity_market_source
where commkt_key = @commkt_key and
      price_source_code = @price_source_code
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      calendar_code,
      commkt_key,
      dflt_alias_source_code,
      financial_borrow_use_ind,
      financial_lend_use_ind,
      option_eval_use_ind,
      price_source_code,
      quote_price_precision,
      resp_trans_id = null,
      trans_id,
      tvm_use_ind
   from dbo.commodity_market_source
   where commkt_key = @commkt_key and
         price_source_code = @price_source_code
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      calendar_code,
      commkt_key,
      dflt_alias_source_code,
      financial_borrow_use_ind,
      financial_lend_use_ind,
      option_eval_use_ind,
      price_source_code,
      quote_price_precision,
      resp_trans_id,
      trans_id,
      tvm_use_ind
   from dbo.aud_commodity_market_source
   where commkt_key = @commkt_key and
         price_source_code = @price_source_code and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchCmdtyMktSourceRevPK] TO [next_usr]
GO
