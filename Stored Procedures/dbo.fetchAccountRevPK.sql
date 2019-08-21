SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchAccountRevPK]
(
   @acct_num           int,
   @asof_trans_id      bigint
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.account
where acct_num = @acct_num
 
if @trans_id <= @asof_trans_id
begin
   select
      acct_fiscal_code,
      acct_full_name,
      acct_num,
      acct_parent_ind,
      acct_short_name,
      acct_status,
      acct_sub_ind,
      acct_sub_type_code,
      acct_type_code,
      acct_vat_code,
      allows_bookout,
      allows_netout,
      asof_trans_id = @asof_trans_id,
      contract_cmnt_num,
      govt_code,
      legal_entity_num,
      man_input_sec_qty_required,
      master_agreement_date,
      resp_trans_id = null,
      risk_transfer_ind_code,
      trans_id
   from dbo.account
   where acct_num = @acct_num
end
else
begin
   select top 1
      acct_fiscal_code,
      acct_full_name,
      acct_num,
      acct_parent_ind,
      acct_short_name,
      acct_status,
      acct_sub_ind,
      acct_sub_type_code,
      acct_type_code,
      acct_vat_code,
      allows_bookout,
      allows_netout,
      asof_trans_id = @asof_trans_id,
      contract_cmnt_num,
      govt_code,
      legal_entity_num,
      man_input_sec_qty_required,
      master_agreement_date,
      resp_trans_id,
      risk_transfer_ind_code,
      trans_id
   from dbo.aud_account
   where acct_num = @acct_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchAccountRevPK] TO [next_usr]
GO
