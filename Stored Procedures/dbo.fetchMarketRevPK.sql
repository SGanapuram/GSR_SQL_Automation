SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchMarketRevPK]
(
   @asof_trans_id      bigint,
   @mkt_code           char(8)
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.market
where mkt_code = @mkt_code
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      mkt_code,
      mkt_full_name,
      mkt_short_name,
      mkt_status,
      mkt_type,
      resp_trans_id = null,
      trans_id
   from dbo.market
   where mkt_code = @mkt_code
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      mkt_code,
      mkt_full_name,
      mkt_short_name,
      mkt_status,
      mkt_type,
      resp_trans_id,
      trans_id
   from dbo.aud_market
   where mkt_code = @mkt_code and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchMarketRevPK] TO [next_usr]
GO
