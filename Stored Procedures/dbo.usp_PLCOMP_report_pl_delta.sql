SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_PLCOMP_report_pl_delta]           
(          
@cob_date1 datetime,          
@cob_date2 datetime,          
@tag_xml_string xml = NULL,          
@debugon bit = 0,          
@show_transfer_prices bit = 0)          
AS          
SET NOCOUNT ON          
DECLARE @status int,          
    @smsg varchar(800),          
    @rows_affected int,          
    @time_started varchar(20),          
    @time_finished varchar(20),          
    @sql varchar(max),          
    @oid int,          
    @last_oid int,          
    @colname sysname,          
    @tag_name varchar(40),          
    @entity_name varchar(40),          
    @new_TAG_columns varchar(max),          
    @hDoc int          
          
SET @status = 0          
if object_id('tempdb..#PlDelta', 'U') is not null                            
   exec('drop table #PlDelta')                            
if object_id('tempdb..#portpl1', 'U') is not null                            
   exec('drop table #portpl1')                            
if           
object_id('tempdb..#portpl2', 'U') is not null                            
   exec('drop table #portpl2')                            
if object_id('tempdb..#xx101_porttags', 'U') is not null                            
   exec('drop table #xx101_porttags')                               
if object_id('tempdb..#xx101_titags', 'U') is not null                            
   exec('drop table #xx101_titags')                               
if object_id('tempdb..#tag_column_info', 'U') is not null                            
   exec('drop table #tag_column_info')           
             
