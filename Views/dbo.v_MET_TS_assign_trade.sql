SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_MET_TS_assign_trade] 
( 
   trade_num, 
   order_num, 
   item_num, 
   ct_doc_num 
)
as
select 
   trade_num,
   order_num,
   item_num,
   ct_doc_num
from dbo.assign_trade WITH (nolock)
where ct_doc_type = 'LC' and
      alloc_num IS NULL  
GO
GRANT SELECT ON  [dbo].[v_MET_TS_assign_trade] TO [next_usr]
GO
