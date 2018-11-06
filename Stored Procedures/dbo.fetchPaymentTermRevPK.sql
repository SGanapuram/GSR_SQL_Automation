SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchPaymentTermRevPK]
(
   @asof_trans_id   int,
   @pay_term_code   char(8)
)
as
set nocount on
declare @trans_id   int

   select @trans_id = trans_id
   from dbo.payment_term
   where pay_term_code = @pay_term_code
 
if @trans_id <= @asof_trans_id
begin
   select 
       accounting_pay_term,
       accounting_trans_cat1,
       accounting_trans_cat2,
       asof_trans_id = @asof_trans_id,
       pay_days,
       pay_term_ba_ind1,
       pay_term_ba_ind2,
       pay_term_ba_ind3,
       pay_term_code,
       pay_term_contr_desc,
       pay_term_days1,
       pay_term_days2,
       pay_term_days3,
       pay_term_desc,
       pay_term_event1,
       pay_term_event2,
       pay_term_event3,
       resp_trans_id = null,
       trans_id
   from dbo.payment_term
   where pay_term_code = @pay_term_code
end
else
begin
   set rowcount 1
   select 
       accounting_pay_term,
       accounting_trans_cat1,
       accounting_trans_cat2,
       asof_trans_id = @asof_trans_id,
       pay_days,
       pay_term_ba_ind1,
       pay_term_ba_ind2,
       pay_term_ba_ind3,
       pay_term_code,
       pay_term_contr_desc,
       pay_term_days1,
       pay_term_days2,
       pay_term_days3,
       pay_term_desc,
       pay_term_event1,
       pay_term_event2,
       pay_term_event3,
       resp_trans_id,
       trans_id
   from dbo.aud_payment_term
   where pay_term_code = @pay_term_code and
         trans_id <= @asof_trans_id and
	       resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchPaymentTermRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchPaymentTermRevPK', NULL, NULL
GO
