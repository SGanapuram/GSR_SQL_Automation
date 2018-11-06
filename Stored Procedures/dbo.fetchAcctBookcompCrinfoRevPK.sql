SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchAcctBookcompCrinfoRevPK]
(
   @acct_bookcomp_key      int,
   @asof_trans_id          int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.acct_bookcomp_crinfo
where acct_bookcomp_key = @acct_bookcomp_key
 
if @trans_id <= @asof_trans_id
begin
   select
      acct_bookcomp_key,
      asof_trans_id = @asof_trans_id,
      dflt_cr_term_code,
      resp_trans_id = null,
      trans_id
   from dbo.acct_bookcomp_crinfo
   where acct_bookcomp_key = @acct_bookcomp_key
end
else
begin
   select top 1
      acct_bookcomp_key,
      asof_trans_id = @asof_trans_id,
      dflt_cr_term_code,
      resp_trans_id,
      trans_id
   from dbo.aud_acct_bookcomp_crinfo
   where acct_bookcomp_key = @acct_bookcomp_key and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchAcctBookcompCrinfoRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchAcctBookcompCrinfoRevPK', NULL, NULL
GO
