SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchFormulaConditionRevPK]
(
   @asof_trans_id         bigint,
   @formula_cond_num      smallint,
   @formula_num           int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.formula_condition
where formula_num = @formula_num and
      formula_cond_num = @formula_cond_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      basis_commkt_key,
      basis_price_source_code,
      basis_trading_prd,
      basis_val_type,
      formula_cond_date,
      formula_cond_last_next_ind,
      formula_cond_num,
      formula_cond_quote_range,
      formula_cond_type,
      formula_num,
      resp_trans_id = null,
      src_commkt_key,
      src_price_source_code,
      src_trading_prd,
      src_val_type,
      trans_id
   from dbo.formula_condition
   where formula_num = @formula_num and
         formula_cond_num = @formula_cond_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      basis_commkt_key,
      basis_price_source_code,
      basis_trading_prd,
      basis_val_type,
      formula_cond_date,
      formula_cond_last_next_ind,
      formula_cond_num,
      formula_cond_quote_range,
      formula_cond_type,
      formula_num,
      resp_trans_id,
      src_commkt_key,
      src_price_source_code,
      src_trading_prd,
      src_val_type,
      trans_id
   from dbo.aud_formula_condition
   where formula_num = @formula_num and
         formula_cond_num = @formula_cond_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchFormulaConditionRevPK] TO [next_usr]
GO
