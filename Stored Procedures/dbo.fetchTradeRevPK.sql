SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchTradeRevPK]
(
   @asof_trans_id  int,
   @trade_num      int
)
as
set nocount on
declare @trans_id  int

select @trans_id = trans_id
from dbo.trade
where trade_num = @trade_num
   
if @trans_id <= @asof_trans_id
begin
   select 
       acct_cont_num,
       acct_num,
       acct_ref_num,
       /* acct_short_name,  removed for UNICODE */
       asof_trans_id = @asof_trans_id,
       cargo_id_number,
       concluded_date,
       conclusion_type,
       contr_anly_init,
       contr_approv_type,
       contr_cnfrm_method,
       contr_date,
       contr_exch_method,
       contr_status_code,
       contr_tlx_hold_ind,
       copy_type,
       cp_gov_contr_ind,
       cr_anly_init,
       creation_date,
       creator_init,
       credit_res_exp_date,
       credit_status,
       credit_term_code,
       econfirm_status,
       external_trade_type,
       inhouse_ind,
       internal_agreement_ind,
       internal_parent_trade_num,
       invoice_cap_type,
       is_long_term_ind,
       max_order_num,
       port_num,
       product_id,
       resp_trans_id = null,
       special_contract_num,
       trade_mod_date,
       trade_mod_init,
       trade_num,
       trade_status_code,
       trader_init,
       trans_id
    from dbo.trade
    where trade_num = @trade_num
end
else
begin
   select top 1
       acct_cont_num,
       acct_num,
       acct_ref_num,
       /* acct_short_name, */
       asof_trans_id = @asof_trans_id,
       cargo_id_number,
       concluded_date,
       conclusion_type,
       contr_anly_init,
       contr_approv_type,
       contr_cnfrm_method,
       contr_date,
       contr_exch_method,
       contr_status_code,
       contr_tlx_hold_ind,
       copy_type,
       cp_gov_contr_ind,
       cr_anly_init,
       creation_date,
       creator_init,
       credit_res_exp_date,
       credit_status,
       credit_term_code,
       econfirm_status,
       external_trade_type,
       inhouse_ind,
       internal_agreement_ind,
       internal_parent_trade_num,
       invoice_cap_type,
       is_long_term_ind,
       max_order_num,
       port_num,
       product_id,
       resp_trans_id,
       special_contract_num,
       trade_mod_date,
       trade_mod_init,
       trade_num,
       trade_status_code,
       trader_init,
       trans_id
   from dbo.aud_trade
   where trade_num = @trade_num and 
         trans_id <= @asof_trans_id and
	       resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchTradeRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchTradeRevPK', NULL, NULL
GO
