SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchCostEqualizationRateRevPK]
(
   @asof_trans_id       int,
   @cost_num            int,
   @effective_date      datetime,
   @spec_code           char(8)
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.cost_equalization_rate
where cost_num = @cost_num and
      spec_code = @spec_code and
      effective_date = @effective_date
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      calc_factor,
      calc_factor_oper,
      cost_num,
      cost_rate_curr_code,
      cost_rate_uom_code,
      effective_date,
      max_spec_value,
      min_spec_value,
      rate_for_high_end,
      rate_for_low_end,
      resp_trans_id = null,
      spec_code,
      trans_id
   from dbo.cost_equalization_rate
   where cost_num = @cost_num and
         spec_code = @spec_code and
         effective_date = @effective_date
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      calc_factor,
      calc_factor_oper,
      cost_num,
      cost_rate_curr_code,
      cost_rate_uom_code,
      effective_date,
      max_spec_value,
      min_spec_value,
      rate_for_high_end,
      rate_for_low_end,
      resp_trans_id,
      spec_code,
      trans_id
   from dbo.aud_cost_equalization_rate
   where cost_num = @cost_num and
         spec_code = @spec_code and
         effective_date = @effective_date and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchCostEqualizationRateRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchCostEqualizationRateRevPK', NULL, NULL
GO