create table #PlDelta (          
      DeltaPL                   float NULL,                                                
      DeltaFxPL                 float NULL,                                              
      TradeKey                  varchar(255) NULL,                                                 
      TradeCostType             varchar(255) NULL,                                                 
      Commodity                 varchar(255) NULL,                                
      Market                    varchar(255) NULL,                                                 
      TradingPrd                varchar(255) NULL,                 
      TradeType                 varchar(255) NULL,                                                 
      PlTypeDesc                varchar(255) NULL,          
      Allocation                   int NULL,            
      ShipmentID                  int NULL   ,          
      --New Change          
      ParcelNum int NULL,                                    
                 
      AllocationKey                varchar(100) NULL,                                                       
      AvgPrice                  float NULL,                                                
      MarketPrice               float NULL,                                 
      PriceUom                  varchar(8) NULL,                                           
      Contr_Qty1                float NULL,                                                
      Contr_Qty                 float NULL,                        
      Sch_Qty1     float NULL,                        
    Sch_Qty     float NULL,                        
    Open_Qty1    float NULL,                        
    Open_Qty     float NULL,                           
      QtyUom                    varchar(8) NULL,                                 
      FxRate             float NULL,                                                
      InhouseInd                char(1) NULL,                                           
      PLRealizationDate         datetime NULL,                                                
      PLRealizeMonth            datetime NULL,                                                 
      PLRealizeYear             varchar(10) NULL,                                              
      PLRealizeDay              varchar(10) NULL,      
      ContractDate           datetime NULL,                                                
      Counterparty              nvarchar(255) NULL,                                                
      DeltaTradePrice           float NULL,                                                
    DeltaMarketPrice          float NULL,                                                
      DeltaFxRate               float NULL,                           
      cob1AvgPrice              float NULL,                          
      cob1MktPrice              float NULL,                        
      cob1PlAmt                 float NULL,                                                
      cob2PlAmt                 float NULL,                                                
      Currency          varchar(8) NULL,                                    
      cob1FxRate                float NULL,                                 
      CostCreation              datetime NULL,                                                
      ChangeType                varchar(10) NULL,                                                
      NewContract               char(1) NULL,                                  
      ModifiedContract          char(1) NULL,                                                
      NewCost                   char(1) NULL,                                              
      NewAllocation             char(1) NULL,                                                
      ModifiedAllocation        char(1) NULL,                                              
      FxRelatedInd              char(1) NULL,                                                
      PLRecordKey               int NULL,                                                
      PLType                    varchar(8) NULL,                                                
      cobDate1                  datetime NULL,                                                
      cob1Calc               datetime NULL,                                                
      cobDate2                  datetime NULL,                                            
      cob2Calc                  datetime NULL,                                                
      TradeModDate              datetime NULL,                                                
      PortNum                   int NULL,                   
      TradingPrdDate            datetime NULL,                                                
      PortfolioName             varchar(100) NULL,                           
                               
      TradingEntity             nvarchar(100) NULL,                                                
      PositionNumber            int NULL,                                                
      StartTransID              bigint NULL,                                
      EndTransID                bigint NULL,                                                
      [Owner]                   varchar(100) NULL,                              
      ClearingBroker            nvarchar(100) NULL,                            
      TraderName                varchar(50) NULL,                            
      TradeNum                  int NULL,                            
      OrderNum                  int NULL,                            
      ItemNum                   int NULL   ,                          
      InvTransferPrice      float NULL,                          
      --CrossPortTransferPrice  int NULL                       
      StrikePrice      float NULL,          
      PutCallInd char(1),          
      OTCOptCode char(8),          
      OptType char(1),          
      CargoIDNumber varchar(16),          
      FormulaInd varchar(10),          
      SettlementType char(1),          
      PSInd char(1), 
      DesiredOptEvalMethod char(1),          
      CostNum int          
     -- ,TradeDate datetime NULL          
)          
          
   create nonclustered index xx01978_pldelta_idx1              
       on #PlDelta (PortNum)                            
                            
   create nonclustered index xx01978_pldelta_idx2                     
       on #PlDelta (TradeNum, OrderNum, ItemNum)                            
                  
   if @debugon = 1                            
      set @time_started = (select convert(varchar, getdate(), 109))                               
   create table #portpl1           
   (                            
      port_num             int,                            
  pl_calc_date         datetime null,                                                          
      trans_id             bigint,                            
   )                            
             
                         
   create table #portpl2                            
   (                  
      port_num             int,                            
      pl_calc_date         datetime null,                                                          
      trans_id             bigint,                            
   )                            
                               
   insert into #portpl1      (port_num, pl_calc_date, trans_id)                            
   select           
    port_num,           
 pl_calc_date,           
 trans_id                            
   from dbo.portfolio_profit_loss ppl WITH (NOLOCK)                            
   where pl_asof_date = @cob_date1           
   and  exists (select 1                             
                 from #children c                             
              where c.port_num = ppl.port_num)                     
                                             
   create nonclustered index xx01910_portpl1_idx                             
      on #portpl1 (port_num)                                     
                            
   insert into #portpl2                            
      (port_num, pl_calc_date, trans_id)                            
   select           
    port_num,           
 pl_calc_date,           
 trans_id                            
   from dbo.portfolio_profit_loss ppl WITH (NOLOCK)                            
   where pl_asof_date = @cob_date2           
   and exists (select 1                  
                     
           from #children c                             
                 where c.port_num = ppl.port_num)                             
                                             
   create nonclustered index xx01910_portpl2_idx                             
      on #portpl2 (port_num)                                     
                            
   if @debugon = 1                            
   begin                            
      set @smsg = '=> Creating temp tables to hold portfolio_profit_loss records ... '                            
      RAISERROR (@smsg, 0, 1) WITH  NOWAIT                            
      set @time_finished = (select convert(varchar, getdate(), 109))                            
      set @smsg = '==> Started : ' + @time_started                            
      RAISERROR (@smsg, 0, 1) WITH NOWAIT                            
      set @smsg = '==> Finished: ' + @time_finished                            
      RAISERROR (@smsg, 0, 1) WITH NOWAIT                                 
   end                            
   
   if @debugon = 1                            
      set @time_started = (select convert(varchar, getdate(), 109))                               
                                                       
   begin try                         
     insert into #PlDelta                                      
     select                  
        DeltaPL,                                               
        DeltaFxPL,            
        --New Change                                                       
        convert(varchar,TradeNum) + '/' + convert(varchar,OrderNum) + '/' + convert(varchar,ItemNum) 'TradeKey',                     
        TradeCostType,                                                          
        Commodity,                                              
        Market,                          
        TradingPrd,                                                          
        TradeType,                                                          
        PlTypeDesc,             
     --New Change (Allocation shipment Id,AllocationKey got from #PL. No joins on allocation, item and shipment tables)          
        Allocation ,            
        ShipmentId,          
        ParcelNum,                                                 
        AllocationKey,                                                                 
    AvgPrice,                                                          
        MarketPrice,                                                        
        PriceUom,                                                       
        Contr_Qty1,                                                     
        Contr_Qty,                        
   Sch_Qty1,                        
   Sch_Qty,                        
   Open_Qty1,                        
   Open_Qty,                                  
        QtyUom,                               
FxRate,                                                          
       InhouseInd,                                                          
        PLRealizationDate,                            
        DATEADD(dd,0,DATEADD(mm, DATEDIFF(mm,0,PLRealizationDate), 0)) PLRealizeMonth,  /* sample date string: 2014-05-01 */                             
        case           
 when isnull(PLRealizationDate, @cob_date2) < @cob_date2 then '.SPOT'           
             when PLRealizationDate is null then 'SPOT'                                                
             else convert(varchar, datepart(yyyy, PLRealizationDate))                             
        end,  /* PLRealizeYear */                                                          
        case           
  when isnull(PLRealizationDate, @cob_date2) < @cob_date2 then '.SPOT'                                
                           
             when PLRealizationDate is null then '.SPOT'                                                
             else                                                
                substring (convert(varchar, PLRealizationDate, 112), 7, 2)                     
        end,   /* PLRealizeDay */                                                        
        ContractDate,                                                          
        Counterparty,                                                 
        DeltaTradePrice,                                                          
        DeltaMarketPrice,                                                          
        DeltaFxRate,                                                          
        cob1AvgPrice,                                            
        cob1MktPrice,                                                          
        cob1PlAmt,                                                          
        cob2PlAmt,                                        
        isnull(Currency, desired_pl_curr_code),   /* Currency */                                                          
        cob1FxRate,                                                       
        CostCreation,                                                          
        ChangeType,                                  
        case           
 when cob1Calc is null then 'Y'                                                      
             when isnull(ContractDate, '01/01/1990') >= cob1Calc and                             
                  isnull(ContractDate, '01/01/1990') < cob2Calc then 'Y'                                                           
             when cob1Calc is null and                             
                  isnull(ContractDate, '01/01/1990') >= cob1Calc then 'Y'                                                           
             else 'N'                             
        end,      /* NewContract */                                                          
        case           
  when cob1Calc is null then 'Y'                                                            
             when isnull(TradeModDate, '01/01/1990') > cob1Calc and                             
                  isnull(TradeModDate, '01/01/1990') <= cob2Calc then 'Y'                              
             else 'N'                             
        end,        /* ModifiedContract */                                     
                               
        case           
  when cob1Calc is null then 'Y'                                                           
             when isnull(CostCreation, '01/01/1990') >= cob1Calc and                       
                  isnull(CostCreation, '01/01/1990') < cob2Calc then 'Y'                                                           
             when cob1Calc is null and                             
                  isnull(CostCreation, '01/01/1990') <= cob2Calc then 'Y'                                                           
   else 'N'                             
        end,            /* NewCost */                                                          
        case           
  when cob1Calc is null then 'Y'                                                           
             when isnull(AllocationCreateDate, '01/01/1990') >= cob1Calc and                             
                  isnull(AllocationCreateDate, '01/01/1990') < cob2Calc then 'Y'                                                           
             when cob1Calc is null and                             
  isnull(AllocationCreateDate, '01/01/1990') <= cob2Calc then 'Y'                                                           
             else 'N'          
      end,     /* NewAllocation */                                                          
        case           
 when cob1Calc is  null then 'N'                                                          
             when AllocTransID >= StartTransID and                             
                  AllocTransID < EndTransID and                             
                  isnull(AllocationCreateDate, '01/01/1990') < cob1Calc then 'Y'                                                           
             else 'N'                             
        end,       /* ModifiedAllocation */                                 
        FxRelatedInd,                                                
        PLRecordKey,                                                        
        PLType,                                                          
        cobDate1,                                    
        cob1Calc,                                                          
        cobDate2,        
        cob2Calc,                                                          
        TradeModDate,                       
        PortNum,                                                          
        DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, TradingPrdDate) + 1, 0)) TradingPrdDate,                                                          
        port.port_short_name,    /* PortfolioName */                                                          
        te.acct_short_name,      /* TradingEntity */                                                   
        PositionNumber,                                                        
        StartTransID,                                                          
        EndTransID,                                              
        [Owner],                              
        clearing_brkr,                             
        trader_name,                            
 TradeNum,                            
        OrderNum,                            
   ItemNum,                          
  --New Change          
  InvTransPrice,                      
  --CrossPortInvTransPrice,             
  tieo.strike_price, -- ADSO-10179 changed the alias from ti_exopt      
   tieo.put_call_ind,   -- ADSO-10179 changed the alias from ti_exopt                                  
   posM2M.otc_opt_code,                    
   case           
    when tieo.opt_type is not null then tieo.opt_type  -- ADSO-10179 changed the alias from ti_exopt                                
     when tioo.opt_type is not null then tioo.opt_type                      
     else NULL        
     end,                      
   trd.cargo_id_number,          
   trdItm.formula_ind,                      
   tieo.settlement_type,          
   trdItm.p_s_ind,          
   tioo.desired_opt_eval_method,          
   CostNum  --BTGO-1044                    
     from (select                                 
           case           
    when EndCOB.pl_record_key is null  then 'DELETED'                             
                   when StartCOB.pl_record_key is null then 'NEW'                             
                   else 'CHANGE'                             
              end 'ChangeType',           
       case           
       when StartCOB.pl_record_key is null then EndCOB.pl_record_key                             
              else StartCOB.pl_record_key                             
              end 'PLRecordKey',                                                          
              EndCOB.pl_asof_date 'cobDate2',                                          
              isnull(EndCOB.real_port_num, StartCOB.real_port_num) 'PortNum',                                                          
              EndCOB.pos_num 'PositionNumber',                                                          
              EndCOB.pl_owner_code,                                                          
              case           
       when StartCOB.pl_amt is null then EndCOB.pl_owner                             
                   else       StartCOB.pl_owner                             
  end 'Owner',                                                          
              isnull(EndCOB.trade_key,StartCOB.trade_key) 'TradeKey',                                                          
              case           
  when EndCOB.pl_amt is null then StartCOB.trade_cost_type                             
                   else EndCOB.trade_cost_type                             
              end 'TradeCostType',                                                          
              EndCOB.pl_type_code 'PLType',                                                          
              case           
        when EndCOB.pl_amt is null then StartCOB.pl_type_desc                             
 else EndCOB.pl_type_desc                             
              end 'PlTypeDesc',                                                          
              EndCOB.avg_price 'AvgPrice',                             
              EndCOB.pl_mkt_price 'MarketPrice',                                                          
              EndCOB.price_uom 'PriceUom',                                                          
              EndCOB.pl_amt 'cob2PlAmt',                     
              StartCOB.contr_qty 'Contr_Qty1',          
              EndCOB.contr_qty 'Contr_Qty',                        
        StartCOB.sch_qty 'Sch_Qty1',                                             
              EndCOB.sch_qty 'Sch_Qty',                        
            StartCOB.open_qty 'Open_Qty1',                                                          
              EndCOB.open_qty 'Open_Qty',                              
              EndCOB.qty_uom 'QtyUom',             
              case           
       when EndCOB.cmdty_short_name is null  then StartCOB.cmdty_short_name                             
                   else EndCOB.cmdty_short_name                             
              end 'Commodity',                                                          
              case           
       when EndCOB.mkt_short_name is null then StartCOB.mkt_short_name                             
                   else  EndCOB.mkt_short_name                             
              end 'Market',                                                          
              case           
        when EndCOB.pl_amt is null then StartCOB.trading_prd_desc                    
                   else EndCOB.trading_prd_desc                 
              end 'TradingPrd',                                     
              case           
       when EndCOB.price_curr_code is null and                             
                        EndCOB.fx_rate in (1,-1)    then 'USD'                             
                   else EndCOB.price_curr_code                             
              end  'Currency',                                                          
             case           
     when EndCOB.cost_creation_date is null and                             
                        StartCOB.trade_cost_type = 'ADDITIONAL COSTS' then StartCOB.cost_creation_date                                            
                   when EndCOB.trade_cost_type = 'ADDITIONAL COSTS'                             
                      then EndCOB.cost_creation_date                             
                   else   null                     
              end 'CostCreation',                                                              
              case           
        when EndCOB.creator_init is null then StartCOB.creator_init                             
                   else  EndCOB.creator_init                       
              end 'Creator',                                                          
              EndCOB.fx_rate 'FxRate',                                                          
  EndCOB.inhouse_ind 'InhouseInd',                                                          
              case           
        when EndCOB.pl_realization_date is null   then StartCOB.pl_realization_date                             
                   else EndCOB.pl_realization_date                             
              end 'PLRealizationDate',                                                          
              case           
        when EndCOB.contr_date is null then StartCOB.contr_date                             
                else EndCOB.contr_date                              
              end 'ContractDate',                                                
       trade_mod_date 'TradeModDate',                                                          
              EndCOB.alloc_creation_date 'AllocationCreateDate',                                                          
              EndCOB.counterparty 'Counterparty',                       
                                             
              isnull(EndCOB.trade_type,StartCOB.trade_type) 'TradeType',             
               --adso-5326              
              EndCOB.alloc_num 'Allocation',                                                   
              --ADSO-3127           
                         
   case           
       when EndCOB.alloc_num is not null and           
       EndCOB.alloc_item_num is not NULL then convert(varchar, EndCOB.alloc_num) + '/'           
       +  convert(varchar, EndCOB.alloc_item_num)                          
              -- when StartCOB.alloc_num is not null and StartCOB.alloc_item_num is not NULL then convert(varchar, StartCOB.alloc_num) + '/' +  convert(varchar, StartCOB.alloc_item_num)                          
     else NULL                   
              end 'AllocationKey',                           
              case           
       when EndCOB.pl_amt is null         then StartCOB.trading_prd_date                             
                   else EndCOB.trading_prd_date                             
              end 'TradingPrdDate',                                                          
              EndCOB.pl_calc_date 'cob2Calc',                                                          
              EndCOB.pl_trans_id as EndTransID,                                                          
              (isnull(EndCOB.avg_price, 0) - isnull(StartCOB.avg_price, 0)) 'DeltaTradePrice',                             
              (isnull(EndCOB.pl_mkt_price,0) - isnull(StartCOB.pl_mkt_price, 0)) 'DeltaMarketPrice',                                                          
              (isnull(EndCOB.fx_rate, 0) - isnull(StartCOB.fx_rate, 0)) 'DeltaFxRate',                                                     
              (isnull(EndCOB.pl_amt, 0) - isnull(StartCOB.pl_amt, 0)) 'DeltaPL',                                                          
              case           
       when (isnull(EndCOB.fx_rate, 1) in (1, 0) OR                             
    isnull(StartCOB.fx_rate, 1) in (1,0) ) then 0                                               
                   else isnull(StartCOB.pl_amt, 1) / isnull(StartCOB.fx_rate, 1) *                             
                              (isnull(EndCOB.fx_rate, 0) - isnull(StartCOB.fx_rate, 0))                             
       end 'DeltaFxPL',                                               
              StartCOB.pl_asof_date 'cobDate1',                                                          
              StartCOB.pl_owner 'OwnerPrev',                                                          
         StartCOB.trade_key 'TradeKeyPrev',                                                          
              StartCOB.avg_price 'cob1AvgPrice',                                                          
              StartCOB.pl_mkt_price 'cob1MktPrice',                         
              StartCOB.pl_amt 'cob1PlAmt',                                               
              StartCOB.fx_rate 'cob1FxRate',                                                          
              StartCOB.pl_calc_date 'cob1Calc',           
              convert(varchar, StartCOB.alloc_num) + '/' +                            
                 convert(varchar, StartCOB.alloc_item_num) 'AllocationPrev',                                                          
              StartCOB.alloc_num as AllocNum,              
              StartCOB.alloc_trans_id as AllocTransID,                                                          
              StartCOB.alloc_item_num as AllocationItem,                 
              StartCOB.trading_prd_date 'TradingPrdDatePrev',                        
              StartCOB.pl_trans_id as StartTransID,                                                      
       case           
       when EndCOB.pl_type_desc = 'CURRENCY' then 'Y'                                                
                   when (isnull(EndCOB.fx_rate, 0) not in (1, -1, 0) OR                             
      isnull(StartCOB.fx_rate, 0) not in (1, -1, 0)) then 'Y'                
                   when  isnull(EndCOB.price_curr_code, 'USD') not in ('USD', 'USC') then 'Y'                                                 
                   else 'N'                                                 
              end 'FxRelatedInd',                              
              EndCOB.clearing_brkr,                            
			  EndCOB.trader_name ,
             case when EndCOB.pl_record_key is null then StartCOB.trade_num else EndCOB.trade_num end 'TradeNum', 
			 case when EndCOB.pl_record_key is null then StartCOB.order_num else	EndCOB.order_num end 'OrderNum', 
			 case when EndCOB.pl_record_key is null then StartCOB.item_num else EndCOB.item_num end 'ItemNum' ,                       
               --New Change          
              EndCOB.inv_trans_price 'InvTransPrice',                      
      --EndCOB.cross_port_trans_price 'CrossPortInvTransPrice'                 
            
            EndCOB.cost_num 'CostNum'--BTGO-1044            
              --New Change          
              ,EndCOB.ship_id 'ShipmentId'          
              ,EndCOB.parcel_num 'ParcelNum'                  
              from (select a.pl_record_key,                                                
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
                        a.contr_qty,          
          a.sch_qty,                        
          a.open_qty,                              
                        a.qty_uom,                                   
                        a.price_uom,                                                   
                        case           
    when a.pl_owner = 'Cost' and                             
                                  a.trade_cost_type = 'COST' and                             
                                  a.cmdty_short_name is null then 'Cost'                      
                        else a.cmdty_short_name                             
                        end cmdty_short_name,                                                          
                        a.mkt_short_name,                                                          
                        a.trading_prd_desc,                                
                        a.fx_rate,                                                          
                        a.inhouse_ind,                                                          
                        a.pl_realization_date,                   
                        a.contr_date,                                                          
                        a.trade_mod_date,                                                          
                        a.counterparty,          
                        a.trade_type,                                                          
                        a.alloc_num,                                                     
   a.creator_init,                             
     a.alloc_item_num,                                                          
                        a.trading_prd_date,                                                          
                        a.price_curr_code,           
                        a.cost_creation_date,                                                          
                        ppl.pl_calc_date,                                                          
   a.alloc_creation_date,                                                          
                        a.alloc_trans_id,                                                          
                        ppl.trans_id pl_trans_id,                            
                        a.clearing_brkr,                                
                        a.trader_name,                            
                        a.trade_num,                              
                        a.order_num,                              
               a.item_num,                     
                
   --New Change           
                        a.inv_trans_price ,                      
                        --a.cross_port_trans_price,              
                        a.cost_num  --BTGO-1044            
                        --New Change            
                        ,a.ship_id            
                        ,a.parcel_num                 
                 from #pl a,                             
                      #portpl2 ppl                                                       
                 where a.pl_asof_date = @cob_date2           
   and ppl.port_num = a.real_port_num) EndCOB                  
   FULL OUTER JOIN (select           
     a.pl_record_key,                                                          
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
                        a.contr_qty,                        
          a.sch_qty,                        
                 a.open_qty,                                  
                               a.qty_uom,                                  
                               a.price_uom,                                                    
                               case           
          when a.pl_owner = 'Cost' and                             
                                         a.trade_cost_type = 'COST' and                             
                 a.cmdty_short_name is null then 'Cost'                             
                                    else a.cmdty_short_name                             
                               end cmdty_short_name,                            
                         a.mkt_short_name,                                                          
              a.trading_prd_desc,                                                          
                               a.fx_rate,                
                               a.pl_realization_date,                                                          
                               a.contr_date,                                                          
                               a.counterparty,                
                               a.trade_type,                                                          
 a.alloc_num,                                                          
          a.alloc_item_num,                                                          
                               a.trading_prd_date,                                                          
                               a.creator_init,                                  
                 a.price_curr_code,                                                          
                               a.cost_creation_date,                                                        
                               a.alloc_trans_id,                                   
                               ppl.trans_id pl_trans_id,                                                          
                               ppl.pl_calc_date,                            
                               a.clearing_brkr,                      
                               a.trader_name,                                                      
                               a.trade_num,                              
                               a.order_num,                              
    a.item_num,                      
                               --New Change          
          a.inv_trans_price ,                      
    -- a.cross_port_trans_price,                 
    a.cost_num  --BTGO-1044           
    --New Change          
    ,a.ship_id            
       ,a.parcel_num                    
                        from #pl a,                             
                             #portpl1 ppl                                                            
              where a.pl_asof_date = @cob_date1           
       and ppl.port_num = a.real_port_num) StartCOB                                                          
  ON EndCOB.real_port_num = StartCOB.real_port_num           
        and EndCOB.pl_record_key = StartCOB.pl_record_key           
   and EndCOB.pl_type_code = StartCOB.pl_type_code           
   and EndCOB.pl_owner_code = StartCOB.pl_owner_code) res                            
             LEFT OUTER JOIN dbo.portfolio port WITH (NOLOCK)                            
                ON port.port_num = res.PortNum                        
        --     left outer join dbo.position_history posHist                               
            --    on res.PositionNumber = posHist.pos_num                       
              --  and  res.cobDate2 = posHist.asof_date                      
