SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_TS_Q_formula_body]
(
   formula_num,
   formula_body_num,
   float_price
)
as
select 
   formula_num, 
   formula_body_num,   
   case when (charindex('+', formula_body_string) > 0) 
           then substring(formula_body_string, charindex('+', formula_body_string), len(formula_body_string))  
        when (charindex('-', formula_body_string) > 0) 
           then substring(formula_body_string, charindex('-', formula_body_string), len(formula_body_string))  
        else '0' 
   end  
from dbo.formula_body
where formula_body_type = 'Q' and 
      isnumeric(case when (charindex('+', formula_body_string) > 0) 
                        then substring(formula_body_string, charindex('+', formula_body_string), len(formula_body_string))  
                     when (charindex('-', formula_body_string) > 0) 
                        then substring(formula_body_string,charindex('-', formula_body_string), len(formula_body_string))  
                     else '0' 
                end) = 1 and 
      convert(float, isnull(case when (charindex('+', formula_body_string) > 0) 
                                    then substring(formula_body_string, charindex('+', formula_body_string), len(formula_body_string))  
                                 when (charindex('-', formula_body_string) > 0) 
                                    then substring(formula_body_string, charindex('-', formula_body_string), len(formula_body_string))  
                                 else '0' 
                            end, 0)) <> 0
GO
GRANT SELECT ON  [dbo].[v_TS_Q_formula_body] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_TS_Q_formula_body] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_TS_Q_formula_body', NULL, NULL
GO
