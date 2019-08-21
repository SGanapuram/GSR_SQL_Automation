SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[actual_detail]
(
   alloc_num,
   alloc_item_num,
   ai_est_actual_num,
   alloc_type_code,	
   mot_code,		
   sch_init, 		
   alloc_status,
   transportation,
   alloc_item_type,
   alloc_item_status,
   sub_alloc_num,
   trade_num,		
   order_num,
   item_num,
   acct_num,  		
   cmdty_code,		
   sch_qty,
   sch_qty_uom_code, 	
   nomin_date_from,
   nomin_date_to,
   nomin_qty_min,
   nomin_qty_min_uom_code, 	
   nomin_qty_max,
   nomin_qty_max_uom_code, 	
   origin_loc_code, 		
   dest_loc_code, 			
   sch_qty_periodicity,
   ai_est_actual_date,
   ai_est_actual_gross_qty,
   ai_gross_qty_uom_code, 		 
   ai_est_actual_net_qty,
   ai_net_qty_uom_code,  		
   ai_est_actual_ind,
   ticket_num,
   transporter_code,
   bol_code,
   trans_id
)
as
select
   alh.alloc_num,
   ali.alloc_item_num,
   alt.ai_est_actual_num,
   alh.alloc_type_code,
   alh.mot_code,
   alh.sch_init,
   alh.alloc_status,
   alh.transportation,
   ali.alloc_item_type	,
   ali.alloc_item_status,
   ali.sub_alloc_num,
   ali.trade_num,
   ali.order_num,
   ali.item_num,
   ali.acct_num,
   ali.cmdty_code,
   ali.sch_qty,
   ali.sch_qty_uom_code,
   ali.nomin_date_from,
   ali.nomin_date_to,
   ali.nomin_qty_min,
   ali.nomin_qty_min_uom_code,
   ali.nomin_qty_max,
   ali.nomin_qty_max_uom_code,
   ali.origin_loc_code,
   ali.dest_loc_code,
   ali.sch_qty_periodicity,
   alt.ai_est_actual_date,
   alt.ai_est_actual_gross_qty,
   alt.ai_gross_qty_uom_code,
   alt.ai_est_actual_net_qty,
   alt.ai_net_qty_uom_code,
   alt.ai_est_actual_ind,
   alt.ticket_num,
   alt.transporter_code,
   alt.bol_code,
   alh.trans_id
from dbo.allocation alh,
     dbo.allocation_item ali,
     dbo.ai_est_actual alt
where	alh.alloc_num = ali.alloc_num and
		  ali.alloc_num = alt.alloc_num and
		  ali.alloc_item_num = alt.alloc_item_num
GO
GRANT SELECT ON  [dbo].[actual_detail] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[actual_detail] TO [next_usr]
GO
