SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchFxExposureRevPK]
(
   @asof_trans_id      int,
   @oid                int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.fx_exposure
where oid = @oid
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      custom_column1,
      custom_column2,
      custom_column3,
      custom_column4,
      fixed_rate_amt,
      fx_exp_curr_oid,
      fx_exp_sub_type,
      fx_exposure_type,
      fx_trading_prd,
      linked_rate_amt,
      oid,
      open_rate_amt,
      real_port_num,
      resp_trans_id = null,
      status,
      trans_id
   from dbo.fx_exposure
   where oid = @oid
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      custom_column1,
      custom_column2,
      custom_column3,
      custom_column4,
      fixed_rate_amt,
      fx_exp_curr_oid,
      fx_exp_sub_type,
      fx_exposure_type,
      fx_trading_prd,
      linked_rate_amt,
      oid,
      open_rate_amt,
      real_port_num,
      resp_trans_id,
      status,
      trans_id
   from dbo.aud_fx_exposure
   where oid = @oid and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchFxExposureRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchFxExposureRevPK', NULL, NULL
GO
