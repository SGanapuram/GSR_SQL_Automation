SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[debug_pl_history]
(
	 @pl_asof_date datetime,
	 @port_num     int
)
as
begin
set nocount on
declare @history_pl float
declare @pl_pl      float
declare @diff       float

   ---see if any costs are missing...
	 select '------------------Missing Costs----------------'
	 select 
		  cost_num,
		  cost_amt,
		  cost_pl_code,
		  trade=cost_owner_key6,
		  tor=cost_owner_key7,
		  item=cost_owner_key8,
		  cost_type_code,
		  creation_date 
	 from dbo.cost 
	 where port_num = @port_num and
		     cost_status != 'CLOSED' and 
		     (cost_pl_code = 'C' or cost_type_code not in ('WPP','RPP','OPP','OTC','PDO','POC','SWAP','SWPR','BO')) and
		     cost_num not in (select pl_record_key 
                          from dbo.pl_history 
                          where pl_owner_code = 'C' and 
				                        pl_asof_date = pl_asof_date) 

   ---see if any inventoryBuildDraws are missing...
	 select '------------------Missing Builds/Draws----------------'
	 select 
		  inv.inv_num,
      inv_b_d_type,
      inv_b_d_cost,
      alloc_num,
      alloc_item_num
	 from dbo.inventory_build_draw ibd, 
	      dbo.inventory inv 
	 where inv.port_num = @port_num and
		     inv.inv_num = ibd.inv_num and
		     inv_b_d_status = 'C' and 
		     inv_b_d_num not in (select pl_record_key 
			                       from dbo.pl_history 
                             where pl_owner_code = 'I' and 
                                   pl_asof_date = pl_asof_date) 

   ---see if any positions are missing...
	 select '------------------Missing Positions----------------'
	 select 
		  pos_num,
		  cmdty_code,
		  mkt_code,
		  trading_prd
	 from dbo.position 
	 where real_port_num = @port_num and
		     pos_type = 'I' and 
         pos_num not in (select pl_record_key 
			                   from dbo.pl_history 
			                   where pl_owner_code = 'P' and 
				                       pl_asof_date = pl_asof_date) 

	 return 0
end
GO
GRANT EXECUTE ON  [dbo].[debug_pl_history] TO [next_usr]
GO
