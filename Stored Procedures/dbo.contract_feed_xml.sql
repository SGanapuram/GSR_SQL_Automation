SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[contract_feed_xml]
(
   @trade_id int
)
as
begin
set nocount on
declare @trade_num int, @order_num int, @item_num int, @has_more tinyint,
        @inst_type varchar(8), @prc_1_payor_sn varchar(20), @prc_2_payor_sn varchar(20),
        @quote_cmdty1 varchar(8),
        @quote_mkt1 varchar(8), @quote_prd1 varchar(10), @quote_source1 varchar(20),
        @quote_cmdty2 varchar(8), @cdty_code varchar(8),
        @quote_mkt2 varchar(8), @quote_prd2 varchar(10), @quote_source2 varchar(20),
	      @se_cmpny_sn varchar(20), @cpty_sn varchar(20), @qty_per_duration_code varchar(5),
        @dlvry_start_dt char(8), @dlvry_end_dt char(8), @se_buysell_ind char(1),
        @dmo_count int

declare @efp_flag char(1), @formula_ind char(1), @pricing_start_date1 char(8),
        @pricing_end_date1 char(8), @formula_num int, @buy_formula_num int,
        @sell_formula_num int, @formula_type char(1),
        @fixed_price float, @fixed_price_str varchar(255),
        @formula_diff_str1 varchar(255), @formula_diff1 float,
        @formula_diff_str2 varchar(255), @formula_diff2 float, @plus_position int,
        @is_spread char(1), @qty_formula_body_count tinyint,
        @is_unknown_spread char(1), @quote_qty1 float, @quote_qty2 float,
	      @quote_uom1 varchar(5), @quote_uom2 varchar(5), @payment_term varchar(8),
        @pay_days int, @settlement_date char(8), @use_actual_for_due_date char(1),
        @use_allocation_for_due_date char(1), @open_qty float, @allocation_count int,
	      @prc_1_exch_roll_a char(1), @prc_2_exch_roll_a char(1),
        @prc_1_exch_roll_b char(1), @prc_2_exch_roll_b char(1), @diff_failure tinyint,
        @formula_curr_code varchar(8), @formula_uom_code varchar(5), @acct_num int,
        @swap_flt_total_qty float, @swap_com_prc_flag char(1), @fixed_price_count int,
        @message varchar(255), @efs_flag char(1), @order_count int, @future_count int,
        @swap_count int, @cost_book_curr_code varchar(8),
        @cost_price_curr_code varchar(8), @item_type char(1), @is_colonial_pipeline char(1),
        @mot_code varchar(8), @cycle_number varchar(10), @cycle_trading_prd varchar(50),
        @quote1_year int, @quote1_month int, @quote1_nearby int,
        @current_period varchar(10), @prc_1_quote_ind_a char(1), @prc_1_quote_ind_b char(1),
        @prc_2_quote_ind_a char(1), @prc_2_quote_ind_b char(1),
        @optn_strike_quote_ind_a char(1), @optn_strike_quote_ind_b char(1),
        @fut_fill_price_count int, @future_fill_price_desc varchar(255),
        @fut_buy_sell_ind char(1),@row_count int
 

/* for roll indicators */

declare @accum_prd_ind char(1), @rel_price_cal_ind char(2), @rel_days smallint, @term_count int
declare @xml as xml
declare @xml_val varchar(max)

select @efs_flag = 'N'

select @order_count = count(*) from trade_order where trade_num = @trade_id
select @future_count = count(*) from trade_order where trade_num = @trade_id and
        order_type_code = 'FUTURE'
select @swap_count = count(*) from trade_order where trade_num = @trade_id and
        order_type_code like 'SWAP%'
/*
if @order_count = 2 and @future_count = 1 and @swap_count = 1
begin
        select @efs_flag = 'Y'
end
*/
select @acct_num = acct_num from trade where trade_num = @trade_id

/*
if @acct_num is null
begin
return 1
end  */

create table #contract_feed (
id      int,
trading_system_code varchar(5),
trade_num int,
order_num int,
item_num int,
trade_dt char(10),
se_cmpny_sn varchar(20) null,
se_trader varchar(41) null,
cpty_sn varchar(20) null,
cpty_trader varchar(60) null,
broker_sn       varchar(20) null,
inst_type       varchar(8),
cdty_code       varchar(8) null,
sttl_type       varchar(8),
se_buysell_ind char(1),
efp_flag        char(1),
dlvry_start_dt  char(10) null,
dlvry_end_dt    char(10) null,
dlvry_location  varchar(40) null,
cycle_number    varchar(15) null,
qty_per         float,
qty_uom_code    varchar(5),
qty_per_duration_code   varchar(5),
qty_total       float,
prc_1_payor_sn     varchar(20) null,
prc_1_fixed_flag        char(1) null,
prc_1_pricediff varchar(32) null,
prc_1_ccy_code          varchar(8) null,
prc_1_uom_code  varchar(5) null,
prc_1_curve     varchar(255) null,
prc_1_start_dt  char(10) null,
prc_1_end_dt    char(10) null,
prc_1_trig_start_dt     char(10) null,
prc_1_trig_end_dt       char(10) null,
prc_1_contract_month    varchar(20) null,
prc_1_exch_roll_a       char(1) null,
prc_1_exch_roll_b       char(1) null,
prc_2_payor_sn  varchar(20) null,
prc_2_fixed_flag        char(1) null,
prc_2_pricediff    varchar(32) null,
prc_2_ccy_code   varchar(8) null,
prc_2_uom_code  varchar(5) null,
prc_2_curve     varchar(255) null,
prc_2_start_dt  char(10) null,
prc_2_end_dt    char(10) null,
prc_2_trig_start_dt     char(10) null,
prc_2_trig_end_dt       char(10) null,
prc_2_contract_month      varchar(20) null,
prc_2_exch_roll_a       char(1) null,
prc_2_exch_roll_b       char(1) null,
swap_com_prc_flag       char(1) null,
sttl_model      varchar(20) null,
sttl_ccy_code           varchar(8) null,
sttl_month_offset tinyint  null,
sttl_days_offset        int null,
sttl_dt_final   char(10) null,
--mot_carrier     varchar(64) null,
mot_type        varchar(15) null,
mot             varchar(40) null,
--title_location varchar(40) null,
lease_tank      varchar(255) null,
load_port_loc   varchar(40) null,
disch_port_loc  varchar(40) null,
origin_country  varchar(40) null,
processed       tinyint
)

create table #feed_option (
trade_num int,
order_num int,
item_num int,
optn_put_call_ind       char(1) null,
optn_trade_type_code    varchar(5) null,
optn_style_code         varchar(5) null,
optn_prem_fee_type        char(1) null,
optn_fee_rate   float null,
optn_prem_ccy_code      varchar(5) null,
optn_prem_uom_code      varchar(5) null,
optn_prem_val_dt char(10) null,
optn_strike_fixed_flag  char(1) null,
optn_strike_pricediff   varchar(32) null,
optn_strike_ccy_code     varchar(5) null,
optn_strike_uom_code    varchar(5) null,
optn_strike_curve       varchar(255) null,
optn_strike_start_dt    char(10) null,
optn_strike_end_dt char(10) null,
optn_strike_trig_start_dt       char(10) null,
optn_strike_trig_end_dt char(10) null,
optn_strike_contract_month        varchar(20) null,
optn_strike_exch_roll_a char(1) null,
optn_strike_exch_roll_b char(1) null
)

create table #feed_efs (
trade_num int,
order_num int,
item_num int,
fut_buy_sell_ind        char(1),
fut_type varchar(8),
fut_contract varchar(20) null,
fut_contract_month varchar(20) null,
fut_lots int null,
fut_avg_fill_prc float null,
fut_prc_ccy_code varchar(5) null,
fut_prc_uom_code varchar(5) null
)

insert #contract_feed
select distinct
t.trade_num,
'SYM',
ti.trade_num,
ti.order_num,
ti.item_num,
'20' + convert(char(8), t.contr_date, 12),
a_bc.acct_short_name,
iu.user_first_name+' '+iu.user_last_name,
ta.acct_short_name,
ac.acct_cont_first_name + ' '  + ac.acct_cont_last_name,
a_bkr.acct_short_name,
tord.order_type_code,
ti.cmdty_code,
'PHYS',         /* only otc options may be financially settled */
ti.p_s_ind,
'N',                  /* default to not EFP */
'20' + convert(char(8), wet.del_date_from, 12),
'20' + convert(char(8), wet.del_date_to, 12),
wet.del_loc_code,
null,
ti.contr_qty,
ti.contr_qty_uom_code,
ti.contr_qty_periodicity,
d.dist_qty,
ti.p_s_ind,
'N',                 /* default to formula pricing */
null,               /* default to no data */
ti.price_curr_code,
ti.price_uom_code,
null,
null,
null,
null,  	           /* pricing start date, to be filled in later */
null,           /* pricing end date, to be filled in later */
null,
null,
null,
null,           /* second quote data, to be filled in later */
null,
null,
null,
null,
null,
null,
null,
null,
null,
null,
null,
null,
null,
wet.pay_term_code,
null,
null,
wet.pay_days,
null,
mt.mot_type_short_name,
m.mot_full_name,
lti.long_description,
lloc.loc_name,
dloc.loc_name,
c.country_name,
0
from trade t
--icts_user iu,
--trade_item ti,
--trade_order tord,
--trade_item_wet_phy wet,
--trade_item_dist d,
--account a_bc,
--account_contact ac,
--account a_bkr
join trade_order tord on tord.trade_num = t.trade_num
join trade_item ti on ti.trade_num = tord.trade_num and ti.order_num = tord.order_num
join trade_item_dist d on d.trade_num = ti.trade_num and d.order_num = ti.order_num and d.item_num = ti.item_num
join icts_user iu on iu.user_init = t.trader_init
left join trade_item_wet_phy wet on wet.trade_num = ti.trade_num and wet.order_num = ti.order_num and wet.item_num = ti.item_num
left join account a_bc on a_bc.acct_num = ti.booking_comp_num
join account ta on ta.acct_num = t.acct_num
left join account_contact ac on ac.acct_num = t.acct_num and ac.acct_cont_num = t.acct_cont_num
left join account a_bkr on a_bkr.acct_num = ti.brkr_num
left join mot m on m.mot_code = wet.mot_code
left join mot_type mt on mt.mot_type_code = m.mot_type_code
left join location_tank_info lti on lti.tank_num = wet.tank_num
left join location lloc on lloc.loc_code = ti.load_port_loc_code
left join location dloc on dloc.loc_code = ti.disch_port_loc_code
left join country c on c.country_code = ti.origin_country_code
where t.trade_num=@trade_id
--and tord.trade_num=t.trade_num
--and ti.trade_num=tord.trade_num
--and ti.order_num=tord.order_num
--and d.trade_num = ti.trade_num
--and d.order_num = ti.order_num
--and d.item_num = ti.item_num
and d.dist_type = 'D'
and d.is_equiv_ind = 'N'
--and t.trader_init=iu.user_init
--and ti.booking_comp_num *= a_bc.acct_num
--and ti.trade_num *= wet.trade_num
--and ti.order_num *= wet.order_num
--and ti.item_num *= wet.item_num
--and t.acct_num *=ac.acct_num
--and t.acct_cont_num *= ac.acct_cont_num
--and ti.brkr_num *= a_bkr.acct_num
and tord.strip_summary_ind != 'Y'
and tord.order_type_code not in ('FUTURE', 'EXCHGOPT')
order by ti.trade_num, ti.order_num, ti.item_num


select @has_more = count(*) from #contract_feed

while
  @has_more > 0
begin

select @is_colonial_pipeline = 'N'
select @is_spread = 'N'
select @is_unknown_spread = 'N'

set rowcount 1

select @trade_num = trade_num, @order_num = order_num, @item_num = item_num,
@inst_type = inst_type, @se_cmpny_sn = se_cmpny_sn, @cpty_sn = cpty_sn,
@se_buysell_ind = se_buysell_ind, @cdty_code=cdty_code,
@qty_per_duration_code = qty_per_duration_code,
@dlvry_start_dt = dlvry_start_dt, @dlvry_end_dt = dlvry_end_dt,
@prc_1_payor_sn = prc_1_payor_sn,
@prc_2_payor_sn = prc_2_payor_sn
from #contract_feed where processed = 0

set rowcount 0

if @dlvry_start_dt = '20'
        select @dlvry_start_dt = null

if @dlvry_end_dt = '20'
	select @dlvry_end_dt = null

if @se_buysell_ind = 'P'
        select @se_buysell_ind = 'B'


if @inst_type = 'EFPEXCH'
        select @efp_flag = 'Y'
else
        select @efp_flag = 'N'

if @qty_per_duration_code = 'L'
	select @qty_per_duration_code = 'M'

if @inst_type like 'OTC%'     /* OCT Options */
begin
        insert #feed_option
        select @trade_num, @order_num, @item_num, put_call_ind, null, opt_type, null, premium,
        premium_curr_code, premium_uom_code, convert(char(8), premium_pay_date, 112), null,
	convert(varchar(32), convert(numeric(15, 4),strike_price)), strike_price_curr_code,
        premium_uom_code, null, null, null, null, null, null, null, null
        from trade_item_otc_opt
        where trade_num = @trade_num and order_num = @order_num and
        item_num = @item_num
end

select @item_type = item_type from trade_item where trade_num = @trade_num and
        order_num = @order_num and item_num = @item_num

/* check for efs */

if @item_type = 'C'  /* swap */
begin
        if (select efs_ind from trade_item_cash_phy where trade_num =
@trade_num and
        order_num = @order_num and item_num = @item_num) = 'Y'
                select @efs_flag = 'Y'
end
if @efs_flag = 'Y'    /* exchange for swap */
begin
        insert #feed_efs
        select @trade_num, @order_num, @item_num, i.p_s_ind, 'EFS',
        i.risk_mkt_code + ': ' + i.cmdty_code,
        i.trading_prd, i.contr_qty, f.avg_fill_price, i.price_curr_code, i.price_uom_code
        from trade_item i, trade_item_fut f
        where i.trade_num = @trade_num and i.item_type = 'F' and i.trade_num = f.trade_num
        and i.order_num = f.order_num and i.item_num = f.item_num

        select @fut_buy_sell_ind = fut_buy_sell_ind from #feed_efs where trade_num = @trade_num and
        order_num = @order_num and item_num = @item_num
        if @fut_buy_sell_ind = 'P'

                update #feed_efs set fut_buy_sell_ind = 'B'
                where trade_num = @trade_num and
                order_num = @order_num and item_num = @item_num

