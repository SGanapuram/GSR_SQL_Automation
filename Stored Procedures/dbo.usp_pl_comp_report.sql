SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_pl_comp_report]  
(                            
   @root_port_num    int,                                                  
   @cob_date1        datetime = NULL,                              
   @cob_date2        datetime = NULL 
)                             
AS                              
BEGIN                                                           
set nocount on                                                  
declare @my_top_port_num   int                                                  
declare @smsg            varchar(255)                                                  
declare @status          int                                                  
declare @errcode         int                                                  
declare @asofdate datetime                                                  
 set @my_top_port_num=@root_port_num                                                  
                                                  
 set @status = 0                                                  
 set @errcode = 0                                                  
 if @my_top_port_num is null                                                  
 select @my_top_port_num = 0                                     
                               
                               
 if not exists (select 1                                                  
    from dbo.portfolio                                                  
    where port_num = @root_port_num)                                                  
 begin                                                  
 print '=> You must provide a valid port # for the argument @root_port_num!'                                                  
 print 'Usage: exec dbo.usp_dump_fx_data_for_portnum_test @root_port_num = ? [, @debugon = ?]'                                                  
 return 2                                                  
 end                                                                 
  
 if isnull(@cob_date2,'01/01/1900')='01/01/1900'  
 SELECT @cob_date2=max(pl_asof_date) from portfolio_profit_loss where port_num=@root_port_num  
   
 if isnull(@cob_date1,'01/01/1900')='01/01/1900'  
 SELECT @cob_date1=max(pl_asof_date) from portfolio_profit_loss where port_num=@root_port_num and pl_asof_date<@cob_date2  
   
   
   
                              
 create table #children                                                  
 (                                                  
   port_num int PRIMARY KEY,                                                  
   port_type char(2)                                                
 )                                                  
                              
 begin try                                                      
  exec dbo.usp_get_child_port_nums @my_top_port_num, 1                                                  
 end try                                                  
 begin catch                                                  
  print '=> Failed to execute the ''usp_get_child_port_nums'' sp due to the following error:'                                                  
  print '==> ERROR: ' + ERROR_MESSAGE()                                                  
  set @errcode = ERROR_NUMBER()                                                  
  goto errexit                                                  
 end catch                                                  
                               
 delete #children                               
 from #children c                              
 where exists (select 1                               
    from [v_portfolio_profit_loss] ppl1 ,[v_portfolio_profit_loss] ppl2                              
    where ppl1.pl_asof_date=@cob_date1                               
    and ppl2.pl_asof_date=@cob_date2                              
    and ppl1.real_port_num=ppl2.real_port_num                              
    and ppl2.real_port_num=c.port_num                              
    and (isnull(ppl1.summary_pl_amt,0)+isnull(ppl1.total_pl_no_sec_cost,0)=isnull(ppl2.summary_pl_amt,0)  +isnull(ppl2.total_pl_no_sec_cost , 0) )                               
    )                              
                                
 CREATE TABLE #pl_hist                            
 (                            
 pl_record_key int ,                            
 pl_owner_code char(8) NULL,                             
 pl_asof_date datetime ,                            
 real_port_num int ,                            
 pl_owner_sub_code char(20) NULL,                             
 pl_record_owner_key int NULL,                            
 pl_primary_owner_key1 int NULL,                            
 pl_primary_owner_key2 int NULL,                            
pl_primary_owner_key3 int NULL,                            
 pl_primary_owner_key4 int NULL,                            
 pl_secondary_owner_key1 int NULL,                            
 pl_secondary_owner_key2 int NULL,                            
 pl_secondary_owner_key3 int NULL,                            
 pl_type char(8) NULL,                             
 pl_category_type char(8) NULL,                             
 pl_realization_date datetime NULL,                            
 pl_cost_status_code char(8) NULL,                             
 pl_cost_prin_addl_ind char(8) NULL,                             
 pl_mkt_price float NULL,                            
 pl_amt float NULL,                            
 trans_id int NULL,                            
 currency_fx_rate float NULL,                            
 pl_record_qty numeric NULL,                            
 pl_record_qty_uom_code char(4) NULL,                            
 pos_num int NULL                            
 )                            
                              
  INSERT INTO #pl_hist                            
 SELECT                            
 pl_record_key ,                            
 pl_owner_code ,                            
 pl_asof_date ,                            
 real_port_num ,                            
 pl_owner_sub_code ,                            
 pl_record_owner_key ,                            
 pl_primary_owner_key1 ,                            
 pl_primary_owner_key2 ,                            
 pl_primary_owner_key3 ,                            
 pl_primary_owner_key4 ,                            
 pl_secondary_owner_key1 ,                            
 pl_secondary_owner_key2 ,                            
 pl_secondary_owner_key3 ,                            
 pl_type ,                            
 pl_category_type ,                            
 pl_realization_date ,                            
 pl_cost_status_code ,                            
 pl_cost_prin_addl_ind ,                            
 pl_mkt_price ,                            
 pl_amt ,                            
 trans_id ,                            
 currency_fx_rate ,                            
 pl_record_qty ,                            
 pl_record_qty_uom_code ,                            
 pos_num                             
 from pl_history with (NOLOCK)                          
 where pl_asof_date=@cob_date2                              
 and real_port_num in (select port_num from #children)                                 
 and pl_type not in ('W','I')                              
                              
 UNION                            
 SELECT                            
 pl_record_key ,                            
 pl_owner_code ,                            
 pl_asof_date ,                            
 real_port_num ,   pl_owner_sub_code ,                            
 pl_record_owner_key ,                            
 pl_primary_owner_key1 ,                            
 pl_primary_owner_key2 ,                            
 pl_primary_owner_key3 ,                            
 pl_primary_owner_key4 ,                            
 pl_secondary_owner_key1 ,                            
 pl_secondary_owner_key2 ,                            
 pl_secondary_owner_key3 ,                 
 pl_type ,                            
 pl_category_type ,                            
 pl_realization_date ,                            
 pl_cost_status_code ,                            
 pl_cost_prin_addl_ind ,                            
 pl_mkt_price ,                            
 pl_amt ,                            
 trans_id ,                            
 currency_fx_rate ,                            
 pl_record_qty ,                            
 pl_record_qty_uom_code ,                            
 pos_num                             
 from pl_history    with (NOLOCK)                          
 where pl_asof_date=@cob_date1                              
 and real_port_num in (select port_num from #children)                                 
 and pl_type not in ('W','I')                              
                            
                            
                            
                            
         
                            
                            
                            
                               
                              
 create table #pl                              
 (                                 
  pl_record_key int ,                              
  pl_asof_date datetime ,                              
  real_port_num int ,                             
  cost_num int NULL,                              
  pos_num int NULL,                              
  pl_owner_code char(8) NULL,                              
  pl_owner varchar(18) NULL,                          
  trade_key varchar(92) NULL,       
  trade_num int NULL,  
  order_num int NULL,  
  item_num int NULL,                         
  trade_cost_type varchar(16) NULL,                              
  pl_type_code char(8) NULL,                              
  pl_type_desc varchar(20) NULL,                              
  trade_type varchar(9) NULL,                              
  alloc_num int NULL,                              
  alloc_item int NULL,                              
  pl_amt float NULL,                              
  qty float NULL,                              
  qty_uom char(8) NULL,                              
  cmdty_short_name varchar(15) NULL,                              
  mkt_short_name varchar(15) NULL,                              
  trading_prd_desc varchar(40) NULL,                              
  trading_prd_date datetime NULL,                              
  pl_mkt_price float NULL,                              
  contr_date datetime NULL,                              
  trade_mod_date datetime NULL,                              
  avg_price float NULL,                              
  fx_rate float NULL,                              
  inhouse_ind char(1) NULL,                              
  pl_realization_date datetime NULL,                              
  counterparty nvarchar(80) NULL,    
  clearing_brkr nvarchar(80) NULL,    
  price_curr_code char(8) NULL,                              
  alloc_creation_date datetime NULL,                              
  alloc_trans_id int NULL,                              
  cost_creation_date datetime NULL,                              
  cost_trans_id int NULL,                              
  trade_trans_id int NULL,                              
  pl_trans_id int NULL,                              
  creator_init char(3) NULL                    
 )                              
                            
CREATE TABLE #associated_trades            
( TradeKey varchar(50) null,            
  AssociatedTrades nvarchar(MAX) null            
  )            
                            
                            
                            
 insert into #pl                               
      select  pl_record_key,                                                        
      pl.pl_asof_date ,                                                         
      pl.real_port_num 'PortfolioNum',                                                            
      case when pl_owner_sub_code is null then null when pl_owner_code in ( 'I','P') then null else pl_record_key end as 'COST NUMBER',                                                        
      pl.pos_num,  pl_owner_code ,                                                      
      case when pl.pl_owner_code = 'C' then 'Cost'                                                         
                  when pl_owner_code in ( 'I','P') then 'Inventory Position'                                                         
                  when pl.pl_owner_code = 'T' then 'Trade Value/MTM' else pl_owner_code end 'PL_Owner',                                                        
      case when pl_owner_sub_code = 'ADDLP' then convert (varchar,pl_record_key)                           
                  else convert(varchar,pl.pl_secondary_owner_key1) + '/' + convert(varchar,pl.pl_secondary_owner_key2)+ '/' + convert(varchar,pl.pl_secondary_owner_key3) end  'TradeKey',                                                        
      pl.pl_secondary_owner_key1,pl.pl_secondary_owner_key2,pl.pl_secondary_owner_key3,              
      case when pl_owner_sub_code  in ('WPP','W','F','PR','PO','SWAP','F','CPP', 'CPR') then 'TRADE'                                                         
                  when  pl_owner_sub_code in ('WS', 'ADDLP', 'WS', 'ADDLAI', 'ADDLA', 'ADDLTI','SPP') then 'ADDITIONAL COSTS'                                             
                  when pl_owner_sub_code is null then 'INVENTORY'                                                         
                  when pl_owner_sub_code in ('Inventory Position', 'I', 'D') then 'INVENTORY'                                                      
                   end 'TradeCostType',                             
      pl_type,                                                        
      case   when  pl_owner_sub_code in ('CPP', 'CPR') then 'CURRENCY'                                     
                 when pl_owner_sub_code is null then 'INVENTORY_POSITION'                                                          
                 when pl_owner_sub_code = 'D' then 'INVENTORY_DRAWS'                                                         
                 when  pl_owner_sub_code ='B' then 'INVENTORY_BUILD'                 
                 when pl_owner_sub_code ='W' then 'MARKET_VALUE'                                     
                 when pl_owner_sub_code ='SWAP' then 'MTMVALUE'                                                         
                 when pl_owner_sub_code ='PO' then 'PROVISIONAL OFFSET'                                                        
                 when pl_owner_sub_code ='PR' then 'PROVISIONAL'                                              
     when pl_owner_sub_code in ('F','X') and pl_type='U' then 'MARKET_VALUE'                                      
              when pl_owner_sub_code in ('F','X') and pl_type='R' then 'TRADE_VALUE'                                          
     when pl_owner_sub_code in ('F','X') and pl_type='C' then 'TRADE_COST'                                            
                 when pl_owner_sub_code ='NO' then 'NETOUT'                                       
                 when pl_owner_sub_code in ('ADDLA','ADDLAA','ADDLAI', 'ADDLP','ADDLSWAP','ADDLTI', 'BC','FBC','JV', 'MEMO','OBC','PS','PTS', 'SAC',  'SPP',   
            'STC',  'SWBC', 'TAC', 'TPP',  'WAP', 'WO',   'WS'  ) then 'SERVICES'                              
     when pl_owner_sub_code in ('BO','BOAI','BPP','E','O','OPP','OTC','WPP') then 'TRADE_VALUE'                                            
     when pl_owner_sub_code in ('C','NO') then 'TRADE_COST'                                    
                 when pl_owner_sub_code in ('Inventory Position', 'I') then 'INVENTORY'                                    
             else pl_owner_sub_code end 'PLTypeDesc',                                                      
      case when pl_owner_code in ('I', 'P')  then 'INVENTORY'      
      else isnull(isnull(case                             
       when tor.order_type_code  in ('SWAP','SWAPFLT') then 'SWAP'                             
          when pl_owner_sub_code in ('ADDLA','ADDLAA','ADDLAI', 'ADDLP','ADDLSWAP','ADDLTI', 'BC','FBC','JV', 'MEMO','OBC','PS','PTS', 'SAC',  'SPP',   
            'STC',  'SWBC', 'TAC', 'TPP',  'WAP', 'WO',   'WS'  ) then 'SERVICES'                                 
      else tor.order_type_code end,t.trade_status_code),'OTHER')                             
      end as order_type_code,                                                               
      case when pl_owner_sub_code = 'D' then pl_primary_owner_key1                                                         
            when pl_owner_sub_code  = 'WPP' and c.cost_owner_code!= 'TI' then cost_owner_key1 else null end as AllocationNum,                                                        
      case when pl_owner_sub_code = 'D' then pl_primary_owner_key2                                                         
            when pl_owner_sub_code  = 'WPP' and c.cost_owner_code!= 'TI' then cost_owner_key2 else null end as AllocationITEM,                   
      pl_amt 'PLAmt',                                                        
      case when pl_record_qty is null and pl_owner_sub_code is null                                               
   then pos.long_qty-short_qty                                               
   when  pl_record_qty is null and pl_owner_sub_code is not null                                               
   then case when ti.p_s_ind='S' then -1 else 1 end * ti.contr_qty else pl_record_qty end as Quantity,                       
   case when pl_record_qty_uom_code is null and pl_owner_sub_code is null then pos.qty_uom_code                                                        
                  when  pl_record_qty_uom_code is null and pl_owner_sub_code is not null then ti.contr_qty_uom_code                                                        
                  when  pl_owner_sub_code in ('CPP', 'CPR') then cost_price_curr_code                                                        
                  else pl_record_qty_uom_code end as QTY_UOM,                                                        
   case when pl_owner_sub_code = 'SPP' then 'STORAGE'                                               
   when pl_owner_sub_code in ('ADDLA','ADDLAA','ADDLAI', 'ADDLP','ADDLSWAP','ADDLTI', 'BC','FBC','JV', 'MEMO','OBC','PS','PTS', 'SAC',  'SPP',   
            'STC',  'SWBC', 'TAC', 'TPP',  'WAP', 'WO',   'WS'  )                                                
   then c.cost_code else cmdty.cmdty_short_name end as Commodity,                                                        
   mkt.mkt_short_name as Market,                                                        
      case  when order_type_code in ('SWAP','SWAPFLT') 
				then convert(char(3),upper(datename(mm,quote_end_date)))+'-'+substring(convert(char,datepart(yy,quote_end_date)),3,4)
			when tp.trading_prd_desc like 'W-%' 
				then 'W-'+ convert(varchar,datepart(wk,first_del_date))+' (' +substring(trading_prd_desc,7,5)+') ' + substring(trading_prd_desc,13,5)
			else tp.trading_prd_desc 
      end  as TradingPrd,                                                        
      case  when order_type_code in ('SWAP','SWAPFLT') 
				then quote_end_date
	      else tp.last_issue_date
      end last_issue_date,                                               
      pl.pl_mkt_price,                                                        
      t.contr_date as ContractDate,                                                        
      t.trade_mod_date as TradeModDate,                                                        
        case when pl_owner_sub_code in ('P', 'I') then pos.avg_purch_price else ti.avg_price end 'avg_price',                                                        
      case when currency_fx_rate is null then 1 else currency_fx_rate end as FX_RATE,                                    
      inhouse_ind,                                                
      isnull(isnull(c.cost_eff_date,last_trade_date),pl_realization_date),                                                        
      case  when pl.pl_owner_code = 'C' then isnull(a1.acct_short_name,cpty.acct_short_name)  
      when t.inhouse_ind = 'I' then 'INTERNAL-'+++ '-' + convert(varchar,t.port_num)                                               
   end as Counterparty  ,   
   clr.acct_short_name,                                                  
  isnull(c.cost_price_curr_code,ti.price_curr_code ) price_curr_code,                                        
  alloc.creation_date as alloc_creation_date  ,                                          
  alloc.trans_id,                                         
  c.creation_date as cost_creation_date   ,                                 
  c.trans_id,                                
  t.trans_id,                                
  pl.trans_id,                              
  case when c.cost_prim_sec_ind='S' then c.creator_init                                       
    when cost_owner_code in ('A','AA','AI') and cost_prim_sec_ind='P' then alloc.sch_init                                      
    when cost_owner_code in ('TI') and cost_prim_sec_ind='P' then t.creator_init                                      
  end 'creator_init'                                      
      from #pl_hist pl WITH (NOLOCK)                                                   
      left outer join position pos WITH (NOLOCK) on pl.pos_num = pos.pos_num                                                        
      left outer join commodity cmdty  on cmdty.cmdty_code= pos.cmdty_code                                                        
      left outer join market mkt on mkt.mkt_code= pos.mkt_code                             
      left outer join trading_period tp on  pos.commkt_key= tp.commkt_key and tp.trading_prd = pos.trading_prd                                                         
      left outer join trade_item ti  with (NOLOCK) on ti.trade_num = pl.pl_secondary_owner_key1 and ti.order_num = pl.pl_secondary_owner_key2                                               
      --left outer join allocation_item ai ON ti.trade_num=ai.trade_num and ti.order_num=ai.order_num and ti.item_num=ai.item_num and ai                                            
      and ti.item_num = pl.pl_secondary_owner_key3 and ti.real_port_num = pl.real_port_num                                                        
      --left outer join price p on p.commkt_key = pos.commkt_key and p.trading_prd = pos.trading_prd                                                        
      left outer join trade_order tor  with (NOLOCK) on  tor.trade_num = pl.pl_secondary_owner_key1 and tor.order_num = pl.pl_secondary_owner_key2                                             
      left outer join accumulation acc with (nolock) on acc.trade_num= pl.pl_secondary_owner_key1 and acc.order_num = pl.pl_secondary_owner_key2 and acc.item_num=pl.pl_secondary_owner_key2 and order_type_code in ('SWAP','SWAPFLT')      
      left outer join trade t on t.trade_num = ti.trade_num                                                        
      left outer join cost c WITH (NOLOCK) on c.cost_num = pl.pl_record_key and pl.pl_owner_code = 'C'                                                        
      left outer join allocation alloc ON alloc.alloc_num =c.cost_owner_key1 and cost_owner_code in ('A','AA','AI')                                            
      left outer join account a1 on a1.acct_num = c.acct_num                                                        
      left outer join account clr ON clr.acct_num=ti.exch_brkr_num  
      --left outer join inventory i on i.open_close_ind='O' and i.pos_num = pl.pos_num and pl_owner_sub_code is null                                                        
      left outer join account cpty on cpty.acct_num = t.acct_num                                                       
      left outer join trade_item_curr tic on tic.trade_num = pl.pl_secondary_owner_key1 and tic.order_num = pl.pl_secondary_owner_key2 and tic.item_num = pl.pl_secondary_owner_key3                                                    
      where                                                        
      pl_type not in ('W','I')                                                    
  and  pl.pl_asof_date=@cob_date2                              
  and pl.real_port_num in (select port_num from #children)                              
                               
 union                              
                            
                  
 select                               
 pl_record_key ,                              
 pl_asof_date ,                              
 real_port_num ,                              
 case when pl_owner_sub_code is null then null when pl_owner_code in ( 'I','P') then null else pl_record_key end   ,                              
 pos_num ,                              
 pl_owner_code ,                              
       case when pl.pl_owner_code = 'C' then 'Cost'                                                         
                  when pl_owner_code in ( 'I','P') then 'Inventory Position'                                                         
                  when pl.pl_owner_code = 'T' then 'Trade Value/MTM' else pl_owner_code end 'PL_Owner',                                                        
      case when pl_owner_sub_code = 'ADDLP' then convert (varchar,pl_record_key)                                                         
                  else convert(varchar,pl.pl_secondary_owner_key1) + '/' + convert(varchar,pl.pl_secondary_owner_key2)+ '/' + convert(varchar,pl.pl_secondary_owner_key3) end  'TradeKey',                                                        
      pl.pl_secondary_owner_key1,pl.pl_secondary_owner_key2,pl.pl_secondary_owner_key3,                                
      case when pl_owner_sub_code  in ('WPP','W','F','PR','PO','SWAP','F','CPP', 'CPR') then 'TRADE'                                                         
                  when  pl_owner_sub_code in ('WS', 'ADDLP', 'WS', 'ADDLAI', 'ADDLA', 'ADDLTI','SPP') then 'ADDITIONAL COSTS'                                                         
         when pl_owner_sub_code is null then 'INVENTORY'                                                         
                  when pl_owner_sub_code in ('Inventory Position', 'I', 'D') then 'INVENTORY'                                                      
                   end 'TradeCostType',                                                        
      pl_type,                                                        
                                          
      case   when  pl_owner_sub_code in ('CPP', 'CPR') then 'CURRENCY'                                     
                 when pl_owner_sub_code is null then 'INVENTORY_POSITION'                                          
                 when pl_owner_sub_code = 'D' then 'INVENTORY_DRAWS'                                                         
                 when  pl_owner_sub_code ='B' then 'INVENTORY_BUILD'                                      
                 when pl_owner_sub_code ='W' then 'MARKET_VALUE'                                                         
                 when pl_owner_sub_code ='SWAP' then 'MTMVALUE'                                                         
                 when pl_owner_sub_code ='PO' then 'PROVISIONAL OFFSET'                                                        
                 when pl_owner_sub_code ='PR' then 'PROVISIONAL'                                              
  when pl_owner_sub_code in ('F','X') and pl_type='U' then 'MARKET_VALUE'                                      
              when pl_owner_sub_code in ('F','X') and pl_type='R' then 'TRADE_VALUE'                                          
     when pl_owner_sub_code in ('F','X') and pl_type='C' then 'TRADE_COST'                                            
                 when pl_owner_sub_code ='NO' then 'NETOUT'                                       
                 when pl_owner_sub_code in ('ADDLA','ADDLAA','ADDLAI', 'ADDLP','ADDLSWAP','ADDLTI', 'BC','FBC','JV',   
           'MEMO','OBC','PS','PTS', 'SAC',  'SPP',  'STC',  'SWBC', 'TAC', 'TPP',  'WAP', 'WO',   'WS'  ) then 'SERVICES'                         
     when pl_owner_sub_code in ('BO','BOAI','BPP','E','O','OPP','OTC','WPP') then 'TRADE_VALUE'                                            
     when pl_owner_sub_code in ('C','NO') then 'TRADE_COST'                                    
                 when pl_owner_sub_code in ('Inventory Position', 'I') then 'INVENTORY'                                    
                 else pl_owner_sub_code end 'PLTypeDesc',                                                      
   NULL ,                              
   NULL ,                              
   NULL,                              
   pl_amt ,                              
   pl_record_qty ,                              
   pl_record_qty_uom_code ,                       
   NULL ,                              
   NULL,                              
   NULL ,                              
   NULL ,                              
   pl_mkt_price ,                              
   NULL ,                              
   NULL ,                              
   NULL ,                              
   currency_fx_rate ,                              
   NULL ,                              
   pl_realization_date ,                              
   NULL ,                              
   NULL ,     
   NULL ,                           
   NULL ,                              
   NULL ,                              
   NULL ,                              
   NULL ,                              
   NULL ,                              
   pl.trans_id ,                              
   NULL                            
    from #pl_hist  pl                            
   where pl_asof_date=@cob_date1                              
   and real_port_num in (select port_num from #children)                              
                                
                               
  update #pl                    
  SET clearing_brkr=acct_short_name  
  from #pl pl, trade_item_fut tif with (nolock) , account ac with (nolock)   
  where pl.trade_num=tif.trade_num  
  and pl.order_num=tif.order_num  
  and pl.item_num=tif.item_num  
  and ac.acct_num=tif.clr_brkr_num  
  
  update #pl                    
  SET clearing_brkr=acct_short_name  
  from #pl pl, trade_item_exch_opt tif with (nolock) , account ac with (nolock)   
  where pl.trade_num=tif.trade_num  
  and pl.order_num=tif.order_num  
  and pl.item_num=tif.item_num  
  and ac.acct_num=tif.clr_brkr_num  
      
                    
  CREATE TABLE #PlDelta                    
  (                    
  DeltaPL float  NULL,                    
  DeltaFxPL float  NULL,                    
  TradeKey varchar(255) NULL,                     
  TradeCostType varchar(255) NULL,                     
  Commodity varchar(255) NULL,                     
  Market varchar(255) NULL,                     
  TradingPrd varchar(255) NULL,                     
  TradeType varchar(255) NULL,                     
  PlTypeDesc varchar(255) NULL,                     
  Allocation varchar(100) NULL,                     
  AvgPrice float NULL,                    
  MarketPrice float NULL,                    
  Qty float NULL,                    
  QtyUom char(8) NULL,                    
  FxRate float NULL,                    
  InhouseInd char(1) NULL,                    
  PLRealizationDate datetime NULL,                    
  PLRealizeMonth datetime NULL, --varchar(20)  NULL,                    
  PLRealizeYear varchar(10)  NULL,                  
  PLRealizeDay varchar(10) NULL,                    
  ContractDate datetime NULL,                    
  Counterparty nvarchar(255) NULL,                    
  DeltaTradePrice float NULL,                    
  DeltaMarketPrice float NULL,                    
  DeltaFxRate float NULL,                    
  cob1AvgPrice float NULL,                    
  cob1MktPrice float NULL,                    
  cob1PlAmt float NULL,                    
  cob2PlAmt float NULL,                    
  Currency varchar(8) NULL,                    
  cob1FxRate float NULL,                    
  CostCreation datetime NULL,                    
  ChangeType varchar(10) NULL,                    
  NewContract varchar(1) NULL,                    
  ModifiedContract varchar(1) NULL,                    
  NewCost varchar(1) NULL,                    
  NewAllocation varchar(1) NULL,                    
  ModifiedAllocation varchar(1) NULL,                  
  FxRelatedInd varchar(1) NULL,                    
  PLRecordKey int NULL,                    
  PLType char(8) NULL,                    
  cobDate1 datetime NULL,                    
  cob1Calc datetime NULL,                    
  cobDate2 datetime NULL,                    
  cob2Calc datetime NULL,                    
  TradeModDate datetime NULL,                    
  PortNum int NULL,                    
  TradingPrdDate datetime NULL,                    
  PortfolioName varchar(100) NULL,                    
  TradingEntity nvarchar(100) NULL,                    
  ProfitCenter varchar(100) NULL,                    
  GroupCode varchar(100) NULL,                    
  Division varchar(100) NULL,                    
  PostionNumber int NULL,                    
  StartTransID int NULL,                    
  EndTransID int NULL,                    
  [Owner] varchar(100) NULL,  
  ClearingBroker nvarchar(100) NULL,          
  )                    
                    
                               
 insert into #PlDelta                               
 SELECT                               
    DeltaPL,                   
    DeltaFxPL,                             
    TradeKey,                              
    TradeCostType,                              
    Commodity,                              
    Market,                              
    TradingPrd,                              
    TradeType,                              
    PlTypeDesc,                              
    Allocation,                              
    AvgPrice,                              
    MarketPrice,                              
    Qty,                              
    QtyUom,                              
    FxRate,                              
 InhouseInd,                              
    PLRealizationDate,                              
    --case when isnull(PLRealizationDate,@cob_date2)<@cob_date2 then '.SPOT'                     
   --WHEN PLRealizationDate is null then '.SPOT'                    
   --ELSE       
   DATEADD(dd,0,DATEADD(mm, DATEDIFF(mm,0,PLRealizationDate),0))  PLRealizeMonth,                      
    case when isnull(PLRealizationDate,@cob_date2)<@cob_date2 then '.SPOT'                     
   WHEN PLRealizationDate is null then 'SPOT'                    
   ELSE convert(varchar,datepart(yyyy,PLRealizationDate)) END PLRealizeYear,                              
    case when isnull(PLRealizationDate,@cob_date2)<@cob_date2 then '.SPOT'                     
   WHEN PLRealizationDate is null then '.SPOT'                    
   ELSE                     
    substring (convert(varchar,PLRealizationDate,112),7,2)                    
   END PLRealizeDay,                            
    ContractDate,                              
 Counterparty,                              
    --DeltaFxPL,                              
    DeltaTradePrice,                              
    DeltaMarketPrice,                              
    DeltaFxRate,                              
    cob1AvgPrice,                              
    cob1MktPrice,                              
    cob1PlAmt,                              
    cob2PlAmt,                              
    isnull(Currency,desired_pl_curr_code )Currency,                              
    cob1FxRate,                           
    CostCreation,                              
    ChangeType,                              
    case when cob1Calc is null then 'Y'                              
  when ContractDate >= cob1Calc and ContractDate < cob2Calc then 'Y'                               
  when cob1Calc is null and ContractDate  >= cob1Calc then 'Y'                               
  else 'N' end as NewContract,                              
    case when cob1Calc is null then 'Y'                                
  when TradeModDate > cob1Calc and TradeModDate <=cob2Calc then 'Y'                               
  else 'N' end 'ModifiedContract',                              
    case when cob1Calc is null then 'Y'                               
  when CostCreation     >= cob1Calc and CostCreation    < cob2Calc then 'Y'                               
  when cob1Calc is null and CostCreation    <= cob2Calc then 'Y'                               
   else 'N' end as NewCost,                              
    case when cob1Calc is null then 'Y'                               
  when AllocationCreateDate >= cob1Calc and AllocationCreateDate < cob2Calc then 'Y'                               
  when cob1Calc is null and AllocationCreateDate <= cob2Calc then 'Y'                               
  else 'N' end as NewAllocation,                              
    case when cob1Calc is null then 'N'                              
  when AllocTransID  >= StartTransID and AllocTransID < EndTransID   and AllocationCreateDate < cob1Calc  then 'Y'                               
  else 'N' end ModifiedAllocation,                         
  FxRelatedInd     ,                    
    PLRecordKey,                              
    PLType,                              
    cobDate1,                              
    cob1Calc,                              
    cobDate2,                              
    cob2Calc,                              
    TradeModDate,                              
    PortNum,                              
    DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,TradingPrdDate)+1,0)) TradingPrdDate,                              
    port.port_short_name as PortfolioName,                              
    te.acct_short_name  as TradingEntity,                              
    pt.profit_center_code as ProfitCenter,                              
    pt.group_code as GroupCode,                              
    pt.division_code as Division,                              
    PostionNumber,                              
    StartTransID,                              
    EndTransID,                         
    [Owner],  
    clearing_brkr                    
                                   
    from                              
    (                              
    SELECT                              
    case when EndCOB.pl_record_key is null then 'DELETED' when StartCOB.pl_record_key is null then 'NEW' else 'CHANGE' end 'ChangeType',                              
    case when StartCOB.pl_record_key is null then EndCOB.pl_record_key else StartCOB.pl_record_key end 'PLRecordKey',                              
    EndCOB.pl_asof_date 'cobDate2',                              
    isnull(EndCOB.real_port_num,StartCOB.real_port_num) 'PortNum',                              
    EndCOB.pos_num 'PostionNumber',                              
    EndCOB.pl_owner_code,                              
    case when StartCOB.pl_amt is null then EndCOB.pl_owner else StartCOB.pl_owner end 'Owner',                              
    isnull(EndCOB.trade_key,StartCOB.trade_key) 'TradeKey',                              
    case when EndCOB.pl_amt is null then StartCOB.trade_cost_type else EndCOB.trade_cost_type end 'TradeCostType',                              
    EndCOB.pl_type_code 'PLType',                              
    case when EndCOB.pl_amt is null then StartCOB.pl_type_desc else EndCOB.pl_type_desc end 'PlTypeDesc',                              
    EndCOB.avg_price 'AvgPrice',                EndCOB.pl_mkt_price 'MarketPrice',                              
    EndCOB.pl_amt 'cob2PlAmt',                              
    case when EndCOB.qty is null then StartCOB.qty else EndCOB.qty end 'Qty',                              
    EndCOB.qty_uom 'QtyUom',                              
    case when EndCOB.cmdty_short_name is null then StartCOB.cmdty_short_name else EndCOB.cmdty_short_name end'Commodity',                              
    case when EndCOB.mkt_short_name is null then StartCOB.mkt_short_name else EndCOB.mkt_short_name end 'Market',                              
    case when EndCOB.pl_amt is null then StartCOB.trading_prd_desc else EndCOB.trading_prd_desc end 'TradingPrd',         
    case when EndCOB.price_curr_code is null and EndCOB.fx_rate in (1,-1) then 'USD' else EndCOB.price_curr_code end  'Currency',                              
    case when EndCOB.cost_creation_date is null and StartCOB.trade_cost_type = 'ADDITIONAL COSTS' then StartCOB.cost_creation_date                               
    when EndCOB.trade_cost_type = 'ADDITIONAL COSTS' then EndCOB.cost_creation_date else null end 'CostCreation',                                  
    case when EndCOB.creator_init is null then StartCOB.creator_init else EndCOB.creator_init end 'Creator',                              
    EndCOB.fx_rate 'FxRate',                              
 EndCOB.inhouse_ind 'InhouseInd',                              
    case when EndCOB.pl_realization_date is null then StartCOB.pl_realization_date else EndCOB.pl_realization_date end 'PLRealizationDate',                              
    case when EndCOB.contr_date is null then StartCOB.contr_date else EndCOB.contr_date  end 'ContractDate',                              
    trade_mod_date 'TradeModDate',                              
    EndCOB.alloc_creation_date 'AllocationCreateDate',                              
    EndCOB.counterparty 'Counterparty',                              
    isnull(EndCOB.trade_type,StartCOB.trade_type) 'TradeType',                      
    convert(varchar,EndCOB.alloc_num)+'/'+convert(varchar,EndCOB.alloc_item) 'Allocation',                              
    case when EndCOB.pl_amt is null then StartCOB.trading_prd_date else EndCOB.trading_prd_date end 'TradingPrdDate',                              
    EndCOB.pl_calc_date 'cob2Calc',                              
    EndCOB.pl_trans_id as EndTransID,                              
    (isnull(EndCOB.avg_price,0)-isnull(StartCOB.avg_price,0)) 'DeltaTradePrice',                              
    (isnull(EndCOB.pl_mkt_price,0)-isnull(StartCOB.pl_mkt_price,0)) 'DeltaMarketPrice',                              
    (isnull(EndCOB.fx_rate,0)-isnull(StartCOB.fx_rate,0)) 'DeltaFxRate',                         
    (isnull(EndCOB.pl_amt,0)-isnull(StartCOB.pl_amt,0)) 'DeltaPL',                              
    case when (isnull(EndCOB.fx_rate,1) in (1,0)  OR isnull(StartCOB.fx_rate,1) in (1,0) )                   
   then 0                   
   else isnull(StartCOB.pl_amt,1)/isnull(StartCOB.fx_rate,1) * (isnull(EndCOB.fx_rate,0)-isnull(StartCOB.fx_rate,0)) end 'DeltaFxPL',                   
   --else round(isnull(EndCOB.pl_amt/EndCOB.fx_rate,0)- end 'DeltaFxPL',                              
                      
    ---StartCOB.pl_record_key 'PLRecordKeyPrev',                              
    StartCOB.pl_asof_date 'cobDate1',                              
    ---StartCOB.real_port_num 'PortNumPrev',                              
    ---StartCOB.pos_num 'PostionNumberPrev',                              
    StartCOB.pl_owner 'OwnerPrev',                              
    StartCOB.trade_key 'TradeKeyPrev',                              
    ---StartCOB.trade_cost_type 'TradeCostTypePrev',                              
    ----StartCOB.pl_type_code 'PLTypePrev',                              
    ---StartCOB.pl_type_desc 'PlTypeDescPrev',                              
    StartCOB.avg_price 'cob1AvgPrice',                              
    StartCOB.pl_mkt_price 'cob1MktPrice',                              
    StartCOB.pl_amt 'cob1PlAmt',                              
    ---StartCOB.qty 'QtyPrev',                              
    ---StartCOB.qty_uom 'QtyUomPrev',                              
    ---StartCOB.cmdty_short_name 'CommodityPrev',                              
    ---StartCOB.mkt_short_name 'MarketPrev',                              
    ----StartCOB.trading_prd_desc 'TradingPrdPrev',                              
    StartCOB.fx_rate 'cob1FxRate',                              
    ---StartCOB.counterparty 'CptyPrev',              
    StartCOB.pl_calc_date 'cob1Calc',                              
    ---StartCOB.trade_type 'TradeTypePrev',                              
    convert(varchar,StartCOB.alloc_num)+'/'+convert(varchar,StartCOB.alloc_item) 'AllocationPrev',                              
    StartCOB.alloc_num as AllocNum,                              
StartCOB.alloc_trans_id as AllocTransID,                              
    StartCOB.alloc_item as AllocationItem,                              
StartCOB.trading_prd_date  'TradingPrdDatePrev',                              
    StartCOB.pl_trans_id as StartTransID    ,                          
    case when EndCOB.pl_type_desc='CURRENCY' then 'Y'                    
   when (isnull(EndCOB.fx_rate,0)  not in (1,-1,0) OR isnull(StartCOB.fx_rate,0) not in (1,-1,0)) then 'Y'                     
   when  isnull(EndCOB.price_curr_code,'USD') not in ('USD','USC') then 'Y'                     
   else 'N'                     
 end 'FxRelatedInd'    ,  
 EndCOB.clearing_brkr                      
    from                              
    ( select a.pl_record_key,                              
    a.pl_asof_date,                              
    a.real_port_num,                              
    a.pos_num,                              
    a.pl_owner_code,         
    a.pl_owner,                              
    a.trade_key,                              
    a.trade_cost_type,                              
    a.pl_type_code,                              
    a.pl_type_desc,                              
    a.pl_mkt_price,                              
    a.avg_price,                              
    a.pl_amt,                              
    a.qty,                              
    a.qty_uom,                              
    case when a.pl_owner='Cost' and a.trade_cost_type='COST' and a.cmdty_short_name is null then 'Cost' else a.cmdty_short_name end cmdty_short_name ,                              
    a.mkt_short_name,                              
    a.trading_prd_desc,                              
    a.fx_rate,                              
 a.inhouse_ind,                              
    a.pl_realization_date,                              
    a.contr_date ,                              
    a.trade_mod_date,                              
    a.counterparty,                              
    a.trade_type ,                              
    a.alloc_num ,                         
    a.creator_init,                              
    a.alloc_item,                              
    a.trading_prd_date,                              
    a.price_curr_code,                              
 a.cost_creation_date,                              
    ppl.pl_calc_date,                              
    a.alloc_creation_date,                              
    a.alloc_trans_id,                              
    ppl.trans_id pl_trans_id  ,clearing_brkr                            
    from #pl a, portfolio_profit_loss ppl                               
    where                               
 ppl.pl_asof_date = a.pl_asof_date                               
 and ppl.port_num = a.real_port_num                              
 and ppl.pl_asof_date=@cob_date2                              
 and exists (select 1 from #children c where c.port_num=ppl.port_num)                              
    )                              
    EndCOB                              
    FULL OUTER  JOIN                              
    ( select a.pl_record_key,                              
    a.pl_asof_date,                              
    a.real_port_num,                              
    a.pos_num,                              
    a.pl_owner_code,                              
    a.pl_owner,                              
    a.trade_key,                              
    a.trade_cost_type,                              
    a.pl_type_code,                              
    a.pl_type_desc,                              
    a.pl_mkt_price,                              
    a.avg_price,                              
    a.pl_amt,                              
    a.qty,             
    a.qty_uom,                              
    case when a.pl_owner='Cost' and a.trade_cost_type='COST' and a.cmdty_short_name is null then 'Cost' else a.cmdty_short_name end cmdty_short_name ,                              a.mkt_short_name,                              
    a.trading_prd_desc,                              
    a.fx_rate,                              
    a.pl_realization_date,                              
    a.contr_date ,                              
    a.counterparty,                              
    a.trade_type ,                              
    a.alloc_num ,                              
    a.alloc_item,                              
    a.trading_prd_date,                              
    a.creator_init,                              
    a.price_curr_code,                              
    a.cost_creation_date,                              
    a.alloc_trans_id,                              
    ppl.trans_id pl_trans_id,                              
    ppl.pl_calc_date   ,clearing_brkr                           
    from #pl a, portfolio_profit_loss ppl                                 
    where                               
    ppl.pl_asof_date = a.pl_asof_date and                               
    ppl.port_num = a.real_port_num                              
     and ppl.pl_asof_date=@cob_date1                              
     and exists (select 1 from #children c where c.port_num=ppl.port_num)                              
    )                              
    StartCOB                              
    ON EndCOB.real_port_num=StartCOB.real_port_num                              
    and EndCOB.pl_record_key=StartCOB.pl_record_key              
    and EndCOB.pl_type_code=StartCOB.pl_type_code                              
    and EndCOB.pl_owner_code=StartCOB.pl_owner_code                              
    )a                              
    LEFT OUTER JOIN jms_reports pt ON pt.port_num=a.PortNum                              
    LEFT OUTER JOIN portfolio port ON port.port_num=a.PortNum                               
    LEFT OUTER JOIN account te ON te.acct_num=port.trading_entity_num                              
    where  round(DeltaPL,0)!= 0                              
                
                
                
                
 update pd                    
  set Commodity=pl.Commodity,                    
   Market=pl.Market,                    
   TradingPrd=pl.TradingPrd,                    
   AvgPrice=pl.AvgPrice,                    
   MarketPrice=pl.MarketPrice,                    
   TradeType=pl.TradeType,                    
   InhouseInd=pl.InhouseInd,                    
   Currency=pl.Currency,                    
   QtyUom=pl.QtyUom,                    
   ChangeType=pl.ChangeType,                    
   TradingPrdDate=pl.TradingPrdDate                    
 FROM #PlDelta pd, #PlDelta pl                    
 WHERE pd.TradeKey=pl.TradeKey                    
 AND pd.TradeCostType=pl.TradeCostType                    
 AND pd.TradeType is null                    
 and pl.TradeType is not null                    
                    
 update #PlDelta                    
  set TradeType='DELETED', ChangeType='DELETED'   ,FxRelatedInd='N'                 
  WHERE isnull(TradeType,'')=''                    
              
update #PlDelta                    
  set FxRelatedInd='N'   , Currency='USD'              
  WHERE isnull(DeltaFxRate,0)  in (0,1)               
                  
                
             
             
 insert into #associated_trades            
  SELECT distinct TradeKey,ass_trade_key             
  from                                       
 (   select                                               
   distinct TradeKey,                                                  
    stuff((                                     
       SELECT distinct ', '+  (convert(varchar,phys_trade_num)+'/'+convert(varchar,phys_order_num)+'/'+convert(varchar,phys_item_num))             
     from hedge_physical hp                                      
   WHERE p.TradeKey=(convert(varchar,hp.trade_num)+'/'+convert(varchar,hp.order_num)+'/'+convert(varchar,hp.item_num))             
     for xml path('')                                                  
    ),1,1,'') as ass_trade_key             
    from #PlDelta p             
    group by TradeKey            
   ) pp            
  WHERE  exists (select 1 from #PlDelta p where p.TradeKey=pp.TradeKey) and ass_trade_key is not null            
                 
            
 update #PlDelta set Counterparty=  Market      
 where QtyUom='LOTS'      
   
 update #PlDelta set  TradeType='FUTURE'     
 where QtyUom='LOTS' and TradeType='EFPEXCH'  
                     
 update #PlDelta set  TradeType='PHYSICAL'     
 where QtyUom<>'LOTS' and TradeType='EFPEXCH'  
  
  
 SELECT         
 * , case when (NewContract='Y' OR NewCost='Y') then 'NEW-BIZ' ELSE 'LEGACY' end 'NewBizInd'           ,         
 case when Counterparty in ('NYMEX','THE ICE','LCH CLEARNET','SGX','NOS CLEARING') OR QtyUom='LOTS' OR TradeType='FUTURE' then 'CLEARED'        
      when InhouseInd in ('Y','I') then 'INTERNAL'    
 else 'OTC' end 'InstrumentType'  ,    
 case when PLRealizationDate>cobDate2 then 'Unrealized' else 'Realized' end 'PLRealizationInd'    ,  
 tag_value 'BookingCompany'  
 from #PlDelta  pl            
 LEFT OUTER JOIN #associated_trades ast ON ast.TradeKey=pl.TradeKey            
 LEFT OUTER JOIN portfolio_tag pt ON pt.port_num=pl.PortNum and tag_name='BOOKCOMP'  
 LEFT OUTER JOIN account bcomp ON bcomp.acct_num=pt.tag_value  
                                                
errexit:                                                  
if @errcode > 0                                                  
   set @status = 2                                                                                                      
END                     
GO
GRANT EXECUTE ON  [dbo].[usp_pl_comp_report] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_pl_comp_report', NULL, NULL
GO
