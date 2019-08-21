SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_fx_exposure_rev]
(
   oid,
   fx_exp_curr_oid,
   fx_trading_prd,
   fx_exposure_type,
   real_port_num,
   open_rate_amt,
   fixed_rate_amt,
   linked_rate_amt,
   fx_exp_sub_type,
   status,
   custom_column1,
   custom_column2,
   custom_column3,
   custom_column4,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   oid,
   fx_exp_curr_oid,
   fx_trading_prd,
   fx_exposure_type,
   real_port_num,
   open_rate_amt,
   fixed_rate_amt,
   linked_rate_amt,
   fx_exp_sub_type,
   status,
   custom_column1,
   custom_column2,
   custom_column3,
   custom_column4,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_fx_exposure
GO
GRANT SELECT ON  [dbo].[v_fx_exposure_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_fx_exposure_rev] TO [next_usr]
GO
