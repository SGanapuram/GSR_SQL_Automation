SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_TS_float_price]
(
   formula_num,
   float_price
)
as
select 
   fb.formula_num,
   fb.float_price 
from dbo.v_TS_Q_formula_body fb 
where exists (select 1
              from dbo.formula cf 
                      join dbo.formula f 
                         on cf.parent_formula_num = f.formula_num  
              where cf.formula_num = fb.formula_num)  
GO
GRANT SELECT ON  [dbo].[v_TS_float_price] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_TS_float_price] TO [next_usr]
GO
