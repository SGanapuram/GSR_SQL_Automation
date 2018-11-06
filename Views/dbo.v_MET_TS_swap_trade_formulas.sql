SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_MET_TS_swap_trade_formulas] 
( 
   trade_num, 
   order_num, 
   item_num,
   formula_num
)
as
select 
   trade_num,
   order_num,
   item_num,
   formula_num
from dbo.trade_formula tf
where exists (select 1
              from dbo.trade_order trdord
              where trdord.trade_num = tf.trade_num and
                    trdord.order_num = tf.order_num and
                    trdord.order_type_code = 'SWAP')
GO
GRANT SELECT ON  [dbo].[v_MET_TS_swap_trade_formulas] TO [next_usr]
GO
