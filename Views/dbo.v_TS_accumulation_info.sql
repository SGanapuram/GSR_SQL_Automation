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
   accum_end_date  
)
as
select 
   trade_num,
   order_num,
   item_num,
   MIN(accum_start_date),
   MAX(accum_end_date) 
from dbo.accumulation
group by trade_num,
         order_num,
         item_num
GO
GRANT SELECT ON  [dbo].[v_TS_accumulation_info] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_TS_accumulation_info] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_TS_accumulation_info', NULL, NULL
GO
