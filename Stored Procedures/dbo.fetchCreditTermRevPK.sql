SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchCreditTermRevPK]
(
   @asof_trans_id         int,
   @credit_term_code      char(8)
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.credit_term
where credit_term_code = @credit_term_code
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      credit_secure_ind,
      credit_term_code,
      credit_term_contr_desc,
      credit_term_desc,
      doc_type_code,
      resp_trans_id = null,
      trans_id
   from dbo.credit_term
   where credit_term_code = @credit_term_code
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      credit_secure_ind,
      credit_term_code,
      credit_term_contr_desc,
      credit_term_desc,
      doc_type_code,
      resp_trans_id,
      trans_id
   from dbo.aud_credit_term
   where credit_term_code = @credit_term_code and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchCreditTermRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchCreditTermRevPK', NULL, NULL
GO