left outer join dbo.position_mark_to_market posM2M                               
                     
     on res.PositionNumber = posM2M.pos_num                        
                and res.cobDate2 = posM2M.mtm_asof_date                      
             left outer join trade trd                       
                on trd.trade_num = res.TradeNum            
                --left outer join dbo.trade_item_exch_opt ti_exopt   -- ADSO-10179 removed the duplicate alias       
                --on trd.trade_num = ti_exopt.trade_num                           
    LEFT OUTER JOIN dbo.trade_item trdItm WITH (NOLOCK)                                            
      ON trdItm.trade_num = res.TradeNum           
  and trdItm.order_num = res.OrderNum           
  and trdItm.item_num = res.ItemNum                      
             left outer join dbo.trade_item_exch_opt tieo        
      on tieo.trade_num = res.TradeNum           
  and tieo.order_num = res.OrderNum           
  and tieo.item_num = res.ItemNum              
    left outer join trade_item_otc_opt tioo                       
       on tioo.trade_num = res.TradeNum           
       and tioo.order_num = res.OrderNum           
       and tioo.item_num = res.ItemNum                        
   --New Change - AllocItem and shipment joins deleted          
             LEFT OUTER JOIN dbo.account te WITH (NOLOCK)                             
                ON te.acct_num = port.trading_entity_num                         
                          
 -- where round(DeltaPL, 0) != 0                                                          
     set @rows_affected = @@rowcount                            
   end try                            
   begin catch                            
     set @smsg = '=> Failed to move records into the #PlDelta table due to the error:'                            
     RAISERROR (@smsg, 0, 1) WITH NOWAIT                            
     set @smsg = '==> ERROR: ' + ERROR_MESSAGE()                            
     RAISERROR (@smsg, 0, 1) WITH NOWAIT                            
     goto endofsp               
   end catch                            
   if @debugon = 1                            
   begin                               
      set @smsg = '=> ' + cast(@rows_affected as varchar) + ' records moved into the #PlDelta table ...'                            
      RAISERROR (@smsg, 0, 1) WITH NOWAIT                            
      set @time_finished = (select           
      convert(varchar, getdate(), 109))                            
      set @smsg = '==> Started : ' + @time_started                            
      RAISERROR (@smsg, 0, 1) WITH NOWAIT                      
    set @smsg = '==> Finished: ' + @time_finished                            
      RAISERROR (@smsg, 0, 1) WITH NOWAIT                                 
   end                            
   if object_id('tempdb..#portpl1', 'U') is not null                            
      exec ('drop table #portpl1')                            
   if object_id('tempdb..#portpl2', 'U') is not null                            
      exec('drop table #portpl2')                            
   if @debugon = 1                            
      set @time_started= (select           
        convert(varchar, getdate(), 109))                               
                            
   begin try                                 
     update pd          
     set Commodity = pl.Commodity,                                      
         Market = pl.Market,                                                
         TradingPrd = pl.TradingPrd,                                                
         AvgPrice = pl.AvgPrice,                                                
         MarketPrice = pl.MarketPrice,                                             
         TradeType = pl.TradeType,                                     
         InhouseInd = pl.InhouseInd,                                                
         Currency = pl.Currency,                       
         QtyUom = pl.QtyUom,                           
         ChangeType = pl.ChangeType,                                                
         TradingPrdDate = pl.TradingPrdDate                                                
      from #PlDelta pd                            
              JOIN #PlDelta pl                 
                                         
                 ON pd.TradeKey = pl.TradeKey           
   and pd.TradeCostType = pl.TradeCostType                            
      where pd.TradeType is null           
      and pl.TradeType is not null                                                
   end try                            
   begin catch                            
     set @smsg = '=> Failed to update #PlDelta table (set Commodity = ...) due to the error:'                            
     RAISERROR (@smsg, 0, 1) WITH NOWAIT               
     set @smsg = '==> ERROR: ' + ERROR_MESSAGE()                            
     RAISERROR (@smsg, 0, 1) WITH NOWAIT                            
     goto endofsp                                  
   end catch                            
                                  
