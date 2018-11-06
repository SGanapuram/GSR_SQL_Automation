SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchCustomVoucherRangeRevPK]
(
   @asof_trans_id      int,
   @oid                int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.custom_voucher_range
where oid = @oid
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      booking_comp_num,
      initial_pay_receive_ind,
      invoice_type,
      last_num,
      max_num,
      oid,
      prefix_string,
      ps_group_code,
      reset_date,
      reset_to_num,
      reset_to_year,
      resp_trans_id = null,
      trans_id,
      vat_country_code,
      year
   from dbo.custom_voucher_range
   where oid = @oid
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      booking_comp_num,
      initial_pay_receive_ind,
      invoice_type,
      last_num,
      max_num,
      oid,
      prefix_string,
      ps_group_code,
      reset_date,
      reset_to_num,
      reset_to_year,
      resp_trans_id,
      trans_id,
      vat_country_code,
      year
   from dbo.aud_custom_voucher_range
   where oid = @oid and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchCustomVoucherRangeRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchCustomVoucherRangeRevPK', NULL, NULL
GO
