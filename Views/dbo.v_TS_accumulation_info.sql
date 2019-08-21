SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_TS_accumulation_info]                                  
(      
   trade_num,      
   order_num,      
   item_num,      
   accum_start_date,     
   accum_end_date,   
   nominal_start_date,  
   nominal_end_date       
)     
as    
select     
   trade_num,    
   order_num,     
   item_num,     
   MIN(accum_start_date),    
   MAX(accum_end_date),
   MIN(nominal_start_date),
   MAX(nominal_end_date)     
from dbo.accumulation   
where accum_qty > 0    
group by trade_num,    
         order_num,    
         item_num         
GO
GRANT SELECT ON  [dbo].[v_TS_accumulation_info] TO [next_usr]
GO