begin try                                          
     update #PlDelta                                                
     set TradeType = 'DELETED',                             
         ChangeType = 'DELETED',                            
         FxRelatedInd = 'N'                                   
                    
     where TradeType is null                                                
   end try                            
   begin catch                            
     set @smsg = '=> Failed to update #PlDelta table (set TradeType = ...) due to the error:'                            
             
  RAISERROR (@smsg, 0, 1) WITH NOWAIT                            
     set @smsg = '==> ERROR: ' + ERROR_MESSAGE()                            
     RAISERROR (@smsg, 0, 1) WITH NOWAIT                            
     goto endofsp                                  
   end catch                            
          
   begin try                                          
     update #PlDelta                            
     set FxRelatedInd = 'N'
         --Currency = 'USD'                                          
     where isnull(DeltaFxRate, 0) in (0, 1)                                           
   end try                            
   begin catch                            
     set @smsg = '=> Failed to update #PlDelta table (set FxRelatedInd = ...) due to the error:'                            
     RAISERROR (@smsg, 0, 1) WITH NOWAIT                            
     set @smsg = '==> ERROR: ' + ERROR_MESSAGE()                            
     RAISERROR (@smsg, 0, 1) WITH NOWAIT                            
     goto endofsp                                  
 end catch                            
                      
   begin try                                          
     update #PlDelta                             
     set Counterparty =  Market                                  
     where QtyUom = 'LOTS'                                  
   end try                           
   begin catch                            
     set @smsg = '=> Failed to update #PlDelta table (set Counterparty = ...) due to the error:'                            
     RAISERROR (@smsg, 0, 1) WITH NOWAIT                            
     set @smsg = '==> ERROR: ' + ERROR_MESSAGE()                            
     RAISERROR (@smsg, 0, 1) WITH NOWAIT                            
     goto endofsp                                  
   end catch                            
                               
   begin try                                          
     update #PlDelta                         
              
     set TradeType='FUTURE'                                 
     where QtyUom = 'LOTS'           
      and TradeType = 'EFPEXCH'                              
   end try                            
   begin catch                            
     set @smsg = '=> Failed to update #PlDelta table (set TradeType=''FUTURE'' ...) due to the error:'                            
     RAISERROR (@smsg, 0, 1) WITH NOWAIT                            
     set @smsg = '==> ERROR: ' + ERROR_MESSAGE()                            
     RAISERROR (@smsg, 0, 1) WITH NOWAIT            
     goto endofsp                                  
   end catch                            
                                                 
   begin try                                          
    update #PlDelta                                 
    set TradeType = 'PHYSICAL'                      
    where QtyUom <> 'LOTS'           
    and TradeType = 'EFPEXCH'                  
   end try                            
   begin catch                            
     set @smsg = '=> Failed to update #PlDelta table (set TradeType=''PHYSICAL'' ...) due to the error:'                            
     RAISERROR (@smsg, 0, 1) WITH NOWAIT                            
     set @smsg = '==> ERROR: ' + ERROR_MESSAGE()                            
     RAISERROR (@smsg, 0, 1) WITH NOWAIT                            
     goto endofsp                   
   end catch                            
   if @debugon = 1                            
   begin                               
      set @smsg = '=> POST UPDATE ON the #PlDelta table ...'                            
      RAISERROR (@smsg, 0, 1) WITH NOWAIT                            
      set @time_finished = (select           
      convert(varchar, getdate(), 109))                            
      set @smsg = '==> Started : ' + @time_started                            
      RAISERROR (@smsg, 0, 1) WITH NOWAIT                            
      set @smsg = '==> Finished: ' + @time_finished               
                       
      RAISERROR (@smsg, 0, 1) WITH NOWAIT                                 
   end                            
                            
   if @debugon = 1                            
      set @time_started = (select           
      convert(varchar, getdate(), 109))                               
              
   -- get a handle for XML string                            
   exec sp_xml_preparedocument @hDoc OUTPUT, @tag_xml_string                            
                            
   -- Shred XML string                            
   --Ampo-601           
   select * into #entities                             
   from OPENXML(@hDoc,'/entity-tags/entity-tag')                            
   with (entity_name varchar(16) 'entity-name',                            
         entity_keys varchar(16) 'entity-keys',                       
               
         key_datatype varchar(10) 'entity-key-datatype',                          
         entity_tags_show_list varchar(2000) 'entity-tag-Show-Params')                              
                            
   -- We got data in #entities table, we don't need XML handle, so just drop it                            
   exec sp_xml_removedocument @hDoc                            
                            
   create table #tag_column_info                            
   (                      
      entity_name           varchar(40) primary key,             
      tag_column_list       varchar(2000) null                      
   )                      
                                         
   select @entity_name = min(entity_name)                            
   from #entities                            
                            
   while @entity_name is not null                            
   begin                            
 /* entity_name          
         -------------------                            
         Account                            
         AiEstActual                            
 AllocationItem                            
                   
Commodity                            
         Cost                            
         CostCode                            
         CostTemplateItem                            
         Country                            
         ForecastValue                            
         IctsUser                            
             
      Lc                            
         PaymentTerm                            
         Portfolio                            
         Position                            
         Shipment                            
         Specification                            
         Trade                            
                
   TradeItem                            
         Voucher                            
      */                            
 IF @entity_name NOT IN ('Portfolio', 'TradeItem')          
      begin                 
         set @smsg = 'The entity ''' + @entity_name + ''' is not currently supported by this version of app!'                            
         RAISERROR(@smsg, 0, 1) WITH NOWAIT                            
         goto next1                            
      end                            
                            
      if @entity_name = 'Portfolio'                        
              
      begin                            
         create table #xx101_porttags                             
         (                            
            port_num    int primary key                            
         )                        
exec dbo.usp_get_PORTFOLIO_tags @debugon                     
                 
      end                            
                            
      if @entity_name = 'TradeItem'                            
      begin                            
         create table #xx101_titags                             
         (                            
            trade_num    int,             
                         
            order_num    int,                            
            item_num     int,                            
            constraint [xx101_titags_pk] primary key clustered (trade_num, order_num, item_num)                            
         )                   
                   
         exec dbo.usp_get_TRADE_ITEM_tags @debugon            
      end                            
                            
next1:                                 
      select           
      @entity_name = min(entity_name)                            
      from #entities                          
            
      where entity_name > @entity_name                            
   end                            
                                    
   if @debugon = 1                            
   begin                               
      set @smsg = '=> POST UPDATE ON the #PlDelta table for TAGs ...'                 
                     
      RAISERROR (@smsg, 0, 1) WITH NOWAIT                            
      set @time_finished = (select           
      convert(varchar, getdate(), 109))                            
      set @smsg = '==> Started : ' + @time_started                            
      RAISERROR (@smsg, 0, 1) WITH NOWAIT                            
      set @smsg = '==> Finished: ' + @time_finished                            
      RAISERROR (@smsg, 0, 1) WITH NOWAIT                                 
   end                            
                                  
   declare @portfolio_tag_column_list    varchar(MAX),                            
           @trade_item_tag_column_list   varchar(MAX)                            
                                  
   select           
   @portfolio_tag_column_list = tag_column_list                            
   from #tag_column_info                            
   where entity_name = 'Portfolio'                            
                                      
   select           
   @trade_item_tag_column_list = tag_column_list       
   from #tag_column_info                            
   where entity_name = 'TradeItem'                            
                   
                    
    --Ampo-601 - To show only teh selected entity tags                           
    -------------------------------------------------------------                          
   declare @portfolio_show_tag_column_list    varchar(MAX),                              
                    
 @trade_item_show_tag_column_list   varchar(MAX)                              
                             
   select           
   @portfolio_show_tag_column_list = entity_tags_show_list                              
  from #entities                              
   where entity_name = 'Portfolio'                  
                      
                                        
   select           
   @trade_item_show_tag_column_list = entity_tags_show_list                              
   from #entities                              
   where entity_name = 'TradeItem'                             
                             
   if @portfolio_show_tag_column_list is not null           
   and @portfolio_show_tag_column_list <> ''                          
   begin                          
    --declare @portfolio_show_tag_column_list    varchar(MAX)                          
    --SET @portfolio_show_tag_column_list = 'BOOKCOMP,BOOKLOC'                          
    SET @portfolio_show_tag_column_list = '[' +           
    @portfolio_show_tag_column_list           
    + ']' --[BOOKCOMP,BOOKLOC]                          
    SET @portfolio_show_tag_column_list = REPLACE(          
    @portfolio_show_tag_column_list, ',', '(PortfolioTAG)], [')          
 -- [BOOKCOMP(PortfolioTAG)], [BOOKLOC]                          
    set @portfolio_show_tag_column_list = @portfolio_show_tag_column_list           
    + '(PortfolioTAG)]' -- [BOOKCOMP(PortfolioTAG)], [BOOKLOC](PortfolioTAG)]                          
    SET @portfolio_show_tag_column_list = REPLACE(          
    @portfolio_show_tag_column_list, '](', '(')                        
    --select @portfolio_show_tag_column_list                          
   end                           
                               
   if @trade_item_show_tag_column_list is not null           
   and @trade_item_show_tag_column_list <> ''                          
   begin                          
    --declare @trade_item_show_tag_column_list    varchar(MAX)                          
    --SET @trade_item_show_tag_column_list = 'BOOKCOMP,BOOKLOC'                          
    SET @trade_item_show_tag_column_list = '[' +           
    @trade_item_show_tag_column_list + ']' --[BOOKCOMP,BOOKLOC]                          
    SET @trade_item_show_tag_column_list = REPLACE(          
    @trade_item_show_tag_column_list, ',', '(TradeItemTAG)], [') -- [BOOKCOMP(PortfolioTAG)], [BOOKLOC]                          
      
    set @trade_item_show_tag_column_list =           
    @trade_item_show_tag_column_list           
    + '(TradeItemTAG)]' -- [BOOKCOMP(PortfolioTAG)], [BOOKLOC](PortfolioTAG)]                          
    SET @trade_item_show_tag_column_list = REPLACE(          
    @trade_item_show_tag_column_list, '](', '(')                          
    --select @trade_item_show_tag_column_list                          
  end                          
                            
   -----------------------------------------------------------------------                         
   print 'DEBUG: @portfolio_tag_column_list = '''           
   + @portfolio_tag_column_list + ''''                            
   print 'DEBUG: @trade_item_tag_column_list = '''          
    + @trade_item_tag_column_list + ''''                            
                         
   --ADSO-3127-1,ADSO-3127-2,ADSO-3127-4,ADSO-3127-5,ADSO-3127-6,ADSO-3127-9,ADSO-3127-12,ADSO-3127-14,ADSO-3127-5                      
   set @sql = 'select  distinct           
   case           
 when PLRealizationDate > cobDate2 then ''No''                             
                else ''Yes - '' + convert(varchar, PLRealizationDate, 101)                            
          end ''PL Realized'',                           
          PortNum,                            
          PortfolioName,                                                
          ChangeType as PlChangeCategory,                            
                
 NewContract,                                                
          ModifiedContract as ContractBeingModified,             
          NewCost,                                                
          NewAllocation,                                         
                 
          ModifiedAllocation as AllocationBeingModified,                                              
          cob1PlAmt as PlAmt1,                                                
          cob2PlAmt as PlAmt2,                                                
          DeltaPL as PlChgs,                        
          DeltaFxPL as FxPlChgs,                                                
          cob1MktPrice as MarketPrice1,                                                
          MarketPrice as MarketPrice2,                                                
            
        DeltaMarketPrice as MarketPriceChgs,                       
          TradeKey,              
          Allocation,            
          ShipmentID,           
          ParcelNum,                       
          AllocationKey ,                                               
          TradeCostType as PlChangeGroup,                                                 
          Commodity,                                                 
          Market,                                                 
          TradingPrd as WeeklyTradingPeriod,                 
          TradingPrdDate as RiskPeriod,                                                                                         
          TradingPrdDate as TradingPeriodDate,                                               
          TradeType,                                                 
          PlTypeDesc as PlChangeDetail,                                                 
          cob1AvgPrice as TradePrice1,                                                
          AvgPrice as TradePrice2,                               
          DeltaTradePrice as TradePriceChgs,                  
                                        
          PriceUom,    
    case when PLType=''R'' then ''Realized''    
   when PLType=''U'' then ''Unrealized''    
   when PLType=''M'' then ''Market''    
   when PLType=''C'' then ''Closed''    
   When PLType=''O'' then ''Open''    
   when PLType=''L'' then ''Liquidate''    
   when PLType=''S'' then ''Inhouse Expired''    
   else PLType    
         end as PLType,'                           
                                    
          if @show_transfer_prices = 1                           
          begin                          
           set @sql = @sql +   ' InvTransferPrice as TransferPrice, '           
                      
          end                                           
                                    
          set @sql = @sql + 'cob1FxRate as FxRate1,                                                
          FxRate as FxRate2,                              
          DeltaFxRate as FxRateChgs,                                         
          Contr_Qty1 as Contributing_Qty1,                            
          Contr_Qty as Contributing_Qty2,                             
          (isnull(Contr_Qty, 0) - isnull(Contr_Qty1, 0)) as Contributing_QtyChgs,                       
            
          Sch_Qty1,                            
          Sch_Qty as Sch_Qty2,                             
          (isnull(Sch_Qty, 0) - isnull(Sch_Qty1, 0)) as Sch_QtyChgs,                        
          Open_Qty1,                            
          Open_Qty as Open_Qty2,                          
             
          (isnull(Open_Qty, 0) - isnull(Open_Qty1, 0)) as Open_QtyChgs,                            
          QtyUom,                                                
          case           
   when InhouseInd = ''I'' then ''Internal''                            
               when InhouseInd = ''Y'' then ''Inhouse''                            
               else ''''                            
      end as InhouseTrade,                                                
          ContractDate as ContractDate,                                                
          Counterparty,                                                
          Currency,                              
          cob1Calc as PlCalcDate1,                                                
          cob2Calc as PlCalcDate2,                                                
                    