end

if @item_type = 'W'
begin
        select @mot_code = mot_code from trade_item_wet_phy
        where trade_num = @trade_num and order_num = @order_num and
        item_num = @item_num

        if @mot_code = 'CPL'
                select @is_colonial_pipeline = 'Y'
end   /* physical item */

if @is_colonial_pipeline = 'Y'
begin
        select @cycle_trading_prd = p.trading_prd_desc from trading_period p,
        commodity_market cm, trade_item i
        where i.trade_num = @trade_num and i.order_num = @order_num and
        i.item_num = @item_num and cm.cmdty_code = i.cmdty_code and
        cm.mkt_code  = i.risk_mkt_code and cm.commkt_key = p.commkt_key
        and p.trading_prd = i.trading_prd

        if (select substring(@cycle_trading_prd, 3, 1) ) = 'F'
                select @cycle_number = 'Front '
        else if (select substring(@cycle_trading_prd, 3, 1) ) = 'B'
                select @cycle_number = 'Back '
        else /* should not happen */
                select @cycle_number = ''

        if (select substring(@cycle_trading_prd, 5, 1)) in ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
                select @cycle_number = @cycle_number + substring(@cycle_trading_prd, 4, 2)
        else
                select @cycle_number = @cycle_number + substring(@cycle_trading_prd, 4, 1)
        update #contract_feed set cycle_number = @cycle_number where
        trade_num = @trade_num and order_num = @order_num and item_num = @item_num
end

if @efp_flag = 'Y'    /* exchange for physical */
begin
        if @item_type = 'W'
        begin
                insert #feed_efs
                select @trade_num, @order_num, @item_num,p_s_ind, 'EFP',
                risk_mkt_code + ': ' + cmdty_code,
                trading_prd, contr_qty, avg_price, price_curr_code, price_uom_code
                from trade_item where trade_num = @trade_num and order_num = @order_num
                and item_type = 'X'

                if (select fut_buy_sell_ind from #feed_efs where trade_num = @trade_num and
                order_num = @order_num and item_num = @item_num) = 'P'
                        update #feed_efs set fut_buy_sell_ind = 'B'
                        where trade_num = @trade_num and
                        order_num = @order_num and item_num = @item_num

                delete #contract_feed where order_num != @order_num
                or item_num != item_num
        end
end

if @inst_type in ('OTCAPO', 'OTCCASH', 'SWAP', 'SWAPFLT')
        update #contract_feed set sttl_type = 'FNCL' where trade_num = @trade_num and order_num = @order_num and item_num = @item_num

select @formula_ind = formula_ind
from trade_item
where trade_num = @trade_num and order_num = @order_num and item_num =  @item_num

if @formula_ind = 'Y'
        select @formula_ind = 'N'
else


select @formula_ind = 'Y'

