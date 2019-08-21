SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_invruns] (@invnum int = null)
as
begin
	set nocount on

	create table #invrun (
		id 				int IDENTITY(1, 1) primary key,
		bdDate 			datetime,
		bdQty 			float,
		bdAllocNum 		int,
		bdAllocItemNum 	int,
		invNum 			int,
		invBDNum 		int,
		bdType 			varchar(8),
		bdUom 			varchar(4),
		invUom 			varchar(4),
		needConv 		bit default 0 null,
		associatedTrade varchar(40),
		invBDCost 		float,
		associatedCpty 	varchar(30),
		actFactor 		float,
		errorMessage 	varchar(50)
		)

	create table #invrunoutput (
		id 				int,
		bdDate 			datetime,
		bdQty 			float,
		bdUom 			varchar(4),
		bdAllocNum 		int,
		bdAllocItemNum 	int,
		invNum 			int,
		invBDNum 		int,
		bdType 			varchar(8),
		runningBal 		float,
		eodBal 			float,
		associatedTrade varchar(40),
		invBDCost 		float,
		associatedCpty 	varchar(30),
		errorMessage 	varchar(50)
		)

	-- @invnum is really mandatory but just return an empty result if it is not present            
	if @invnum is null
	begin
		select i.id,
			i.bdDate,
			i.bdQty,
			i.bdUom,
			i.bdAllocNum,
			i.bdAllocItemNum,
			i.invNum,
			i.invBDNum,
			i.bdType,
			null as pTradeNum,
			null as counterpartyName,
			i.runningBal as 'Running Balance',
			i.eodBal as 'End of Day Balance',
			i.associatedTrade,
			i.invBDCost,
			i.associatedCpty,
			i.errorMessage
		from #invrunoutput i

		return
	end

	-- opening balance is projected plus actual (actually, I don't think there's such thing as an opening projected quantity)            
	insert #invrun (
		bdDate,
		bdQty,
		bdAllocNum,
		bdAllocItemNum,
		invNum,
		invBDNum,
		bdType,
		bdUom,
		invUom,
		needConv,
		associatedTrade,
		invBDCost,
		associatedCpty,
		actFactor,
		errorMessage
		)
	select i.inv_bal_from_date,
		--i.inv_open_prd_proj_qty + i.inv_open_prd_actual_qty,            
		case 
			when exists (select 1 from inventory
							where inv_num = i.prev_inv_num
								and open_close_ind in ('R','C')	)
				then i.inv_open_prd_proj_qty + i.inv_open_prd_actual_qty
			else 0
			end,
		null,
		null,
		i.inv_num,
		null,
		'Open',
		i.inv_qty_uom_code,
		i.inv_qty_uom_code,
		0,
		null,
		null,
		null,
		1,
		''
	from dbo.inventory i
	where i.inv_num = @invnum

	-- actual builds and draws            
	insert #invrun (
		bdDate,
		bdQty,
		bdAllocNum,
		bdAllocItemNum,
		invNum,
		invBDNum,
		bdType,
		bdUom,
		invUom,
		needConv,
		associatedTrade,
		invBDCost,
		associatedCpty,
		actFactor,
		errorMessage
		)
	select aea.ai_est_actual_date,
		(
			case 
				when ti.billing_type = 'G'
					then aea.ai_est_actual_gross_qty
				else aea.ai_est_actual_net_qty
				end
			),
		ibd.alloc_num,
		ibd.alloc_item_num,
		ibd.inv_num as invNum,
		ibd.inv_b_d_num as invBDNum,
		(
			case 
				when ibd.inv_b_d_type = 'D'
					then 'Draw'
				else 'Build'
				end
			),
		--aea.ai_net_qty_uom_code, -- assumption: net and gross quantity will have same uom            
		(
			case 
				when ti.billing_type = 'G'
					then aea.ai_gross_qty_uom_code
				else aea.ai_net_qty_uom_code
				end
			),
		ti.contr_qty_uom_code,
		(
			case 
				when aea.ai_net_qty_uom_code <> ti.contr_qty_uom_code
					then 1
				when manual_input_sec_ind = 'Y'
					then 1
				else 0
				end
			),
		ibd.associated_trade,
		ibd.inv_b_d_cost,
		ibd.associated_cpty,
		(
			case 
				when ti.billing_type = 'G'
					then case 
							when aea.secondary_actual_gross_qty > 0
								and aea.ai_est_actual_gross_qty > 0
								then aea.secondary_actual_gross_qty / aea.ai_est_actual_gross_qty
							when aea.secondary_actual_gross_qty = 0
								and aea.ai_est_actual_gross_qty = 0
								then 0
							end
				else case 
						when aea.secondary_actual_net_qty > 0
							and aea.ai_est_actual_net_qty > 0
							then aea.secondary_actual_net_qty / aea.ai_est_actual_net_qty
						when aea.secondary_actual_net_qty = 0
							and aea.ai_est_actual_net_qty = 0
							then 0
						end
				end
			),
		(
			case 
				when ti.billing_type = 'G'
					and aea.secondary_actual_gross_qty = 0
					and aea.ai_est_actual_gross_qty > 0
					then 'Only one of the prim or sec qty is zero.'
				when ti.billing_type = 'G'
					and aea.secondary_actual_gross_qty > 0
					and aea.ai_est_actual_gross_qty = 0
					then 'Only one of the prim or sec qty is zero.'
				when ti.billing_type = 'N'
					and aea.secondary_actual_net_qty = 0
					and aea.ai_est_actual_net_qty > 0
					then 'Only one of the prim or sec qty is zero.'
				when ti.billing_type = 'N'
					and aea.secondary_actual_net_qty > 0
					and aea.ai_est_actual_net_qty = 0
					then 'Only one of the prim or sec qty is zero.'
				else ''
				end
			)
	from dbo.inventory_build_draw ibd
	join dbo.ai_est_actual aea on aea.alloc_num = ibd.alloc_num
		and aea.alloc_item_num = ibd.alloc_item_num
	join dbo.allocation_item ai on ai.alloc_num = ibd.alloc_num
		and ai.alloc_item_num = ibd.alloc_item_num
	join dbo.trade_item ti on ti.trade_num = ai.trade_num
		and ti.order_num = ai.order_num
		and ti.item_num = ai.item_num
	join dbo.allocation a on a.alloc_num = ibd.alloc_num
	where a.alloc_type_code <> 'J'
		and aea.ai_est_actual_ind = 'A'
		and ibd.inv_num = @invnum

	-- adjustments            
	insert #invrun (
		bdDate,
		bdQty,
		bdAllocNum,
		bdAllocItemNum,
		invNum,
		invBDNum,
		bdType,
		bdUom,
		invUom,
		needConv,
		associatedTrade,
		invBDCost,
		associatedCpty,
		actFactor,
		errorMessage
		)
	select ibd.inv_b_d_date,
		ibd.adj_qty,
		ibd.alloc_num,
		ibd.alloc_item_num,
		ibd.inv_num,
		ibd.inv_b_d_num as invBDNum,
		'Adj',
		ibd.adj_qty_uom_code,
		i.inv_qty_uom_code,
		(
			case 
				when ibd.adj_qty_uom_code <> i.inv_qty_uom_code
					then 1
				else 0
				end
			),
		ibd.associated_trade,
		ibd.inv_b_d_cost,
		ibd.associated_cpty,
		1,
		''
	from dbo.inventory_build_draw ibd
	join dbo.allocation a on a.alloc_num = ibd.alloc_num
	join dbo.inventory i on i.inv_num = ibd.inv_num
	where a.alloc_type_code = 'J'
		and ibd.adj_type_ind = 'P'
		and ibd.inv_num = @invnum

	-- do simple one-step uom conversion between bdUom and invUom to convert the bdQty if needed and if possible.            
	-- these SHOULD be same uom type so commodity is not important, well..., hopefully.            
	update #invrun
	set bdQty = (
			case 
				when bdUom != invUom
					then case 
							when actFactor is not null
								and actFactor > 0
								then bdQty * actFactor
							else 0
							end
				else case 
						when actFactor is not null
							and actFactor > 0
							then bdQty / actFactor
						else 0
						end
				end
			),
		needConv = 0
	from dbo.uom_conversion uc
	where uc.uom_code_conv_from = bdUom
		and uc.uom_code_conv_to = invUom
		and uc.cmdty_code is null
		and needConv = 1

	update #invrun
	set bdQty = (
			case 
				when bdUom != invUom
					then case 
							when actFactor is not null
								and actFactor > 0
								then bdQty * actFactor
							else 0
							end
				else case 
						when actFactor is not null
							and actFactor > 0
							then bdQty / actFactor
						else 0
						end
				end
			),
		needConv = 0
	from dbo.uom_conversion uc
	where uc.uom_code_conv_to = bdUom
		and uc.uom_code_conv_from = invUom
		and uc.cmdty_code is null
		and needConv = 1

	-- total up for the output table            
	insert #invrunoutput (
		id,
		bdDate,
		bdQty,
		bdUom,
		bdAllocNum,
		bdAllocItemNum,
		invNum,
		invBDNum,
		bdType,
		runningBal,
		eodBal,
		associatedTrade,
		invBDCost,
		associatedCpty,
		errorMessage
		)
	select i.id,
		i.bdDate,
		i.bdQty,
		(
			case 
				when needConv = 1
					then i.bdUom
				else i.invUom
				end
			),
		i.bdAllocNum,
		i.bdAllocItemNum,
		i.invNum,
		i.invBDNum,
		i.bdType,
		(
			select isnull(sum(case 
							when bdType = 'Draw'
								then bdQty * - 1
							else bdQty
							end), 0)
			from #invrun i2
			where datediff(dd, i2.bdDate, i.bdDate) = 0
				and id <= i.id
			),
		(
			select isnull(sum(case 
							when bdType = 'Draw'
								then bdQty * - 1
							else bdQty
							end), 0)
			from #invrun i2
			where datediff(dd, i2.bdDate, i.bdDate) >= 0
			),
		i.associatedTrade,
		i.invBDCost,
		i.associatedCpty,
		i.errorMessage
	from #invrun i

	-- output the whole table            
	select i.id,
		i.bdDate,
		i.bdQty,
		i.bdUom,
		i.bdAllocNum,
		i.bdAllocItemNum,
		i.invNum,
		i.invBDNum,
		i.bdType,
		null as pTradeNum,
		null as counterpartyName,
		i.runningBal as 'Running Balance',
		i.eodBal as 'End of Day Balance',
		i.associatedTrade,
		i.invBDCost,
		i.associatedCpty,
		case 
			when i.bdType = 'Open'
				then i.bdQty
			else null
			end as OpenQty,
		case 
			when i.bdType = 'Adj'
				then i.bdQty
			else null
			end as AdjQty,
		case 
			when i.bdType = 'Draw'
				then i.bdQty
			else null
			end as DrawQty,
		case 
			when i.bdType = 'Build'
				then i.bdQty
			else null
			end as BuildQty,
		i.errorMessage
	from #invrunoutput i
	order by i.bdDate,
		OpenQty desc,
		BuildQty desc,
		DrawQty desc,
		AdjQty desc

	drop table #invrun

	drop table #invrunoutput
end
GO