CostCreation as CostCreationDate,                                                
          FxRelatedInd,                                                
          TradeModDate as TradeModDate,                                                
          TradingEntity,                             
                          
          PositionNumber as PositionNumber,                               
          case           
   when TradeType in (''FUTURE'', ''SWAP'', ''PHYSICAL'') then ''Total Trade Value''                           
               when UPPER([Owner]) = ''CPB'' then ''Cross Port Base''                          
      when UPPER([Owner]) = ''CPO'' then ''Cross Port Offset''                          
               else [Owner]                             
          end As PlChangeOwner,                              
          ClearingBroker,                            
    TraderName,                        
          StrikePrice,                      
          PutCallInd,                       
          OTCOptCode,                       
          OptType,                      
          CargoIDNumber,                        
          case when FormulaInd = ''Y'' then ''Formula''           
                     
      when FormulaInd = ''N'' then ''Fixed''                      
      else      NULL                      
      end as PriceType,                      
    case           
    when SettlementType = ''C'' then ''Cash''                      
     when SettlementType = ''P'' then ''Physical''                      
      else      NULL             
      end as SettlementType,                      
    case           
    when PSInd = ''P'' then ''Buy''                      
      when PSInd = ''S'' then ''Sell''                      
      else      NULL                      
           
     end as BuyOrSell,                      
    case           
    when DesiredOptEvalMethod is not null           
    and DesiredOptEvalMethod = ''C'' then ''Calculate''                      
     when DesiredOptEvalMethod is not null           
     and DesiredOptEvalMethod = ''L'' then ''Look-Up''                      
              
 else            NULL                      
     end as MarketEvalMethod,                       
    CostNum as CostNumber,                       
          case           
   when Counterparty in (''NYMEX'',           
      ''THE ICE'',           
    ''LCH CLEARNET'',           
    ''SGX'',           
    ''NOS CLEARING'')           
    OR                             
              
                QtyUom = ''LOTS'' OR                             
                    TradeType = ''FUTURE''    then ''CLEARED''                                    
               when InhouseInd in (''Y'', ''I'')             then ''INTERNAL''                                
        else ''OTC''                             
          end ''InstrumentType'''                           
                        
          if (@portfolio_show_tag_column_list is null           
   or @portfolio_show_tag_column_list = '')           
   and (@trade_item_show_tag_column_list is null           
   or @trade_item_show_tag_column_list = '')                          
          begin                          
     set @sql = @sql + ' from #PlDelta pl'                          
          end                          
          else           
   if (@portfolio_show_tag_column_list is not null           
   or @portfolio_show_tag_column_list <> '')           
   and (@trade_item_show_tag_column_list is null           
   or @trade_item_show_tag_column_list = '')                          
         begin                          
   set @sql = @sql + ' ,'  + @portfolio_show_tag_column_list           
   + ' from #PlDelta pl LEFT OUTER JOIN #xx101_porttags pt with (nolock) on pl.PortNum = pt.port_num '                            
          end                          
          else           
   if (@portfolio_show_tag_column_list is null           
   or @portfolio_show_tag_column_list  = '')           
   and (@trade_item_show_tag_column_list is not null           
   or @trade_item_show_tag_column_list <> '')                          
          begin                          
   set @sql = @sql + ' ,'  + @trade_item_show_tag_column_list           
    + ' from #PlDelta pl  '                            
   set @sql = @sql           
   +    'LEFT OUTER JOIN #xx101_titags ti with (nolock) on pl.TradeNum = ti.trade_num and '                            
   set @sql = @sql           
   + 'pl.OrderNum = ti.order_num and pl.ItemNum = ti.item_num'                            
          end                          
else                          
          begin                          
             set @sql = @sql + ' , ' +  @portfolio_show_tag_column_list           
      + ', ' + @trade_item_show_tag_column_list + ' '                            
   set @sql = @sql + ' from #PlDelta pl LEFT OUTER JOIN #xx101_porttags pt with (nolock) on pl.PortNum = pt.port_num '                            
   set @sql = @sql           
   + 'LEFT OUTER JOIN #xx101_titags ti with (nolock) on pl.TradeNum = ti.trade_num and '                            
   set @sql = @sql           
   + 'pl.OrderNum = ti.order_num and pl.ItemNum = ti.item_num'                            
          end                      
                                                
                             
   if @debugon = 1                            
      set @time_started = (select           
      convert(varchar, getdate(), 109))                               
            
                           
   begin try                            
     exec(@sql)                                
     set @rows_affected = @@rowcount                            
   end try                            
   begin catch                            
     set @smsg = '=> Failed to return records retrieved from the #PlDelta table due to the error:'                            
     RAISERROR (@smsg, 0, 1) WITH NOWAIT                            
     set @smsg = '==> ERROR: ' + ERROR_MESSAGE()                            
   RAISERROR (@smsg, 0, 1) WITH NOWAIT                            
     set @smsg = '==> SQL: ' + @sql                            
     RAISERROR (@smsg, 0, 1) WITH NOWAIT                                 
     goto endofsp                                  
end catch                            
                               
   if @debugon = 1                            
   begin                
                      
      set @smsg = '=> ' + cast(@rows_affected as varchar)           
      + ' records in result set'                            
      RAISERROR (@smsg, 0, 1) WITH NOWAIT                            
      set @time_finished = (select           
      convert(varchar, getdate(), 109))                     
                 
      set @smsg = '==> Started : ' + @time_started                            
      RAISERROR (@smsg, 0, 1) WITH NOWAIT                            
      set @smsg = '==> Finished: ' + @time_finished                            
      RAISERROR (@smsg, 0, 1) WITH NOWAIT                 
                          
   end                            
                                
endofsp:                            
if object_id('tempdb..#PlDelta', 'U') is not null                            
   exec('drop table #PlDelta')                            
if object_id('tempdb..#portpl1', 'U') is not null                            
   exec('drop table #portpl1')                            
if object_id('tempdb..#portpl2', 'U') is not null                            
   exec('drop table #portpl2')                            
if object_id('tempdb..#xx101_porttags', 'U') is not null                     
                 
   exec('drop table #xx101_porttags')               
if object_id('tempdb..#xx101_titags', 'U') is not null                            
   exec('drop table #xx101_titags')                               
if object_id('tempdb..#tag_column_info', 'U') is not null                           
    exec('drop table #tag_column_info')                                 
return @status                   
 
GO
GRANT EXECUTE ON  [dbo].[usp_PLCOMP_report_pl_delta] TO [next_usr]
GO
