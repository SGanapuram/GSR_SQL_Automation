SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[trdcapcom_sp_ri_chk]
as
begin
set nocount on

   select "Distributions Where Positions Don't Exist"
set nocount off
   select count(*) 
   from scratch_trade..trade_item_dist where pos_num not
   in (select pos_num from scratch_trade..position)
end

begin
-- finds any position type portfolios where the position record is missing
set nocount on
select "Position Portfolios Where Positions Don't Exist"
set nocount off
select count(*) from scratch_trade..portfolio where port_type='P' and
port_num not in (select pos_num from scratch_trade..position)
end

begin
-- finds any positions where the position type portfolio record is missing
set nocount on
select "Positions Where Portfolios Don't Exist"
set nocount off
select count(*) from scratch_trade..position
where pos_num not in
(select port_num from scratch_trade..portfolio where port_type='P')
end

begin
-- finds portfolio groups where the port_num no longer exists
set nocount on
select "Portfolio Groups Where Portfolios Don't Exist"
set nocount off
select count(*) from scratch_trade..portfolio_group
where port_num not in
(select port_num from scratch_trade..portfolio)
end

begin
-- finds portfolio groups where the parent_port_num no longer exists
set nocount on
select "Portfolio Groups Where Parent Portfolios Don't Exist"
set nocount off
select count(*) from scratch_trade..portfolio_group where
parent_port_num
not in (select port_num from scratch_trade..portfolio)
end

-- FROM ZIMIN

begin
--
set nocount on
select "Check if a commodity_market referred by any formula has been
deleted"
set nocount off
select count(*)
from scratch_trade..formula_component
where commkt_key in (select commkt_key from
scratch_trade..aud_commodity_market where master_loc_num=255)
end

begin
--
set nocount on
select "Incorrect exercising date for A/E OTC options"
set nocount off
select trade_num,order_num,item_num,exp_date,strike_excer_date
from scratch_trade..trade_item_otc_opt
where opt_type<>'A' and exp_date<strike_excer_date and
strike_excer_date is not null
end

begin
--
set nocount on
select "Incorrect exercising date for APO OTC options"
set nocount off
select trade_num,order_num,item_num,price_date_to,strike_excer_date
from scratch_trade..trade_item_otc_opt
where opt_type='A' and price_date_to<strike_excer_date and
strike_excer_date is not null
end

begin
--
set nocount on
select "Checking item_status_code for triger type item"
set nocount off
select ti.trade_num,ti.order_num,ti.item_num
from scratch_trade..trade_item ti,  scratch_trade..trade_formula tf,
scratch_trade..formula f
where ti.trade_num=tf.trade_num
and ti.order_num=tf.order_num
and ti.item_num=tf.item_num
and tf.formula_num=f.formula_num
and ti.item_status_code in ('FT','PT')
and f.formula_type!='T'
end

begin
--
set nocount on
select "Trade_item has no trade_order"
set nocount off
select trade_num,order_num
from scratch_trade..trade_item ti
where order_num not in (select order_num from
scratch_trade..trade_order
where trade_num=ti.trade_num)
end

begin
--
set nocount on
select "For Listed Options, exp_date out of sync with
trading_period.opt_exp_date"
set nocount off
select
opt.trade_num,opt.order_num,opt.item_num,opt.strike_excer_date,opt.exp_date,tp.opt_exp_date
from scratch_trade..trade_item_exch_opt opt, scratch_trade..trade_item
ti,
scratch_trade..trading_period tp,
scratch_trade..commodity_market cm
where opt.trade_num=ti.trade_num
and opt.order_num=ti.order_num
and opt.item_num=ti.item_num
and ti.cmdty_code=cm.cmdty_code
and ti.risk_mkt_code=cm.mkt_code
and cm.commkt_key=tp.commkt_key
and ti.trading_prd=tp.trading_prd
and opt.exp_date<>tp.opt_exp_date
end

begin
--
set nocount on
select "For Listed Options, position's opt_exp_date out of sync with
trade_item_exch_opt.opt_exp_date"
set nocount off
select distinct tid.trade_num
from scratch_trade..trade_item_exch_opt opt,
scratch_trade..trade_item_dist
tid, scratch_trade..position pos
where opt.trade_num=tid.trade_num
and opt.order_num=tid.order_num
and opt.item_num=tid.item_num
and pos.pos_num=tid.pos_num
and opt.exp_date<>pos.opt_exp_date
end

begin
--
set nocount on
select "Checking if trading_period.opt_exp_date has been changed"
set nocount off
select tp.commkt_key,tp.trading_prd,tp.opt_exp_date,atp.opt_exp_date
from scratch_trade..trading_period tp,
scratch_trade..aud_trading_period atp
where tp.commkt_key=atp.commkt_key
and tp.trading_prd=atp.trading_prd
and tp.opt_exp_date<>atp.opt_exp_date
end

begin
--
set nocount on
select "Checking if cost_pay_rec_ind is correct for PP costs."
set nocount off
select distinct c.cost_num,c.cost_pay_rec_ind,c.cost_status,
c.cost_type_code, c.cost_owner_key6, c.cost_owner_key7,
c.cost_owner_key8
from scratch_trade..cost c, scratch_trade..trade_item ti
where c.cost_owner_key6=ti.trade_num
and c.cost_owner_key7=ti.order_num
and c.cost_owner_key8=ti.item_num
and c.cost_prim_sec_ind='P'
and c.cost_pay_rec_ind='R'
and ti.p_s_ind='P'
and c.cost_type_code in ('WPP') and c.cost_status<>'CLOSED'
end

begin
--
set nocount on
select "Check Accum have 2 QPPs for the same quote but should have
one"
set nocount off
select distinct qpp1.trade_num,qpp1.order_num,qpp1.item_num
from scratch_trade..quote_pricing_period qpp1,
scratch_trade..quote_pricing_period qpp2
where qpp1.formula_num=qpp2.formula_num
and qpp1.formula_body_num=qpp2.formula_body_num
and qpp1.formula_comp_num=qpp2.formula_comp_num
and qpp1.quote_start_date=qpp2.quote_start_date
and qpp1.quote_end_date=qpp2.quote_end_date
and qpp1.qpp_num<>qpp2.qpp_num
and qpp1.accum_num=qpp2.accum_num
end


begin
--
set nocount on
select "Costs which do not have cost_owner_key6/7/8"
set nocount off
select cost_num,cost_type_code,cost_status,cost_owner_code,
cost_owner_key1,cost_owner_key2,cost_owner_key3,
cost_owner_key6,cost_owner_key7,cost_owner_key8,
creation_date,creator_init,mod_init
from scratch_trade..cost
where cost_owner_code in ('TI','AI','AA','AC')
and (cost_owner_key6 is null or cost_owner_key7 is null or
cost_owner_key8 is null)
end
return
GO
GRANT EXECUTE ON  [dbo].[trdcapcom_sp_ri_chk] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[trdcapcom_sp_ri_chk] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'trdcapcom_sp_ri_chk', NULL, NULL
GO
