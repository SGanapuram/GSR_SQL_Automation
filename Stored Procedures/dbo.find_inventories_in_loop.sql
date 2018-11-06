SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE proc [dbo].[find_inventories_in_loop]  
   @inv_loop_num  int, 
   @asof_trans_id    int 
    
as  
select
   inv_num  
from 
(select  
   inv_num,  
   inv_loop_num  
from dbo.inventory  
where trans_id <= @asof_trans_id  
union  
select  
   inv_num,  
   inv_loop_num  
from dbo.aud_inventory  
where (trans_id <= @asof_trans_id and   
       resp_trans_id > @asof_trans_id)  
) as temp
where temp.inv_loop_num = @inv_loop_num

return
GO
GRANT EXECUTE ON  [dbo].[find_inventories_in_loop] TO [next_usr]
GO
