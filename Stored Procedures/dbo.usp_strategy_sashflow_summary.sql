SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_strategy_sashflow_summary] 
(
	@topPortNum int,
	@asofDate varchar(12)
)
as
set nocount on

	if object_id('tempdb..#children','U') is not null
	drop table #children

	create table #children (port_num int,port_type char(2) )
	exec port_children 1668276, 'R',0

	if object_id('tempdb..#TempRevenues','U') is not null
	drop table #TempRevenues

	create table #TempRevenues (
		section varchar(26) not null,
		sub_section varchar(15) null,
		Trade varchar(27) null,
		Counterparty nvarchar(15) null,
		TradeDetail varchar(30) null,
		Qty decimal null,
		[Qty UOM] char(4) null,
		[Per Unit] float null,
		[Due date] varchar(12) null,
		[Paid date] varchar(12) null,
		Cost float null,
		Revenue float null	);

	begin
	insert into #TempRevenues
	select 'PRIMARY REVENUES/(COSTS)' section,

		case ti.p_s_ind
			when 'P'
				then 'PURCHASES'
			else 'SALES'
			end sub_section,

		'Trade' + convert(varchar(10), ti.trade_num) + '/' + convert(varchar(5), ti.order_num) + '/' + convert(varchar(5), ti.item_num) 'Trade',

		cp.acct_short_name 'Counterparty',

		'Physical, ' + cmdty.cmdty_short_name + ', BL=' as 'TradeDetail',

		plh.pl_record_qty 'Qty',

		plh.pl_record_qty_uom_code 'Qty UOM',

		isnull(plh.pl_amt, 0.) / case isnull(plh.pl_record_qty, 1.)
			when 0
				then 1
			else isnull(plh.pl_record_qty, 1)
			end 'Per Unit',

		convert(varchar(12), cost.cost_due_date, 106) 'Due Date',

		convert(varchar(12), cost.cost_paid_date, 106) 'Paid Date',

		case ti.p_s_ind
			when 'P'
				then - 1. * plh.pl_amt
			else null
			end 'Cost',
		
		case ti.p_s_ind
			when 'S'
				then plh.pl_amt
			else null
			end 'Revenue'
	from pl_history plh
	inner join #children c on c.port_num = plh.real_port_num
	inner join trade_item ti on plh.pl_secondary_owner_key1 = ti.trade_num
		and plh.pl_secondary_owner_key2 = ti.order_num
		and plh.pl_secondary_owner_key3 = ti.item_num
	inner join trade trd on trd.trade_num = ti.trade_num
	inner join account cp on cp.acct_num = trd.acct_num
	inner join commodity cmdty on cmdty.cmdty_code = ti.cmdty_code
	inner join trade_item_wet_phy tiwp on tiwp.trade_num = ti.trade_num
		and tiwp.order_num = ti.order_num
		and tiwp.item_num = ti.item_num
	inner join cost on cost.cost_num = plh.pl_record_key
	where plh.pl_asof_date = @asofDate
		and pl_owner_sub_code = 'WPP'

	union all

	select 'SECONDARY REVENUES/(COSTS)' section,

		case isnull(cgrp.parent_cmdty_code, 'NULL')
			when 'NULL'
				then cmdty.cmdty_short_name
			else cgrp.parent_cmdty_code
			end sub_section,

		cmdty.cmdty_short_name,
		cp.acct_short_name 'Counterparty',

		'Trade' + convert(varchar(10), ti.trade_num) + '/' + convert(varchar(5), ti.order_num) + '/' + convert(varchar(5), ti.item_num) 'TradeDetail',

		null 'Qty',

		null 'Qty UOM',

		case cost.cost_amt_type
			when 'F'
				then 0
			else isnull(plh.pl_amt, 0.) / case isnull(plh.pl_record_qty, 1.)
					when 0
						then 1
					else isnull(plh.pl_record_qty, 1)
					end
			end 'Per Unit',

		convert(varchar(12), cost.cost_due_date, 106) 'Due Date',

		convert(varchar(12), cost.cost_paid_date, 106) 'Paid Date',

		case cost.cost_pay_rec_ind
			when 'P'
				then - 1. * plh.pl_amt
			else null
			end 'Cost',

		case cost.cost_pay_rec_ind
			when 'R'
				then plh.pl_amt
			else null
			end 'Revenue'

	from pl_history plh
	inner join #children c on c.port_num = plh.real_port_num
	inner join cost on cost.cost_num = plh.pl_record_key
	inner join trade_item ti on plh.pl_secondary_owner_key1 = ti.trade_num
		and plh.pl_secondary_owner_key2 = ti.order_num
		and plh.pl_secondary_owner_key3 = ti.item_num
	inner join account cp on cp.acct_num = cost.acct_num
	inner join commodity cmdty on cmdty.cmdty_code = cost.cost_code
	left outer join commodity_group cgrp on cgrp.cmdty_code = cost.cost_code
	where plh.pl_asof_date = @asofDate
		and pl_owner_sub_code != 'WPP'
		and pl_owner_code = 'C'
		order by section,sub_section
	end 

	select * from #TempRevenues
	union all
	select 'SECONDARY REVENUE/(COSTS)' section,
		'HEDGE RESULTS' sub_section,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		sum(cost) 'Cost',
		sum(revenue) 'Revenue'

	from (
		(
			select null plKey,
				sum(- 1. * pl_amt) cost,
				null revenue
			from pl_history plh
			inner join #children c on c.port_num = plh.real_port_num
			where pl_asof_date = @asofDate
				and pl_owner_code = 'C'
				and pl_owner_sub_code = 'SWAP'
				and pl_amt < 0
			
			union all
			
			select null plKey,
							null,
				sum(plh.pl_amt) Revenue
			from pl_history plh
			inner join #children c on c.port_num = plh.real_port_num
			where pl_asof_date = @asofDate
				and pl_owner_code = 'C'
				and pl_owner_sub_code = 'SWAP'
				and pl_amt > 0
			
			union all
			
			select pl_record_key plKey,
				sum(pl_amt) cost,
				null revenue
			from pl_history plh
			inner join #children c on c.port_num = plh.real_port_num
			where pl_asof_date = @asofDate
				and pl_owner_code = 'T'
				and pl_owner_sub_code = 'F'
				and pl_type != 'W'
			group by pl_record_key
			having sum(pl_amt) < 0
			
			union all
			
			select pl_record_key plKey,
				null cost,
				sum(pl_amt) revenue
			from pl_history plh
			inner join #children c on c.port_num = plh.real_port_num
			where pl_asof_date = @asofDate
				and pl_owner_code = 'T'
				and pl_owner_sub_code = 'F'
				and pl_type != 'W'
			group by pl_record_key
			having sum(pl_amt) > 0
			)
		) swapFutureHedge
GO
GRANT EXECUTE ON  [dbo].[usp_strategy_sashflow_summary] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_strategy_sashflow_summary', NULL, NULL
GO
