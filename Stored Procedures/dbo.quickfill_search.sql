SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[quickfill_search]
(
   @future varchar(20) = null,
   @option varchar(20) = null,
   @efp varchar(20) = null,
   @fromDate varchar(30) = null,
   @toDate varchar(30) = null,
   @traderInit char(3) = null,
   @portNum int = null,
   @creatorInit char(3) = null,
   @deskCode char(8) = null,
   @rptdatasw char(1) = null
)
as
set nocount on
declare @result int
declare @status int

   if @portNum = 0
      select @portNum = null

   if @future = 'NULL' or @future = 'null' or @future = ' '
      select @future = null

   if @option = 'NULL' or @option = 'null' or @option = ' '
      select @option = null

   if @efp = 'NULL' or @efp = 'null' or @efp = ' '
      select @efp = null

   if @fromDate = 'NULL' or @fromDate = 'null' or @fromDate = ' '
      select @fromDate = null

   if @toDate = 'NULL' or @toDate = 'null' or @toDate = ' '
      select @toDate = null

   if @traderInit = 'NUL' or @traderInit = 'nul' or @traderInit = ' '
      select @traderInit = null

   if @creatorInit = 'NUL' or @creatorInit = 'nul' or @creatorInit = ' '
      select @creatorInit = null

   if @deskCode = 'NULL' or @deskCode = 'null' or @deskCode = ' '
      select @deskCode = null

   if @rptdatasw = 'N' or @rptdatasw = 'n' or @rptdatasw = ' '
      select @rptdatasw = null

   if (@future is null) and 
      (@option is null) and
      (@efp is null)
      return -600

   create table #orderTypes (order_type_code varchar(8) not null)

   if (@future is not null) 
      insert into #orderTypes values (@future)

   if (@option is not null) 
      insert into #orderTypes values (@option)

   if (@efp is not null) 
      insert into #orderTypes values (@efp)

   create table #creatorInit (creator_init char(3) null)
   if (@creatorInit is not null)
      insert into #creatorInit values (@creatorInit)

   create table #traderInit (trader_init char(3) null)
   if (@deskCode is not null)
      insert into #traderInit 
        select user_init 
        from dbo.icts_user 
        where desk_code = @deskCode

   /* if there are > 240 rows in this temp table, return, too 
      many users in this desk */
   if (@traderInit is not null)
      insert into #traderInit values (@traderInit)

   select @result = count(*) from #traderInit 

   if (@result > 240)
      return -599

   create table #flattrade_view
   (
      trade_num int not null,
      order_num smallint not null,
      order_type_code varchar(8) not null,
      trader_init char(3) null,
      trade_status_code varchar(8) null,
      contr_date datetime null,
      creation_date datetime null,
      creator_init char(3) null,
      order_price float null,
      order_price_curr_code char(8) null,
      order_points float null,
      order_instr_code varchar(8) null,
      order_strategy_name varchar(15) null
   )
 
   if (@deskCode is not null) and (@result = 0)
      select @result = 0
   else 
   begin 
      /* select all the trades that match the different criteria.  
         quickfill_search1 and quickfill_search2 join trade, 
         trade_order and trade_order_on_exch tables and get all 
         the data needed from these tables.  Two procedures were 
         used because with one file the sql buffer was very long 
         and was not loaded 
      */
      if (@fromDate is not null) and (@toDate is not null) 
      begin
         exec @status = dbo.quickfill_search1 @fromDate, @toDate, @creatorInit
         if (@status < 0)
            return @status
      end
      else 
      begin
         exec @status = dbo.quickfill_search2 @fromDate, @toDate, @creatorInit
         if (@status < 0)
	          return @status
      end
   end

   create table #quickfill_search
   (
      trade_num int not null,
      order_num smallint not null,
      item_num smallint not null,
      trader_init char(3) null,
      trade_status_code varchar(8) null,
      contr_date datetime null,
      creation_date datetime null,
      creator_init char(3) null,
      order_type_code varchar(8) null,
      order_price float null,
      order_price_curr_code char(8) null,
      order_points float null,
      order_instr_code varchar(8) null,
      order_strategy_name varchar(15) null,
      item_status_code varchar(8) null,
      p_s_ind char(1) null,
      booking_comp_num int null,
      cmdty_code varchar(8) null,
      risk_mkt_code varchar(8) null,
      title_mkt_code varchar(8) null,
      trading_prd varchar(8) null,
      contr_qty float null,
      contr_qty_uom_code char(4) null,
      item_type char(1) null,
      total_priced_qty float null,
      priced_qty_uom_code varchar(4) null,
      avg_price float null,
      price_curr_code varchar(8) null,
      price_uom_code varchar(4) null,
      idms_bb_ref_num varchar(10) null,
      idms_acct_alloc varchar(8) null,
      brkr_num int null,
      fut_trader_init char(3) null,
      settlement_type char(1) null,
      fut_price float null,
      fut_price_curr_code char(8) null,
      total_fill_qty float null,
      avg_fill_price float null,
      clr_brkr_num int null,
      put_call_ind char(1) null,
      opt_type char(1) null,
      strike_price float null,
      strike_price_uom_code varchar(4) null,
      strike_price_curr_code varchar(8) null,
      real_port_num int null,
      trd_prd_desc varchar(8) null,
      cmnt_num int null
   )

   create table #valid_trades (trade_num int not null)

   if (@result > 0) and (@portNum is not null) 
   begin	
      insert into #valid_trades 
      select f.trade_num 
      from #flattrade_view f, 
           dbo.trade_item i 
      where f.trade_num = i.trade_num and
            f.order_num = i.order_num and 
	          i.fut_trader_init in (select trader_init from #traderInit) and
	          i.real_port_num = @portNum

      delete from #flattrade_view 
      where trade_num not in (select trade_num from #valid_trades)

      insert into #quickfill_search 
      select 
          f.trade_num,
          f.order_num,
          i.item_num,
          f.trader_init,
          f.trade_status_code,
          f.contr_date,
          f.creation_date,
          f.creator_init,
          f.order_type_code,
          f.order_price,
          f.order_price_curr_code,
          f.order_points,
          f.order_instr_code,
          f.order_strategy_name,
          i.item_status_code,
          i.p_s_ind,
          i.booking_comp_num,
          i.cmdty_code,
          i.risk_mkt_code,
          i.title_mkt_code,
          i.trading_prd,
          i.contr_qty,
          i.contr_qty_uom_code,
          i.item_type,
          i.total_priced_qty,
          i.priced_qty_uom_code,
          i.avg_price,
          i.price_curr_code,
          i.price_uom_code,
          i.idms_bb_ref_num,
          i.idms_acct_alloc,
          i.brkr_num,
          i.fut_trader_init,
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
          i.real_port_num,
          null,
          i.cmnt_num
      from #flattrade_view f, 
           dbo.trade_item i 
      where f.trade_num = i.trade_num and
            f.order_num = i.order_num 
   end
   else if (@result > 0) and (@portNum is null) 
   begin
      insert into #valid_trades 
      select f.trade_num 
      from #flattrade_view f, 
           dbo.trade_item i 
      where f.trade_num = i.trade_num and
            f.order_num = i.order_num and 
	          i.fut_trader_init in (select trader_init from #traderInit)

      delete from #flattrade_view 
      where trade_num not in (select trade_num from #valid_trades)

      insert into #quickfill_search 
      select 
          f.trade_num,
          f.order_num,
          i.item_num,
          f.trader_init,
          f.trade_status_code,
          f.contr_date,
          f.creation_date,
          f.creator_init,
          f.order_type_code,
          f.order_price,
          f.order_price_curr_code,
          f.order_points,
          f.order_instr_code,
          f.order_strategy_name,
          i.item_status_code,
          i.p_s_ind,
          i.booking_comp_num,
          i.cmdty_code,
          i.risk_mkt_code,
          i.title_mkt_code,
          i.trading_prd,
          i.contr_qty,
          i.contr_qty_uom_code,
          i.item_type,
          i.total_priced_qty,
          i.priced_qty_uom_code,
          i.avg_price,
          i.price_curr_code,
          i.price_uom_code,
          i.idms_bb_ref_num,
          i.idms_acct_alloc,
          i.brkr_num,
          i.fut_trader_init,
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
          i.real_port_num,
          null,
          i.cmnt_num
      from #flattrade_view f, 
           dbo.trade_item i 
      where f.trade_num = i.trade_num and
            f.order_num = i.order_num
   end
   else if (@result = 0) and (@portNum is null) 
   begin
      insert into #quickfill_search 
      select 
          f.trade_num,
          f.order_num,
          i.item_num,
          f.trader_init,
          f.trade_status_code,
          f.contr_date,
          f.creation_date,
          f.creator_init,
          f.order_type_code,
          f.order_price,
          f.order_price_curr_code,
          f.order_points,
          f.order_instr_code,
          f.order_strategy_name,
          i.item_status_code,
          i.p_s_ind,
          i.booking_comp_num,
          i.cmdty_code,
          i.risk_mkt_code,
          i.title_mkt_code,
          i.trading_prd,
          i.contr_qty,
          i.contr_qty_uom_code,
          i.item_type,
          i.total_priced_qty,
          i.priced_qty_uom_code,
          i.avg_price,
          i.price_curr_code,
          i.price_uom_code,
          i.idms_bb_ref_num,
          i.idms_acct_alloc,
          i.brkr_num,
          i.fut_trader_init,
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
          i.real_port_num,
          null,
          i.cmnt_num
      from #flattrade_view f, 
           dbo.trade_item i 
      where f.trade_num = i.trade_num and
	          f.order_num = i.order_num
   end
   else if (@result = 0) and (@portNum is not null) 
   begin
      insert into #valid_trades 
      select f.trade_num 
      from #flattrade_view f, 
           dbo.trade_item i 
      where f.trade_num = i.trade_num and
            f.order_num = i.order_num and 
	          i.real_port_num = @portNum

      delete from #flattrade_view 
      where trade_num not in (select trade_num from #valid_trades)

      insert into #quickfill_search 
      select 
          f.trade_num,
          f.order_num,
          i.item_num,
          f.trader_init,
          f.trade_status_code,
          f.contr_date,
          f.creation_date,
          f.creator_init,
          f.order_type_code,
          f.order_price,
          f.order_price_curr_code,
          f.order_points,
          f.order_instr_code,
          f.order_strategy_name,
          i.item_status_code,
          i.p_s_ind,
          i.booking_comp_num,
          i.cmdty_code,
          i.risk_mkt_code,
          i.title_mkt_code,
          i.trading_prd,
          i.contr_qty,
          i.contr_qty_uom_code,
          i.item_type,
          i.total_priced_qty,
          i.priced_qty_uom_code,
          i.avg_price,
          i.price_curr_code,
          i.price_uom_code,
          i.idms_bb_ref_num,
          i.idms_acct_alloc,
          i.brkr_num,
          i.fut_trader_init,
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
          i.real_port_num,
          null,
          i.cmnt_num
      from #flattrade_view f, 
           dbo.trade_item i 
      where f.trade_num = i.trade_num and
            f.order_num = i.order_num 
   end
 
   update #quickfill_search 
   set settlement_type = u.settlement_type,
       fut_price = u.fut_price,
       fut_price_curr_code = u.fut_price_curr_code,
       total_fill_qty = u.total_fill_qty,
       avg_fill_price = u.avg_fill_price,
       clr_brkr_num = u.clr_brkr_num
   from #quickfill_search a, 
        dbo.trade_item_fut u
   where a.trade_num = u.trade_num and
         a.order_num = u.order_num and
         a.item_num = u.item_num

   update #quickfill_search 
   set total_fill_qty = e.total_fill_qty,
       avg_fill_price = e.avg_fill_price,
       clr_brkr_num = e.clr_brkr_num,
       put_call_ind = e.put_call_ind,
       opt_type = e.opt_type,
       strike_price = e.strike_price,
       strike_price_uom_code = e.strike_price_uom_code,
       strike_price_curr_code = e.strike_price_curr_code
   from #quickfill_search a, 
        dbo.trade_item_exch_opt e
   where a.trade_num = e.trade_num and
         a.order_num = e.order_num and
         a.item_num = e.item_num

   /* get trading period desc now */
   update #quickfill_search 
   set trd_prd_desc = trading_prd_desc 
   from #quickfill_search q, 
        dbo.commodity_market c, 
        dbo.trading_period t 
   where q.cmdty_code = c.cmdty_code and 
         q.risk_mkt_code = c.mkt_code and 
         c.commkt_key = t.commkt_key and 
         q.trading_prd = t.trading_prd 

   if @rptdatasw = 'Y' 
   begin
      alter table #quickfill_search 
         add f_broker char(13) null,
             c_broker char(13) null,
	           tiny_cmnt char(15) null
 
      exec dbo.quickfill_search_desc
   end
   else 
   begin
      select 
          a.*,
	        l.item_fill_num,
          l.fill_qty,
          l.fill_qty_uom_code,
          l.fill_price,
          l.fill_price_curr_code,
          l.fill_price_uom_code,
          l.fill_date,
          l.bsi_fill_num	
/******************************************************************************          
      from #quickfill_search a, trade_item_fill l	
      where a.trade_num *= l.trade_num and
	    a.order_num *= l.order_num and
	    a.item_num  *= l.item_num
******************************************************************************/
      from #quickfill_search a
              left outer join dbo.trade_item_fill l
                 on a.trade_num = l.trade_num and 
                    a.order_num = l.order_num and 
                    a.item_num = l.item_num	    
      order by a.creation_date, a.item_num, item_fill_num
   end
GO
GRANT EXECUTE ON  [dbo].[quickfill_search] TO [next_usr]
GO
