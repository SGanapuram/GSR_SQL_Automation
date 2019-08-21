SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[quickfill_searchNEW]
(
   @future           varchar(20) = null,  
   @option           varchar(20) = null,  
   @efp              varchar(20) = null,  
   @fromDate         varchar(30) = null,  
   @toDate           varchar(30) = null,  
   @traderInit       char(1) = null,  
   @portNum          char(1) = null,  
   @creatorInit      char(1) = null,  
   @deskCode         char(1) = null,  
   @rptdatasw        char(1) = null,  
   @inhouseind       varchar(10) = null,  
   @commodity        char(1) = null,  
   @market           char(1) = null,  
   @trading          char(1) = null,  
   @itemstatus       varchar(8) = null,  
   @tradefromdate    varchar(30) = null,  
   @tradetodate      varchar(30) = null,  
   @fbroker          char(1) = null,  
   @cbroker          char(1) = null,  
   @fromFillDate     varchar(30) = null,    
   @toFillDate       varchar(30) = null,  
   @fromEfpPostDate  varchar(30) = null,   
   @toEfpPostDate    varchar(30) = null   
)  
as  
set nocount on  
declare @result int  
declare @status int  
  
   if @fromFillDate  = 'NULL' or @fromFillDate  = 'null' or @fromFillDate  = ' '
      select @fromFillDate  = null  
  
   if @toFillDate  = 'NULL' or @toFillDate  = 'null' or @toFillDate  = ' '  
      select @toFillDate  = null  
  
   if @fromEfpPostDate = 'NULL' or @fromEfpPostDate = 'null' or @fromEfpPostDate = ' '  
      select @fromEfpPostDate = null  
  
   if @toEfpPostDate = 'NULL' or @toEfpPostDate = 'null' or @toEfpPostDate = ' '  
      select @toEfpPostDate = null  
  
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
  
   if @tradefromdate = 'NULL' or @tradefromdate = 'null' or @tradefromdate = ' '  
      select @tradefromdate = null  
  
   if @tradetodate = 'NULL' or @tradetodate = 'null' or @tradetodate = ' '  
      select @tradetodate = null  
  
   if @rptdatasw = 'N' or @rptdatasw = 'n' or @rptdatasw = ' '  
      select @rptdatasw = null  
  
   if @inhouseind = 'NULL' or @inhouseind = 'null' or @inhouseind = ' '  
      select @inhouseind = null  
  
   if @itemstatus = 'NULL' or @itemstatus =  'null' or @itemstatus =  ' '  
      select @itemstatus = null       
       
  
   if  (@future is null) and  
       (@option is null) and  
       (@efp is null) and  
       (@inhouseind is null)  
       return -600  
  
   /* create and temp table and insert the order_type_codes in it */  
   create table #orderTypes (order_type_code varchar(8) not null)  
   if (@future is not null)  
      insert into #orderTypes values (@future)  
  
   if (@option is not null)  
      insert into #orderTypes values (@option)  
  
   if (@efp is not null)  
      insert into #orderTypes values (@efp)  
  
   /* create another temp table and insert creator init */  
   create table #creatorInit (creator_init char(3) null)  
   if (@creatorInit <> 'N')  
      insert into #creatorInit 
        select user_init from #creators  
  
   /* create temp table to contain trader_init's */  
   create table #traderInit (trader_init char(3) null)  
   if (@deskCode <> 'N')  
      insert into #traderInit   
      select user_init   
      from dbo.icts_user   
      where desk_code IN (select desk_code from #desks)  
  
   /* if there are > 240 rows in this temp table, return, too many   
      users in this desk */  
   if (@traderInit <> 'N')  
      insert into #traderInit select user_init from #traders  
  
       
   --Print 'Started 1'
   select @result = count(*) 
   from #traderInit  
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
      order_strategy_name varchar(15) null,  
      inhouse_ind varchar(1) null  
    )

    create nonclustered index xx862283_fv_idx     
      on #flattrade_view (trade_num, order_num)  
  
   if (@deskCode <> 'N') and (@result = 0)  
      select @result = 0  
   else   
   begin  
      /* select all the trades that match the different criteria.    
         quickfill_search1 and quickfill_search2 join trade,   
         trade_order and trade_order_on_exch tables and get all   
         the data needed from these tables.  Two procedures were   
         used because with one file the sql buffer was very long   
         and was not loaded */  
      if (@fromDate is not null) and (@toDate is not null)   
      begin  
         exec @status = dbo.quickfill_search1NEW @fromDate, 
                                                 @toDate, 
                                                 @creatorInit,  
                                                 @inhouseind,
                                                 @tradefromdate,
                                                 @tradetodate  
        if (@status < 0)  
           return @status  
      end  
      else   
      begin  
         exec @status = dbo.quickfill_search2NEW @fromDate, 
                                                 @toDate, 
                                                 @creatorInit,  
                                                 @inhouseind,
                                                 @tradefromdate,
                                                 @tradetodate  
         if (@status < 0)  
            return @status  
      end  
   end  
  
   --Print 'Flat View Created 2'

   create table #trade_item_862283 
   (
      trade_num                 int            NOT NULL,
      order_num                 smallint       NOT NULL,
      item_num                  smallint       NOT NULL,
      item_status_code          varchar(8)     NULL,
      booking_comp_num          int            NULL,
      cmdty_code                char(8)        NULL,
      risk_mkt_code             char(8)        NULL,
      title_mkt_code            char(8)        NULL,
      trading_prd               varchar(40)    NULL,
      contr_qty                 float          NULL,
      contr_qty_uom_code        char(4)        NULL,
      item_type                 char(1)        NULL,
      total_priced_qty          float          NULL,
      priced_qty_uom_code       char(4)        NULL,
      avg_price                 float          NULL,
      price_curr_code           char(8)        NULL,
      price_uom_code            char(4)        NULL,
      idms_bb_ref_num           varchar(10)    NULL,
      idms_acct_alloc           varchar(8)     NULL,
      brkr_num                  int            NULL,
      fut_trader_init           char(3)        NULL,
      real_port_num             int            NULL,
   ) 

   create nonclustered index xx862283_ti_idx     
      on #trade_item_862283 (trade_num, order_num, item_num)

   insert into #trade_item_862283
   select trade_num,
          order_num,
          item_num,
          item_status_code,
          booking_comp_num,
          cmdty_code,
          risk_mkt_code,
          title_mkt_code,
          trading_prd,
          contr_qty,
          contr_qty_uom_code,
          item_type,
          total_priced_qty,
          priced_qty_uom_code,
          avg_price,
          price_curr_code,
          price_uom_code,
          idms_bb_ref_num,
          idms_acct_alloc,
          brkr_num,
          fut_trader_init,
          real_port_num
    from dbo.trade_item 
    where trade_num in (select trade_num from #flattrade_view )
  
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
      trd_prd_desc varchar(40) null,  
      cmnt_num int null,  
      inhouse_ind char(1) null  
   )  
  
   create table #valid_trades (trade_num int not null)  
  
   if @commodity <> 'N' and @market <> 'N' and @trading <> 'N'  
   begin  
      insert into #valid_trades  
      select f.trade_num   
      from #flattrade_view f,  
           dbo.trade_item i  
      where f.trade_num = i.trade_num and  
            f.order_num = i.order_num and  
            i.cmdty_code IN (select cmdty_code from #commodity ) and  
            i.risk_mkt_code IN (select mkt_code from #market) and  
            i.trading_prd IN (select trading_prd from #trading)  
  
      delete from #flattrade_view   
      where trade_num not in (select trade_num from #valid_trades)  
      delete from #valid_trades  
   end  
   else if @commodity <> 'N' and @market <> 'N'    
   begin  
      insert into #valid_trades  
      select f.trade_num   
      from #flattrade_view f,  
           dbo.trade_item i  
      where f.trade_num = i.trade_num and  
            f.order_num = i.order_num and  
            i.cmdty_code IN (select cmdty_code from #commodity) and  
            i.risk_mkt_code IN (select mkt_code from #market)    
        
      delete from #flattrade_view   
      where trade_num not in (select trade_num from #valid_trades)  
      delete from #valid_trades  
   end  
   else if @commodity <> 'N' and @trading <> 'N'    
   begin  
      insert into #valid_trades  
      select f.trade_num   
      from #flattrade_view f,  
           dbo.trade_item i  
      where f.trade_num = i.trade_num and  
            f.order_num = i.order_num and  
            i.cmdty_code IN (select cmdty_code from #commodity) and  
            i.trading_prd IN (select trading_prd from #trading)  
        
      delete from #flattrade_view   
      where trade_num not in (select trade_num from #valid_trades)  
      delete from #valid_trades  
   end  
   else if @market <> 'N' and @trading <> 'N'    
   begin  
      insert into #valid_trades  
      select f.trade_num   
      from #flattrade_view f,   
           dbo.trade_item i  
      where f.trade_num = i.trade_num and  
            f.order_num = i.order_num and  
            i.risk_mkt_code IN (select mkt_code from #market) and  
            i.trading_prd IN (select trading_prd from #trading)  
        
      delete from #flattrade_view   
      where trade_num not in (select trade_num from #valid_trades)  
      delete from #valid_trades  
   end  
   else if @market <> 'N'    
   begin  
      insert into #valid_trades  
      select f.trade_num   
      from #flattrade_view f,   
           dbo.trade_item i  
      where f.trade_num = i.trade_num and  
            f.order_num = i.order_num and  
            i.risk_mkt_code IN (select mkt_code from #market)  
  
      delete from #flattrade_view   
      where trade_num not in (select trade_num from #valid_trades)  
      delete from #valid_trades  
   end  
   else if @trading <> 'N'  
   begin    
      insert into #valid_trades  
      select f.trade_num   
      from #flattrade_view f,   
           dbo.trade_item i  
      where f.trade_num = i.trade_num and  
            f.order_num = i.order_num and  
            i.trading_prd IN (select trading_prd from #trading)  
     
      delete from #flattrade_view   
      where trade_num not in (select trade_num from #valid_trades)  
      delete from #valid_trades  
   end  
   else if @commodity <> 'N'  
   begin    
      insert into #valid_trades  
      select f.trade_num   
      from #flattrade_view f,   
           dbo.trade_item i  
      where f.trade_num = i.trade_num and  
            f.order_num = i.order_num and  
            i.cmdty_code IN (select cmdty_code from #commodity)  
     
      delete from #flattrade_view   
      where trade_num not in (select trade_num from #valid_trades)  
      delete from #valid_trades  
   end  
  
   if @fbroker <> 'N'  
   begin    
      insert into #valid_trades  
      select f.trade_num   
      from #flattrade_view f,   
           dbo.trade_item i  
      where f.trade_num = i.trade_num and  
            f.order_num = i.order_num and  
            i.brkr_num IN (select brkr_num from #fbrokers)  
     
      delete from #flattrade_view   
      where trade_num not in (select trade_num from #valid_trades)  
      delete from #valid_trades  
   end  
  
   if @cbroker <> 'N'  
   begin    
      insert into #valid_trades  
      select f.trade_num   
      from #flattrade_view f,  
           dbo.trade_item_fut u  
      where f.trade_num = u.trade_num and  
            f.order_num = u.order_num and  
            u.clr_brkr_num IN (select clr_brkr_num from #cbrokers)  
           
      insert into #valid_trades  
      select f.trade_num   
      from #flattrade_view f,  
           dbo.trade_item_exch_opt e  
      where f.trade_num = e.trade_num and  
            f.order_num = e.order_num and  
            e.clr_brkr_num IN (select clr_brkr_num from #cbrokers)  
  
      delete from #flattrade_view   
      where trade_num not in (select trade_num from #valid_trades)  
      delete from #valid_trades  
   end  
  
   if @itemstatus is not null  
   begin    
      insert into #valid_trades  
      select f.trade_num   
      from #flattrade_view f,   
           dbo.trade_item i  
      where f.trade_num = i.trade_num and  
            f.order_num = i.order_num and  
            i.item_status_code = @itemstatus   
     
      delete from #flattrade_view   
      where trade_num not in (select trade_num from #valid_trades)  
      delete from #valid_trades  
   end  
  
   if (@result > 0) and (@portNum <> 'N')   
   begin  
      --Print 'Port Num given 3' + @portNum
      		   		
      insert into #valid_trades  
      select f.trade_num   
      from #flattrade_view f,   
           dbo.trade_item i  
      where f.trade_num = i.trade_num and  
            f.order_num = i.order_num and  
            f.trader_init in (select trader_init from #traderInit) and  
            i.real_port_num IN (select real_port_num from #portnum)  
  
      delete from #flattrade_view   
      where trade_num not in (select trade_num from #valid_trades)  
  
      -- Handling Inhouse  
  
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
         tid.p_s_ind,  
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
         tid.real_port_num,  
         null,  
         i.cmnt_num,  
         f.inhouse_ind  
      from #flattrade_view f,   
           dbo.trade_item i,  
           dbo.trade_item_dist tid  
      where f.trade_num = i.trade_num and  
            f.order_num = i.order_num and  
            i.trade_num = tid.trade_num and  
            i.order_num = tid.order_num and  
            i.item_num  = tid.item_num and  
            f.inhouse_ind = 'Y'  
  
     -- Handling Non_Inhouse  
  
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
         i.cmnt_num,  
         f.inhouse_ind  
      from #flattrade_view f,   
           dbo.trade_item i  
      where f.trade_num = i.trade_num and  
            f.order_num = i.order_num and  
            f.inhouse_ind <> 'Y'  
   end  
   else if (@result > 0) and (@portNum = 'N')   
   begin  
      insert into #valid_trades  
      select f.trade_num   
      from #flattrade_view f  
      where f.trader_init in (select trader_init from #traderInit)  
  
      delete from #flattrade_view   
      where trade_num not in (select trade_num from #valid_trades)  
  
      -- Handling Inhouse  
        
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
         tid.p_s_ind,  
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
         tid.real_port_num,  
         null,  
         i.cmnt_num,  
         f.inhouse_ind  
      from #flattrade_view f,   
           dbo.trade_item i,  
           dbo.trade_item_dist tid  
      where f.trade_num = i.trade_num and  
            f.order_num = i.order_num and  
            i.trade_num = tid.trade_num and  
            i.order_num = tid.order_num and  
            i.item_num  = tid.item_num and  
            f.inhouse_ind = 'Y'  
  
      -- Handling Non-inhouse  
  
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
         i.cmnt_num,  
         f.inhouse_ind  
      from #flattrade_view f,   
           dbo.trade_item i  
      where f.trade_num = i.trade_num and  
            f.order_num = i.order_num and  
            f.inhouse_ind <> 'Y'  
   end  
   else if (@result = 0) and (@portNum = 'N')   
   begin  
      -- Handling Inhouse  
	    --Print 'Port Num given 3 handling Inhous ' + @portNum
  
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
         tid.p_s_ind,  
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
         tid.real_port_num,  
         null,  
         i.cmnt_num,  
         f.inhouse_ind  
      from #flattrade_view f,   
           dbo.trade_item i,  
           dbo.trade_item_dist tid  
      where f.trade_num = i.trade_num and  
            f.order_num = i.order_num and  
            i.trade_num = tid.trade_num and  
            i.order_num = tid.order_num and  
            i.item_num  = tid.item_num and  
            f.inhouse_ind = 'Y'  
  
      -- Handling Non_Inhouse  
  
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
         i.cmnt_num,  
         f.inhouse_ind  
      from #flattrade_view f,   
           dbo.trade_item i  
      where f.trade_num = i.trade_num and  
            f.order_num = i.order_num and  
            f.inhouse_ind <> 'Y'    
   end  
   else if (@result = 0) and (@portNum <> 'N')   
   begin  
   	  --Print 'Port Num given 3 handling Inhous ' + @portNum 
   	
      insert into #valid_trades  
      select f.trade_num   
      from #flattrade_view f,   
           dbo.trade_item i  
      where f.trade_num = i.trade_num and  
            f.order_num = i.order_num and  
            i.real_port_num IN (select real_port_num from #portnum)  
  
      delete from #flattrade_view   
      where trade_num not in (select trade_num from #valid_trades)  
  
  		declare @rowCntFlat int
  		select @rowCntFlat = count(*)  
  		from #flattrade_view  
     
      --Print 'the number of rows in flattrade_view....' + convert(VARCHAR,@rowCntFlat)
      -- Handling Inhouse  
  
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
         tid.p_s_ind,  
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
         tid.real_port_num,  
         null,  
         i.cmnt_num,  
         f.inhouse_ind  
      from #flattrade_view f,   
           dbo.trade_item i,  
           dbo.trade_item_dist tid  
      where f.trade_num = i.trade_num and  
            f.order_num = i.order_num and  
            i.trade_num = tid.trade_num and  
            i.order_num = tid.order_num and  
            i.item_num  = tid.item_num and  
            f.inhouse_ind = 'Y'  
  
	    select @rowCntFlat = count(*)  
	    from #quickfill_search  
	   
      --Print 'the number of rows in #quickfill_search 1....' + convert(VARCHAR,@rowCntFlat)
      -- Handling Non_Inhouse  
  
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
         i.cmnt_num,  
         f.inhouse_ind  
      from #flattrade_view f,   
           dbo.trade_item i  
      where f.trade_num = i.trade_num and  
            f.order_num = i.order_num and  
            f.inhouse_ind <> 'Y'  
     
	    select @rowCntFlat = count(*)  
	    from #quickfill_search  
      --Print 'the number of rows in #quickfill_search 2....' + convert(VARCHAR,@rowCntFlat)     
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
  
   select @rowCntFlat = count(*)  
   from #quickfill_search  
   --Print 'the number of rows in #quickfill_search 3....' + convert(VARCHAR,@rowCntFlat)
     
   if @rptdatasw = 'Y'   
   begin  
      --Print 'If statement of Reportdata SW'
      alter table #quickfill_search  
         add f_broker char(15) null,  
             c_broker char(15) null,  
             tiny_cmnt char(15) null  
  
      exec dbo.quickfill_search_descNEW @fromFillDate, 
                                        @toFillDate, 
                                        @fromEfpPostDate,  
                                        @toEfpPostDate       
   end  
   else   
   begin  
      --Print 'else statement of Reportdata SW'
   	
      IF ((@fromFillDate = '1998-01-01 00:00:00.0' AND @toFillDate = '2015-01-01 00:00:00.0')
	       AND (@fromEfpPostDate = '1998-01-01 00:00:00.0' AND @toEfpPostDate = '2015-01-01 00:00:00.0'))
	    BEGIN	
		     Print 'Enter condition 11'	
         select  
            a.trade_num,   
            a.order_num,            
            a.item_num,   
            a.trader_init,   
            a.trade_status_code,   
            a.contr_date,   
            a.creation_date,   
            a.creator_init,   
            a.order_type_code,   
            a.order_price,   
            a.order_price_curr_code,   
            a.order_points,   
            a.order_instr_code,   
            a.order_strategy_name,   
            a.item_status_code,   
            a.p_s_ind,   
            a.booking_comp_num,   
            a.cmdty_code,   
            a.risk_mkt_code,   
            a.title_mkt_code,   
            a.trading_prd,   
            a.contr_qty,   
            a.contr_qty_uom_code,   
            a.item_type,   
            a.total_priced_qty,   
            a.priced_qty_uom_code,   
            a.avg_price,   
            a.price_curr_code,   
            a.price_uom_code,   
            a.idms_bb_ref_num,   
            a.idms_acct_alloc,   
            a.brkr_num,   
            a.fut_trader_init,   
            a.settlement_type,   
            a.fut_price,   
            a.fut_price_curr_code,   
            a.total_fill_qty,   
            a.avg_fill_price,   
            a.clr_brkr_num,   
            a.put_call_ind,   
            a.opt_type,   
            a.strike_price,   
            a.strike_price_uom_code,   
            a.strike_price_curr_code,   
            a.real_port_num,   
            a.trd_prd_desc,   
            a.cmnt_num,   
            a.inhouse_ind,  
            l.item_fill_num,  
            l.fill_qty,  
            l.fill_qty_uom_code,  
            l.fill_price,  
            l.fill_price_curr_code,  
            l.fill_price_uom_code,  
            l.fill_date,  
            l.bsi_fill_num,  
            l.inhouse_trade_num  
      from #quickfill_search a 
              left outer join dbo.trade_item_fill l  
                 on a.trade_num = l.trade_num and  
                    a.order_num = l.order_num and  
                    a.item_num  = l.item_num 
      order by a.creation_date, a.item_num, item_fill_num 		
	 end	
   ELSE IF (@fromFillDate = '1998-01-01 00:00:00.0' AND @toFillDate = '2015-01-01 00:00:00.0')
	 BEGIN	
		  Print 'Enter condition 22'
      select  
         a.trade_num,   
         a.order_num,            
         a.item_num,   
         a.trader_init,   
         a.trade_status_code,   
         a.contr_date,   
         a.creation_date,   
         a.creator_init,   
         a.order_type_code,   
         a.order_price,   
         a.order_price_curr_code,   
         a.order_points,   
         a.order_instr_code,   
         a.order_strategy_name,   
         a.item_status_code,   
         a.p_s_ind,   
         a.booking_comp_num,   
         a.cmdty_code,   
         a.risk_mkt_code,   
         a.title_mkt_code,   
         a.trading_prd,   
         a.contr_qty,   
         a.contr_qty_uom_code,   
         a.item_type,   
         a.total_priced_qty,   
         a.priced_qty_uom_code,   
         a.avg_price,   
         a.price_curr_code,   
         a.price_uom_code,   
         a.idms_bb_ref_num,   
         a.idms_acct_alloc,   
         a.brkr_num,   
         a.fut_trader_init,   
         a.settlement_type,   
         a.fut_price,   
         a.fut_price_curr_code,   
         a.total_fill_qty,   
         a.avg_fill_price,   
         a.clr_brkr_num,   
         a.put_call_ind,   
         a.opt_type,   
         a.strike_price,   
         a.strike_price_uom_code,   
         a.strike_price_curr_code,   
         a.real_port_num,   
         a.trd_prd_desc,   
         a.cmnt_num,   
         a.inhouse_ind,  
         l.item_fill_num,  
         l.fill_qty,  
         l.fill_qty_uom_code,  
         l.fill_price,  
         l.fill_price_curr_code,  
         l.fill_price_uom_code,  
         l.fill_date,  
         l.bsi_fill_num,  
         l.inhouse_trade_num  
      from #quickfill_search a 
              left outer join dbo.trade_item_fill l  
                 on a.trade_num = l.trade_num and  
                    a.order_num = l.order_num and  
                    a.item_num  = l.item_num 
      where l.efp_post_date >= @fromEfpPostDate and
            l.efp_post_date <= @toEfpPostDate 
      order by a.creation_date, a.item_num, item_fill_num 	
	 end
   else if (@fromEfpPostDate = '1998-01-01 00:00:00.0' AND @toEfpPostDate = '2015-01-01 00:00:00.0')
	 begin	
		  print 'Enter condition 33'
      select  
         a.trade_num,   
         a.order_num,            
         a.item_num,   
         a.trader_init,   
         a.trade_status_code,   
         a.contr_date,   
         a.creation_date,   
         a.creator_init,   
         a.order_type_code,   
         a.order_price,   
         a.order_price_curr_code,   
         a.order_points,   
         a.order_instr_code,   
         a.order_strategy_name,   
         a.item_status_code,   
         a.p_s_ind,   
         a.booking_comp_num,   
         a.cmdty_code,   
         a.risk_mkt_code,   
         a.title_mkt_code,   
         a.trading_prd,   
         a.contr_qty,   
         a.contr_qty_uom_code,   
         a.item_type,   
         a.total_priced_qty,   
         a.priced_qty_uom_code,   
         a.avg_price,   
         a.price_curr_code,   
         a.price_uom_code,   
         a.idms_bb_ref_num,   
         a.idms_acct_alloc,   
         a.brkr_num,   
         a.fut_trader_init,   
         a.settlement_type,   
         a.fut_price,   
         a.fut_price_curr_code,   
         a.total_fill_qty,   
         a.avg_fill_price,   
         a.clr_brkr_num,   
         a.put_call_ind,   
         a.opt_type,   
         a.strike_price,   
         a.strike_price_uom_code,   
         a.strike_price_curr_code,   
         a.real_port_num,   
         a.trd_prd_desc,   
         a.cmnt_num,   
         a.inhouse_ind,  
         l.item_fill_num,  
         l.fill_qty,  
         l.fill_qty_uom_code,  
         l.fill_price,  
         l.fill_price_curr_code,  
         l.fill_price_uom_code,  
         l.fill_date,  
         l.bsi_fill_num,  
         l.inhouse_trade_num  
      from #quickfill_search a 
              left outer join dbo.trade_item_fill l  
                 on a.trade_num = l.trade_num and  
                    a.order_num = l.order_num and  
                    a.item_num  = l.item_num 
      where l.fill_date >= @fromFillDate and
            l.fill_date <= @toFillDate
      order by a.creation_date, a.item_num, item_fill_num 	
	 end		
   else
	 begin
	    print 'Enter condition 44'	
      select  
         a.trade_num,   
         a.order_num,            
         a.item_num,   
         a.trader_init,   
         a.trade_status_code,   
         a.contr_date,   
         a.creation_date,   
         a.creator_init,   
         a.order_type_code,   
         a.order_price,   
         a.order_price_curr_code,   
         a.order_points,   
         a.order_instr_code,   
         a.order_strategy_name,   
         a.item_status_code,   
         a.p_s_ind,   
         a.booking_comp_num,   
         a.cmdty_code,   
         a.risk_mkt_code,   
         a.title_mkt_code,   
         a.trading_prd,   
         a.contr_qty,   
         a.contr_qty_uom_code,   
         a.item_type,   
         a.total_priced_qty,   
         a.priced_qty_uom_code,   
         a.avg_price,   
         a.price_curr_code,   
         a.price_uom_code,   
         a.idms_bb_ref_num,   
         a.idms_acct_alloc,   
         a.brkr_num,   
         a.fut_trader_init,   
         a.settlement_type,   
         a.fut_price,   
         a.fut_price_curr_code,   
         a.total_fill_qty,   
         a.avg_fill_price,   
         a.clr_brkr_num,   
         a.put_call_ind,   
         a.opt_type,   
         a.strike_price,   
         a.strike_price_uom_code,   
         a.strike_price_curr_code,   
         a.real_port_num,   
         a.trd_prd_desc,   
         a.cmnt_num,   
         a.inhouse_ind,  
         l.item_fill_num,  
         l.fill_qty,  
         l.fill_qty_uom_code,  
         l.fill_price,  
         l.fill_price_curr_code,  
         l.fill_price_uom_code,  
         l.fill_date,  
         l.bsi_fill_num,  
         l.inhouse_trade_num  
      from #quickfill_search a 
              left outer join dbo.trade_item_fill l  
                 on a.trade_num = l.trade_num and  
                    a.order_num = l.order_num and  
                    a.item_num = l.item_num 
      where l.fill_date >= @fromFillDate and
            l.fill_date <= @toFillDate and
            l.efp_post_date >= @fromEfpPostDate and
            l.efp_post_date <= @toEfpPostDate 
      order by a.creation_date, a.item_num, item_fill_num  		
	 end
		   	
   /*
      select  
         a.trade_num,   
         a.order_num,            
         a.item_num,   
         a.trader_init,   
         a.trade_status_code,   
         a.contr_date,   
         a.creation_date,   
         a.creator_init,   
         a.order_type_code,   
         a.order_price,   
         a.order_price_curr_code,   
         a.order_points,   
         a.order_instr_code,   
         a.order_strategy_name,   
         a.item_status_code,   
         a.p_s_ind,   
         a.booking_comp_num,   
         a.cmdty_code,   
         a.risk_mkt_code,   
         a.title_mkt_code,   
         a.trading_prd,   
         a.contr_qty,   
         a.contr_qty_uom_code,   
         a.item_type,   
         a.total_priced_qty,   
         a.priced_qty_uom_code,   
         a.avg_price,   
         a.price_curr_code,   
         a.price_uom_code,   
         a.idms_bb_ref_num,   
         a.idms_acct_alloc,   
         a.brkr_num,   
         a.fut_trader_init,   
         a.settlement_type,   
         a.fut_price,   
         a.fut_price_curr_code,   
         a.total_fill_qty,   
         a.avg_fill_price,   
         a.clr_brkr_num,   
         a.put_call_ind,   
         a.opt_type,   
         a.strike_price,   
         a.strike_price_uom_code,   
         a.strike_price_curr_code,   
         a.real_port_num,   
         a.trd_prd_desc,   
         a.cmnt_num,   
         a.inhouse_ind,  
         l.item_fill_num,  
         l.fill_qty,  
         l.fill_qty_uom_code,  
         l.fill_price,  
         l.fill_price_curr_code,  
         l.fill_price_uom_code,  
         l.fill_date,  
         l.bsi_fill_num,  
         l.inhouse_trade_num  
      from #quickfill_search a 
              left outer join dbo.trade_item_fill l  
                 on a.trade_num = l.trade_num and  
                    a.order_num = l.order_num and  
                    a.item_num  = l.item_num  
      where l.fill_date >= @fromFillDate and  
            l.fill_date <= @toDate and  
            l.efp_post_date >= @fromEfpPostDate and  
            l.efp_post_date <= @toEfpPostDate  
      order by a.creation_date, a.item_num, item_fill_num  
      */
   end
GO
GRANT EXECUTE ON  [dbo].[quickfill_searchNEW] TO [next_usr]
GO
