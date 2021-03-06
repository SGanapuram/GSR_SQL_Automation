SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_trade_term_info_rev]
(
   trade_num,
   contr_start_date,
   contr_end_date,
   contr_ren_term_date,
   warning_start_date,
   sap_contract_num,
   sap_contract_item_num,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as 
select
   trade_num,
   contr_start_date,
   contr_end_date,
   contr_ren_term_date,
   warning_start_date,
   sap_contract_num,
   sap_contract_item_num,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_trade_term_info                                                                                                                                          
GO
GRANT SELECT ON  [dbo].[v_trade_term_info_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_trade_term_info_rev] TO [next_usr]
GO
