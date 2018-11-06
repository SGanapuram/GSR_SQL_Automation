SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_MET_TS_Q_formula_body]   
(   
   formula_num,   
   formula_body_num,   
   float_price  
)  
as  
select   
   formula_num,  
   formula_body_num,  
   case when (Charindex('+', formula_body_string) > 0)   
           then Substring(formula_body_string, Charindex('+', formula_body_string), Len(formula_body_string))  
        when (Charindex('-', formula_body_string) > 0)   
           then Substring(formula_body_string, Charindex('-', formula_body_string), Len(formula_body_string))  
        else '0'  
   end  
from dbo.formula_body  
where formula_body_type = 'Q' and 
      isnull(ltrim(case when (Charindex('+', formula_body_string) > 0)  
                                    then Substring(formula_body_string, Charindex('+', formula_body_string)+1, Len(formula_body_string))   
                                 when (Charindex('-', formula_body_string) > 0)  
                                    then Substring(formula_body_string, Charindex('-', formula_body_string)+1, Len(formula_body_string))   
                                 else '0'   
                            end),'0') <> '0'    
GO
GRANT SELECT ON  [dbo].[v_MET_TS_Q_formula_body] TO [next_usr]
GO
