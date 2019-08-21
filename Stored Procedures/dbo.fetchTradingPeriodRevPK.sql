SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchTradingPeriodRevPK]
(
   @asof_trans_id      bigint,
   @commkt_key         int,
   @trading_prd        char(8)
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.trading_period
where commkt_key = @commkt_key and
      trading_prd = @trading_prd
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      commkt_key,
      first_del_date,
      first_issue_date,
      last_del_date,
      last_issue_date,
      last_quote_date,
      last_trade_date,
      opt_eval_method,
      opt_exp_date,
      resp_trans_id = null,
      trading_prd,
      trading_prd_desc,
      trans_id
   from dbo.trading_period
   where commkt_key = @commkt_key and
         trading_prd = @trading_prd
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      commkt_key,
      first_del_date,
      first_issue_date,
      last_del_date,
      last_issue_date,
      last_quote_date,
      last_trade_date,
      opt_eval_method,
      opt_exp_date,
      resp_trans_id,
      trading_prd,
      trading_prd_desc,
      trans_id
   from dbo.aud_trading_period
   where commkt_key = @commkt_key and
         trading_prd = @trading_prd and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchTradingPeriodRevPK] TO [next_usr]
GO
