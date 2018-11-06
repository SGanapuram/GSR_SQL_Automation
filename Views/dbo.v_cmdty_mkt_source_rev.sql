SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_cmdty_mkt_source_rev]
(
   commkt_key,
   price_source_code,
   dflt_alias_source_code,
   calendar_code,
   tvm_use_ind,
   option_eval_use_ind,
   financial_borrow_use_ind,
   financial_lend_use_ind,
   quote_price_precision,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   commkt_key,
   price_source_code,
   dflt_alias_source_code,
   calendar_code,
   tvm_use_ind,
   option_eval_use_ind,
   financial_borrow_use_ind,
   financial_lend_use_ind,
   quote_price_precision,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_commodity_market_source
GO
GRANT SELECT ON  [dbo].[v_cmdty_mkt_source_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_cmdty_mkt_source_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_cmdty_mkt_source_rev', NULL, NULL
GO
