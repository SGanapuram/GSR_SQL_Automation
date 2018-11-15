SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_update_actual_qty_and_inv_price]
	@iCommodity char(8),
	@iMarket char(8),
	@iLocation char(8),
	@iTradingPrd varchar(40),
	@qty int,
	@uomCode char(8),
	@price float,
	@priceCurrCode char(8),
	@priceUomCode char(8)
as
begin
set nocount on   
declare @transId int,
		@rows_affected1 int,
		@rows_affected2 int,
		@rows_affected3 int

create table #aieTemp
(
	alloc_num int,
	alloc_item_num int,
	ai_est_actual_num int,
	inv_num int
)
insert into #aieTemp
	select aie.alloc_num as alloc_num
		, aie.alloc_item_num as alloc_item_num
		, aie.ai_est_actual_num as ai_est_actual_num
		, i.inv_num as inv_num
	from ai_est_actual aie
	join allocation_item ai
		on ai.alloc_num = aie.alloc_num
			and ai.alloc_item_num = aie.alloc_item_num
	join trade_item ti
		on ti.trade_num = ai.trade_num
			and ti.order_num = ai.order_num
			and ti.item_num = ai.item_num
	join (select ai.alloc_num as alloc_num
		from ai_est_actual aie
		join allocation_item ai
			on ai.alloc_num = aie.alloc_num
				and ai.alloc_item_num = aie.alloc_item_num
		join trade_item ti
			on ti.trade_num = ai.trade_num
				and ti.order_num = ai.order_num
				and ti.item_num = ai.item_num
		where ai_est_actual_ind = 'A'
			and ai.cmdty_code = @iCommodity
			and aie.del_loc_code = @iLocation
			and ti.trading_prd = @iTradingPrd
		group by ai.alloc_num
		having count(ai.alloc_item_num) = 1) as salloc
		on salloc.alloc_num = ai.alloc_num
	join inventory i
		on i.inv_num = ai.inv_num
			and ai.cmdty_code = i.cmdty_code
	where ti.item_type = 'S'
		and ti.p_s_ind = 'S'
		and ai.fully_actualized = 'Y'
		and ai_est_actual_ind = 'A'
		and ai.cmdty_code = @iCommodity
		and aie.del_loc_code = @iLocation
		and ti.risk_mkt_code = @iMarket
		and ti.trading_prd = @iTradingPrd
	
if exists (select 1 from #aieTemp)
begin
	exec gen_new_transaction_NOI 'DB#ADSO-12365'
	select @transId=last_num from icts_trans_sequence where oid=1
	begin tran
		/*Updating ai_est_actual*/
		begin try 
		update aie
		set aie.ai_est_actual_gross_qty = @qty
			, aie.ai_est_actual_net_qty = @qty
			, aie.ai_gross_qty_uom_code = @uomCode
			, aie.ai_net_qty_uom_code = @uomCode
			, aie.secondary_actual_gross_qty = @qty
			, aie.secondary_actual_net_qty = @qty
			, secondary_qty_uom_code = @uomCode
			, aie.trans_id = @transId
		from #aieTemp aiet
		join ai_est_actual aie
			on aiet.alloc_num = aie.alloc_num
				and aiet.alloc_item_num = aie.alloc_item_num
				and aiet.ai_est_actual_num = aie.ai_est_actual_num
		select @rows_affected1 = @@rowcount
		end try
		begin catch
			if @@trancount > 0
			   rollback tran
			print '==> Failed to update the ai_est_actual table ... '
			print '===> ERROR: ' + ERROR_MESSAGE()
			goto endofscript
		end catch
		if @rows_affected1 > 0
		print '==> Updated ai_est_actual table successfuly!'
		/*Updating ai_est_actual*/
		begin try  
		update ai
		set ai.actual_gross_qty = @qty
			, ai.actual_gross_uom_code = @uomCode
			, ai.secondary_actual_qty = @qty
			, ai.sec_actual_uom_code = @uomCode
			, ai.trans_id = @transId
		from #aieTemp aiet
		join allocation_item ai
			on ai.alloc_num = aiet.alloc_num
				and ai.alloc_item_num = aiet.alloc_item_num
		select @rows_affected2 = @@rowcount
		end try
		begin catch
			if @@trancount > 0
			   rollback tran
			print '==> Failed to update the allocation_item table ... '
			print '===> ERROR: ' + ERROR_MESSAGE()
			goto endofscript
		end catch
		if @rows_affected2 > 0
		print '==> Updated allocation_item table successfuly!'
		/*Updating inventory*/
		begin try  	
		update inv
		set inv.inv_avg_cost = @price
			, inv.inv_wacog_cost = @price
			, inv.inv_cost_curr_code = @priceCurrCode
			, inv.inv_cost_uom_code = @priceUomCode
			, inv.r_inv_avg_cost_amt = 0
			, inv.unr_inv_avg_cost_amt = @price * @qty
			, trans_id = @transId
		from #aieTemp t
		join inventory inv
			on t.inv_num = inv.inv_num
		select @rows_affected3 = @@rowcount
		end try
		begin catch
			if @@trancount > 0
			   rollback tran
			print '==> Failed to update the inventory table ... '
			print '===> ERROR: ' + ERROR_MESSAGE()
			goto endofscript
		end catch
		if @rows_affected3 > 0
		print '==> Updated inventory table successfuly!'
		
		/*Updating inventoryBuidDraw*/
		begin try  	
		update invBD
		set 
			invBD.r_inv_b_d_cost = 0,
			invBD.unr_inv_b_d_cost = @price * @qty
			, trans_id = @transId
		from #aieTemp t
		join inventory inv
			on t.inv_num = inv.inv_num
		join inventory_build_draw invBD
			on invBD.inv_num = inv.inv_num
		select @rows_affected3 = @@rowcount
		end try
		begin catch
			if @@trancount > 0
			   rollback tran
			print '==> Failed to update the inventory Build Draw table ... '
			print '===> ERROR: ' + ERROR_MESSAGE()
			goto endofscript
		end catch
		if @rows_affected3 > 0
		print '==> Updated inventory Build Draw table successfuly!'
		
	commit tran
end
else 
	print 'Did not find valid aiEstActals and inventories for commodity, market, location and tradingPeriod ... '
endofscript:
drop table #aieTemp
end
GO
GRANT EXECUTE ON  [dbo].[usp_update_actual_qty_and_inv_price] TO [next_usr]
GO
