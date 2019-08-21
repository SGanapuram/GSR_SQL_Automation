SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchCostToExposureDetail]
(
   @asof_trans_id      bigint,
   @cost_num           int
)
as
set nocount on
 
   select asof_trans_id = @asof_trans_id,
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
          resp_trans_id = NULL,
          shift_exposure_num,
          trans_id
   from dbo.exposure_detail
   where cost_num = @cost_num and
         trans_id <= @asof_trans_id
   union
   select asof_trans_id = @asof_trans_id,
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
         (trans_id <= @asof_trans_id and
          resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchCostToExposureDetail] TO [next_usr]
GO
