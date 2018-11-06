SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchExposureDetailRevPK]
(
   @asof_trans_id      int,
   @cost_num           int,
   @exposure_num       int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.exposure_detail
where cost_num = @cost_num and
      exposure_num = @exposure_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      cash_exp_amt,
      cash_from_date,
      cash_to_date,
      cost_amt,
      cost_num,
      cost_price_curr_code,
      credit_exposure_oid,
      exposure_num,
      lc_type_code,
      mtm_end_date,
      mtm_from_date,
      mtm_pl,
      resp_trans_id = null,
      shift_exposure_num,
      trans_id
   from dbo.exposure_detail
   where cost_num = @cost_num and
         exposure_num = @exposure_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      cash_exp_amt,
      cash_from_date,
      cash_to_date,
      cost_amt,
      cost_num,
      cost_price_curr_code,
      credit_exposure_oid,
      exposure_num,
      lc_type_code,
      mtm_end_date,
      mtm_from_date,
      mtm_pl,
      resp_trans_id,
      shift_exposure_num,
      trans_id
   from dbo.aud_exposure_detail
   where cost_num = @cost_num and
         exposure_num = @exposure_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchExposureDetailRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchExposureDetailRevPK', NULL, NULL
GO
