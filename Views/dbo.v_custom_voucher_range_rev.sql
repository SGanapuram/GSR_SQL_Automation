SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_custom_voucher_range_rev]
(
   oid,
   booking_comp_num,
   initial_pay_receive_ind,
   year,
   ps_group_code,
   prefix_string,
   last_num,
   max_num,
   vat_country_code,
   invoice_type,
   reset_date,
   reset_to_year,
   reset_to_num,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   oid,
   booking_comp_num,
   initial_pay_receive_ind,
   year,
   ps_group_code,
   prefix_string,
   last_num,
   max_num,
   vat_country_code,
   invoice_type,
   reset_date,
   reset_to_year,
   reset_to_num,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_custom_voucher_range
GO
GRANT SELECT ON  [dbo].[v_custom_voucher_range_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_custom_voucher_range_rev] TO [next_usr]
GO
