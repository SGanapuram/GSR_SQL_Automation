SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_fx_hedge_rate_rev]
(
   fx_hedge_rate_num,	
   commkt_key,    
   trading_prd,
   clr_brkr_num,
   price_source_code,
   from_curr_code,
   to_curr_code,	
   conv_rate,		
   mul_div_ind,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   fx_hedge_rate_num,	
   commkt_key,    
   trading_prd,
   clr_brkr_num,
   price_source_code,
   from_curr_code,
   to_curr_code,	
   conv_rate,		
   mul_div_ind,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_fx_hedge_rate
GO
GRANT SELECT ON  [dbo].[v_fx_hedge_rate_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_fx_hedge_rate_rev] TO [next_usr]
GO
