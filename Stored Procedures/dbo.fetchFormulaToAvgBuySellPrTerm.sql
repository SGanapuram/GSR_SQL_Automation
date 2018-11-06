SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchFormulaToAvgBuySellPrTerm]
(
   @asof_trans_id      int,
   @formula_num        int
)
as
set nocount on
 
   select all_quotes_reqd_ind,
          asof_trans_id = @asof_trans_id,
          buyer_seller_opt,
          determination_mths_num,
          determination_opt,
          exclusion_days,
          formula_num,
          price_term_end_date,
          price_term_start_date,
          quote_type,
          resp_trans_id = NULL,
          roll_days,
          trans_id
   from dbo.avg_buy_sell_price_term
   where formula_num = @formula_num and
         trans_id <= @asof_trans_id
   union
   select all_quotes_reqd_ind,
          asof_trans_id = @asof_trans_id,
          buyer_seller_opt,
          determination_mths_num,
          determination_opt,
          exclusion_days,
          formula_num,
          price_term_end_date,
          price_term_start_date,
          quote_type,
          resp_trans_id,
          roll_days,
          trans_id
   from dbo.aud_avg_buy_sell_price_term
   where formula_num = @formula_num and
         (trans_id <= @asof_trans_id and
          resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchFormulaToAvgBuySellPrTerm] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchFormulaToAvgBuySellPrTerm', NULL, NULL
GO