if @formula_ind = 'N'    /* formula pricing */
begin
        select @formula_num=t.formula_num, @formula_type=f.formula_type
        from trade_formula t, formula f
        where t.formula_num=f.formula_num and t.trade_num=@trade_num and
        t.order_num=@order_num and t.item_num=@item_num


        select @formula_curr_code = formula_curr_code, @formula_uom_code =formula_uom_code
        from formula where formula_num = @formula_num

        if @inst_type like 'OTC%'
                update #feed_option set optn_strike_ccy_code = @formula_curr_code,
                optn_strike_uom_code = @formula_uom_code
                where trade_num = @trade_num and order_num = @order_num and item_num = @item_num
        else
                update #contract_feed set prc_1_ccy_code = @formula_curr_code,
                prc_1_uom_code = @formula_uom_code
                where trade_num = @trade_num and order_num = @order_num and item_num
                = @item_num

        if exists (select * from avg_buy_sell_price_term where formula_num = @formula_num)
        begin
                select @pricing_start_date1= '20' + convert(char(6), price_term_start_date, 12), @pricing_end_date1='20' + convert(char(6), price_term_end_date, 12),
                @swap_com_prc_flag = all_quotes_reqd_ind
                from avg_buy_sell_price_term
                where formula_num=@formula_num

	    if @inst_type like 'OTC%'
                        update #feed_option set optn_strike_start_dt = @pricing_start_date1,
                        optn_strike_end_dt = @pricing_end_date1
                        where trade_num = @trade_num and order_num = @order_num and item_num = @item_num
                else
                        update #contract_feed set prc_1_start_dt = @pricing_start_date1,
                        prc_1_end_dt = @pricing_end_date1
                        where trade_num = @trade_num and order_num = @order_num and item_num = @item_num
        end   /* average formula */
        select @qty_formula_body_count = count(*) from formula_body
                where formula_num = @formula_num and formula_body_type = 'Q'



        /* figure out how many quote type formula_bodies there are */
        if @qty_formula_body_count > 2
                select @is_unknown_spread= 'Y'
        else if @qty_formula_body_count = 2
        begin
                select @is_spread = 'Y'

                select @quote_uom1 = formula_qty_uom_code,
                @quote_qty1 = abs(formula_qty_pcnt_val)
                from formula_body where formula_num = @formula_num
                and formula_body_type = 'Q' and formula_qty_pcnt_val > 0.0

                select @quote_uom2 = formula_qty_uom_code,
                @quote_qty2 = abs(formula_qty_pcnt_val)
                from formula_body where formula_num = @formula_num
                and formula_body_type = 'Q' and formula_qty_pcnt_val < 0.0

                if @quote_uom1 != @quote_uom2 or @quote_qty1 != @quote_qty2
                        select @is_unknown_spread= 'Y'
        end

        if @inst_type = 'SWAP'
        begin

                select @settlement_date = '20' + convert(char(6), max(c.cost_due_date), 12),
                @cost_book_curr_code = c.cost_book_curr_code,
                @cost_price_curr_code = c.cost_price_curr_code
                from cost c
                where c.cost_owner_code = 'AC'
                and c.cost_owner_key1=@trade_num
                and c.cost_owner_key2=@order_num
                and c.cost_owner_key3=@item_num
                group by c.cost_book_curr_code, c.cost_price_curr_code
                --group by cost_owner_code, cost_owner_key1, cost_owner_key2,
                --cost_owner_key3
                --having cost_due_date = max(cost_due_date)

                if @cost_book_curr_code is null
                        select @cost_book_curr_code = @cost_price_curr_code

                select @fixed_price_str = convert(varchar(20), -1.0 * convert(decimal(19,6),formula_body_string))
                from formula_body
                where formula_num = @formula_num and
                formula_body_type = 'M'
                if @prc_1_payor_sn = 'P'      /* for swap p_s_ind is for fixed price */
	                 begin
                        select @prc_1_payor_sn = 'S'
                        select @prc_2_payor_sn = @se_cmpny_sn
                end
                else
                begin
                        select @prc_1_payor_sn = 'P'
                        select @prc_2_payor_sn = @cpty_sn
                end

                select @payment_term = pay_term_code, @pay_days = pay_days
                from trade_item_cash_phy
                where trade_num = @trade_num and order_num = @order_num and item_num = @item_num

                update #contract_feed set cdty_code = 'OIL', sttl_type = 'FNCL',
                prc_2_payor_sn=@prc_2_payor_sn,
                prc_2_curve = 'FIXED', prc_2_fixed_flag = 'Y', prc_2_pricediff =
			convert(varchar(20), convert(decimal(19,6), @fixed_price_str)),
                prc_2_ccy_code = prc_1_ccy_code, prc_2_uom_code = prc_1_uom_code,
                sttl_model = @payment_term, sttl_ccy_code = @cost_book_curr_code,
                sttl_days_offset = @pay_days,
                sttl_dt_final = @settlement_date
                where trade_num = @trade_num and order_num = @order_num and item_num = @item_num

        end   /* swap case */


	   else if @inst_type = 'SWAPFLT'
  	      begin           /* for swapflt, dist_qty is 0.  use accum_qty */
                select @swap_flt_total_qty = sum(accum_qty) from accumulation where
                        trade_num=@trade_num and order_num= @order_num and
                        item_num=@item_num
                update #contract_feed set qty_total = @swap_flt_total_qty where
                trade_num=@trade_num and order_num=@order_num and
                        item_num=@item_num
                select @buy_formula_num = formula_comp_ref
                from formula_component
                where formula_num = @formula_num
                and formula_comp_name = 'SwapBuyFloat'

                select @qty_formula_body_count = count(*) from formula_body
                where formula_num = @buy_formula_num and formula_body_type = 'Q'
                if @qty_formula_body_count > 1
                        select @is_spread = 'Y'
                else
	                select @is_spread = 'N'

                if @is_spread = 'N'
                begin

                        select @quote_cmdty1 = c.cmdty_code, @quote_mkt1 = c.mkt_code,
                        @quote_prd1 = f.trading_prd, @quote_source1 = f.price_source_code,
                        @prc_1_quote_ind_a = f.formula_comp_val_type
                        from formula_component f, formula_body b, commodity_market c
                        where f.commkt_key = c.commkt_key and
                        b.formula_num = @buy_formula_num and b.formula_body_type = 'Q'
                        and b.formula_qty_pcnt_val > 0.0 and b.formula_num = f.formula_num
                        and b.formula_body_num = f.formula_body_num and f.formula_comp_type = 'G'

                        /* check roll term */

                        select @term_count = count(*) from formula_comp_price_term t,
                        formula_component f, formula_body b, commodity_market c
                        where f.commkt_key = c.commkt_key and
                        b.formula_num = @buy_formula_num and b.formula_body_type = 'Q'
                        and b.formula_qty_pcnt_val > 0.0 and b.formula_num = f.formula_num
                        and b.formula_body_num = f.formula_body_num and
                        f.formula_comp_type = 'G' and t.formula_num = f.formula_num
                        and t.formula_body_num = f.formula_body_num and
	                    t.formula_comp_num = f.formula_comp_num

                        if @term_count > 0
                        begin
                                select @accum_prd_ind = t.fcpt_roll_accum_prd_ind, @rel_price_cal_ind = t.fcpt_rel_price_cal_days_ind,
                                @rel_days = t.fcpt_relative_days

                                from formula_comp_price_term t,
                                formula_component f, formula_body b, commodity_market c
                                where f.commkt_key = c.commkt_key and
                                b.formula_num = @buy_formula_num and b.formula_body_type = 'Q'
                                and b.formula_qty_pcnt_val > 0.0 and b.formula_num =f.formula_num
                                and b.formula_body_num = f.formula_body_num and
                                f.formula_comp_type = 'G' and t.formula_num = f.formula_num
                                and t.formula_body_num = f.formula_body_num and
                                t.formula_comp_num = f.formula_comp_num

                                if @accum_prd_ind = 'R' and @rel_price_cal_ind = 'PB'
				    and @rel_days = 1


	                            select @prc_1_exch_roll_a = 'Y'
                                else
                                        select @prc_1_exch_roll_a = 'N'
                        end /* there are terms on the quote */


	         else
                                select @prc_1_exch_roll_a = 'N'
                        /* quote differential */
                        select @formula_diff1 = 0.0
                        select @formula_diff_str1  = '0.0'



	                select @formula_diff_str1 = formula_body_string
                        from formula_body
                        where formula_num = @buy_formula_num and formula_body_type in ('P', 'Q')

                        select @diff_failure = 0
                        select @plus_position = charindex('+', @formula_diff_str1)

                        if @plus_position > 0
                        begin
                                select @formula_diff_str1 = substring(@formula_diff_str1,
				@plus_position + 1, len(@formula_diff_str1) - @plus_position)

       				if not @formula_diff_str1 like '%Var%' and not @formula_diff_str1 like '%Quote%'
                                        select @formula_diff1 = convert(float,@formula_diff_str1)


	                         else
                                        select @diff_failure = 1
                        end
                        else
                        begin
                                select @plus_position = charindex('-', @formula_diff_str1)
                                if @plus_position > 0
                                begin
                                        select @formula_diff_str1 =substring(@formula_diff_str1, @plus_position + 1,
					len(@formula_diff_str1) -@plus_position)
                                        if not @formula_diff_str1 like '%Var%' and not @formula_diff_str1 like '%Quote%'
                                                select @formula_diff_str1 = '-'+ltrim(@formula_diff_str1)
	                     else
                                                select @diff_failure = 1
                                end
                                else
                                        select @formula_diff_str1 = '0.0'


	                         end  /* minus differential */

                        /* set quote data */
                        if @diff_failure = 0
                        begin
                                update #contract_feed set prc_1_payor_sn = se_cmpny_sn,
				prc_1_pricediff = convert(varchar(20), convert(decimal(19,6),
					@formula_diff_str1)), prc_1_curve
				= @quote_cmdty1 + '/' + @quote_mkt1 + '/' + @quote_source1,
				prc_1_contract_month =@quote_prd1, prc_1_exch_roll_a = @prc_1_exch_roll_a
        			where trade_num = @trade_num and order_num = @order_num and
				item_num =@item_num
                                if @prc_1_quote_ind_a in ('H', 'L')
                                        update #contract_feed set prc_1_curve = prc_1_curve + '/' +
                                        @prc_1_quote_ind_a where trade_num = @trade_num and order_num = @order_num and item_num =@item_num
                        end
                        else


	                   update #contract_feed set prc_1_pricediff = '???? unknown price diff'
                                where trade_num = @trade_num and order_num = @order_num
				and item_num = @item_num

                end   /* only one buy quote */
                else
                begin
                        select @quote_uom1 = formula_qty_uom_code,
                        @quote_qty1 = abs(formula_qty_pcnt_val)
                        from formula_body where formula_num = @buy_formula_num
                        and formula_body_type = 'Q' and formula_qty_pcnt_val > 0.0

                        select @quote_uom2 = formula_qty_uom_code,
                        @quote_qty2 = abs(formula_qty_pcnt_val)


	                from formula_body where formula_num = @buy_formula_num
                        and formula_body_type = 'Q' and formula_qty_pcnt_val < 0.0

                        if @quote_uom1 != @quote_uom2 or @quote_qty1 != @quote_qty2


	                        update #contract_feed set prc_1_curve = '????'
                                where trade_num = @trade_num and order_num = @order_num
				and item_num = @item_num
                        else
                        begin
	 						/* equal qtys for spread */
                                select @quote_cmdty1 = c.cmdty_code, @quote_mkt1 =c.mkt_code,
                        	@quote_prd1 = f.trading_prd, @quote_source1 = f.price_source_code,
                        	@prc_1_quote_ind_a = f.formula_comp_val_type
                        	from formula_component f, formula_body b, commodity_market c
                        	where f.commkt_key = c.commkt_key and
                        	b.formula_num = @buy_formula_num
							and b.formula_body_type = 'Q'
                        	and b.formula_qty_pcnt_val > 0.0 and b.formula_num = f.formula_num
                        	and b.formula_body_num = f.formula_body_num and
                        	f.formula_comp_type = 'G'



                        /* check roll term */

                        select @term_count = count(*) from formula_comp_price_term t,
                        formula_component f, formula_body b, commodity_market c
                        where f.commkt_key = c.commkt_key and
                        b.formula_num = @buy_formula_num and b.formula_body_type = 'Q'
                        and b.formula_qty_pcnt_val > 0.0 and b.formula_num = f.formula_num
                        and b.formula_body_num = f.formula_body_num and
                        f.formula_comp_type = 'G' and t.formula_num = f.formula_num
                        and t.formula_body_num = f.formula_body_num and
                        t.formula_comp_num = f.formula_comp_num

                        if @term_count > 0
                        begin
                                select @accum_prd_ind = t.fcpt_roll_accum_prd_ind,
                                @rel_price_cal_ind = t.fcpt_rel_price_cal_days_ind,


	                                 @rel_days = t.fcpt_relative_days
                                from formula_comp_price_term t,
                                formula_component f, formula_body b, commodity_market c
	 			where f.commkt_key = c.commkt_key and
                                b.formula_num = @buy_formula_num and b.formula_body_type= 'Q'
                                and b.formula_qty_pcnt_val > 0.0 and b.formula_num =f.formula_num
                                and b.formula_body_num = f.formula_body_num and
				f.formula_comp_type = 'G' and t.formula_num = f.formula_num
                                and t.formula_body_num = f.formula_body_num and
                                t.formula_comp_num = f.formula_comp_num


                                if @accum_prd_ind = 'R' and @rel_price_cal_ind = 'PB' and @rel_days = 1
                                        select @prc_1_exch_roll_a = 'Y'
                                else


	                                         select @prc_1_exch_roll_a = 'N'
                        end /* there are terms on the quote */
                        else
                                select @prc_1_exch_roll_a = 'N'


	            select @quote_cmdty2 = c.cmdty_code, @quote_mkt2 = c.mkt_code,
                        @quote_prd2 = f.trading_prd, @quote_source2= f.price_source_code,
                        @prc_1_quote_ind_b = f.formula_comp_val_type
                        from formula_component f, formula_body b, commodity_market c
                        where f.commkt_key = c.commkt_key and
                        b.formula_num = @buy_formula_num and b.formula_body_type = 'Q'
                        and b.formula_qty_pcnt_val < 0.0 and b.formula_num = f.formula_num
                        and b.formula_body_num = f.formula_body_num and
                        f.formula_comp_type = 'G'

                        /* check roll term */



	            select @term_count = count(*) from formula_comp_price_term t,
                        formula_component f, formula_body b, commodity_market c
                        where f.commkt_key = c.commkt_key and
                        b.formula_num = @buy_formula_num and b.formula_body_type = 'Q'
                        and b.formula_qty_pcnt_val < 0.0 and b.formula_num = f.formula_num
                        and b.formula_body_num = f.formula_body_num and
                        f.formula_comp_type = 'G' and t.formula_num = f.formula_num
                        and t.formula_body_num = f.formula_body_num and
                        t.formula_comp_num = f.formula_comp_num

                        if @term_count > 0


	           begin
                                select @accum_prd_ind = t.fcpt_roll_accum_prd_ind,
                                @rel_price_cal_ind = t.fcpt_rel_price_cal_days_ind,
                                @rel_days = t.fcpt_relative_days


                                from formula_comp_price_term t,
                                formula_component f, formula_body b, commodity_market c
                                where f.commkt_key = c.commkt_key and
                                b.formula_num = @buy_formula_num and b.formula_body_type = 'Q'
                                and b.formula_qty_pcnt_val > 0.0 and b.formula_num = f.formula_num
                                and b.formula_body_num = f.formula_body_num and
                                f.formula_comp_type = 'G' and t.formula_num = f.formula_num
                                and t.formula_body_num = f.formula_body_num and
                                t.formula_comp_num = f.formula_comp_num

	                                 if @accum_prd_ind = 'R' and @rel_price_cal_ind = 'PB' and @rel_days = 1
                                        select @prc_1_exch_roll_b = 'Y'
                                else



	        select @prc_1_exch_roll_b = 'N'
                        end /* there are terms on the quote */
                        else
                                select @prc_1_exch_roll_b = 'N'

                        /* quote differential */


                        select @formula_diff1 = 0.0
                        select @formula_diff_str1 = '0.0'
                        select @formula_diff_str1 = formula_body_string
                        from formula_body
                        where formula_num = @buy_formula_num and formula_body_type = 'Q'
                        and formula_qty_pcnt_val > 0.0

                        select @diff_failure = 0
                        select @plus_position = charindex('+', @formula_diff_str1)

                        if @plus_position > 0
                        begin
                                select @formula_diff_str1 = substring(@formula_diff_str1,@plus_position + 1, len(@formula_diff_str1) - @plus_position)


      if not @formula_diff_str1 like '%Var%' and not @formula_diff_str1 like '%Quote%'
                                        select @formula_diff1 = convert(float,@formula_diff_str1)
                                else
                                        select @diff_failure = 1


                        end
                        else
                        begin
                                select @plus_position = charindex('-', @formula_diff_str1)
                                if @plus_position > 0


	                     begin
                                        select @formula_diff_str1 =substring(@formula_diff_str1, @plus_position + 1,
					len(@formula_diff_str1) -@plus_position)
                                        if not @formula_diff_str1 like '%Var%' and not @formula_diff_str1 like '%Quote%'
                                        begin
                                                select @formula_diff1 = -1.0 * convert(decimal(19,6), @formula_diff_str1)
                                                select @formula_diff_str1 = '-' + @formula_diff_str1
                                        end
                                        else
                                                select @diff_failure = 1
                                end


                                else
                                        select @formula_diff_str1 = '0.0'
                        end  /* minus differential */

                        /* quote differential */
                        select @formula_diff2 = 0.0
                        select @formula_diff_str2 = '0.0'

                        select @formula_diff_str2 = formula_body_string
                        from formula_body
                        where formula_num = @buy_formula_num and formula_body_type = 'Q'
                        and formula_qty_pcnt_val < 0.0

                        select @plus_position = charindex('+', @formula_diff_str2)


                        if @plus_position > 0


	           begin
                                select @formula_diff_str2 = substring(@formula_diff_str2,
				@plus_position + 1, len(@formula_diff_str2) - @plus_position)
      				if not @formula_diff_str2 like '%Var%' and not @formula_diff_str2 like '%Quote%'


	                       select @formula_diff2 = convert(float,@formula_diff_str2)
                                else
                                        select @diff_failure = 1
                        end
                        else


	                   begin
                                select @plus_position = charindex('-', @formula_diff_str2)
                                if @plus_position > 0
                                begin


	 				select @formula_diff_str2 = substring(@formula_diff_str2, @plus_position + 1,
					len(@formula_diff_str2) - @plus_position)
                                        if not @formula_diff_str2 like '%Var%' and not @formula_diff_str2 like '%Quote%'


	     begin
                                                select @formula_diff2 = -1.0 * convert(float, @formula_diff_str2)
                                                select @formula_diff_str2 = '-' +ltrim(@formula_diff_str2)


	                       end
                                        else
                                                select @diff_failure = 1
                                end
                                else


	             select @formula_diff_str2 = '0.0'
                        end  /* minus differential */
                        /* set quote data */
                        if @diff_failure = 0
                        begin


	 update #contract_feed set prc_1_pricediff = convert(varchar(255),
				convert(decimal(19,6), @formula_diff1 - @formula_diff2)), prc_1_curve =
				@quote_cmdty1 + '/' +@quote_mkt1 + '/' + @quote_source1
        			where trade_num = @trade_num and order_num = @order_num and
				item_num =@item_num

                                if @prc_1_quote_ind_a in ('L', 'H')
                                        update #contract_feed set
					prc_1_curve = prc_1_curve + '/' + @prc_1_quote_ind_a


					where trade_num = @trade_num and order_num = @order_num and item_num =
					@item_num
                                	update #contract_feed set prc_1_curve = prc_1_curve + ' - ' + @quote_cmdty2 +
						'/' + @quote_mkt2 + '/' + @quote_source2
        				where trade_num = @trade_num and order_num = @order_num and
					item_num =@item_num
                                if @prc_1_quote_ind_b in ('L', 'H')
                                        update #contract_feed set prc_1_curve = prc_1_curve + '/' +
                                                @prc_1_quote_ind_b
					where trade_num = @trade_num and order_num = @order_num and item_num = @item_num
                        end
                        else


	                     update #contract_feed set prc_1_pricediff = '???? unknown price diff'
                                where trade_num = @trade_num and order_num = @order_num
				and item_num = @item_num
                        if @quote_prd1 = @quote_prd2
                                update #contract_feed set prc_1_contract_month = @quote_prd1,
				prc_1_exch_roll_a = @prc_1_exch_roll_a, prc_1_exch_roll_b =@prc_1_exch_roll_b
                                where trade_num = @trade_num
                                and order_num = @order_num
				and item_num = @item_num
                        else
                                update #contract_feed set prc_1_contract_month = 'VAR'
                                where trade_num = @trade_num and order_num = @order_num and item_num = @item_num

                        end
                end     /* spread buy formula */

                select @sell_formula_num =  formula_comp_ref
                from formula_component
                where formula_num = @formula_num
                and formula_comp_name = 'SwapSellFloat'

                select @qty_formula_body_count = count(*) from formula_body
                where formula_num = @sell_formula_num and formula_body_type = 'Q'

	               if @qty_formula_body_count > 1
                        select @is_spread = 'Y'
                else
                        select @is_spread = 'N'

                if @is_spread = 'N'
                begin



	        select @quote_cmdty2 = c.cmdty_code, @quote_mkt2 = c.mkt_code,
  	        @quote_prd2 = f.trading_prd, @quote_source2 = f.price_source_code,
                        @prc_2_quote_ind_a = f.formula_comp_val_type
                        from formula_component f, formula_body b, commodity_market c
                        where f.commkt_key = c.commkt_key and
                        b.formula_num = @sell_formula_num and b.formula_body_type = 'Q'
                        and b.formula_qty_pcnt_val > 0.0 and b.formula_num = f.formula_num
                        and b.formula_body_num = f.formula_body_num and
                        f.formula_comp_type = 'G'

                        /* check roll term */

                        select @term_count = count(*) from formula_comp_price_term t,
                        formula_component f, formula_body b, commodity_market c
                        where f.commkt_key = c.commkt_key and
                        b.formula_num = @sell_formula_num and b.formula_body_type = 'Q'
                        and b.formula_qty_pcnt_val > 0.0 and b.formula_num = f.formula_num
                        and b.formula_body_num = f.formula_body_num and
                        f.formula_comp_type = 'G' and t.formula_num = f.formula_num
                        and t.formula_body_num = f.formula_body_num and
                        t.formula_comp_num = f.formula_comp_num

                        if @term_count > 0

                        begin
                                select @accum_prd_ind = t.fcpt_roll_accum_prd_ind,
                                @rel_price_cal_ind = t.fcpt_rel_price_cal_days_ind,
                                @rel_days = t.fcpt_relative_days
    	                        from formula_comp_price_term t,
                                formula_component f, formula_body b, commodity_market c
                                where f.commkt_key = c.commkt_key and
                                b.formula_num = @sell_formula_num and b.formula_body_type = 'Q'
                                and b.formula_qty_pcnt_val > 0.0 and b.formula_num = f.formula_num
                                and b.formula_body_num = f.formula_body_num and


	                      f.formula_comp_type = 'G' and t.formula_num = f.formula_num
                                and t.formula_body_num = f.formula_body_num and
                                t.formula_comp_num = f.formula_comp_num



	                    if @accum_prd_ind = 'R' and @rel_price_cal_ind = 'PB' and @rel_days = 1
                                        select @prc_2_exch_roll_a = 'Y'
                                else
                                        select @prc_2_exch_roll_a = 'N'
                        end /* there are terms on the quote */
                        else
                                select @prc_2_exch_roll_a = 'N'
                        /* quote differential */


	        select @formula_diff2 = 0.0
                        select @formula_diff_str2 = '0.0'


 			select @formula_diff_str2 = formula_body_string
                        from formula_body
                        where formula_num = @sell_formula_num and formula_body_type in ('P', 'Q')

                        select @diff_failure = 0
                        select @plus_position = charindex('+', @formula_diff_str2)

                        if @plus_position > 0
	    	        begin
                                select @formula_diff_str2 =
				substring(@formula_diff_str2,
				@plus_position + 1, len(@formula_diff_str2) - @plus_position)
      				if not @formula_diff_str2 like '%Var%' and not @formula_diff_str2 like '%Quote%'


	                         select @formula_diff2 = convert(float,@formula_diff_str2)
                                else
                                        select @diff_failure = 1
                        end
                        else


	                     begin
                                select @plus_position = charindex('-', @formula_diff_str2)
                                if @plus_position > 0
                                begin
           			select @formula_diff_str2 =
					substring(@formula_diff_str2, @plus_position + 1,
					len(@formula_diff_str2) - @plus_position)
                                        if not @formula_diff_str2 like '%Var%' and not @formula_diff_str2 like '%Quote%'
           			            begin
                                                select @formula_diff2 = -1.0 * convert(float,@formula_diff_str2)
                                                select @formula_diff_str2 = '-' + @formula_diff_str2
           	                       end
                                        else
                                                select @diff_failure = 1
                                end
                                else


	                select @formula_diff_str2 = '0.0'
                        end  /* minus differential */

                        /* set quote data */
                        if @diff_failure = 0
                        begin


	              update #contract_feed set prc_2_payor_sn = cpty_sn,
                                prc_2_ccy_code = prc_1_ccy_code, prc_2_uom_code = prc_1_uom_code,
                                prc_2_start_dt = prc_1_start_dt, prc_2_end_dt = prc_1_end_dt,
                                prc_2_pricediff = @formula_diff_str2, prc_2_fixed_flag = 'N',
				prc_2_curve = @quote_cmdty2 + '/' + @quote_mkt2 + '/' + @quote_source2,
				prc_2_contract_month = @quote_prd2, prc_2_exch_roll_a = @prc_2_exch_roll_a
                                where trade_num = @trade_num and
				order_num = @order_num and item_num = @item_num
                                if @prc_2_quote_ind_a in ('L', 'H')
                                        update #contract_feed set prc_2_curve = prc_2_curve +
                                        '/' + @prc_2_quote_ind_a
                        end
                        else
                                update #contract_feed set prc_2_pricediff = '???? unknown price diff'
                                where trade_num = @trade_num and order_num = @order_num
				and item_num = @item_num


                end /* single sell quote */
                else /* spread sell quotes */
	 				begin
                        select @quote_uom1 = formula_qty_uom_code,
                        @quote_qty1 = abs(formula_qty_pcnt_val)
                        from formula_body where formula_num = @sell_formula_num
                        and formula_body_type = 'Q' and formula_qty_pcnt_val > 0.0

                        select @quote_uom2 = formula_qty_uom_code,
                        @quote_qty2 = abs(formula_qty_pcnt_val)
                        from formula_body where formula_num = @sell_formula_num
                        and formula_body_type = 'Q' and formula_qty_pcnt_val < 0.0


                        if @quote_uom1 != @quote_uom2 or @quote_qty1 != @quote_qty2
                                update #contract_feed set prc_1_curve = '????'
                                where trade_num = @trade_num and order_num = @order_num
				and item_num = @item_num
                        else
                        begin  /* equal qtys for spread */



	       select @quote_cmdty1 = c.cmdty_code, @quote_mkt1 = c.mkt_code,
                        @quote_prd1 = f.trading_prd, @quote_source1 = f.price_source_code,
                        @prc_2_quote_ind_a = f.formula_comp_val_type
	     			from formula_component f, formula_body b, commodity_market c
	                where f.commkt_key = c.commkt_key and
                        b.formula_num = @sell_formula_num and b.formula_body_type = 'Q'
                        and b.formula_qty_pcnt_val > 0.0 and b.formula_num = f.formula_num
                        and b.formula_body_num = f.formula_body_num and
                        f.formula_comp_type = 'G'

                        /* check roll term */

                     	select @term_count = count(*) from formula_comp_price_term t,
                        formula_component f, formula_body b, commodity_market c
                        where f.commkt_key = c.commkt_key and
                        b.formula_num = @sell_formula_num and b.formula_body_type = 'Q'
                        and b.formula_qty_pcnt_val > 0.0 and b.formula_num = f.formula_num
                        and b.formula_body_num = f.formula_body_num and
                        f.formula_comp_type = 'G' and t.formula_num = f.formula_num
                        and t.formula_body_num = f.formula_body_num and
                        t.formula_comp_num = f.formula_comp_num

                        if @term_count > 0
	     				begin
                                select @accum_prd_ind = t.fcpt_roll_accum_prd_ind,
                                @rel_price_cal_ind = t.fcpt_rel_price_cal_days_ind,
                                @rel_days = t.fcpt_relative_days
	                            from formula_comp_price_term t,
                                formula_component f, formula_body b, commodity_market c
                                where f.commkt_key = c.commkt_key and
                                	b.formula_num = @sell_formula_num and b.formula_body_type = 'Q'
                                and b.formula_qty_pcnt_val > 0.0 and
								b.formula_num =f.formula_num
                                and b.formula_body_num = f.formula_body_num and
	                                 f.formula_comp_type = 'G' and t.formula_num = f.formula_num
                                and t.formula_body_num = f.formula_body_num and t.formula_comp_num = f.formula_comp_num


                                if @accum_prd_ind = 'R' and @rel_price_cal_ind = 'PB' and @rel_days = 1
                                        select @prc_2_exch_roll_a = 'Y'
                                else
							select @prc_2_exch_roll_a = 'N'
                        end /* there are terms on the quote */
                        else
                                select @prc_2_exch_roll_a = 'N'

                        select @quote_cmdty2 = c.cmdty_code, @quote_mkt2 = c.mkt_code,
                        @quote_prd2 = f.trading_prd, @quote_source2= f.price_source_code,
                        @prc_2_quote_ind_b = f.formula_comp_val_type
                        from formula_component f, formula_body b, commodity_market c
                        where f.commkt_key = c.commkt_key and
                        b.formula_num = @sell_formula_num and b.formula_body_type = 'Q'
                        and b.formula_qty_pcnt_val < 0.0 and b.formula_num = f.formula_num
                        and b.formula_body_num = f.formula_body_num and
                        f.formula_comp_type = 'G'

                        /* check roll term */

                        select @term_count = count (*) from formula_comp_price_term t,
                        formula_component f, formula_body b, commodity_market c
                        where f.commkt_key = c.commkt_key and
                        b.formula_num = @sell_formula_num and b.formula_body_type = 'Q'
                        and b.formula_qty_pcnt_val < 0.0 and b.formula_num = f.formula_num
                        and b.formula_body_num = f.formula_body_num and
                        f.formula_comp_type = 'G' and t.formula_num = f.formula_num
                        and t.formula_body_num = f.formula_body_num and
                        t.formula_comp_num = f.formula_comp_num

                        if @term_count > 0
                        begin


	               select @accum_prd_ind = t.fcpt_roll_accum_prd_ind,
                                @rel_price_cal_ind = t.fcpt_rel_price_cal_days_ind,
                                @rel_days = t.fcpt_relative_days
                                from formula_comp_price_term t,
                                formula_component f, formula_body b, commodity_market c
                                where f.commkt_key = c.commkt_key and
                                b.formula_num = @sell_formula_num and b.formula_body_type= 'Q'
                                and b.formula_qty_pcnt_val > 0.0 and b.formula_num =f.formula_num
                                and b.formula_body_num = f.formula_body_num and
                                f.formula_comp_type = 'G' and t.formula_num = f.formula_num
                                and t.formula_body_num = f.formula_body_num and
                                t.formula_comp_num = f.formula_comp_num


                                if @accum_prd_ind = 'R' and @rel_price_cal_ind = 'PB' and @rel_days = 1
                                        select @prc_2_exch_roll_b = 'Y'
                                else
                                        select @prc_2_exch_roll_b = 'N'


                        end /* there are terms on the quote */
                        else
                                select @prc_2_exch_roll_b = 'N'

                        /* quote differential */
                        select @formula_diff1 = 0.0

                        select @formula_diff_str1 = '0.0'

                        select @formula_diff_str1 = formula_body_string
                        from formula_body
                        where formula_num = @sell_formula_num and formula_body_type = 'Q'
                        and formula_qty_pcnt_val > 0.0

                        select @diff_failure = 0
                        select @plus_position = charindex('+', @formula_diff_str1)

	      if @plus_position > 0
                        begin
                                select @formula_diff_str1 = substring(@formula_diff_str1,
				@plus_position + 1, len(@formula_diff_str1) - @plus_position)
      				if not @formula_diff_str1 like '%Var%' and not @formula_diff_str1 like '%Quote%'
                                        select @formula_diff1 = convert(float,@formula_diff_str1)
                                else
                                        select @diff_failure = 1
                         	end
                        else
                        begin
                                select @plus_position = charindex('-', @formula_diff_str1)
                                if @plus_position > 0
                                begin
                                        select @formula_diff_str1 =
					substring(@formula_diff_str1, @plus_position + 1,
					len(@formula_diff_str1) -@plus_position)
                                        if not @formula_diff_str1 like '%Var%' and not @formula_diff_str1 like '%Quote%'
                                        begin
                                                select @formula_diff1 = -1.0 * convert(float,@formula_diff_str1)
                                                select @formula_diff_str1 = '-' + @formula_diff_str1
                                        end
                                        else
                                                select @diff_failure = 1
                                end


	           else
                                        select @formula_diff_str1 = '0.0'
                        end  /* minus differential */

                        /* quote differential */

 			select @formula_diff2 = 0.0


	          select @formula_diff_str2 = '0.0'

                        select @formula_diff_str2 = formula_body_string
                        from formula_body
                        where formula_num = @sell_formula_num and formula_body_type = 'Q'
                        and formula_qty_pcnt_val < 0.0

                        select @plus_position = charindex('+', @formula_diff_str2)

                        if @plus_position > 0
                        begin


	         select @formula_diff_str2 = substring(@formula_diff_str2,
				@plus_position + 1, len(@formula_diff_str2) - @plus_position)
      				if not @formula_diff_str2 like '%Var%' and not @formula_diff_str2 like '%Quote%'
                                        select @formula_diff2 = convert(float, @formula_diff_str2)
                                else
                                        select @diff_failure = 1
                        end
                        else
                        begin
	                  select @plus_position = charindex('-', @formula_diff_str2)
                                if @plus_position > 0
                                begin

                                        select @formula_diff_str2 =
					substring(@formula_diff_str2, @plus_position + 1,
					len(@formula_diff_str2) - @plus_position)
                                        if not @formula_diff_str2 like '%Var%' and not @formula_diff_str2 like '%Quote%'
                                        begin
	                              select @formula_diff2 = -1.0 * convert(float,@formula_diff_str2)
                                                select @formula_diff_str2 = '-' + @formula_diff_str2
                                        end


	                               else
                                                select @diff_failure = 1
                                end
                                else
                                        select @formula_diff_str2 = '0.0'
                        end  /* minus differential */
                        /* set quote data */
                        if @diff_failure = 0
                        begin
                        update #contract_feed set  prc_2_payor_sn = cpty_sn,
                                prc_2_ccy_code = prc_1_ccy_code, prc_2_uom_code =prc_1_uom_code,
                                prc_2_start_dt = prc_1_start_dt, prc_2_end_dt = prc_1_end_dt,
				prc_2_pricediff = convert(varchar(255), @formula_diff1 - @formula_diff2),
				prc_2_curve = @quote_cmdty1 + '/' + @quote_mkt1 + '/' + @quote_source1
        			where trade_num = @trade_num and order_num = @order_num and item_num =@item_num
                                if @prc_2_quote_ind_a in ('L', 'H')
                                        update #contract_feed set prc_2_curve = prc_2_curve +'/'
                                        + @prc_2_quote_ind_a where
					trade_num = @trade_num and order_num = @order_num and item_num =@item_num
                                update #contract_feed set prc_2_curve = prc_2_curve + ' - ' + @quote_cmdty2 + '/' +
				@quote_mkt2 + '/' + @quote_source2
        			where trade_num = @trade_num and order_num = @order_num and item_num=@item_num
                                if @prc_2_quote_ind_b in ('L', 'H')
                                        update #contract_feed set prc_2_curve = prc_2_curve +'/'
                                        + @prc_2_quote_ind_b where trade_num = @trade_num and
					order_num = @order_num and item_num =@item_num

                        end
                        else
                                update #contract_feed set prc_2_pricediff = '???? unknown price diff'
	                         where trade_num = @trade_num and order_num = @order_num
				and item_num = @item_num
                        	if @quote_prd1 = @quote_prd2
                                update #contract_feed set prc_2_contract_month = @quote_prd2,
				prc_2_exch_roll_a = @prc_2_exch_roll_a, prc_2_exch_roll_b = @prc_2_exch_roll_b
                                where trade_num = @trade_num and order_num = @order_num
				and item_num = @item_num
                        else


	                          update #contract_feed set prc_2_contract_month = 'VAR'
                                where trade_num = @trade_num and order_num = @order_num
				and item_num = @item_num
                        end
                end

	  /* spread sell quotes */

                /* payment term */
                select @settlement_date = '20' + convert(char(6), max(c.cost_due_date), 12),
                @cost_book_curr_code = c.cost_book_curr_code,
                @cost_price_curr_code = c.cost_price_curr_code
                from cost c
                where c.cost_owner_code = 'AC'
                and c.cost_owner_key1=@trade_num
                and c.cost_owner_key2=@order_num
                and c.cost_owner_key3=@item_num
                group by c.cost_book_curr_code, c.cost_price_curr_code
