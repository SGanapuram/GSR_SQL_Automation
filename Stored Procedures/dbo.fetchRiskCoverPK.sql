SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchRiskCoverPK]
(
   @asof_trans_id   int,
   @risk_cover_num  int
)
as
set nocount on
declare @trans_id   int
   
select @trans_id = trans_id
from dbo.risk_cover
where risk_cover_num = @risk_cover_num
 
if @trans_id <= @asof_trans_id
begin
   select 
       analyst_init,
       asof_trans_id = @asof_trans_id,
       cmnt_num,
       covered_percent,       
       disc_date,
       disc_rec_amt,
       disc_rec_curr_code,
       guarantee_acct_num,
       guarantee_end_date,
       guarantee_ref_num,
       guarantee_start_date,
       instr_type_code,
       max_covered_amt,
       min_num_of_days,
       office_loc_code,
       rc_status_code,
       risk_cover_num,  
       resp_trans_id = null, 
       trans_id
   from dbo.risk_cover
   where risk_cover_num = @risk_cover_num
end
else
begin     
   set rowcount 1
   select 
       analyst_init,
       asof_trans_id = @asof_trans_id,
       cmnt_num,
       covered_percent,       
       disc_date,
       disc_rec_amt,
       disc_rec_curr_code,
       guarantee_acct_num,
       guarantee_end_date,
       guarantee_ref_num,
       guarantee_start_date,
       instr_type_code,
       max_covered_amt,
       min_num_of_days,
       office_loc_code,
       rc_status_code,
       risk_cover_num, 
       resp_trans_id,
       trans_id
   from dbo.aud_risk_cover
   where risk_cover_num = @risk_cover_num and
         trans_id <= @asof_trans_id and
	 resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchRiskCoverPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchRiskCoverPK', NULL, NULL
GO
