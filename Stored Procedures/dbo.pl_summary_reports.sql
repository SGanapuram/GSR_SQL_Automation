SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[pl_summary_reports]
@report_type int
as
begin


declare @asofdate datetime
select @asofdate = max(pl_asof_date) from portfolio_profit_loss 
--select @asofdate='12/4/2009'

--declare @asofdate2 datetime
--select @asofdate2  = max(pl_asof_date) from portfolio_profit_loss 
--where pl_asof_date !=@asofdate
--select @asofdate2

if @report_type = 1
begin
	select 
		p.port_num 'PortNum',
		p.port_short_name 'Portfolio',
		b.acct_short_name 'BookingCompany',
		tor.order_type_code 'OrderType',
		sum(pl_amt) 'SumPL'
	from 
		pl_history pl,
		trade_item ti,
		trade_order tor,
		account b,
		portfolio p
	where
		pl.pl_secondary_owner_key1=ti.trade_num and
		pl.pl_secondary_owner_key2=ti.order_num and
		pl.pl_secondary_owner_key3=ti.item_num and
		tor.trade_num = ti.trade_num and
		tor.order_num = ti.order_num and
		b.acct_num=ti.booking_comp_num and
		p.port_num = pl.real_port_num and
		pl.pl_asof_date=@asofdate and
		pl.pl_owner_code != 'P' and
		pl.pl_type not in ('I','W')
	group by
		p.port_num,
		p.port_short_name,
		b.acct_short_name,
		tor.order_type_code

	union all

	select 
		p.port_num 'PortNum',
		p.port_short_name 'Portfolio',
		pos.acct_short_name 'BookingCompany',
		(select 'INVENTORY') 'OrderType',
		sum(pl_amt) 'SumPL'
	from 
		pl_history pl,
		position pos,
		portfolio p
	where
		pl.pl_secondary_owner_key1=pos.pos_num and
		p.port_num = pl.real_port_num and
		pl.pl_asof_date=@asofdate and
		pl.pl_secondary_owner_key2 is null and
		pl.pl_owner_code='P' and
		pl.pl_type not in ('I','W')
	group by
		p.port_num,
		p.port_short_name,
		pos.acct_short_name
end

else if @report_type = 2
begin
declare @asofdate2 datetime
select @asofdate2  = max(pl_asof_date) from portfolio_profit_loss 
where pl_asof_date !=@asofdate
--select @asofdate2='12/3/2009'

select 	
	pl1.port_num 'PortNum',
	p.port_short_name 'Portfolio',
	pl1.open_phys_pl+pl1.closed_phys_pl+pl1.open_hedge_pl+pl1.closed_hedge_pl+pl1.liq_closed_phys_pl+pl1.liq_closed_hedge_pl as day1, 
	pl2.open_phys_pl+pl2.closed_phys_pl+pl2.open_hedge_pl+pl2.closed_hedge_pl+pl2.liq_closed_phys_pl+pl2.liq_closed_hedge_pl as day2
from	
	portfolio p,
	portfolio_profit_loss pl1,
	portfolio_profit_loss pl2
where	
	p.port_num=pl1.port_num and
	p.port_num=pl2.port_num and
	pl1.pl_asof_date=@asofdate and
	pl2.pl_asof_date=@asofdate2
order 	
	by p.port_num 



end


end
GO
GRANT EXECUTE ON  [dbo].[pl_summary_reports] TO [next_usr]
GO