-- and c.cost_due_date = (select max(c2.cost_due_date) from cost c2 where c2.cost_owner_code = 'AC' and c2.cost_owner_key1=@trade_num and c2.cost_owner_key2=@order_num and c2.cost_owner_key3=@item_num)
                --group by cost_owner_code, cost_owner_key1, cost_owner_key2,
                --cost_owner_key3
                --having cost_due_date = max(cost_due_date)

                if @cost_book_curr_code is null
                        select @cost_book_curr_code = @cost_price_curr_code



	       select @payment_term = pay_term_code, @pay_days = pay_days
                        from trade_item_cash_phy
                        where trade_num = @trade_num and order_num = @order_num and
			item_num = @item_num
                update #contract_feed set swap_com_prc_flag = @swap_com_prc_flag,
		sttl_model = @payment_term, sttl_days_offset = @pay_days,
                sttl_dt_final = @settlement_date, sttl_ccy_code = @cost_book_curr_code
                where trade_num = @trade_num
	 			and order_num = @order_num and item_num = @item_num
        end    /* float vs. float swap */

        if not @inst_type = 'SWAPFLT'
        begin
        if @is_unknown_spread= 'N'
        begin
                if @is_spread = 'N'
	          begin
                        set rowcount 1

                        select @quote_cmdty1 = c.cmdty_code, @quote_mkt1 = c.mkt_code,
                        @quote_prd1 = f.trading_prd, @quote_source1 = f.price_source_code,
	                @prc_1_quote_ind_a = f.formula_comp_val_type
                        from formula_component f, quote_pricing_period qpp, commodity_market c
                        where qpp.trade_num = @trade_num and qpp.order_num = @order_num and
	                       qpp.item_num = @item_num and f.commkt_key = c.commkt_key and
                        f.formula_num = qpp.formula_num and f.formula_body_num =qpp.formula_body_num
                        and f.formula_comp_num = qpp.formula_comp_num

                        set rowcount 0

                        if @formula_type = 'T' and @is_colonial_pipeline = 'Y' and @quote_prd1 like 'SPOT%'

                /* colonial pipeline deal requires calendar month rather than nearby periods */
                        begin
                                select @current_period = min(p.trading_prd) from
                                trading_period p, commodity_market cm
                                where cm.cmdty_code = @quote_cmdty1 and cm.mkt_code =
                                @quote_mkt1 and p.commkt_key = cm.commkt_key and
                                p.last_trade_date >= dateadd(dd, datediff(dd, @pricing_start_date1, @pricing_end_date1)/2, @pricing_start_date1)
                                if @current_period is not null
                                begin
                                        select @quote1_nearby = convert(int,substring(@quote_prd1, 5, 2))
	     								select @quote1_month = convert(int,substring(@current_period, 5, 2))
                                        select @quote1_year = convert(int,substring(@current_period, 1, 4))
                                        select @quote1_month = @quote1_month + @quote1_nearby - 1

                                if @quote1_month > 12
                                        begin
                                                select @quote1_month = @quote1_month - 12
	                       select @quote1_year = @quote1_year + 1
                                        end
                                        if @quote1_month > 9
                                                select @quote_prd1 = convert(char(4), @quote1_year) +
						convert(char(2), @quote1_month)
                                        else
                                                select @quote_prd1 = convert(char(4),@quote1_year) + '0' +
						convert(char(1), @quote1_month)
                                end

                        end

                        /* check roll term */

                        select @term_count = count(*) from formula_comp_price_term t,
                        quote_pricing_period qpp
                        where t.formula_num = qpp.formula_num and
                        t.formula_body_num = qpp.formula_body_num and
                        t.formula_comp_num = qpp.formula_comp_num
                        and qpp.trade_num = @trade_num and qpp.order_num = @order_num
                        and qpp.item_num = @item_num


        		if @term_count > 0
                        begin
                                select @accum_prd_ind = t.fcpt_roll_accum_prd_ind,
                                @rel_price_cal_ind = t.fcpt_rel_price_cal_days_ind,
                                @rel_days = t.fcpt_relative_days
                                from formula_comp_price_term t,
                             	quote_pricing_period qpp
                                where t.formula_num = qpp.formula_num and
                                t.formula_body_num = qpp.formula_body_num and
                                t.formula_comp_num = qpp.formula_comp_num
                                and qpp.trade_num = @trade_num and qpp.order_num = @order_num
                                and qpp.item_num = @item_num

                                if @accum_prd_ind = 'R' and @rel_price_cal_ind = 'PB'
	  								and @rel_days = 1
                                        select @prc_1_exch_roll_a = 'Y'
                                else
                                        select @prc_1_exch_roll_a = 'N'
                        end /* there are terms on the quote */
                        else
                                select @prc_1_exch_roll_a = 'N'
                        /* quote differential */
                        select @formula_diff1 = 0.0
                        select @formula_diff_str1 = '0.0'

                        select @formula_diff_str1 = formula_body_string
                        from formula_body
                        where formula_num = @formula_num and formula_body_type in ('P', 'Q')
	              		select @diff_failure = 0
                        select @plus_position = charindex('+', @formula_diff_str1)

                        if @plus_position > 0
                        begin
                                select @formula_diff_str1 = substring(@formula_diff_str1,
				@plus_position + 1, len(@formula_diff_str1) - @plus_position)
      				if not @formula_diff_str1 like '%Var%' and not @formula_diff_str1 like '%Quote%'
                                        select @formula_diff1 = convert(float,@formula_diff_str1)
                                else
                                        select @diff_failure = 1
                        end
                        else
                        begin
                                select @plus_position = charindex('-', @formula_diff_str1)
                                if @plus_position > 0
                                begin
                                        select @formula_diff_str1 = substring(@formula_diff_str1, @plus_position + 1,
					len(@formula_diff_str1) - @plus_position)
                                        if not @formula_diff_str1 like '%Var%' and not @formula_diff_str1 like '%Quote%'
                                        begin
                                                select @formula_diff1 = -1.0 * convert(float,@formula_diff_str1)
                                                select @formula_diff_str1 = '-' + ltrim(@formula_diff_str1)
                                        end
                                      else
                                                select @diff_failure = 1
                                end
                                else
                                        select @formula_diff_str1 = '0.0'


	        end  /* minus differential */

                        /* set quote data */
                        if @diff_failure = 0
                        begin
                                if @inst_type like 'OTC%'
	              update #feed_option set /* optn_strike_pricediff= @formula_diff_str1,  */
					optn_strike_curve = @quote_cmdty1 + '/' + @quote_mkt1 + '/' +
					@quote_source1, optn_strike_contract_month = @quote_prd1,
					optn_strike_exch_roll_a = @prc_1_exch_roll_a
        				where trade_num = @trade_num and order_num = @order_num and item_num = @item_num
                                else
                                        update #contract_feed set prc_1_pricediff =
					convert(varchar(20), convert(decimal(19,6), @formula_diff_str1)),
					prc_1_curve = @quote_cmdty1 + '/' + @quote_mkt1 + '/' +
					@quote_source1, prc_1_contract_month = @quote_prd1,
					prc_1_exch_roll_a = @prc_1_exch_roll_a
        				where trade_num = @trade_num and order_num = @order_num and
					item_num =@item_num

                                if @prc_1_quote_ind_a in ('L', 'H')
                                begin
                                        if @inst_type like 'OTC%'


                                                update #feed_option set optn_strike_curve =
                                                optn_strike_curve + '/' + @prc_1_quote_ind_a
                                                where trade_num = @trade_num and order_num = @order_num and
 						item_num = @item_num
                                        else
                                                update #contract_feed set prc_1_curve = prc_1_curve + '/' +
						@prc_1_quote_ind_a
                                                where trade_num = @trade_num and order_num = @order_num and
						item_num = @item_num
                                end
                        end
                        else


	                begin

        		    if @inst_type like 'OTC%'
                                        update #feed_option set optn_strike_curve= '???? unknown price diff'
                                else
	    update #contract_feed set prc_1_curve = '???? unknownprice diff'
                                where trade_num = @trade_num and order_num = @order_num and item_num = @item_num
                        end
                end /* not spread swap */
                else
                begin /* spread swap */

                        select @quote_cmdty1 = c.cmdty_code, @quote_mkt1 = c.mkt_code,
                        @quote_prd1 = f.trading_prd, @quote_source1 = f.price_source_code,
	                        @prc_1_quote_ind_a = f.formula_comp_val_type
                        from formula_component f, formula_body b, commodity_market c
                        where f.commkt_key = c.commkt_key and
                        b.formula_num = @formula_num and b.formula_body_type = 'Q'
                        and b.formula_qty_pcnt_val > 0.0 and b.formula_num = f.formula_num
                        and b.formula_body_num = f.formula_body_num and
                        f.formula_comp_type = 'G'

                        /* check roll term */

                        select @term_count = count(*) from formula_comp_price_term t,
                        formula_component f, formula_body b, commodity_market c
                 		where f.commkt_key = c.commkt_key and
                        b.formula_num = @formula_num and b.formula_body_type = 'Q'
                        and b.formula_qty_pcnt_val > 0.0 and b.formula_num = f.formula_num
                        and b.formula_body_num = f.formula_body_num and
                        f.formula_comp_type = 'G' and t.formula_num = f.formula_num
                        and t.formula_body_num = f.formula_body_num and
                        t.formula_comp_num = f.formula_comp_num

                        if @term_count > 0
                        begin
                                select @accum_prd_ind = t.fcpt_roll_accum_prd_ind,
                                @rel_price_cal_ind = t.fcpt_rel_price_cal_days_ind,
                                @rel_days = t.fcpt_relative_days
                                from formula_comp_price_term t,
                                formula_component f, formula_body b, commodity_market c
                     			where f.commkt_key = c.commkt_key and
                                b.formula_num = @formula_num and b.formula_body_type = 'Q'
                                and b.formula_qty_pcnt_val > 0.0 and b.formula_num = f.formula_num
           						and b.formula_body_num = f.formula_body_num and
                                f.formula_comp_type = 'G' and t.formula_num = f.formula_num
                                and t.formula_body_num = f.formula_body_num and
								t.formula_comp_num = f.formula_comp_num


                                if @accum_prd_ind = 'R' and @rel_price_cal_ind = 'PB' and @rel_days = 1
                                        select @prc_1_exch_roll_a = 'Y'
                          		else
                                        select @prc_1_exch_roll_a = 'N'
                        end /* there are terms on the quote */

                else
                                select @prc_1_exch_roll_a = 'N'




	                 select @quote_cmdty2 = c.cmdty_code, @quote_mkt2 = c.mkt_code,
                        @quote_prd2 = f.trading_prd, @quote_source2= f.price_source_code,
                        @prc_1_quote_ind_b = f.formula_comp_val_type
	                from formula_component f, formula_body b, commodity_market c
                        where f.commkt_key = c.commkt_key and
                        b.formula_num = @formula_num and b.formula_body_type = 'Q'
                        and b.formula_qty_pcnt_val < 0.0 and b.formula_num = f.formula_num
                        and b.formula_body_num = f.formula_body_num and
                        f.formula_comp_type = 'G'

                        /* check roll term */



	             select @term_count = count(*) from formula_comp_price_term t,
                        formula_component f, formula_body b, commodity_market c
                        where f.commkt_key = c.commkt_key and
                        b.formula_num = @formula_num and b.formula_body_type = 'Q'
                        and b.formula_qty_pcnt_val < 0.0 and b.formula_num = f.formula_num
                        and b.formula_body_num = f.formula_body_num and
                        f.formula_comp_type = 'G' and t.formula_num = f.formula_num
                        and t.formula_body_num = f.formula_body_num and
                        t.formula_comp_num = f.formula_comp_num

                        if @term_count > 0
                  			begin
                                select @accum_prd_ind = t.fcpt_roll_accum_prd_ind,
                                @rel_price_cal_ind = t.fcpt_rel_price_cal_days_ind,
                                @rel_days = t.fcpt_relative_days
	                               from formula_comp_price_term t,
                                formula_component f, formula_body b, commodity_market c
                                where f.commkt_key = c.commkt_key and
								b.formula_num = @formula_num and b.formula_body_type = 'Q'
                                and b.formula_qty_pcnt_val < 0.0 and b.formula_num =f.formula_num
                                and b.formula_body_num = f.formula_body_num and
	                        	f.formula_comp_type = 'G' and t.formula_num = f.formula_num
                                and t.formula_body_num = f.formula_body_num and
                                t.formula_comp_num = f.formula_comp_num

	                            if @accum_prd_ind = 'R' and @rel_price_cal_ind = 'PB' and @rel_days = 1
                                        select @prc_1_exch_roll_b = 'Y'
                                else
                                        select @prc_1_exch_roll_b = 'N'
                        end /* there are terms on the quote */
                        else
				select @prc_1_exch_roll_b = 'N'


 			/* quote differential */
                        select @formula_diff1 = 0.0


                        select @formula_diff_str1 = '0.0'

                        select @formula_diff_str1 = formula_body_string
                        from formula_body
                        where formula_num = @formula_num and formula_body_type = 'Q'
                        and formula_qty_pcnt_val > 0.0

                        select @diff_failure = 0
                        select @plus_position = charindex('+', @formula_diff_str1)

                        if @plus_position > 0
                        begin
                                select @formula_diff_str1 = substring(@formula_diff_str1,
				@plus_position + 1, len(@formula_diff_str1) - @plus_position)
      				if not @formula_diff_str1 like '%Var%' and not @formula_diff_str1 like '%Quote%'
                                        select @formula_diff1 = convert(float,@formula_diff_str1)
                                else
                                        select @diff_failure = 1
                        end


	          else
                        begin
                                select @plus_position = charindex('-', @formula_diff_str1)
                                if @plus_position > 0
                                begin


	                       select @formula_diff_str1 =substring(@formula_diff_str1, @plus_position + 1,
					len(@formula_diff_str1) -@plus_position)
                                        if not @formula_diff_str1 like '%Var%' and not @formula_diff_str1 like '%Quote%'


	                         begin
                                                select @formula_diff1 = -1.0 * convert(float,@formula_diff_str1)
                                                select @formula_diff_str1 = '-' +@formula_diff_str1


	                                   end
                                        else
                                                select @diff_failure = 1
                                end
                                else


	                         select @formula_diff_str1 = '0.0'
                        end  /* minus differential */

                        /* quote differential */
                        select @formula_diff2 = 0.0
                        select @formula_diff_str2 = '0.0'

                        select @formula_diff_str2 = formula_body_string
                        from formula_body
                        where formula_num = @formula_num and formula_body_type = 'Q'
                   		and formula_qty_pcnt_val < 0.0

                        select @plus_position = charindex('+', @formula_diff_str2)

                        if @plus_position > 0
                        begin
                                select @formula_diff_str2 = substring(@formula_diff_str2,
				@plus_position + 1, len(@formula_diff_str2) - @plus_position)
      				if not @formula_diff_str2 like '%Var%' and not @formula_diff_str2 like '%Quote%'
                                        select @formula_diff2 = convert(float,@formula_diff_str2)
                                else
                                        select @diff_failure = 1
                        end
                        else
                        begin
                                select @plus_position = charindex('-', @formula_diff_str2)
                                if @plus_position > 0
                                begin
                                        select @formula_diff_str2 =
					substring(@formula_diff_str2, @plus_position + 1,
					len(@formula_diff_str2) -@plus_position)
                                        if not @formula_diff_str2 like '%Var%' and not @formula_diff_str2 like '%Quote%'
                                        begin
                                            select @formula_diff2 = -1.0 * convert(float,@formula_diff_str2)
                                            select @formula_diff_str2 = '-' + ltrim(@formula_diff_str2)
                                        end
										else
                                                select @diff_failure = 1
                                end
                        end  /* minus differential */
                        /* set quote data */


	    			if @diff_failure = 0
                        begin
                                if @inst_type like 'OTC%'
                                begin
                                        update #feed_option set optn_strike_pricediff=
					convert(varchar(255), @formula_diff1 - @formula_diff2),
					optn_strike_curve = @quote_cmdty1 + '/'
					+ @quote_mkt1 + '/' + @quote_source1, optn_strike_exch_roll_a =
					@prc_1_exch_roll_a, optn_strike_exch_roll_b = @prc_1_exch_roll_b
	 				where trade_num = @trade_num and order_num = @order_num and
					item_num = @item_num
                                        if @prc_1_quote_ind_a in ('L', 'H')
                                                update #feed_option set
 						optn_strike_curve = optn_strike_curve + '/' + @prc_1_quote_ind_a
						where trade_num = @trade_num and order_num = @order_num and
						item_num = @item_num
                                        update #feed_option set optn_strike_curve = optn_strike_curve + ' - ' +
						@quote_cmdty2 + '/' + @quote_mkt2 + '/' + @quote_source2
        				where trade_num = @trade_num and order_num = @order_num and
						item_num = @item_num
                                        if @prc_1_quote_ind_b in ('L', 'H')
                                                update #feed_option set optn_strike_curve = optn_strike_curve + '/'
                                                + @prc_1_quote_ind_b where trade_num = @trade_num and
						order_num = @order_num and item_num = @item_num
                                end
                                else
                                begin
                                        update #contract_feed set prc_1_pricediff =
					convert(varchar(255), convert(decimal(19,6), @formula_diff1 - @formula_diff2)),
					prc_1_curve = @quote_cmdty1 + '/' + @quote_mkt1 + '/' + @quote_source1,
					prc_1_exch_roll_a = @prc_1_exch_roll_a, prc_1_exch_roll_b = @prc_1_exch_roll_b
        			where trade_num = @trade_num and order_num = @order_num and
					item_num = @item_num
                                        if @prc_1_quote_ind_a in ('L', 'H')
                                                update #contract_feed
						set prc_1_curve = prc_1_curve + '/' + @prc_1_quote_ind_a
						where trade_num = @trade_num and order_num = @order_num and
						item_num = @item_num
                                        update #contract_feed set prc_1_curve =
					prc_1_curve + ' - ' + @quote_cmdty2 + '/' + @quote_mkt2 + '/' + @quote_source2
        				where trade_num = @trade_num and order_num = @order_num and item_num = @item_num
                                        if @prc_1_quote_ind_b in ('L', 'H')


	                       update #contract_feed set prc_1_curve = prc_1_curve + '/'
                                                + @prc_1_quote_ind_b
						where trade_num = @trade_num and order_num = @order_num and
						item_num = @item_num


	                              end
                        end
                        else
                                if @inst_type like 'OTC%'
                                        update #feed_option
                                        set optn_strike_curve = '???? unknown price diff'
                                	where trade_num = @trade_num and order_num = @order_num
					and item_num = @item_num
                                else
                                        update #contract_feed set prc_1_curve =  '???? unknown price diff'
                                	where trade_num = @trade_num and order_num = @order_num
					and item_num = @item_num
                        if @quote_prd1 = @quote_prd2
                                update #contract_feed set prc_1_contract_month = @quote_prd1
                                where trade_num = @trade_num and order_num = @order_num
				and item_num = @item_num
                        else
                                update #contract_feed set prc_1_contract_month = 'VAR'
 				where trade_num = @trade_num and order_num = @order_num
				and item_num = @item_num
                end   /* spread swap */
        end /* not unknown spread */
        else
                update #contract_feed set prc_1_curve = '???'
                where trade_num = @trade_num and order_num = @order_num and item_num = @item_num
        end  /* not swapflt */
        end   /* formula price */
        else  /* fixed price */
        begin
		   	select @fixed_price = avg_price from trade_item where trade_num=@trade_num
	        and order_num=@order_num and item_num=@item_num

	        update #contract_feed set prc_1_pricediff = convert(varchar(255), convert(decimal(19,6), @fixed_price)),
				prc_1_curve = 'FIXED'
	        where trade_num = @trade_num and order_num = @order_num and item_num = @item_num
        end  /* fixed price */

        if @item_type = 'W'
        begin
                select @use_actual_for_due_date = 'N'

                select @open_qty = open_qty from trade_item where trade_num=@trade_num
                and order_num = @order_num and item_num=@item_num

                if @open_qty = 0.0
                        select @use_allocation_for_due_date = 'Y'
                else

                select @use_allocation_for_due_date = 'N'

                if @use_allocation_for_due_date = 'Y'
                begin
                        select @allocation_count = count(*)  from allocation_item
                        where trade_num=@trade_num
                        and order_num=@order_num and item_num=@item_num and
                        fully_actualized != 'Y'
                        if @allocation_count = 0


	      select @use_actual_for_due_date = 'Y'
                end   /* use allocation */

                if @use_actual_for_due_date = 'Y'
                        select @settlement_date = '20' + convert(char(6), max(c.cost_due_date), 12),
 						@cost_book_curr_code = c.cost_book_curr_code,
                        @cost_price_curr_code = c.cost_price_curr_code
                        from cost c where c.cost_owner_code = 'AA'
                        and	c.cost_qty_est_actual_ind = 'A'
                        and c.cost_owner_key6=@trade_num
                        and c.cost_owner_key7=@order_num
                        and c.cost_owner_key8=@item_num
                        and c.cost_prim_sec_ind = 'P'
                        and c.cost_code = @cdty_code
                        group by c.cost_book_curr_code, c.cost_price_curr_code
