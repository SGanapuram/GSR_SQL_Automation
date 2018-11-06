SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_fx_exposure_currency_rev]
(
   oid,
   price_curr_code,
   pl_curr_code,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   oid,
   price_curr_code,
   pl_curr_code,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_fx_exposure_currency
GO
GRANT SELECT ON  [dbo].[v_fx_exposure_currency_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_fx_exposure_currency_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_fx_exposure_currency_rev', NULL, NULL
GO
