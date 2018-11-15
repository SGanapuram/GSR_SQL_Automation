SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_position_grid]
(
   @ProfitCntr              varchar(255) = NULL,                      
   @PortNum                 varchar(255) = NULL,                 
   @PositionMode            varchar(25) = 'Live',                     
   @AsOfDate                datetime = NULL,          
   @ShowPriceDelta          char(1) = 'N',    
   @ShowCorrelationedCurves char(1) = 'N' 
)                 
AS                      
BEGIN                                            
	create table #children (port_num int, port_type char(2))                                                

	if (isnull(@AsOfDate,'01/01/1900')='01/01/1900')                      
	 select @AsOfDate=max(pl_asof_date) from v_BI_cob_date                        
                      
	IF @PortNum IS NOT NULL                                              
	BEGIN                                              
	  exec dbo.usp_get_child_port_nums @PortNum, 1                                                
	END                                              
                                          
	IF @ProfitCntr IS NOT NULL                                              
	 BEGIN                                              
		insert into #children                                                 
		SELECT port_num,'R'                       
		from dbo.portfolio_tag pt                      
		INNER JOIN dbo.udf_ListToTable(@ProfitCntr) i ON pt.tag_value=i.vchar_value                       
		where tag_name='PRFTCNTR'                       
	END                              
	                       
	CREATE TABLE #pos                      
	 (                
		 AsofDate datetime NULL,                
		 trader_init varchar (3) NULL,                      
		 contr_date datetime    NULL,                      
		 trade_num int    NULL,                      
		 trade_key varchar (123) NULL,                      
		 counterparty nvarchar (60) NULL,                      
		 order_type_code varchar (8) NULL,                      
		 inhouse_ind varchar (1) NULL,                      
		 postion_type_desc varchar (24) NULL,                      
		 trading_entity nvarchar (30) NULL,                      
		 book varchar (32) NULL,                      
		 profit_cntr varchar (32) NULL,                      
		 real_port_num int    NULL,                      
		 dist_num int    NULL,                      
		 pos_num int    NULL,                      
		 cmdty_group char (8) NULL,                      
		 cmdty_code char (8) NULL,                      
		 cmdty_short_name varchar (15) NULL,                      
		 mkt_code char (8) NULL,                      
		 mkt_short_name varchar (15) NULL,                      
		 commkt_key int    NULL,                      
		 trading_prd varchar (40) NULL,                      
		 pos_type char (1) NULL,                      
		 position_p_s_ind varchar (1) NULL,                      
		 pos_qty_uom_code char (4) NULL,                      
		 primary_pos_qty float    NULL,                      
		 secondary_qty_uom_code char (4) NULL,                      
		 secondary_pos_qty float    NULL,                      
		 is_equiv_ind char (1) NULL,                      
		 contract_p_s_ind varchar (1) NULL,                      
		 contract_qty_uom_code char (4) NULL,                      
		 contract_qty float    NULL,                      
		 mtm_price_source_code char (8) NULL,                      
		 is_hedge_ind char (1) NULL,                      
		 GridPositionMonth nvarchar (6) NULL,                      
		 GridPositionQtr varchar (31) NULL,                      
		 GridPositionYear nvarchar (60) NULL,                      
		 trading_prd_desc varchar (40) NULL,                      
		 last_issue_date datetime    NULL,                      
		 last_trade_date datetime    NULL,                      
		 trade_mod_date datetime    NULL,                      
		 trade_creation_date datetime    NULL,                      
		 trans_id int    NULL,                      
		 BookEntityNum int    NULL,                      
		 PricingRiskDate datetime    NULL,                      
		 Product varchar (8) NULL,                      
		 QuantityMT float NULL,                      
		 QuantityBBL Float null      ,            
		 CorrelatedComMktKey int null,          
		 CorrelatedComMkt varchar(100) null,          
		 CorrelatedPrice float null,          
		 CorrelatedPriceDiff float null,               
		 PositionMode varchar(25) null            
	 )            
	                     
	CREATE TABLE #corr          
	(          
		commkt_key int,          
		price_source_code char(8),          
		trading_prd char(8),          
		price_quote_date datetime,          
		avg_closed_price float null,          
		prvpr_avg_closed_price float null          
	)               
	                
	 if (@PositionMode in ('Historical','Delta'))                
	 BEGIN                
	  insert into #pos                                   
	   select asof_date,                
	   trader_init ,                      
		contr_date ,                      
		trade_num ,                      
		trade_key ,                      
		counterparty ,                      
		order_type_code ,                      
		inhouse_ind ,                      
		postion_type_desc ,                      
		trading_entity ,                      
		book ,                      
		profit_cntr ,                      
		real_port_num ,                      
		dist_num ,                      
		pos_num ,                      
		cmdty_group ,                      
		cmdty_code ,                      
		cmdty_short_name ,                      
		mkt_code ,                      
		mkt_short_name ,                      
		commkt_key ,                      
		trading_prd ,                      
		pos_type ,                      
		position_p_s_ind ,                      
		pos_qty_uom_code ,                      
		primary_pos_qty ,                      
		secondary_qty_uom_code ,                      
		secondary_pos_qty ,                      
		is_equiv_ind ,                      
		contract_p_s_ind ,                      
		contract_qty_uom_code ,                      
		contract_qty ,                      
		mtm_price_source_code ,                      
		is_hedge_ind ,                      
		GridPositionMonth ,                      
		GridPositionQtr ,                      
		GridPositionYear ,                      
		trading_prd_desc ,                      
		last_issue_date ,                      
		last_trade_date ,                      
		trade_mod_date ,                      
		trade_creation_date ,                      
		trans_id ,                      
		BookEntityNum ,                      
		PricingRiskDate ,                      
		Product ,                      
		NULL,                      
		NULL   , NULL,    NULL, NULL,NULL,          
		'Historical'                   
	 from dbo.BI_snapshot_pos_detail pos with(NOLOCK)                    
	 where exists (select 1 from #children c1 where c1.port_num=pos.real_port_num)                   
	 and asof_date=@AsOfDate                   
	 END                     
	
	 if (@PositionMode in ('Live','Delta'))                 
	 BEGIN                
		insert into #pos                                   
		   select convert(char,getdate(),101),                
		   trader_init ,                      
			contr_date ,                      
			trade_num ,                      
			trade_key ,                      
			counterparty ,                      
			order_type_code ,                    
			inhouse_ind ,                      
			postion_type_desc ,                      
			trading_entity ,                      
			book ,                      
			profit_cntr ,                      
			real_port_num ,                      
			dist_num ,                      
			pos_num ,                      
			cmdty_group ,                      
			cmdty_code ,                      
			cmdty_short_name ,                   
			mkt_code ,                      
			mkt_short_name ,                      
			commkt_key ,                      
			trading_prd ,                      
			pos_type ,                      
			position_p_s_ind ,                      
			pos_qty_uom_code ,                      
			primary_pos_qty ,                      
			secondary_qty_uom_code ,                      
			secondary_pos_qty ,                      
			is_equiv_ind ,                      
			contract_p_s_ind ,                      
			contract_qty_uom_code ,                      
			contract_qty ,                      
			mtm_price_source_code ,                      
			is_hedge_ind ,                      
		    GridPositionMonth ,                      
			GridPositionQtr ,                      
			GridPositionYear ,                      
			trading_prd_desc ,                      
			last_issue_date ,                      
			last_trade_date ,                      
			trade_mod_date ,                      
			trade_creation_date ,                      
			trans_id ,                      
			BookEntityNum ,                      
			PricingRiskDate ,                      
			Product ,                      
			NULL,                      
			NULL    ,  NULL,   NULL,  NULL,NULL,              
			'Live'                  
		 from dbo.v_BI_position pos  with(NOLOCK)                    
		 where exists (select 1 from #children c1 where c1.port_num=pos.real_port_num)                      
	 END                     
                 
	 UPDATE p                                                  
	 SET QuantityMT = case when pos_qty_uom_code='MT' then primary_pos_qty                      
		  when secondary_qty_uom_code='MT' then secondary_pos_qty end                      
	 FROM #pos p                                                  
	 WHERE pos_qty_uom_code='MT' OR secondary_qty_uom_code='MT'                      
                   
	 UPDATE p                                                  
	 SET QuantityBBL = case when pos_qty_uom_code='BBL' then primary_pos_qty                      
		  when secondary_qty_uom_code='BBL' then secondary_pos_qty end                      
	 FROM #pos p                                                  
	 WHERE pos_qty_uom_code='BBL' OR secondary_qty_uom_code='BBL'                      
	                      
	 UPDATE p                                                  
	 SET QuantityMT =  primary_pos_qty*uom_factor                                                 
	 FROM #pos p                                                  
	 CROSS APPLY dbo.udf_getUomConversion (pos_qty_uom_code, 'MT',NULL,NULL,cmdty_code )                                  
	 where QuantityMT is null                                                  
                      
	 UPDATE p                                                  
	 SET QuantityBBL =  primary_pos_qty*uom_factor                                                 
	 FROM #pos p                           
	 CROSS APPLY dbo.udf_getUomConversion (pos_qty_uom_code, 'BBL',NULL,NULL,cmdty_code )                                              
	 where QuantityBBL is null                                                  
                      
	 UPDATE p                                        
	 SET QuantityMT =  secondary_pos_qty*uom_factor                                                 
	 FROM #pos p                                                  
	 CROSS APPLY dbo.udf_getUomConversion (secondary_qty_uom_code, 'MT',NULL,NULL,cmdty_code )                                              
	 where QuantityMT is null                                                  
                      
	 UPDATE p                                                  
	 SET QuantityBBL =  secondary_pos_qty*uom_factor                                                 
	 FROM #pos p                                                  
	 CROSS APPLY dbo.udf_getUomConversion (secondary_qty_uom_code, 'BBL',NULL,NULL,cmdty_code )                                              
	 where QuantityBBL is null                          
                        
	CREATE table #price                      
	(                      
	 price_quote_date   datetime  null,                      
	 commkt_key   int  null,                      
	 cmdty_code   char (8) null,       
	 mkt_code   char (8) null,                      
	 cmdty_short_name   varchar (15) null,                      
	 mkt_short_name   varchar (15) null,                      
	 trading_prd   char (8) null,                      
	 trading_prd_desc   varchar (40) null,                      
	 last_issue_date   datetime  null,                      
	 last_trade_date   datetime  null,                      
	 price_source_code   char (8) null,                      
	 low_bid_price   float  null,                      
	 high_asked_price   float  null,                      
	 avg_closed_price   float  null,                  
	 price_uom_code   char (4) null,                      
	 price_curr_code   char (8) null,                      
	 lot_size     float (8) null,                      
	 underlying_commkt_key int  null,                      
	 underlying_cmdty_code      char (8) null,                      
	 underlying_cmdty   varchar (15) null,                      
	 underlying_mkt_code      char (8) null,                      
	 underlying_mkt   varchar (15) null,                      
	 underlying_source   varchar (30) null,                      
	 underlying_trading_prd   varchar (30) null,                      
	 underlying_quote_type   varchar (30) null,                      
	 underlying_quote_diff   float (8) null,                      
	 underlying_quote   varchar (156) null,                      
	 prvpr_quote_date datetime,                      
	 prvpr_low_bid_price  float null,                      
	 prvpr_high_asked_price  float null,                      
	 prvpr_avg_closed_price float null                     
	 )                      
  
	if (@ShowPriceDelta ='N' AND @ShowCorrelationedCurves='N')   
	BEGIN  
	  insert into #price                      
	  SELECT @AsOfDate             ,                      
	  pr.commkt_key             ,                      
	  NULL             ,                      
	  NULL             ,                      
	  NULL,                      
	  NULL,                      
	  trading_prd             ,                      
	  NULL     ,                      
	  NULL,                      
	  NULL,                      
	  price_source_code             ,                      
	  NULL,                      
	  NULL,                      
	  NULL,                      
	  NULL,                      
	  NULL,                      
	  NULL,                      
	  underlying_commkt_key      ,                      
	  underlying_cmdty_code           ,                      
	  underlying_cmdty_short_name             ,                      
	  underlying_mkt_code           ,                      
	  underlying_mkt_short_name             ,                      
	  underlying_price_source_code,                      
	  underlying_trading_prd             ,                      
	  underlying_quote_type             ,                      
	  commkt_premium_diff             ,                      
	  underlying_quote             ,                      
	  null,                      
	  null,                      
	  null,                      
	  null                 
	  from dbo.v_BI_commkt_formula pr   with(NOLOCK)                    
	  where exists (select 1 from #pos pos where pr.commkt_key=pos.commkt_key and pr.trading_prd=pos.trading_prd and pos.mtm_price_source_code=pr.price_source_code)                      
	END   
  
	if (@ShowPriceDelta ='Y' OR @ShowCorrelationedCurves='Y')    
	BEGIN                      
	 insert into #price                      
	 SELECT price_quote_date             ,                      
	 pr.commkt_key             ,                      
	 cmdty_code             ,                      
	 mkt_code             ,                      
	 cmdty_short_name             ,                      
	 mkt_short_name             ,                      
	 trading_prd             ,                      
	 trading_prd_desc             ,                      
	 last_issue_date             ,                      
	 last_trade_date             ,                      
	 price_source_code             ,                      
	 low_bid_price             ,                      
	 high_asked_price             ,                      
	 avg_closed_price             ,                      
	 price_uom_code             ,                      
	 price_curr_code             ,                      
	 lot_size          ,                      
	 underlying_commkt_key      ,                      
	 underlying_cmdty_code           ,                      
	 underlying_cmdty             ,                      
	 underlying_mkt_code           ,                      
	 underlying_mkt             ,                      
	 underlying_source             ,                      
	 underlying_trading_prd             ,                      
	 underlying_quote_type             ,                      
	 underlying_quote_diff             ,                      
	 underlying_quote             ,                      
	 null,                      
	 null,                      
	 null,                      
	 null                 
	 from dbo.v_price_detail pr   with(NOLOCK)                    
	 where price_quote_date=@AsOfDate                      
	 and exists (select 1 from #pos pos where pr.commkt_key=pos.commkt_key and pr.trading_prd=pos.trading_prd and pos.mtm_price_source_code=pr.price_source_code)                      
	 update p             
	 SET prvpr_quote_date =prev_quote_date,                      
	  prvpr_low_bid_price  =prev_low_price,                      
	  prvpr_high_asked_price=prev_high_price,                      
	  prvpr_avg_closed_price =prev_closed_price                        
	                             
	 FROM #price p,                      
	 (SELECT price_quote_date 'prev_quote_date',pp.commkt_key, pp.price_source_code, pp.avg_closed_price 'prev_closed_price',pp.low_bid_price 'prev_low_price',pp.high_asked_price 'prev_high_price', pp.trading_prd                      
	  FROM dbo.price pp  with(NOLOCK), #pos pos                      
	  WHERE pos.commkt_key=pp.commkt_key                      
	  and pp.price_source_code=pos.mtm_price_source_code                      
	  and pp.trading_prd=pos.trading_prd                       
	  and price_quote_date in (select max(price_quote_date)                       
			from price p2  with(NOLOCK)                      
			where  p2.commkt_key=pp.commkt_key                      
			and p2.price_quote_date< @AsOfDate                      
			)                      
	  ) oldpr                      
	  WHERE p.commkt_key=oldpr.commkt_key                      
	  and p.trading_prd=oldpr.trading_prd                      
	  and p.price_source_code=oldpr.price_source_code                      
	END    
           
	if (@ShowCorrelationedCurves='Y')          
	BEGIN           
	 update a           
	  set CorrelatedComMkt =convert(varchar,cm.cmdty_code)+'/'+convert(varchar,cm.mkt_code),CorrelatedComMktKey =cm.commkt_key          
	  from #pos a, commodity_alias ca, commodity_market cm          
	  where alias_source_code =  'BASECORR'            and convert(int,ca.cmdty_alias_name)=cm.commkt_key          
	  and a.cmdty_group=ca.cmdty_code          
	 insert into #corr          
	 SELECT commkt_key, price_source_code, pr.trading_prd, price_quote_date,avg_closed_price,null          
	 from dbo.price pr   with(NOLOCK)                    
	 where price_quote_date=@AsOfDate                      
	 and pr.trading_prd in ('SPOT','SPOT01')           
	 and pr.price_source_code in ('EXCHANGE','PLATTS','ARGUS')           
	 and exists (select 1 from #pos pos           
		where pr.commkt_key=pos.CorrelatedComMktKey )                      
	 insert into #corr          
	 SELECT commkt_key, price_source_code, pr.trading_prd, price_quote_date,avg_closed_price,null          
	 from dbo.price pr   with(NOLOCK)                    
	 where price_quote_date=@AsOfDate                      
	 and pr.price_source_code in ('EXCHANGE','PLATTS','ARGUS')          
	 and not exists (select 1 from #corr cc where pr.commkt_key=cc.commkt_key)          
	 and exists (select 1 from #pos pos           
		where pr.commkt_key=pos.CorrelatedComMktKey           
		and pr.trading_prd=pos.trading_prd          
		)            
	 insert into #corr          
	 SELECT commkt_key, price_source_code, pr.trading_prd, price_quote_date,avg_closed_price,null          
	 from dbo.price pr   with(NOLOCK)                    
	 where price_quote_date=@AsOfDate                      
	 and pr.price_source_code in ('INTERNAL')          
	 and not exists (select 1 from #corr cc where pr.commkt_key=cc.commkt_key)          
	 and exists (select 1 from #pos pos           
		where pr.commkt_key=pos.CorrelatedComMktKey           
		and pr.trading_prd=pos.trading_prd          
		)            
	 update p                      
	  SET  prvpr_avg_closed_price =prev_closed_price                        
	  FROM #corr p,                      
	  (SELECT pp.commkt_key, pp.price_source_code, pp.trading_prd, price_quote_date,avg_closed_price 'prev_closed_price'          
	   FROM price pp  with(NOLOCK), #pos pos                      
	   WHERE pp.commkt_key=pos.CorrelatedComMktKey                      
	   --and pp.price_source_code in ('EXCHANGE','PLATTS','ARGUS')                   
	   and price_quote_date in (select max(price_quote_date)                       
	   from dbo.price p2  with(NOLOCK)                      
	   where  p2.commkt_key=pp.commkt_key                      
	   and p2.price_quote_date< @AsOfDate                      
	   )                      
	 ) oldpr                      
	   WHERE p.commkt_key=oldpr.commkt_key                      
	   and p.trading_prd=oldpr.trading_prd                      
	   and p.price_source_code=oldpr.price_source_code                      
	 update pos          
	 SET CorrelatedPrice =c.avg_closed_price,          
	 CorrelatedPriceDiff =c.avg_closed_price-prvpr_avg_closed_price          
	 FROM #pos pos, #corr c          
	 WHERE pos.CorrelatedComMktKey=c.commkt_key          
	END          
                       
                      
	 if (@PositionMode in ('Live','Historical') )              
	 BEGIN                    
		select                    
		postion_type_desc 'PosType',                    
		isnull(parent_cmdty_code,a.cmdty_group) CmdtyGroup,                    
		a.cmdty_code 'CmdtyCode',                    
		a.cmdty_short_name 'CmdtyShortName',                    
		a.mkt_code 'MktCode',                    
		a.mkt_short_name 'MktShortName',               
		primary_pos_qty 'PrimaryPosQty',                    
		pos_qty_uom_code 'PrimaryUom',                    
		secondary_pos_qty 'SecondaryPosQty',                    
		secondary_qty_uom_code 'SecondaryQtyUom',                    
		QuantityBBL ,                    
		QuantityMT ,                    
		---convert(float, null) 'Quantity',                    
		GridPositionYear [Year],                    
		--GridPositionMonth,                    
		a.profit_cntr as ProfitCenter,                    
		convert(datetime, convert(char(6),a.last_issue_date,112)+ '15', 112) 'Month',                    
		a.trading_prd_desc 'TradingPrdDesc',                    
		a.real_port_num 'PortNum',                    
		a.contract_p_s_ind 'Purch-SaleInd',                    
		contract_qty as ContractQty,                    
		is_hedge_ind as HedgeInd,                    
		PricingRiskDate,                    
		order_type_code 'OrderTypeCode',                    
		trader_init 'TraderInit', 
		--I#1392836 - Venu Added Trader 
		isnull(isnull(isnull(isnull(t5.user_first_name +' '+t5.user_last_name,t4.user_first_name +' '+t4.user_last_name),t3.user_first_name +' '+t3.user_last_name),t2.user_first_name +' '+t2.user_last_name),t1.user_first_name +' '+t1.user_last_name) 'Trader',                   
		contr_date 'ContractDate',                    
		trade_key 'TradeKey',                    
		trade_num 'TradeNum',                    
		counterparty 'Cpty',                    
		inhouse_ind 'InhouseInd',                    
		pr.price_quote_date 'PriceQuoteDate',                    
		pr.price_source_code  PriceSource,                    
		pr.low_bid_price  Low,                    
		pr.high_asked_price  High,                    
		pr.avg_closed_price  ClosePrice,                    
		pr.avg_closed_price - isnull(pr.prvpr_avg_closed_price,0) 'DeltaPrice',                    
		--(pr.avg_closed_price / case when isnull(pr.prvpr_avg_closed_price,0)=0 then 1 else isnull(pr.prvpr_avg_closed_price,0) end ) 'DeltaPrice%',                  
		(isnull(pr.avg_closed_price,0) - isnull(pr.prvpr_avg_closed_price,0))/case when isnull(pr.avg_closed_price,0)=0 then 1 else isnull(pr.avg_closed_price,0) end  'DeltaPrice%',                        
		price_uom_code PriceUom,                    
		price_curr_code PriceCurr,                    
		lot_size LotSize,                    
	  isnull(underlying_cmdty,a.cmdty_short_name) UnderlylingCmdty,                    
		isnull(underlying_mkt,a.mkt_short_name) UnderlyingMkt,                    
		isnull(underlying_source,a.mtm_price_source_code)  UnderlyingSource,                    
		isnull(underlying_trading_prd,a.trading_prd)  UnderlyingTradingPrd,                    
		underlying_quote_type UnderlyingQuoteType,                    
		underlying_quote_diff UnderlyingQuoteDiff,                    
		underlying_quote UnderlyingQuote,                    
		prvpr_quote_date 'PrevPriceQuoteDate',                    
		case when cma.alias_source_code is null then 'VERIFIED' else 'UNVERIFIED' end 'CurveStatus'  ,              
		a.pos_num PosNum,              
		a.commkt_key 'CommktKey' ,              
		@AsOfDate 'Historical',              
		getdate() 'Live',          
		CorrelatedComMkt,          
		CorrelatedPrice,          
		CorrelatedPriceDiff   ,        
		(CorrelatedPriceDiff)/case when isnull(CorrelatedPrice,0)=0 then 1 else isnull(CorrelatedPrice,0) end   'CorrelatedDeltaPrice%' ,      
		tag_option_desc 'PortDivision'       
		--,CorrelatedComMktKey          
		from #pos a                    
		LEFT outer join #price pr ON pr.commkt_key=a.commkt_key and a.trading_prd=pr.trading_prd and a.mtm_price_source_code=pr.price_source_code 
		LEFT outer join dbo.commodity_group under_grp ON under_grp.cmdty_group_type_code='POSITION' and under_grp.cmdty_code=underlying_cmdty_code                    
		LEFT outer join dbo.commodity_market_alias cma on cma.commkt_key=a.commkt_key and cma.alias_source_code = 'CURVESRC'                
		LEFT OUTER JOIN dbo.portfolio_tag pt ON pt.tag_name='DIVISION' and pt.port_num=a.real_port_num      
		LEFT OUTER JOIN dbo.entity_tag_option eto ON eto.entity_tag_id=6 and eto.tag_option=pt.tag_value    
		--I#1392836 - Venu Added Trader joins
		left JOIN dbo.portfolio_tag ptt ON ptt.port_num=a.real_port_num and ptt.tag_name like 'TRADER%'
		LEFT OUTER JOIN dbo.icts_user t1 on t1.user_init=ptt.tag_value and ptt.tag_name like 'TRADER'
		LEFT OUTER JOIN dbo.icts_user t2 on t2.user_init=ptt.tag_value and ptt.tag_name like 'TRADER2'
		LEFT OUTER JOIN dbo.icts_user t3 on t3.user_init=ptt.tag_value and ptt.tag_name like 'TRADER3'
		LEFT OUTER JOIN dbo.icts_user t4 on t4.user_init=ptt.tag_value and ptt.tag_name like 'TRADER4'
		LEFT OUTER JOIN dbo.icts_user t5 on t5.user_init=ptt.tag_value and ptt.tag_name like 'TRADER5'
	 END              
	              
	 if (@PositionMode in ('Delta') )              
	 BEGIN                    
		select                
		isnull(EndCOB.PosType,StartCOB.PosType) PosType,                    
		isnull( isnull(under_grp.parent_cmdty_code,EndCOB.cmdty_group), StartCOB.cmdty_group) CmdtyGroup,                    
	   EndCOB.CmdtyCode,                    
		isnull(EndCOB.CmdtyShortName,StartCOB.CmdtyShortName) CmdtyShortName,                    
		EndCOB.MktCode,                    
		isnull(EndCOB.MktShortName,StartCOB.MktShortName) MktShortName,                    
		EndCOB.PrimaryPosQty,                    
		EndCOB.PrimaryUom,                    
		EndCOB.SecondaryPosQty,                    
		EndCOB.SecondaryQtyUom,                    
		isnull(EndCOB.QuantityBBL,0)-isnull(StartCOB.QuantityBBL,0) QuantityBBL,                    
		isnull(EndCOB.QuantityMT,0)- isnull(StartCOB.QuantityMT,0) QuantityMT,                    
		isnull(EndCOB.[Year],StartCOB.[Year]) 'Year',                
		isnull(EndCOB.ProfitCenter,StartCOB.ProfitCenter) ProfitCenter,                    
		isnull(EndCOB.[Month],StartCOB.[Month]) 'Month',                    
		isnull(EndCOB.TradingPrdDesc,StartCOB.TradingPrdDesc) TradingPrdDesc,                    
		EndCOB.PortNum,                    
		EndCOB.PurchSaleInd,                    
		EndCOB.ContractQty,                    
		EndCOB.HedgeInd,                    
		EndCOB.PricingRiskDate,                    
		EndCOB.OrderTypeCode,                    
		EndCOB.TraderInit,  
		--I#1392836 - Venu Added Trader
		isnull(isnull(isnull(isnull(t5.user_first_name +' '+t5.user_last_name,t4.user_first_name +' '+t4.user_last_name),t3.user_first_name +' '+t3.user_last_name),t2.user_first_name +' '+t2.user_last_name),t1.user_first_name +' '+t1.user_last_name) 'Trader',                          
		EndCOB.ContractDate,                    
		EndCOB.TradeKey,                    
		EndCOB.TradeNum,                    
		EndCOB.Cpty,                    
		EndCOB.InhouseInd,                  
		pr.price_quote_date 'PriceQuoteDate',                    
		pr.price_source_code  PriceSource,                    
		pr.low_bid_price  Low,                    
		pr.high_asked_price  High,                    
		pr.avg_closed_price  ClosePrice,                    
		pr.avg_closed_price - isnull(pr.prvpr_avg_closed_price,0) 'DeltaPrice',                  
		(isnull(pr.avg_closed_price,0) - isnull(pr.prvpr_avg_closed_price,0))/case when isnull(pr.avg_closed_price,0)=0 then 1 else isnull(pr.avg_closed_price,0) end   'DeltaPrice%',                        
		price_uom_code PriceUom,                    
		price_curr_code PriceCurr,                    
		lot_size LotSize,                    
	  isnull(underlying_cmdty,EndCOB.CmdtyShortName) UnderlylingCmdty,                    
		isnull(underlying_mkt,EndCOB.MktShortName) UnderlyingMkt,                    
		isnull(underlying_source,EndCOB.mtm_price_source_code)  UnderlyingSource,                    
		isnull(underlying_trading_prd,EndCOB.TradingPrd)  UnderlyingTradingPrd,                    
		underlying_quote_type UnderlyingQuoteType,                    
		underlying_quote_diff UnderlyingQuoteDiff,                    
		underlying_quote UnderlyingQuote,                    
		prvpr_quote_date 'PrevPriceQuoteDate',                    
	   case when cma.alias_source_code is null then 'VERIFIED' else 'UNVERIFIED' end 'CurveStatus'      ,              
		isnull(EndCOB.PosNum,StartCOB.PosNum ) PosNum,              
	isnull(EndCOB.commkt_key ,StartCOB.commkt_key) 'CommktKey',              
		@AsOfDate 'Historical',              
		getdate() 'Live' ,          
		EndCOB.CorrelatedComMkt,          
		EndCOB.CorrelatedPrice,          
		EndCOB.CorrelatedPriceDiff      ,               
		(EndCOB.CorrelatedPriceDiff)/case when isnull(EndCOB.CorrelatedPrice,0)=0 then 1 else isnull(EndCOB.CorrelatedPrice,0) end   'CorrelatedDeltaPrice%'  ,      
		tag_option_desc 'PortDivision'      
		from               
		(select      cmdty_group,              
		postion_type_desc 'PosType',                    
		a.cmdty_code 'CmdtyCode',                    
		a.cmdty_short_name 'CmdtyShortName',                    
		a.mkt_code 'MktCode',                    
		a.mkt_short_name 'MktShortName',                    
		primary_pos_qty 'PrimaryPosQty',                    
		pos_qty_uom_code 'PrimaryUom',                    
		secondary_pos_qty 'SecondaryPosQty',                    
		secondary_qty_uom_code 'SecondaryQtyUom',                    
		QuantityBBL ,                    
		QuantityMT ,                    
		---convert(float, null) 'Quantity',                    
		 GridPositionYear [Year],                
		--GridPositionMonth,               
	   a.profit_cntr as ProfitCenter,                    
		convert(datetime, convert(char(6),a.last_issue_date,112)+ '15', 112) 'Month',                    
		a.trading_prd_desc 'TradingPrdDesc',               
		a.trading_prd 'TradingPrd',                   
		a.real_port_num 'PortNum',                    
		a.contract_p_s_ind 'PurchSaleInd',                    
		contract_qty as ContractQty,                    
		is_hedge_ind as HedgeInd,                    
		PricingRiskDate,                    
		order_type_code 'OrderTypeCode',                    
		trader_init 'TraderInit',                    
		contr_date 'ContractDate',                    
		trade_key 'TradeKey',                    
		trade_num 'TradeNum',                    
		counterparty 'Cpty',                    
		inhouse_ind 'InhouseInd',                
		pos_num 'PosNum'  ,a.commkt_key  ,mtm_price_source_code   ,          
		CorrelatedComMkt,          
		CorrelatedPrice,          
		CorrelatedPriceDiff                
		from #pos a                    
		WHERE PositionMode='Live'              
		) EndCOB              
	  FULL OUTER  JOIN                
		(select      cmdty_group,              
		postion_type_desc 'PosType',                    
		a.cmdty_code 'CmdtyCode',                    
		a.cmdty_short_name 'CmdtyShortName',                    
		a.mkt_code 'MktCode',                    
		a.mkt_short_name 'MktShortName',                    
		primary_pos_qty 'PrimaryPosQty',                    
		pos_qty_uom_code 'PrimaryUom',             
		secondary_pos_qty 'SecondaryPosQty',                    
		secondary_qty_uom_code 'SecondaryQtyUom',                    
		QuantityBBL ,                    
		QuantityMT ,                    
		---convert(float, null) 'Quantity',                    
		 GridPositionYear [Year],                
		--GridPositionMonth,                    
		a.profit_cntr as ProfitCenter,                    
		convert(datetime, convert(char(6),a.last_issue_date,112)+ '15', 112) 'Month',                    
		a.trading_prd_desc 'TradingPrdDesc',                   
		a.trading_prd 'TradingPrd',               
		a.real_port_num 'PortNum',                    
		a.contract_p_s_ind 'PurchSaleInd',                    
		contract_qty as ContractQty,                    
		is_hedge_ind as HedgeInd,                    
		PricingRiskDate,                    
		order_type_code 'OrderTypeCode',                    
		trader_init 'TraderInit',                    
		contr_date 'ContractDate',                    
		trade_key 'TradeKey',                    
		trade_num 'TradeNum',                    
		counterparty 'Cpty',                    
		inhouse_ind 'InhouseInd',                 
		pos_num 'PosNum'  ,a.commkt_key ,mtm_price_source_code              
		from #pos a                    
		WHERE PositionMode='Historical'                    ) StartCOB              
		  ON EndCOB.PortNum=StartCOB.PortNum     AND  EndCOB.PosNum=StartCOB.PosNum              
		  AND EndCOB.TradeKey=StartCOB.TradeKey              
	                    
		LEFT outer join #price pr ON pr.commkt_key=EndCOB.commkt_key and EndCOB.TradingPrd=pr.trading_prd and EndCOB.mtm_price_source_code=pr.price_source_code --and pr.avg_closed_price!=0                    
		LEFT outer join dbo.commodity_group under_grp ON under_grp.cmdty_group_type_code='POSITION' and under_grp.cmdty_code=underlying_cmdty_code                    
		LEFT outer join dbo.commodity_market_alias cma on cma.commkt_key=EndCOB.commkt_key and cma.alias_source_code = 'CURVESRC'                    
		LEFT OUTER JOIN dbo.portfolio_tag pt ON pt.tag_name='DIVISION' and pt.port_num=EndCOB.PortNum      
		LEFT OUTER JOIN dbo.entity_tag_option eto ON eto.entity_tag_id=6 and eto.tag_option=pt.tag_value 
		--I#1392836 - Venu Added Trader joins
		left JOIN portfolio_tag ptt ON ptt.port_num=EndCOB.PortNum and ptt.tag_name like 'TRADER%'
		LEFT OUTER JOIN dbo.icts_user t1 on t1.user_init=ptt.tag_value and ptt.tag_name like 'TRADER'
		LEFT OUTER JOIN dbo.icts_user t2 on t2.user_init=ptt.tag_value and ptt.tag_name like 'TRADER2'
		LEFT OUTER JOIN dbo.icts_user t3 on t3.user_init=ptt.tag_value and ptt.tag_name like 'TRADER3'
		LEFT OUTER JOIN dbo.icts_user t4 on t4.user_init=ptt.tag_value and ptt.tag_name like 'TRADER4'
		LEFT OUTER JOIN dbo.icts_user t5 on t5.user_init=ptt.tag_value and ptt.tag_name like 'TRADER5'     
	   WHERE isnull(EndCOB.QuantityMT,0)-isnull(StartCOB.QuantityMT,0)<>0              
	 END              
END                          
GO
GRANT EXECUTE ON  [dbo].[usp_position_grid] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_position_grid', NULL, NULL
GO