-- and c.cost_due_date = (select max(c2.cost_due_date) from cost c2 where c2.cost_owner_code = 'AA' and c2.cost_qty_est_actual_ind = 'A' and c2.cost_owner_key6=@trade_num and c2.cost_owner_key7=@order_num and c2.cost_owner_key8=@item_num and c2.cost_prim_sec_ind = 'P' and c2.cost_code = @cdty_code)
                        --group by cost_owner_code, cost_qty_est_actual_ind, cost_owner_key6,
                        --cost_owner_key7, cost_owner_key8, cost_prim_sec_ind, cost_code
                        --having cost_due_date = max(cost_due_date)
                else if @use_allocation_for_due_date = 'Y'
                        select @settlement_date = '20' + convert(char(6), max(c.cost_due_date), 12),
                        @cost_book_curr_code = c.cost_book_curr_code,
                        @cost_price_curr_code = c.cost_price_curr_code
                        from cost c where c.cost_owner_code = 'AI'
                        and c.cost_owner_key6=@trade_num
                        and c.cost_owner_key7=@order_num
                        and c.cost_owner_key8=@item_num
                        and c.cost_prim_sec_ind = 'P'
                        and c.cost_code = @cdty_code
                        group by c.cost_book_curr_code, c.cost_price_curr_code
