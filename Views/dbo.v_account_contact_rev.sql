SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_account_contact_rev]
(
   acct_num,
   acct_cont_num,
   acct_cont_last_name,
   acct_cont_first_name,
   acct_cont_nick_name,
   acct_cont_title,
   acct_cont_addr_line_1,
   acct_cont_addr_line_2,
   acct_cont_addr_line_3,
   acct_cont_addr_line_4,
   acct_cont_addr_city,
   state_code,
   country_code,
   acct_cont_addr_zip_code,
   acct_cont_home_ph_num,
   acct_cont_off_ph_num,
   acct_cont_oth_ph_num,
   acct_cont_telex_num,
   acct_cont_fax_num,
   acct_cont_email,
   acct_cont_function,
   acct_addr_num,
   acct_cont_status,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   acct_num,
   acct_cont_num,
   acct_cont_last_name,
   acct_cont_first_name,
   acct_cont_nick_name,
   acct_cont_title,
   acct_cont_addr_line_1,
   acct_cont_addr_line_2,
   acct_cont_addr_line_3,
   acct_cont_addr_line_4,
   acct_cont_addr_city,
   state_code,
   country_code,
   acct_cont_addr_zip_code,
   acct_cont_home_ph_num,
   acct_cont_off_ph_num,
   acct_cont_oth_ph_num,
   acct_cont_telex_num,
   acct_cont_fax_num,
   acct_cont_email,
   acct_cont_function,
   acct_addr_num,
   acct_cont_status,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_account_contact
GO
GRANT SELECT ON  [dbo].[v_account_contact_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_account_contact_rev] TO [next_usr]
GO
