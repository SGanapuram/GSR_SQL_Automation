SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchFormulaToFormulaCondition]
(
   @asof_trans_id      bigint,
   @formula_num        int
)
as
set nocount on
 
   select asof_trans_id = @asof_trans_id,
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
          resp_trans_id = NULL,
          src_commkt_key,
          src_price_source_code,
          src_trading_prd,
          src_val_type,
          trans_id
   from dbo.formula_condition
   where formula_num = @formula_num and
         trans_id <= @asof_trans_id
   union
   select asof_trans_id = @asof_trans_id,
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
         (trans_id <= @asof_trans_id and
          resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchFormulaToFormulaCondition] TO [next_usr]
GO
