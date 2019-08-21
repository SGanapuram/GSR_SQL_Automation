SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_exposure_detail_rev]
(
   cost_num,
   exposure_num,	
   cash_exp_amt,		  
   mtm_pl,		  					
   mtm_from_date,
   mtm_end_date,		  
   cash_from_date,	   
   cash_to_date,
   shift_exposure_num,	
   credit_exposure_oid,	  
   cost_amt,
   cost_price_curr_code,
   lc_type_code,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   cost_num,
   exposure_num,	
   cash_exp_amt,		  
   mtm_pl,		  					
   mtm_from_date,
   mtm_end_date,		  
   cash_from_date,	   
   cash_to_date,
   shift_exposure_num,
   credit_exposure_oid,		  
   cost_amt,
   cost_price_curr_code,
   lc_type_code,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_exposure_detail
GO
GRANT SELECT ON  [dbo].[v_exposure_detail_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_exposure_detail_rev] TO [next_usr]
GO
