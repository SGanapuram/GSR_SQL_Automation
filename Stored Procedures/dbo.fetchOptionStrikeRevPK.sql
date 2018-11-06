SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchOptionStrikeRevPK]
(
   @asof_trans_id         int,
   @commkt_key            int,
   @opt_strike_price      float,
   @put_call_ind          char(1),
   @trading_prd           char(8)
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.option_strike
where commkt_key = @commkt_key and
      trading_prd = @trading_prd and
      opt_strike_price = @opt_strike_price and
      put_call_ind = @put_call_ind
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      commkt_key,
      opt_strike_price,
      put_call_ind,
      resp_trans_id = null,
      trading_prd,
      trans_id
   from dbo.option_strike
   where commkt_key = @commkt_key and
         trading_prd = @trading_prd and
         opt_strike_price = @opt_strike_price and
         put_call_ind = @put_call_ind
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      commkt_key,
      opt_strike_price,
      put_call_ind,
      resp_trans_id,
      trading_prd,
      trans_id
   from dbo.aud_option_strike
   where commkt_key = @commkt_key and
         trading_prd = @trading_prd and
         opt_strike_price = @opt_strike_price and
         put_call_ind = @put_call_ind and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchOptionStrikeRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchOptionStrikeRevPK', NULL, NULL
GO
