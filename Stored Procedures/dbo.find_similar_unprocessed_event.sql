SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
create proc [dbo].[find_similar_unprocessed_event]  
   @edpl_event_id  int 
as  
set nocount on  
declare @event_type varchar(30),  
        @event_id int
select @event_type = event_type from dbo.edpl_event where oid = @edpl_event_id

if(@event_type = 'TI_Inserted' or @event_type = 'TI_Updated' or @event_type = 'TI_Deleted')
begin
	select e.oid from edpl_event e join (select oid, trade_num,order_num,item_num from edpl_event where oid = @edpl_event_id) t 
		on e.trade_num=t.trade_num and e.order_num=t.order_num and e.item_num=t.item_num and e.oid <> t.oid
		where e.status = 0 and e.event_type in ('TI_Inserted','TI_Updated','TI_Deleted','Cost_Inserted','Cost_Updated','Cost_Deleted')

end
else if (@event_type = 'Cost_Inserted' or @event_type = 'Cost_Updated' or @event_type = 'Cost_Deleted')
begin
	select e.oid from edpl_event e join (select oid, cost_num from edpl_event where oid = @edpl_event_id) t 
		on e.cost_num=t.cost_num and e.oid <> t.oid
		where e.status = 0 and e.event_type in ('Cost_Inserted','Cost_Updated','Cost_Deleted')
	union
	select e.oid from edpl_event e join (select oid, trade_num,order_num,item_num from edpl_event where oid = @edpl_event_id) t 
		on e.trade_num=t.trade_num and e.order_num=t.order_num and e.item_num=t.item_num and e.oid <> t.oid
		where e.status = 0 and e.event_type in ('TI_Inserted','TI_Updated','TI_Deleted')

end
else if (@event_type = 'InvAlloc_Inserted' or @event_type = 'InvAlloc_Updated' or @event_type = 'InvAlloc_Deleted' or @event_type = 'Inv_Updated')
begin
	select e.oid from edpl_event e join (select oid, alloc_num from edpl_event where oid = @edpl_event_id) t 
		on e.alloc_num=t.alloc_num and e.oid <> t.oid
		where e.status = 0 and e.event_type in ('InvAlloc_Inserted','InvAlloc_Updated','InvAlloc_Deleted')
	union
	select e.oid from edpl_event e join (select oid, inv_num from edpl_event where oid = @edpl_event_id) t 
		on e.inv_num=t.inv_num and e.oid <> t.oid
		where e.status = 0 and e.event_type in ('InvAlloc_Inserted','InvAlloc_Updated','InvAlloc_Deleted')
	union
	select e.oid from edpl_event e join inventory i on i.inv_num = e.inv_num join 
		(select ee.oid, ii.inv_loop_num from edpl_event ee join inventory ii on ii.inv_num = ee.inv_num where oid = @edpl_event_id) t 
		on i.inv_loop_num=t.inv_loop_num and e.oid <> t.oid
		where e.status = 0 and e.event_type in ('InvAlloc_Inserted','InvAlloc_Updated','InvAlloc_Deleted')
	union
	select e.oid from edpl_event e join (select oid, inv_num from edpl_event where oid = @edpl_event_id) t 
		on e.inv_num=t.inv_num and e.oid <> t.oid
		where e.status = 0 and e.event_type = 'Inv_Updated'
	union
	select e.oid from edpl_event e join inventory i on i.inv_num = e.inv_num join 
		(select ee.oid, ii.inv_loop_num from edpl_event ee join inventory ii on ii.inv_num = ee.inv_num where oid = @edpl_event_id) t 
		on i.inv_loop_num=t.inv_loop_num and e.oid <> t.oid
		where e.status = 0 and e.event_type = 'Inv_Updated'

end
else if (@event_type = 'Trade_Deleted')
begin
	select e.oid from edpl_event e join (select oid, trade_num from edpl_event where oid = @edpl_event_id) t 
		on e.trade_num=t.trade_num and e.oid <> t.oid
		where e.status = 0 and e.event_type in ('Trade_Deleted', 'TI_Inserted','TI_Updated','TI_Deleted','Cost_Inserted','Cost_Updated','Cost_Deleted')

end
return
GO
GRANT EXECUTE ON  [dbo].[find_similar_unprocessed_event] TO [next_usr]
GO