-- and c.cost_due_date = (select max(c2.cost_due_date) from cost c2 where c2.cost_owner_code = 'AI' and c2.cost_owner_key6=@trade_num and c2.cost_owner_key7=@order_num and c2.cost_owner_key8=@item_num and c2.cost_prim_sec_ind = 'P' and c2.cost_code = @cdty_code)
                        --group by cost_owner_code, cost_owner_key6,
                        --cost_owner_key7, cost_owner_key8, cost_prim_sec_ind, cost_code
                        --having cost_due_date = max(cost_due_date)

	         	else
                        select @settlement_date = '20' + convert(char(6), max(c.cost_due_date), 12),
                        @cost_book_curr_code = c.cost_book_curr_code,
                        @cost_price_curr_code = c.cost_price_curr_code
                        from cost c where c.cost_owner_code = 'TI'
                        and c.cost_owner_key1=@trade_num
                        and c.cost_owner_key2=@order_num
                        and c.cost_owner_key3=@item_num
                        and c.cost_prim_sec_ind = 'P'
                        and c.cost_code = @cdty_code
                        group by c.cost_book_curr_code, c.cost_price_curr_code
-- and c.cost_due_date = (select max(c2.cost_due_date) from cost c2 where c2.cost_owner_code = 'TI' and c2.cost_owner_key1=@trade_num and c2.cost_owner_key2=@order_num and c2.cost_owner_key3=@item_num and c2.cost_prim_sec_ind = 'P' and c2.cost_code = @cdty_code)
                        --group by cost_owner_code, cost_owner_key6,
                        --cost_owner_key7, cost_owner_key8, cost_prim_sec_ind, cost_code
                        --having cost_due_date = max(cost_due_date)



                if @cost_book_curr_code is null
                        select @cost_book_curr_code = @cost_price_curr_code

                update #contract_feed set sttl_dt_final=@settlement_date,
                sttl_ccy_code = @cost_book_curr_code where
                trade_num=@trade_num and order_num=@order_num and item_num=@item_num
        end   /* physical */


        if @prc_1_payor_sn = 'P'
                select @prc_1_payor_sn = @se_cmpny_sn
        else


	           select @prc_1_payor_sn = @cpty_sn


        update #contract_feed set efp_flag = @efp_flag, se_buysell_ind = @se_buysell_ind,
        dlvry_start_dt = @dlvry_start_dt,
        dlvry_end_dt = @dlvry_end_dt, prc_1_fixed_flag = @formula_ind,
        prc_1_payor_sn = @prc_1_payor_sn, qty_per_duration_code =
        @qty_per_duration_code,
        processed = 1
        where trade_num = @trade_num and order_num = @order_num and item_num = @item_num

        if @formula_type = 'T '
        begin
                update #contract_feed set prc_1_trig_start_dt = prc_1_start_dt,
                prc_1_trig_end_dt = prc_1_end_dt, prc_2_trig_start_dt = prc_2_start_dt,
                prc_2_trig_end_dt = prc_2_end_dt


	     where trade_num = @trade_num and order_num = @order_num and item_num
                = @item_num
                update #contract_feed set prc_1_start_dt = null, prc_1_end_dt = null,
                prc_2_start_dt = null, prc_2_end_dt = null
                where trade_num = @trade_num and order_num = @order_num and item_num = @item_num
                update #feed_option set optn_strike_trig_start_dt = optn_strike_start_dt,
                optn_strike_trig_end_dt = optn_strike_end_dt
                where trade_num = @trade_num and order_num = @order_num and item_num = @item_num
                update #feed_option set optn_strike_start_dt = null, optn_strike_end_dt = null
        	where trade_num = @trade_num and order_num = @order_num and item_num  = @item_num
        end


 select @has_more = count(*) from #contract_feed where processed = 0
end



update #contract_feed set inst_type = 'PHYS' where inst_type in ('PHYSICAL', 'EFPEXCH')

/* check for fixed prices */

