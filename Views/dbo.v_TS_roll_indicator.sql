SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_TS_roll_indicator] 
( 
   trade_num, 
   order_num, 
   item_num 
)
as
select distinct 
   tf.trade_num,
   tf.order_num,
   tf.item_num
from (select
         tf.trade_num,
         tf.order_num,
         tf.item_num
      from dbo.v_TS_swap_trade_formulas tf
      where exists (select 1
                    from dbo.formula_comp_price_term fcpt
                    where tf.formula_num = fcpt.formula_num and
                          fcpt.fcpt_start_end_ind = 'R')
      union all
      select 
         tf.trade_num,
         tf.order_num,
         tf.item_num
      from dbo.v_TS_swapflt_trade_formulas tf
      where exists (select 1
                    from dbo.formula f
                    where f.parent_formula_num = tf.formula_num and
                          exists (select 1
                                  from dbo.formula_comp_price_term fcpt
                                  where f.formula_num = fcpt.formula_num and
                                        fcpt.fcpt_start_end_ind = 'R'))
     ) tf
GO
GRANT SELECT ON  [dbo].[v_TS_roll_indicator] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_TS_roll_indicator] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_TS_roll_indicator', NULL, NULL
GO
