SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_avg_buy_sell_price_term_rev]
(
   formula_num,
   roll_days,
   exclusion_days,
   determination_opt,
   determination_mths_num,
   price_term_start_date,
   price_term_end_date,
   quote_type,
   buyer_seller_opt,
   all_quotes_reqd_ind,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   formula_num,
   roll_days,
   exclusion_days,
   determination_opt,
   determination_mths_num,
   price_term_start_date,
   price_term_end_date,
   quote_type,
   buyer_seller_opt,
   all_quotes_reqd_ind,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_avg_buy_sell_price_term
GO
GRANT SELECT ON  [dbo].[v_avg_buy_sell_price_term_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_avg_buy_sell_price_term_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_avg_buy_sell_price_term_rev', NULL, NULL
GO
