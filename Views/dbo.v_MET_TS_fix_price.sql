SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_MET_TS_fix_price]     
(     
   formula_num,     
   formula_precision,    
   formula_rounding_level,     
   roll_days,     
   exclusion_days,     
   all_quotes_reqd_ind,    
   price_term_start_date,     
   price_term_end_date,     
   formula_body_num,     
   fix_price   
)    
as    
select     
   f.formula_num,    
   f.formula_precision,    
   f.formula_rounding_level,    
   absp.roll_days,    
   absp.exclusion_days,    
   absp.all_quotes_reqd_ind,    
   absp.price_term_start_date,    
   absp.price_term_end_date,    
   fb.formula_body_num,    
   fb.formula_body_string  
from (select formula_num,    
             formula_body_num,    
             formula_body_string    
      from dbo.formula_body    
      where formula_body_type = 'M' and    
            Isnumeric(formula_body_string) = 1) fb    
         INNER JOIN dbo.avg_buy_sell_price_term absp    
            ON absp.formula_num = fb.formula_num    
         INNER JOIN dbo.formula f    
            ON fb.formula_num = f.formula_num 
GO
GRANT SELECT ON  [dbo].[v_MET_TS_fix_price] TO [next_usr]
GO
