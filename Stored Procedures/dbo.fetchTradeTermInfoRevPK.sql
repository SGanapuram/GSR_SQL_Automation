SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchTradeTermInfoRevPK]
(
   @asof_trans_id      bigint,
   @trade_num          int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.trade_term_info
where trade_num = @trade_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      contr_end_date,
      contr_ren_term_date,
      contr_start_date,
      resp_trans_id = null,
      sap_contract_item_num,
      sap_contract_num,
      trade_num,
      trans_id,
      warning_start_date
   from dbo.trade_term_info
   where trade_num = @trade_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      contr_end_date,
      contr_ren_term_date,
      contr_start_date,
      resp_trans_id,
      sap_contract_item_num,
      sap_contract_num,
      trade_num,
      trans_id,
      warning_start_date
   from dbo.aud_trade_term_info
   where trade_num = @trade_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchTradeTermInfoRevPK] TO [next_usr]
GO