if (select count(*) from #contract_feed where inst_type  = 'SWAP') > 0
begin
        select @fixed_price_count = count(distinct prc_2_pricediff)
from #contract_feed
        where inst_type  = 'SWAP'

        if @fixed_price_count > 1
                update #contract_feed set prc_2_pricediff = 'VAR'
end

update #contract_feed set inst_type = 'SWAP' where inst_type = 'SWAPFLT'

/* delivery month

	 count */

if @swap_count > 0
begin
        select @dmo_count = datediff(mm, min(prc_1_start_dt), max(prc_1_end_dt)) + 1
        from #contract_feed
end
else
begin
        select @dmo_count = datediff(mm, min(dlvry_start_dt), max(dlvry_end_dt)) + 1
        from #contract_feed
end
-------------------------------------------------------------------------------
if @inst_type like 'OTC%'
begin 

select @row_count = 0

	select @row_count=count(*) from 
	( select distinct a.id,
	a.trading_system_code,
	a.trade_num,
	a.trade_dt,
	a.se_cmpny_sn,
	a.se_trader,
	a.cpty_sn,
	a.cpty_trader,
	a.broker_sn,
	a.inst_type,
	a.cdty_code,
	a.sttl_type,
	a.se_buysell_ind,
	a.efp_flag,
	--@dmo_count,
	a.cycle_number,
	a.dlvry_location,
	a.qty_per,
	a.qty_uom_code,
	a.qty_per_duration_code,
	a.sttl_model,
	a.sttl_ccy_code,
	a.sttl_month_offset,
	a.sttl_days_offset,
	b.optn_put_call_ind,
	--a.sttl_type,
	b.optn_style_code,
	b.optn_prem_fee_type,
	b.optn_fee_rate,
	b.optn_prem_ccy_code,
	b.optn_prem_uom_code,
	b.optn_prem_val_dt,
	b.optn_strike_fixed_flag,
	b.optn_strike_pricediff,
	b.optn_strike_ccy_code,
	b.optn_strike_uom_code,
	b.optn_strike_curve,
	b.optn_strike_contract_month,
	b.optn_strike_exch_roll_a,
	b.optn_strike_exch_roll_b from #contract_feed a, #feed_option b
	where a.trade_num = b.trade_num and a.order_num = b.order_num and
	a.item_num = b.item_num
	group by
	a.id,
	a.trading_system_code,
	a.trade_num,
	a.trade_dt,
	a.se_cmpny_sn,
	a.se_trader,
	a.cpty_sn,
	a.cpty_trader,
	a.broker_sn,
	a.inst_type,
	a.cdty_code,
	a.sttl_type,
	a.se_buysell_ind,
	a.efp_flag,
	--@dmo_count,
	a.cycle_number,
	a.dlvry_location,
	a.qty_per,
	a.qty_uom_code,
	a.qty_per_duration_code,
	a.sttl_model,
	a.sttl_ccy_code,
	a.sttl_month_offset,
	a.sttl_days_offset,
	b.optn_put_call_ind,
	--a.sttl_type,
	b.optn_style_code,
	b.optn_prem_fee_type,
	b.optn_fee_rate,
	b.optn_prem_ccy_code,
	b.optn_prem_uom_code,
	b.optn_prem_val_dt,
	b.optn_strike_fixed_flag,
	b.optn_strike_pricediff,
	b.optn_strike_ccy_code,
	b.optn_strike_uom_code,
	b.optn_strike_curve,
	b.optn_strike_contract_month,
	b.optn_strike_exch_roll_a,
	b.optn_strike_exch_roll_b) con_feed

if (@row_count=1)
set @xml_val =
(
select distinct
(select rtrim(a.id) as '*' for xml path ('')) as id,
(select rtrim(a.trading_system_code) as '*' for xml path ('')) as trading_system_code,
(select rtrim(convert(varchar(20), a.trade_num)) as '*' for xml path ('')) as trading_system_id,
(select rtrim(convert(char(10), a.trade_dt, 120)) as '*' for xml path ('')) as trade_dt,
(select rtrim(a.se_cmpny_sn) as '*' for xml path ('')) as se_cmpny_sn,
(select rtrim(a.se_trader) as '*' for xml path ('')) as se_trader,
(select rtrim(a.cpty_sn) as '*' for xml path ('')) as cpty_sn,
(select rtrim(a.cpty_trader) as '*' for xml path ('')) as cpty_trader,
(select rtrim(a.broker_sn) as '*' for xml path ('')) as broker_sn,
(select rtrim(a.inst_type) as '*' for xml path ('')) as inst_type,
(select rtrim(a.cdty_code) as '*' for xml path ('')) as cdty_code,
(select rtrim(a.sttl_type) as '*' for xml path ('')) as sttl_type,
(select rtrim(a.se_buysell_ind) as '*' for xml path ('')) as se_buysell_ind,
(select rtrim(a.efp_flag) as '*' for xml path ('')) as efp_flag,
(select rtrim(convert(char(10), min(a.dlvry_start_dt), 120)) as '*' for xml path ('')) as dlvry_start_dt,
(select rtrim(convert(char(10), max(a.dlvry_end_dt), 120)) as '*' for xml path ('')) as dlvry_end_dt,
(select rtrim(@dmo_count) as '*' for xml path ('')) as dmo_count,
(select rtrim(a.cycle_number) as '*' for xml path ('')) as cycle_number,
(select rtrim(a.dlvry_location) as '*' for xml path ('')) as dlvry_location,
(select rtrim(a.qty_per) as '*' for xml path ('')) as qty_per,
(select rtrim(a.qty_uom_code) as '*' for xml path ('')) as qty_uom_code,
(select rtrim(a.qty_per_duration_code) as '*' for xml path ('')) as qty_per_duration_code,
(select rtrim(sum(a.qty_total)) as '*' for xml path ('')) as qty_total,
(select rtrim(a.sttl_model) as '*' for xml path ('')) as sttl_model,
(select rtrim(a.sttl_ccy_code) as '*' for xml path ('')) as sttl_ccy_code,
(select rtrim(a.sttl_month_offset) as '*' for xml path ('')) as sttl_month_offset,
(select rtrim(a.sttl_days_offset) as '*' for xml path ('')) as sttl_days_offset,
(select rtrim(max(a.sttl_dt_final)) as '*' for xml path ('')) as sttl_dt_final,
(select rtrim(b.optn_put_call_ind) as '*' for xml path ('')) as optn_put_call_ind,
(select rtrim(a.sttl_type) as '*' for xml path ('')) as optn_trade_type_code,
(select rtrim(b.optn_style_code) as '*' for xml path ('')) as optn_style_code,
(select rtrim(b.optn_prem_fee_type) as '*' for xml path ('')) as optn_prem_fee_type,
(select rtrim(b.optn_fee_rate) as '*' for xml path ('')) as optn_fee_rate,
(select rtrim(b.optn_prem_ccy_code) as '*' for xml path ('')) as optn_prem_ccy_code,
(select rtrim(b.optn_prem_uom_code) as '*' for xml path ('')) as optn_prem_uom_code,
(select rtrim(convert(char(10), b.optn_prem_val_dt, 120)) as '*' for xml path ('')) as optn_prem_val_dt,
(select rtrim(b.optn_strike_fixed_flag) as '*' for xml path ('')) as optn_strike_fixed_flag,
(select rtrim(b.optn_strike_pricediff) as '*' for xml path ('')) as optn_strike_pricediff,
(select rtrim(b.optn_strike_ccy_code) as '*' for xml path ('')) as optn_strike_ccy_code,
(select rtrim(b.optn_strike_uom_code) as '*' for xml path ('')) as optn_strike_uom_code,
(select rtrim(b.optn_strike_curve) as '*' for xml path ('')) as optn_strike_curve,
(select rtrim(convert(char(10), min(b.optn_strike_start_dt), 120)) as '*' for xml path ('')) as optn_strike_start_dt,
(select rtrim(convert(char(10), max(b.optn_strike_end_dt), 120)) as '*' for xml path ('')) as optn_strike_end_dt,
(select rtrim(convert(char(10), min(b.optn_strike_trig_start_dt), 120)) as '*' for xml path ('')) as optn_strike_trig_start_dt,
(select rtrim(convert(char(10), max(b.optn_strike_trig_end_dt), 120)) as '*' for xml path ('')) as optn_strike_trig_end_dt,
(select rtrim(b.optn_strike_contract_month) as '*' for xml path ('')) as optn_strike_contract_month,
(select rtrim(b.optn_strike_exch_roll_a) as '*' for xml path ('')) as optn_strike_exch_roll_a,
(select rtrim(b.optn_strike_exch_roll_b) as '*' for xml path ('')) as optn_strike_exch_roll_b
from #contract_feed a, #feed_option b
where a.trade_num = b.trade_num and a.order_num = b.order_num and
a.item_num = b.item_num
group by
a.id,
a.trading_system_code,
a.trade_num,
a.trade_dt,
a.se_cmpny_sn,
a.se_trader,
a.cpty_sn,
a.cpty_trader,
a.broker_sn,
a.inst_type,
a.cdty_code,
a.sttl_type,
a.se_buysell_ind,
a.efp_flag,
--@dmo_count,
a.cycle_number,
a.dlvry_location,
a.qty_per,
a.qty_uom_code,
a.qty_per_duration_code,
a.sttl_model,
a.sttl_ccy_code,
a.sttl_month_offset,
a.sttl_days_offset,
b.optn_put_call_ind,
a.sttl_type,
b.optn_style_code,
b.optn_prem_fee_type,
b.optn_fee_rate,
b.optn_prem_ccy_code,
b.optn_prem_uom_code,
b.optn_prem_val_dt,
b.optn_strike_fixed_flag,
b.optn_strike_pricediff,
b.optn_strike_ccy_code,
b.optn_strike_uom_code,
b.optn_strike_curve,
b.optn_strike_contract_month,
b.optn_strike_exch_roll_a,
b.optn_strike_exch_roll_b
for xml path('ContractData')
)
end
else if @efs_flag = 'Y' or @efp_flag = 'Y'
begin

select @future_fill_price_desc = convert(varchar(255),
	convert(numeric(14, 6), fut_avg_fill_prc)) from #feed_efs

select @fut_fill_price_count = count(distinct fut_avg_fill_prc) from #feed_efs

if @fut_fill_price_count > 1
	select @future_fill_price_desc = 'Various'

select @fut_fill_price_count = count(distinct fut_contract_month) from #feed_efs
if @fut_fill_price_count > 1
	update #feed_efs set fut_contract_month = 'Various'

select @fut_fill_price_count = count(distinct fut_lots) from #feed_efs
if @fut_fill_price_count > 1
	update #feed_efs set fut_lots = null

select @row_count = 0

select @row_count=count(*) from 
	(select distinct a.id,
	a.trading_system_code,
	a.trade_num,
	a.trade_dt,
	a.se_cmpny_sn,
	a.se_trader,
	a.cpty_sn,
	a.cpty_trader,
	a.broker_sn,
	a.inst_type,
	a.cdty_code,
	a.sttl_type,
	a.se_buysell_ind,
	a.efp_flag,
	--@dmo_count dmo_count,
	a.cycle_number,
	a.dlvry_location,
	a.qty_per,
	a.qty_uom_code,
	a.qty_per_duration_code,
	a.prc_1_payor_sn,
	a.prc_1_fixed_flag,
	a.prc_1_pricediff,
	a.prc_1_ccy_code,
	a.prc_1_uom_code,
	a.prc_1_curve,
	a.prc_1_contract_month,
	a.prc_1_exch_roll_a,
	a.prc_1_exch_roll_b,
	a.prc_2_payor_sn,
	a.prc_2_fixed_flag,
	a.prc_2_pricediff,
	a.prc_2_ccy_code,
	a.prc_2_uom_code,
	a.prc_2_curve,
	a.prc_2_contract_month,
	a.prc_2_exch_roll_a,
	a.prc_2_exch_roll_b,
	a.swap_com_prc_flag,
	a.sttl_model,
	a.sttl_ccy_code,
	a.sttl_month_offset,
	a.sttl_days_offset,
	a.mot_type,
	a.mot,
	a.lease_tank,
	a.load_port_loc,
	a.disch_port_loc,
	a.origin_country,
	b.fut_buy_sell_ind,
	b.fut_type,
	b.fut_contract,
	b.fut_contract_month,
	b.fut_lots,
	--@future_fill_price_desc fut_avg_fill_prc,
	b.fut_prc_ccy_code,
	b.fut_prc_uom_code from #contract_feed a, #feed_efs b
	where a.trade_num = b.trade_num and a.order_num = b.order_num
	and a.item_num = b.item_num
	group by
	a.id,
	a.trading_system_code,
	a.trade_num,
	a.trade_dt,
	a.se_cmpny_sn,
	a.se_trader,
	a.cpty_sn,
	a.cpty_trader,
	a.broker_sn,
	a.inst_type,
	a.cdty_code,
	a.sttl_type,
	a.se_buysell_ind,
	a.efp_flag,
	--@dmo_count dmo_count,
	a.cycle_number,
	a.dlvry_location,
	a.qty_per,
	a.qty_uom_code,
	a.qty_per_duration_code,
	a.prc_1_payor_sn,
	a.prc_1_fixed_flag,
	a.prc_1_pricediff,
	a.prc_1_ccy_code,
	a.prc_1_uom_code,
	a.prc_1_curve,
	a.prc_1_contract_month,
	a.prc_1_exch_roll_a,
	a.prc_1_exch_roll_b,
	a.prc_2_payor_sn,
	a.prc_2_fixed_flag,
	a.prc_2_pricediff,
	a.prc_2_ccy_code,
	a.prc_2_uom_code,
	a.prc_2_curve,
	a.prc_2_contract_month,
	a.prc_2_exch_roll_a,
	a.prc_2_exch_roll_b,
	a.swap_com_prc_flag,
	a.sttl_model,
	a.sttl_ccy_code,
	a.sttl_month_offset,
	a.sttl_days_offset,
	a.mot_type,
	a.mot,
	a.lease_tank,
	a.load_port_loc,
	a.disch_port_loc,
	a.origin_country,
	b.fut_buy_sell_ind,
	b.fut_type,
	b.fut_contract,
	b.fut_contract_month,
	b.fut_lots,
	--@future_fill_price_desc fut_avg_fill_prc,
	b.fut_prc_ccy_code,
	b.fut_prc_uom_code) con_feed

if(@row_count=1)
set @xml_val =
(	
select distinct
(select rtrim(a.id) as '*' for xml path ('')) as id, 
(select rtrim(a.trading_system_code) as '*' for xml path ('')) as trading_system_code,
(select rtrim(convert(varchar(20), a.trade_num)) as '*' for xml path ('')) as trading_system_id,
(select rtrim(convert(char(10), a.trade_dt, 120)) as '*' for xml path ('')) as trade_dt,
(select rtrim(a.se_cmpny_sn) as '*' for xml path ('')) as se_cmpny_sn,
(select rtrim(a.se_trader) as '*' for xml path ('')) as se_trader,
(select rtrim(a.cpty_sn) as '*' for xml path ('')) as cpty_sn,
(select rtrim(a.cpty_trader) as '*' for xml path ('')) as cpty_trader,
(select rtrim(a.broker_sn) as '*' for xml path ('')) as broker_sn,
(select rtrim(a.inst_type) as '*' for xml path ('')) as inst_type,
(select rtrim(a.cdty_code) as '*' for xml path ('')) as cdty_code,
(select rtrim(a.sttl_type) as '*' for xml path ('')) as sttl_type,
(select rtrim(a.se_buysell_ind) as '*' for xml path ('')) as se_buysell_ind,
(select rtrim(a.efp_flag) as '*' for xml path ('')) as efp_flag,
(select rtrim(min(a.dlvry_start_dt)) as '*' for xml path ('')) as dlvry_start_dt,
(select rtrim(max(a.dlvry_end_dt)) as '*' for xml path ('')) as dlvry_end_dt,
(select rtrim(@dmo_count) as '*' for xml path ('')) as dmo_count,
(select rtrim(a.cycle_number) as '*' for xml path ('')) as cycle_number,
(select rtrim(a.dlvry_location) as '*' for xml path ('')) as dlvry_location,
(select rtrim(a.qty_per) as '*' for xml path ('')) as qty_per,
(select rtrim(a.qty_uom_code) as '*' for xml path ('')) as qty_uom_code,
(select rtrim(a.qty_per_duration_code) as '*' for xml path ('')) as qty_per_duration_code,
(select rtrim(sum(a.qty_total)) as '*' for xml path ('')) as qty_total,
(select rtrim(a.prc_1_payor_sn) as '*' for xml path ('')) as prc_1_payor_sn,
(select rtrim(a.prc_1_fixed_flag) as '*' for xml path ('')) as prc_1_fixed_flag,
(select rtrim(a.prc_1_pricediff) as '*' for xml path ('')) as prc_1_pricediff,
(select rtrim(a.prc_1_ccy_code) as '*' for xml path ('')) as prc_1_ccy_code,
(select rtrim(a.prc_1_uom_code) as '*' for xml path ('')) as prc_1_uom_code,
(select rtrim(a.prc_1_curve) as '*' for xml path ('')) as prc_1_curve,
(select rtrim(convert(char(10), min(a.prc_1_start_dt), 120)) as '*' for xml path ('')) as prc_1_start_dt,
(select rtrim(convert(char(10), max(a.prc_1_end_dt), 120)) as '*' for xml path ('')) as prc_1_end_dt,
(select rtrim(convert(char(10), min(a.prc_1_trig_start_dt), 120)) as '*' for xml path ('')) as prc_1_trig_start_dt,
(select rtrim(convert(char(10), max(a.prc_1_trig_end_dt), 120)) as '*' for xml path ('')) as prc_1_trig_end_dt,
(select rtrim(a.prc_1_contract_month) as '*' for xml path ('')) as prc_1_contract_month,
(select rtrim(a.prc_1_exch_roll_a) as '*' for xml path ('')) as prc_1_exch_roll_a,
(select rtrim(a.prc_1_exch_roll_b) as '*' for xml path ('')) as prc_1_exch_roll_b,
(select rtrim(a.prc_2_payor_sn) as '*' for xml path ('')) as prc_2_payor_sn,
(select rtrim(a.prc_2_fixed_flag) as '*' for xml path ('')) as prc_2_fixed_flag,
(select rtrim(a.prc_2_pricediff) as '*' for xml path ('')) as prc_2_pricediff,
(select rtrim(a.prc_2_ccy_code) as '*' for xml path ('')) as prc_2_ccy_code,
(select rtrim(a.prc_2_uom_code) as '*' for xml path ('')) as prc_2_uom_code,
(select rtrim(a.prc_2_curve) as '*' for xml path ('')) as prc_2_curve,
(select rtrim(convert(char(10), min(a.prc_2_start_dt), 120)) as '*' for xml path ('')) as prc_2_start_dt,
(select rtrim(convert(char(10), max(a.prc_2_end_dt), 120)) as '*' for xml path ('')) as prc_2_end_dt,
(select rtrim(convert(char(10), min(a.prc_2_trig_start_dt), 120)) as '*' for xml path ('')) as prc_2_trig_start_dt,
(select rtrim(convert(char(10), max(a.prc_2_trig_end_dt), 120)) as '*' for xml path ('')) as prc_2_trig_end_dt,
(select rtrim(a.prc_2_contract_month) as '*' for xml path ('')) as prc_2_contract_month,
(select rtrim(a.prc_2_exch_roll_a) as '*' for xml path ('')) as prc_2_exch_roll_a,
(select rtrim(a.prc_2_exch_roll_b) as '*' for xml path ('')) as prc_2_exch_roll_b,
(select rtrim(a.swap_com_prc_flag) as '*' for xml path ('')) as swap_com_prc_flag,
(select rtrim(a.sttl_model) as '*' for xml path ('')) as sttl_model,
(select rtrim(a.sttl_ccy_code) as '*' for xml path ('')) as sttl_ccy_code,
(select rtrim(a.sttl_month_offset) as '*' for xml path ('')) as sttl_month_offset,
(select rtrim(a.sttl_days_offset) as '*' for xml path ('')) as sttl_days_offset,
(select rtrim(convert(char(10), max(a.sttl_dt_final), 120)) as '*' for xml path ('')) as sttl_dt_final,
(select rtrim(a.mot_type) as '*' for xml path ('')) as mot_type,
(select rtrim(a.mot) as '*' for xml path ('')) as mot,
(select rtrim(a.lease_tank) as '*' for xml path ('')) as lease_tank,
(select rtrim(a.load_port_loc) as '*' for xml path ('')) as load_port_loc,
(select rtrim(a.disch_port_loc) as '*' for xml path ('')) as disch_port_loc,
(select rtrim(a.origin_country) as '*' for xml path ('')) as origin_country,
(select rtrim(b.fut_buy_sell_ind) as '*' for xml path ('')) as fut_buy_sell_ind,
(select rtrim(b.fut_type) as '*' for xml path ('')) as fut_type,
(select rtrim(b.fut_contract) as '*' for xml path ('')) as fut_contract,
(select rtrim(b.fut_contract_month) as '*' for xml path ('')) as fut_contract_month,
(select rtrim(isnull(convert(varchar(255), b.fut_lots), 'Various')) as '*' for xml path ('')) as fut_lots,
(select rtrim(fut_lots) as '*' for xml path ('')) as fut_lots,--fut_lots
(select rtrim(@future_fill_price_desc) as '*' for xml path ('')) as fut_avg_fill_prc,
(select rtrim(b.fut_prc_ccy_code) as '*' for xml path ('')) as fut_prc_ccy_code,
(select rtrim(b.fut_prc_uom_code) as '*' for xml path ('')) as fut_prc_uom_code
from #contract_feed a, #feed_efs b
where a.trade_num = b.trade_num and a.order_num = b.order_num
and a.item_num = b.item_num
group by
a.id,
a.trading_system_code,
a.trade_num,
a.trade_dt,
a.se_cmpny_sn,
a.se_trader,
a.cpty_sn,
a.cpty_trader,
a.broker_sn,
a.inst_type,
a.cdty_code,
a.sttl_type,
a.se_buysell_ind,
a.efp_flag,
--@dmo_count dmo_count,
a.cycle_number,
a.dlvry_location,
a.qty_per,
a.qty_uom_code,
a.qty_per_duration_code,
a.prc_1_payor_sn,
a.prc_1_fixed_flag,
a.prc_1_pricediff,
a.prc_1_ccy_code,
a.prc_1_uom_code,
a.prc_1_curve,
a.prc_1_contract_month,
a.prc_1_exch_roll_a,
a.prc_1_exch_roll_b,
a.prc_2_payor_sn,
a.prc_2_fixed_flag,
a.prc_2_pricediff,
a.prc_2_ccy_code,
a.prc_2_uom_code,
a.prc_2_curve,
a.prc_2_contract_month,
a.prc_2_exch_roll_a,
a.prc_2_exch_roll_b,
a.swap_com_prc_flag,
a.sttl_model,
a.sttl_ccy_code,
a.sttl_month_offset,
a.sttl_days_offset,
a.mot_type,
a.mot,
a.lease_tank,
a.load_port_loc,
a.disch_port_loc,
a.origin_country,
b.fut_buy_sell_ind,
b.fut_type,
b.fut_contract,
b.fut_contract_month,
b.fut_lots,
--@future_fill_price_desc fut_avg_fill_prc,
b.fut_prc_ccy_code,
b.fut_prc_uom_code
for xml path('ContractData')
)
end
else
begin 

select @row_count = 0

select @row_count=count(*) from 
	(select distinct id,
	trading_system_code,
	trade_num,
	trade_dt,
	se_cmpny_sn,
	se_trader,
	cpty_sn,
	cpty_trader,
	broker_sn,
	inst_type,
	cdty_code,
	sttl_type,
	se_buysell_ind,
	efp_flag,
	--@dmo_count dmo_count,
	cycle_number,
	dlvry_location,
	qty_per,
	qty_uom_code,
	qty_per_duration_code,
	prc_1_payor_sn,
	prc_1_fixed_flag,
	prc_1_pricediff,
	prc_1_ccy_code,
	prc_1_uom_code,
	prc_1_curve,
	prc_1_contract_month,
	prc_1_exch_roll_a,
	prc_1_exch_roll_b,
	prc_2_payor_sn,
	prc_2_fixed_flag,
	prc_2_pricediff,
	prc_2_ccy_code,
	prc_2_uom_code,
	prc_2_curve,
	prc_2_contract_month,
	prc_2_exch_roll_a,
	prc_2_exch_roll_b,
	swap_com_prc_flag,
	sttl_model,
	sttl_ccy_code,
	sttl_month_offset,
	sttl_days_offset,
	mot_type,
	mot,
	lease_tank,
	load_port_loc,
	disch_port_loc,
	origin_country from #contract_feed
	group by
	id,
	trading_system_code,
	trade_num,
	trade_dt,
	se_cmpny_sn,
	se_trader,
	cpty_sn,
	cpty_trader,
	broker_sn,
	inst_type,
	cdty_code,
	sttl_type,
	se_buysell_ind,
	efp_flag,
	--@dmo_count dmo_count,
	cycle_number,
	dlvry_location,
	qty_per,
	qty_uom_code,
	qty_per_duration_code,
	prc_1_payor_sn,
	prc_1_fixed_flag,
	prc_1_pricediff,
	prc_1_ccy_code,
	prc_1_uom_code,
	prc_1_curve,
	prc_1_contract_month,
	prc_1_exch_roll_a,
	prc_1_exch_roll_b,
	prc_2_payor_sn,
	prc_2_fixed_flag,
	prc_2_pricediff,
	prc_2_ccy_code,
	prc_2_uom_code,
	prc_2_curve,
	prc_2_contract_month,
	prc_2_exch_roll_a,
	prc_2_exch_roll_b,
	swap_com_prc_flag,
	sttl_model,
	sttl_ccy_code,
	sttl_month_offset,
	sttl_days_offset,
	mot_type,
	mot,
	lease_tank,
	load_port_loc,
	disch_port_loc,
	origin_country) con_feed

if(@row_count=1)
set @xml_val =
(
select distinct
(select rtrim(id) as '*' for xml path ('')) as id,
(select rtrim(trading_system_code) as '*' for xml path ('')) as trading_system_code,
(select rtrim(convert(varchar(20), trade_num)) as '*' for xml path ('')) as trading_system_id,
(select rtrim(convert(char(10), trade_dt, 120)) as '*' for xml path ('')) as trade_dt,
(select rtrim(se_cmpny_sn) as '*' for xml path ('')) as se_cmpny_sn,
(select rtrim(se_trader) as '*' for xml path ('')) as se_trader,
(select rtrim(cpty_sn) as '*' for xml path ('')) as cpty_sn,
(select rtrim(cpty_trader) as '*' for xml path ('')) as cpty_trader,
(select rtrim(broker_sn) as '*' for xml path ('')) as broker_sn,
(select rtrim(inst_type) as '*' for xml path ('')) as inst_type,
(select rtrim(cdty_code) as '*' for xml path ('')) as cdty_code,
(select rtrim(sttl_type) as '*' for xml path ('')) as sttl_type,
(select rtrim(se_buysell_ind) as '*' for xml path ('')) as se_buysell_ind,
(select rtrim(efp_flag) as '*' for xml path ('')) as efp_flag, 
(select rtrim(convert(char(10), min(dlvry_start_dt), 120)) as '*' for xml path ('')) as dlvry_start_dt,
(select rtrim(convert(char(10), max(dlvry_end_dt), 120)) as '*' for xml path ('')) as dlvry_end_dt,
(select rtrim(@dmo_count) as '*' for xml path ('')) as dmo_count,
(select rtrim(cycle_number) as '*' for xml path ('')) as cycle_number,
(select rtrim(dlvry_location) as '*' for xml path ('')) as dlvry_location,
(select rtrim(qty_per) as '*' for xml path ('')) as qty_per,
(select rtrim(qty_uom_code) as '*' for xml path ('')) as qty_uom_code,
(select rtrim(qty_per_duration_code) as '*' for xml path ('')) as qty_per_duration_code,
(select rtrim(sum(qty_total)) as '*' for xml path ('')) as qty_total,
(select rtrim(prc_1_payor_sn) as '*' for xml path ('')) as prc_1_payor_sn,
(select rtrim(prc_1_fixed_flag) as '*' for xml path ('')) as prc_1_fixed_flag, 
(select rtrim(prc_1_pricediff) as '*' for xml path ('')) as prc_1_pricediff,
(select rtrim(prc_1_ccy_code) as '*' for xml path ('')) as prc_1_ccy_code,
(select rtrim(prc_1_uom_code) as '*' for xml path ('')) as prc_1_uom_code,
(select rtrim(prc_1_curve) as '*' for xml path ('')) as prc_1_curve,
(select rtrim(convert(char(10), min(prc_1_start_dt), 120)) as '*' for xml path ('')) as prc_1_start_dt,
(select rtrim(convert(char(10), max(prc_1_end_dt), 120)) as '*' for xml path ('')) as prc_1_end_dt,
(select rtrim(convert(char(10), min(prc_1_trig_start_dt), 120)) as '*' for xml path ('')) as prc_1_trig_start_dt,
(select rtrim(convert(char(10), max(prc_1_trig_end_dt), 120)) as '*' for xml path ('')) as prc_1_trig_end_dt,
(select rtrim(prc_1_contract_month) as '*' for xml path ('')) as prc_1_contract_month,
(select rtrim(prc_1_exch_roll_a) as '*' for xml path ('')) as prc_1_exch_roll_a,
(select rtrim(prc_1_exch_roll_b) as '*' for xml path ('')) as prc_1_exch_roll_b,
(select rtrim(prc_2_payor_sn) as '*' for xml path ('')) as prc_2_payor_sn,
(select rtrim(prc_2_fixed_flag) as '*' for xml path ('')) as prc_2_fixed_flag,
(select rtrim(prc_2_pricediff) as '*' for xml path ('')) as prc_2_pricediff,
(select rtrim(prc_2_ccy_code) as '*' for xml path ('')) as prc_2_ccy_code,
(select rtrim(prc_2_uom_code) as '*' for xml path ('')) as prc_2_uom_code,
(select rtrim(prc_2_curve) as '*' for xml path ('')) as prc_2_curve,
(select rtrim(convert(char(10), min(prc_2_start_dt), 120)) as '*' for xml path ('')) as prc_2_start_dt,
(select rtrim(convert(char(10), max(prc_2_end_dt), 120)) as '*' for xml path ('')) as prc_2_end_dt,
(select rtrim(convert(char(10), min(prc_2_trig_start_dt), 120)) as '*' for xml path ('')) as prc_2_trig_start_dt,
(select rtrim(convert(char(10), max(prc_2_trig_end_dt), 120)) as '*' for xml path ('')) as prc_2_trig_end_dt,
(select rtrim(prc_2_contract_month) as '*' for xml path ('')) as prc_2_contract_month,
(select rtrim(prc_2_exch_roll_a) as '*' for xml path ('')) as prc_2_exch_roll_a,
(select rtrim(prc_2_exch_roll_b) as '*' for xml path ('')) as prc_2_exch_roll_b,
(select rtrim(swap_com_prc_flag) as '*' for xml path ('')) as swap_com_prc_flag,
(select rtrim(sttl_model) as '*' for xml path ('')) as sttl_model,
(select rtrim(sttl_ccy_code) as '*' for xml path ('')) as sttl_ccy_code,
(select rtrim(sttl_month_offset) as '*' for xml path ('')) as sttl_month_offset,
(select rtrim(sttl_days_offset) as '*' for xml path ('')) as sttl_days_offset,
(select rtrim(convert(char(10), max(sttl_dt_final), 120)) as '*' for xml path ('')) as sttl_dt_final,
(select rtrim(mot_type) as '*' for xml path ('')) as mot_type,
(select rtrim(mot) as '*' for xml path ('')) as mot,
(select rtrim(lease_tank) as '*' for xml path ('')) as lease_tank,
(select rtrim(load_port_loc) as '*' for xml path ('')) as load_port_loc,
(select rtrim(disch_port_loc) as '*' for xml path ('')) as disch_port_loc,
(select rtrim(origin_country) as '*' for xml path ('')) as origin_country
from #contract_feed
group by
id,
trading_system_code,
trade_num,
trade_dt,
se_cmpny_sn,
se_trader,
cpty_sn,
cpty_trader,
broker_sn,
inst_type,
cdty_code,
sttl_type,
se_buysell_ind,
efp_flag,
--@dmo_count dmo_count,
cycle_number,
dlvry_location,
qty_per,
qty_uom_code,
qty_per_duration_code,
prc_1_payor_sn,
prc_1_fixed_flag,
prc_1_pricediff,
prc_1_ccy_code,
prc_1_uom_code,
prc_1_curve,
prc_1_contract_month,
prc_1_exch_roll_a,
prc_1_exch_roll_b,
prc_2_payor_sn,
prc_2_fixed_flag,
prc_2_pricediff,
prc_2_ccy_code,
prc_2_uom_code,
prc_2_curve,
prc_2_contract_month,
prc_2_exch_roll_a,
prc_2_exch_roll_b,
swap_com_prc_flag,
sttl_model,
sttl_ccy_code,
sttl_month_offset,
sttl_days_offset,
mot_type,
mot,
lease_tank,
load_port_loc,
disch_port_loc,
origin_country
for xml path('ContractData')
)
end

drop table #contract_feed
drop table #feed_option
drop table #feed_efs

select @xml_val as XML_VAL

end
GO
GRANT EXECUTE ON  [dbo].[contract_feed_xml] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'contract_feed_xml', NULL, NULL
GO
