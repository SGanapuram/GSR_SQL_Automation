SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_POSGRID_get_risk_position]
(  
   @ProfitCntr              varchar(255) = NULL,                        
   @PortNum                 varchar(255) = NULL,                   
   @PositionMode            varchar(25) = 'Live',                       
   @AsOfDate                datetime = NULL,            
   @ShowPriceDelta          char(1) = 'N',      
   @ShowCorrelationedCurves char(1) = 'N',  
   @ShowTimeSpread          char(1) = 'N',  
   @debugon                 bit = 0  
)                   
as    
set nocount on                      
declare @tag_name         varchar(40),  
        @smsg             varchar(800),  
        @rows_affected    int,  
        @time_started     varchar(20),  
        @time_finished    varchar(20)  
                                            
  create table #children   
  (  
     port_num     int primary key,   
     port_type    char(2)  
  )                                                  
                            
  create table #pos                        
  (                  
    asof_date                 datetime NULL,                  
    trader_init               varchar(3) NULL,                        
    contr_date                datetime NULL,                        
    trade_num                 int NULL,                        
    trade_key                 varchar(123) NULL,                        
    counterparty              nvarchar(60) NULL,                        
    order_type_code           varchar(8) NULL,                        
    inhouse_ind               char(1) NULL,                        
    pos_type_desc             varchar(24) NULL,                        
    trading_entity            nvarchar(30) NULL,                        
    port_group_tag            varchar(32) NULL,                        
    profit_center             varchar(32) NULL,                        
    real_port_num             int NULL,                        
    dist_num                  int NULL,                        
    pos_num                   int NULL,                        
    cmdty_group               char(8) NULL,                        
    cmdty_code                char(8) NULL,                        
    cmdty_short_name          varchar(15) NULL,                        
    mkt_code                  char(8) NULL,                        
    mkt_short_name            varchar(15) NULL,                        
    commkt_key                int NULL,                        
    trading_prd               varchar (40) NULL,                        
    pos_type                  char(1) NULL,                        
    position_p_s_ind          char(1) NULL,                        
    pos_qty_uom_code          char(4) NULL,                        
    primary_pos_qty           float NULL,                        
    secondary_qty_uom_code    char(4) NULL,                        
    secondary_pos_qty         float NULL,                        
    is_equiv_ind              char(1) NULL,                        
    contract_p_s_ind          char(1) NULL,                        
    contract_qty_uom_code     char(4) NULL,                        
    contract_qty              float NULL,                        
    mtm_price_source_code     char(8) NULL,                        
    is_hedge_ind              char(1) NULL,                        
    grid_position_month       varchar(6) NULL,                        
    grid_position_qtr         varchar(31) NULL,                        
    grid_position_year        varchar(60) NULL,                        
    trading_prd_desc          varchar(40) NULL,                        
    last_issue_date           datetime NULL,                        
    last_trade_date           datetime NULL,                        
    trade_mod_date            datetime NULL,                        
    trade_creation_date       datetime NULL,                        
    trans_id                  bigint NULL,                        
    trading_entity_num        int NULL,            
    pricing_risk_date         datetime NULL,                        
    product                   varchar(8) NULL,                        
    quantity_in_MT            float NULL,                        
    quantity_in_BBL           float null,              
    correlated_commkt_key     int null,            
    correlated_commkt         varchar(100) null,            
    correlated_price          float null,            
    correlated_price_diff     float null,                 
    position_mode             varchar(25) null,  
    order_num                 smallint null,  
    item_num                  smallint null,  
      quantity_in_KG            float null,  
    time_spread_period        varchar(40) null,  
    time_spread_date          datetime null             
  )              
  
  create nonclustered index xx0191_pos_idx1  
     on #pos (commkt_key, trading_prd, mtm_price_source_code)   
  create nonclustered index xx0191_pos_idx2  
     on #pos (cmdty_group)   
                                
  create table #corr            
  (            
    commkt_key              int,            
    price_source_code       char(8),            
    trading_prd             char(8),            
    price_quote_date        datetime,            
    avg_closed_price        float null,            
    prvpr_avg_closed_price  float null            
  )                 
  
  create nonclustered index xx0191_corr_idx1  
     on #corr (commkt_key, trading_prd, price_source_code)   
                                                         
  create table #price                        
  (                        
     price_quote_date            datetime null,                        
     commkt_key                  int null,                        
     cmdty_code                  char(8) null,         
     mkt_code                    char(8) null,                        
     cmdty_short_name            varchar(15) null,                        
     mkt_short_name              varchar (15) null,                        
     trading_prd                 char(8) null,                        
     trading_prd_desc            varchar (40) null,                        
     last_issue_date             datetime null,                        
     last_trade_date             datetime null,                        
     price_source_code           char(8) null,                        
     low_bid_price               float null,                        
     high_asked_price            float null,                        
     avg_closed_price            float null,                    
     price_uom_code              char(4) null,                        
     price_curr_code             char(8) null,                        
     lot_size                    float(8) null,                        
     underlying_commkt_key       int null,                        
     underlying_cmdty_code       char(8) null,                        
     underlying_cmdty            varchar (15) null,                        
     underlying_mkt_code         char(8) null,                        
     underlying_mkt              varchar (15) null,                        
     underlying_source           varchar (30) null,                        
     underlying_trading_prd      varchar (30) null,                        
     underlying_quote_type       varchar (30) null,                        
     underlying_quote_diff       float(8) null,                        
     underlying_quote            varchar(156) null,                        
     prvpr_quote_date            datetime,                        
     prvpr_low_bid_price         float null,                        
     prvpr_high_asked_price      float null,                        
     prvpr_avg_closed_price      float null                       
  )                        
  
   create nonclustered index xx01178_price_idx1  
      on #price (commkt_key, trading_prd, price_source_code)  
  
   create table #tempkey  
   (  
      commkt_key            int,   
trading_prd           char(8),   
      mtm_price_source_code char(8)  
   )  
     
   create nonclustered index xx01178_tempkey_idx1  
      on #tempkey (commkt_key, trading_prd, mtm_price_source_code)  
  
   create table #porttags   
   (  
      port_num       int primary key,   
      trader_init    char(3)  
    )  
  
   /* ************************************************************************** */     
   if @AsOfDate is null   
   begin       
      set @AsOfDate = '01/01/1900'                  
     select @AsOfDate = case when config_value is null then '01/01/1900'  
                             when len(config_value) = 0 then '01/01/1900'  
                             else config_value  
                        end    
     from dbo.dashboard_configuration  
     where config_name = 'MostRecentCOBDate'                           
   end  
  
   set @time_started = (select convert(varchar, getdate(), 109))  
                        
   if @PortNum IS NOT NULL                                                                                          
   begin                                                                                           
      create table #ParentPort   
      (  
         parent_port_num int,  
         port_status     varchar(15) null  
      )    
    
      insert into #ParentPort     
         select convert(int, vchar_value), null   
         from dbo.udf_move_items_from_list_to_table(@PortNum)     
    
      while (select count(*)   
             from #ParentPort   
             where port_status is null) > 0    
      begin      
         select @PortNum = min(parent_port_num)   
         from #ParentPort   
         where port_status is null    
    
         exec dbo.usp_get_child_port_nums @PortNum, 1    
                                                                                                   
         update #ParentPort   
         set port_status = 'Complete'   
         where parent_port_num = @PortNum                                          
      end                                                                                          
     set @rows_affected = (select count(*) from #children)                                                   
      if @debugon = 1  
     begin  
         set @smsg = '# of REAL portfolioes = ' + cast(@rows_affected as varchar)   
         RAISERROR(@smsg, 0, 1) WITH NOWAIT    
         set @time_finished = (select convert(varchar, getdate(), 109))  
         set @smsg = '==> Started : ' + @time_started  
         RAISERROR (@smsg, 0, 1) WITH NOWAIT  
         set @smsg = '==> Finished: ' + @time_finished  
         RAISERROR (@smsg, 0, 1) WITH NOWAIT       
      end  
   end      
                                               
   if @ProfitCntr IS NOT NULL                                                
  begin                                                
      set @time_started = (select convert(varchar, getdate(), 109))  
    insert into #children                                                   
       select port_num, 'R'                         
      from dbo.portfolio_tag pt                        
      where tag_name = 'PRFTCNTR' and  
            exists (select 1  
                    from dbo.udf_move_items_from_list_to_table(@ProfitCntr) i  
                    where pt.tag_value = i.vchar_value) and  
            not exists (select 1  
                        from #children c  
                        where pt.port_num = c.port_num)                       
     set @rows_affected = (select count(*) from #children)                                                   
      if @debugon = 1  
     begin  
         set @smsg = '# of REAL portfolioes (filtered by ''PRFTCNTR'') = ' + cast(@rows_affected as varchar)   
         RAISERROR(@smsg, 0, 1) WITH NOWAIT    
         set @time_finished = (select convert(varchar, getdate(), 109))  
         set @smsg = '==> Started : ' + @time_started  
         RAISERROR (@smsg, 0, 1) WITH NOWAIT  
         set @smsg = '==> Finished: ' + @time_finished  
   RAISERROR (@smsg, 0, 1) WITH NOWAIT       
      end  
  end                                
  
   /* ************************************************************************** */     
  if @PositionMode in ('Historical', 'Delta')  
  begin  
     insert into #pos  
        exec dbo.usp_POSGRID_get_historical_position @AsOfDate, @ShowTimeSpread, @debugon                  
   end  
  
  if @PositionMode in ('Live', 'Delta')  
  begin               
     insert into #pos  
        exec dbo.usp_POSGRID_get_live_position @ShowTimeSpread, @debugon                  
   end     
  
   /* ************************************************************************** */     
   exec dbo.usp_POSGRID_apply_uom_conversion @debugon  
           
   /* ************************************************************************** */                          
   insert into #tempkey  
     select distinct  
        commkt_key, trading_prd, mtm_price_source_code  
     from #pos  
    
  if (@ShowPriceDelta = 'N' and   
      @ShowCorrelationedCurves = 'N')     
  begin    
     insert into #price                        
       select   
          @AsOfDate,                        
          pr.commkt_key,                        
          NULL,                        
          NULL,                        
          NULL,                        
          NULL,                        
          trading_prd,                        
          NULL,                        
          NULL,                        
          NULL,                        
          price_source_code,                        
          NULL,                        
          NULL,                        
          NULL,                        
          NULL,                        
          NULL,                        
          NULL,                        
          underlying_commkt_key,                        
          underlying_cmdty_code,                        
          underlying_cmdty_short_name,                        
          underlying_mkt_code,                        
          underlying_mkt_short_name,                        
          underlying_price_source_code,                        
          underlying_trading_prd,                        
          underlying_quote_type,                        
          commkt_premium_diff,                        
          underlying_quote,                        
          null,                        
          null,                        
          null,                        
          null                   
       from dbo.v_POSGRID_commkt_formula pr                     
       where exists (select 1   
                     from #tempkey t   
                     where pr.commkt_key = t.commkt_key and   
                           pr.trading_prd = t.trading_prd and   
                           pr.price_source_code = t.mtm_price_source_code) and  
             exists (select 1  
                      from dbo.trading_period tp with (nolock)  
                      where pr.commkt_key = tp.commkt_key and   
                            pr.trading_prd = tp.trading_prd and  
                            tp.last_trade_date >= dateadd(mm, -2, getdate()))    
     select @rows_affected = @@rowcount  
     if @debugon = 1  
     begin  
         set @smsg = 'v_POSGRID_commkt_formula: # of rows retrieved = ' + cast(@rows_affected as varchar)   
         RAISERROR(@smsg, 0, 1) WITH NOWAIT   
      end   
  end     
       
  if (@ShowPriceDelta = 'Y' or   
      @ShowCorrelationedCurves = 'Y')      
  begin                        
     insert into #price                        
       select   
          price_quote_date,                        
          pr.commkt_key,                        
          cmdty_code,                        
          mkt_code,                        
          cmdty_short_name,                        
          mkt_short_name,                        
          trading_prd,                        
          trading_prd_desc,                        
          last_issue_date,                        
          last_trade_date,                        
          price_source_code,                        
          low_bid_price,                        
          high_asked_price,                        
          avg_closed_price,                        
          price_uom_code,                        
          price_curr_code,                        
          lot_size,                        
          underlying_commkt_key,                        
          underlying_cmdty_code,                        
          underlying_cmdty,                        
          underlying_mkt_code,                        
          underlying_mkt,                        
          underlying_source,                        
          underlying_trading_prd,                        
          underlying_quote_type,                        
          underlying_quote_diff,                        
          underlying_quote,                        
          null,                        
          null,                        
          null,                        
          null                   
       from dbo.v_POSGRID_price_detail pr with (NOLOCK)                      
       where price_quote_date = @AsOfDate and   
             exists (select 1   
                     from #tempkey t   
                     where pr.commkt_key = t.commkt_key and   
                           pr.trading_prd = t.trading_prd and   
                           pr.price_source_code = t.mtm_price_source_code)                        
     select @rows_affected = @@rowcount  
     if @debugon = 1  
     begin  
         set @smsg = 'v_POSGRID_price_detail: # of rows retrieved = ' + cast(@rows_affected as varchar)   
         RAISERROR(@smsg, 0, 1) WITH NOWAIT   
      end   
                                                  
     update p               
     set prvpr_quote_date = prev_quote_date,                        
         prvpr_low_bid_price = prev_low_price,                        
         prvpr_high_asked_price = prev_high_price,                        
         prvpr_avg_closed_price = prev_closed_price                                               
     from #price p,                        
          (select price_quote_date 'prev_quote_date',  
                  pp.commkt_key,   
                  pp.price_source_code,   
                  pp.avg_closed_price 'prev_closed_price',  
                  pp.low_bid_price 'prev_low_price',  
                  pp.high_asked_price 'prev_high_price',   
                  pp.trading_prd                        
           from dbo.price pp with (NOLOCK)    
           where exists (select 1  
                         from #tempkey t   
                         where t.commkt_key = pp.commkt_key and   
                               t.mtm_price_source_code = pp.price_source_code and   
                               t.trading_prd = pp.trading_prd) and   
                 price_quote_date in (select max(price_quote_date)                         
                                    from dbo.price p2 with (NOLOCK)                        
                                    where p2.commkt_key = pp.commkt_key and   
                                          p2.price_quote_date < @AsOfDate)) oldpr                        
     where p.commkt_key = oldpr.commkt_key and   
           p.trading_prd = oldpr.trading_prd and   
           p.price_source_code = oldpr.price_source_code                        
     select @rows_affected = @@rowcount  
     if @debugon = 1  
     begin  
         set @smsg = 'update #price (prvpr_quote_date, etc): # of rows retrieved = ' + cast(@rows_affected as varchar)   
         RAISERROR(@smsg, 0, 1) WITH NOWAIT   
      end   
  end      
             
  if (@ShowCorrelationedCurves = 'Y')            
  begin                 
     update a             
     set correlated_commkt = case when corr.commkt_key is not null   
                                     then convert(varchar, corr.cmdty_code) + '/' + convert(varchar, corr.commkt)  
                                  else null  
                             end,  
         correlated_commkt_key = corr.commkt_key            
     from #pos a   
             left outer join dbo.v_POSGRID_base_corr corr  
                on a.cmdty_group = corr.cmdty_code            
     select @rows_affected = @@rowcount  
     if @debugon = 1  
     begin  
         set @smsg = 'update #pos (correlated_commkt, etc): # of rows retrieved = ' + cast(@rows_affected as varchar)   
         RAISERROR(@smsg, 0, 1) WITH NOWAIT   
      end   
  
      create nonclustered index xx0101_pos_idx3  
         on #pos (correlated_commkt_key, trading_prd)  
           
     insert into #corr            
       select commkt_key,   
              price_source_code,   
              pr.trading_prd,   
              price_quote_date,  
              avg_closed_price,  
              null            
       from dbo.price pr with (NOLOCK)                      
       where price_quote_date = @AsOfDate and   
             pr.trading_prd in ('SPOT', 'SPOT01') and   
             pr.price_source_code in ('EXCHANGE', 'PLATTS', 'ARGUS') and   
             exists (select 1   
                     from #pos pos             
                    where pr.commkt_key = pos.correlated_commkt_key)                        
     select @rows_affected = @@rowcount  
     if @debugon = 1  
     begin  
         set @smsg = 'insert #curr (1): # of rows retrieved = ' + cast(@rows_affected as varchar)   
         RAISERROR(@smsg, 0, 1) WITH NOWAIT   
      end   
  
     insert into #corr            
       select commkt_key,   
              price_source_code,   
              pr.trading_prd,   
              price_quote_date,  
              avg_closed_price,  
              null            
       from dbo.price pr with(NOLOCK)                      
       where price_quote_date = @AsOfDate and   
             pr.price_source_code in ('EXCHANGE', 'PLATTS', 'ARGUS') and   
             not exists (select 1   
                         from #corr cc   
                         where pr.commkt_key = cc.commkt_key) and   
             exists (select 1   
                     from #pos pos             
                    where pr.commkt_key = pos.correlated_commkt_key and   
                          pr.trading_prd = pos.trading_prd)              
     select @rows_affected = @@rowcount  
     if @debugon = 1  
     begin  
         set @smsg = 'insert #curr (2): # of rows retrieved = ' + cast(@rows_affected as varchar)   
         RAISERROR(@smsg, 0, 1) WITH NOWAIT   
      end   
  
     insert into #corr            
       select commkt_key,   
              price_source_code,   
              pr.trading_prd,   
              price_quote_date,  
              avg_closed_price,  
              null            
       from dbo.price pr with (NOLOCK)                      
       where price_quote_date = @AsOfDate and   
             pr.price_source_code = 'INTERNAL' and   
             not exists (select 1   
                         from #corr cc   
                         where pr.commkt_key = cc.commkt_key) and   
             exists (select 1   
                     from #pos pos             
                    where pr.commkt_key = pos.correlated_commkt_key and   
                          pr.trading_prd = pos.trading_prd)              
     select @rows_affected = @@rowcount  
     if @debugon = 1  
     begin  
         set @smsg = 'insert #curr (3): # of rows retrieved = ' + cast(@rows_affected as varchar)   
         RAISERROR(@smsg, 0, 1) WITH NOWAIT   
      end   
  
     update p                        
     set prvpr_avg_closed_price = prev_closed_price                          
     from #corr p,                        
           (select pp.commkt_key,   
                   pp.price_source_code,   
                   pp.trading_prd,   
                   price_quote_date,  
                   avg_closed_price 'prev_closed_price'            
            from dbo.price pp with (NOLOCK)         
            where exists (select 1  
                        from #pos pos  
                          where pp.commkt_key = pos.correlated_commkt_key) and   
                  price_quote_date in (select max(price_quote_date)                         
                                       from dbo.price p2 with (NOLOCK)                        
                                       where p2.commkt_key = pp.commkt_key and   
                                             p2.price_quote_date < @AsOfDate)) oldpr                        
     where p.commkt_key = oldpr.commkt_key and   
           p.trading_prd = oldpr.trading_prd and   
           p.price_source_code = oldpr.price_source_code                        
     select @rows_affected = @@rowcount  
     if @debugon = 1  
     begin  
         set @smsg = '#curr (update - prvpr_avg_closed_price): # of rows retrieved = ' + cast(@rows_affected as varchar)   
         RAISERROR(@smsg, 0, 1) WITH NOWAIT   
      end   
  
      update pos            
     set correlated_price = c.avg_closed_price,            
         correlated_price_diff = c.avg_closed_price - c.prvpr_avg_closed_price            
     from #pos pos   
             join #corr c            
                on pos.correlated_commkt_key = c.commkt_key            
     select @rows_affected = @@rowcount  
     if @debugon = 1  
     begin  
         set @smsg = '#pos (update - correlated_price, etc): # of rows retrieved = ' + cast(@rows_affected as varchar)   
         RAISERROR(@smsg, 0, 1) WITH NOWAIT   
      end   
  end                         
       
   select @tag_name = min(tag_name)  
   from dbo.portfolio_tag_definition  
   where tag_name like 'TRADER%'  
     
   while @tag_name is not null  
   begin  
      insert into #porttags (port_num, trader_init)  
        select port_num, tag_value  
        from dbo.portfolio_tag pt  
        where tag_name = @tag_name and  
              (tag_value is not null or  
               len(tag_value) > 0) and  
              exists (select 1  
                      from #pos pos  
                      where pt.port_num = pos.real_port_num) and  
              not exists (select 1  
                          from #porttags t  
                          where pt.port_num = t.port_num)  
    
      select @tag_name = min(tag_name)  
      from dbo.portfolio_tag_definition  
      where tag_name like 'TRADER%' and  
            tag_name > @tag_name  
   end  
  
   update #pos  
   set time_spread_date = convert(datetime, convert(char(6), time_spread_date, 112) + '15', 112)                               
   where time_spread_date is not null  
  select @rows_affected = @@rowcount  
  if @debugon = 1  
  begin  
      set @smsg = '#pos (update - time_spread_date): # of rows retrieved = ' + cast(@rows_affected as varchar)   
      RAISERROR(@smsg, 0, 1) WITH NOWAIT   
   end   
                                               
  if @PositionMode in ('Live', 'Historical')                
  begin     
     exec dbo.usp_POSGRID_show_position @debugon                 
  end                
                 
  if @PositionMode = 'Delta'                
  begin     
     exec dbo.usp_POSGRID_show_position_delta @debugon                  
  end                       
  
endofsp:  
if object_id('tempdb..#tempkey', 'U') is not null  
   exec('drop table #tempkey')  
if object_id('tempdb..#porttags', 'U') is not null  
   exec('drop table #porttags')  
if object_id('tempdb..#corr', 'U') is not null  
   exec('drop table #corr')  
if object_id('tempdb..#pos', 'U') is not null  
   exec('drop table #pos')  
if object_id('tempdb..#price', 'U') is not null  
   exec('drop table #price')  
GO
GRANT EXECUTE ON  [dbo].[usp_POSGRID_get_risk_position] TO [next_usr]
GO
