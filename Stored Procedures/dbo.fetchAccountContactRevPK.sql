SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchAccountContactRevPK]
(
   @acct_cont_num      int,
   @acct_num           int,
   @asof_trans_id      int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.account_contact
where acct_num = @acct_num and
      acct_cont_num = @acct_cont_num
 
if @trans_id <= @asof_trans_id
begin
   select
      acct_addr_num,
      acct_cont_addr_city,
      acct_cont_addr_line_1,
      acct_cont_addr_line_2,
      acct_cont_addr_line_3,
      acct_cont_addr_line_4,
      acct_cont_addr_zip_code,
      acct_cont_email,
      acct_cont_fax_num,
      acct_cont_first_name,
      acct_cont_function,
      acct_cont_home_ph_num,
      acct_cont_last_name,
      acct_cont_nick_name,
      acct_cont_num,
      acct_cont_off_ph_num,
      acct_cont_oth_ph_num,
      acct_cont_status,
      acct_cont_telex_num,
      acct_cont_title,
      acct_num,
      asof_trans_id = @asof_trans_id,
      country_code,
      resp_trans_id = null,
      state_code,
      trans_id
   from dbo.account_contact
   where acct_num = @acct_num and
         acct_cont_num = @acct_cont_num
end
else
begin
   select top 1
      acct_addr_num,
      acct_cont_addr_city,
      acct_cont_addr_line_1,
      acct_cont_addr_line_2,
      acct_cont_addr_line_3,
      acct_cont_addr_line_4,
      acct_cont_addr_zip_code,
      acct_cont_email,
      acct_cont_fax_num,
      acct_cont_first_name,
      acct_cont_function,
      acct_cont_home_ph_num,
      acct_cont_last_name,
      acct_cont_nick_name,
      acct_cont_num,
      acct_cont_off_ph_num,
      acct_cont_oth_ph_num,
      acct_cont_status,
      acct_cont_telex_num,
      acct_cont_title,
      acct_num,
      asof_trans_id = @asof_trans_id,
      country_code,
      resp_trans_id,
      state_code,
      trans_id
   from dbo.aud_account_contact
   where acct_num = @acct_num and
         acct_cont_num = @acct_cont_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchAccountContactRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchAccountContactRevPK', NULL, NULL
GO
