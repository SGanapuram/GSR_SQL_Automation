SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchPriceRevPK]
(
   @asof_trans_id bigint,
   @commkt_key             int,
   @price_quote_date       datetime,
   @price_source_code      char(8),
   @trading_prd            char(8)
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.price
where commkt_key = @commkt_key and
      price_source_code = @price_source_code and
      trading_prd = @trading_prd and
      price_quote_date = @price_quote_date
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      avg_closed_creation_ind,
      avg_closed_price,
      commkt_key,
      creation_type,
      high_asked_creation_ind,
      high_asked_price,
      low_bid_creation_ind,
      low_bid_price,
      open_interest,
      price_quote_date,
      price_source_code,
      resp_trans_id = null,
      trading_prd,
      trans_id,
      vol_traded
   from dbo.price
   where commkt_key = @commkt_key and
         price_source_code = @price_source_code and
         trading_prd = @trading_prd and
         price_quote_date = @price_quote_date
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      avg_closed_creation_ind,
      avg_closed_price,
      commkt_key,
      creation_type,
      high_asked_creation_ind,
      high_asked_price,
      low_bid_creation_ind,
      low_bid_price,
      open_interest,
      price_quote_date,
      price_source_code,
      resp_trans_id,
      trading_prd,
      trans_id,
      vol_traded
   from dbo.aud_price
   where commkt_key = @commkt_key and
         price_source_code = @price_source_code and
         trading_prd = @trading_prd and
         price_quote_date = @price_quote_date and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchPriceRevPK] TO [next_usr]
GO
