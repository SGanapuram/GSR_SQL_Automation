SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchAccountGroupRevPK]
(
   @acct_group_type_code      char(8),
   @acct_num                  int,
   @asof_trans_id             bigint,
   @related_acct_num          int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.account_group
where related_acct_num = @related_acct_num and
      acct_num = @acct_num and
      acct_group_type_code = @acct_group_type_code
 
if @trans_id <= @asof_trans_id
begin
   select
      acct_group_relation,
      acct_group_type_code,
      acct_num,
      asof_trans_id = @asof_trans_id,
      parent_acct_own_pcnt,
      related_acct_num,
      resp_trans_id = null,
      trans_id
   from dbo.account_group
   where related_acct_num = @related_acct_num and
         acct_num = @acct_num and
         acct_group_type_code = @acct_group_type_code
end
else
begin
   select top 1
      acct_group_relation,
      acct_group_type_code,
      acct_num,
      asof_trans_id = @asof_trans_id,
      parent_acct_own_pcnt,
      related_acct_num,
      resp_trans_id,
      trans_id
   from dbo.aud_account_group
   where related_acct_num = @related_acct_num and
         acct_num = @acct_num and
         acct_group_type_code = @acct_group_type_code and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchAccountGroupRevPK] TO [next_usr]
GO
