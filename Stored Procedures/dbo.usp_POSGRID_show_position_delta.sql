SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_POSGRID_show_position_delta]
(
   @debugon       bit = 0
)
as
set nocount on
declare @rows_affected    int,
        @smsg             varchar(800),
        @time_started     varchar(20),
        @time_finished    varchar(20)

   set @time_started = (select convert(varchar, getdate(), 109))

	 select                
		  isnull(EndCOB.PosType, StartCOB.PosType) PosType,                    
		  isnull(isnull(under_grp.parent_cmdty_code, EndCOB.cmdty_group), StartCOB.cmdty_group) CmdtyGroup,                    
	    EndCOB.CmdtyCode,                    
		  isnull(EndCOB.CmdtyShortName, StartCOB.CmdtyShortName) CmdtyShortName,                    
		  EndCOB.MktCode,                    
		  isnull(EndCOB.MktShortName, StartCOB.MktShortName) MktShortName,                    
		  EndCOB.PrimaryPosQty,                    
		  EndCOB.PrimaryUom,                    
		  EndCOB.SecondaryPosQty,                    
		  EndCOB.SecondaryQtyUom,                    
		  isnull(EndCOB.QuantityBBL, 0) - isnull(StartCOB.QuantityBBL, 0) QuantityBBL,                    
		  isnull(EndCOB.QuantityMT, 0) - isnull(StartCOB.QuantityMT, 0) QuantityMT,                    
		  isnull(EndCOB.[Year], StartCOB.[Year]) 'Year',                
		  isnull(EndCOB.ProfitCenter, StartCOB.ProfitCenter) ProfitCenter,                    
		  isnull(EndCOB.[Month], StartCOB.[Month]) 'Month',                    
		  isnull(EndCOB.TradingPrdDesc, StartCOB.TradingPrdDesc) TradingPrdDesc,                    
		  EndCOB.PortNum,                    
		  EndCOB.PurchSaleInd,                    
		  EndCOB.ContractQty,                    
		  EndCOB.HedgeInd,                    
		  EndCOB.PricingRiskDate,                    
		  EndCOB.OrderTypeCode,                    
		  EndCOB.TraderInit,  
		  u.user_first_name + ' ' + u.user_last_name as 'Trader',                   
		  EndCOB.ContractDate,                    
		  EndCOB.TradeKey,                    
		  EndCOB.TradeNum,                    
		  EndCOB.Cpty,                    
		  EndCOB.InhouseInd,                  
		  pr.price_quote_date 'PriceQuoteDate',                    
		  pr.price_source_code PriceSource,                    
		  pr.low_bid_price Low,                    
		  pr.high_asked_price High,                    
		  pr.avg_closed_price ClosePrice,                    
		  pr.avg_closed_price - isnull(pr.prvpr_avg_closed_price, 0) 'DeltaPrice',                  
		  (isnull(pr.avg_closed_price, 0) - isnull(pr.prvpr_avg_closed_price, 0)) /
		         case when isnull(pr.avg_closed_price, 0) = 0 then 1 
		              else isnull(pr.avg_closed_price, 0) 
		         end 'DeltaPrice%',                        
		  price_uom_code PriceUom,                    
		  price_curr_code PriceCurr,                    
		  lot_size LotSize,                    
	    isnull(underlying_cmdty, EndCOB.CmdtyShortName) UnderlylingCmdty,                    
		  isnull(underlying_mkt, EndCOB.MktShortName) UnderlyingMkt,                    
		  isnull(underlying_source, EndCOB.mtm_price_source_code) UnderlyingSource,                    
		  isnull(underlying_trading_prd, EndCOB.TradingPrd) UnderlyingTradingPrd,                    
		  underlying_quote_type UnderlyingQuoteType,                    
	    underlying_quote_diff UnderlyingQuoteDiff,                    
		  underlying_quote UnderlyingQuote,                    
		  prvpr_quote_date 'PrevPriceQuoteDate',                    
	    case when cma.alias_source_code is null then 'VERIFIED' 
	         else 'UNVERIFIED' 
	    end 'CurveStatus',              
		  isnull(EndCOB.PosNum, StartCOB.PosNum) PosNum,              
	    isnull(EndCOB.commkt_key, StartCOB.commkt_key) 'CommktKey',              
		  case when StartCOB.position_mode = 'Historical' then StartCOB.asof_date
		       else null
		  end as 'Historical',              
		  case when EndCOB.position_mode = 'Live' then EndCOB.asof_date
		       else null
		  end as 'Live',              
		  EndCOB.CorrelatedComMkt,          
		  EndCOB.CorrelatedPrice,          
		  EndCOB.CorrelatedPriceDiff,               
		  (EndCOB.CorrelatedPriceDiff) / case when isnull(EndCOB.CorrelatedPrice, 0) = 0 then 1 
		                                      else isnull(EndCOB.CorrelatedPrice, 0) 
		                                 end 'CorrelatedDeltaPrice%',      
		  pt.division_desc 'PortDivision',      
      EndCOB.OrderNum,      
      EndCOB.ItemNum,
      EndCOB.QuantityKG,
      EndCOB.TimeSpreadPeriod,
      EndCOB.TimeSpreadDate		        
	 from (select 
		        cmdty_group,  
		        position_mode,
		        asof_date,            
		        pos_type_desc 'PosType',                    
		        a.cmdty_code 'CmdtyCode',                    
		        a.cmdty_short_name 'CmdtyShortName',                    
		        a.mkt_code 'MktCode',                    
		        a.mkt_short_name 'MktShortName',                    
		        primary_pos_qty 'PrimaryPosQty',                    
		        pos_qty_uom_code 'PrimaryUom',                    
		        secondary_pos_qty 'SecondaryPosQty',                    
		        secondary_qty_uom_code 'SecondaryQtyUom',                    
		        quantity_in_BBL as QuantityBBL,                    
		        quantity_in_MT as QuantityMT,                    
		        grid_position_year [Year],                
	          a.profit_center as ProfitCenter,                    
		        convert(datetime, convert(char(6), a.last_issue_date,112) + '15', 112) 'Month',                    
		        a.trading_prd_desc 'TradingPrdDesc',               
		        a.trading_prd 'TradingPrd',                   
		        a.real_port_num 'PortNum',                    
		        a.contract_p_s_ind 'PurchSaleInd',                    
	          contract_qty as ContractQty,                    
		        is_hedge_ind as HedgeInd,                    
		        pricing_risk_date as PricingRiskDate,                    
		        order_type_code 'OrderTypeCode',                    
		        trader_init 'TraderInit',                    
		        contr_date 'ContractDate',                    
		        trade_key 'TradeKey',                    
	          trade_num 'TradeNum',                    
		        counterparty 'Cpty',                    
		        inhouse_ind 'InhouseInd',                
		        pos_num 'PosNum',
		        a.commkt_key,
		        mtm_price_source_code,          
		        correlated_commkt as CorrelatedComMkt,          
		        correlated_price as CorrelatedPrice,          
		        correlated_price_diff as CorrelatedPriceDiff,            
            a.order_num as OrderNum,      
            a.item_num as ItemNum,
            a.quantity_in_KG as QuantityKG,
            a.time_spread_period as TimeSpreadPeriod,
            a.time_spread_date as TimeSpreadDate	        
		     from #pos a                    
		     where position_mode = 'Live') EndCOB              
	        FULL OUTER JOIN                
		         (select 
		             cmdty_group, 
		             position_mode,   
		             asof_date,          
		             pos_type_desc 'PosType',                    
		             a.cmdty_code 'CmdtyCode',                    
		             a.cmdty_short_name 'CmdtyShortName',                    
		             a.mkt_code 'MktCode',                    
		             a.mkt_short_name 'MktShortName',                    
		             primary_pos_qty 'PrimaryPosQty',                    
		             pos_qty_uom_code 'PrimaryUom',             
		             secondary_pos_qty 'SecondaryPosQty',                    
		             secondary_qty_uom_code 'SecondaryQtyUom',                    
		             quantity_in_BBL as QuantityBBL,                    
		             quantity_in_MT as QuantityMT,                    
		             grid_position_year [Year],                
		             a.profit_center as ProfitCenter,                    
	               convert(datetime, convert(char(6), a.last_issue_date, 112) + '15', 112) 'Month',                    
		             a.trading_prd_desc 'TradingPrdDesc',                   
		             a.trading_prd 'TradingPrd',               
	               a.real_port_num 'PortNum',                    
		             a.contract_p_s_ind 'PurchSaleInd',                    
		             contract_qty as ContractQty,                    
		             is_hedge_ind as HedgeInd,                    
		             pricing_risk_date as PricingRiskDate,                    
		             order_type_code 'OrderTypeCode',                    
		             trader_init 'TraderInit',                    
		             contr_date 'ContractDate',                    
		             trade_key 'TradeKey',                    
		             trade_num 'TradeNum',                    
		             counterparty 'Cpty',                    
		             inhouse_ind 'InhouseInd',                 
		             pos_num 'PosNum',
		             a.commkt_key,
		             mtm_price_source_code,              
                 a.time_spread_period as TimeSpreadPeriod,
                 a.time_spread_date as TimeSpreadDate	        
		          from #pos a                    
		          where position_mode = 'Historical') StartCOB              
		                   ON EndCOB.PortNum = StartCOB.PortNum and  
		                      EndCOB.PosNum = StartCOB.PosNum and 
		                      EndCOB.TradeKey = StartCOB.TradeKey              	                    
	        LEFT OUTER JOIN #price pr 
	           ON EndCOB.commkt_key = pr.commkt_key and 
	              EndCOB.TradingPrd = pr.trading_prd and 
	              EndCOB.mtm_price_source_code = pr.price_source_code                     
	        LEFT OUTER JOIN dbo.v_risk_commodity_group under_grp 
	           ON pr.underlying_cmdty_code = under_grp.cmdty_code                    
	        LEFT OUTER JOIN dbo.v_curve_source cma 
	           ON EndCOB.commkt_key = cma.commkt_key                    
	        LEFT OUTER JOIN dbo.v_portfolio_division_info pt 
	           ON EndCOB.PortNum = pt.real_port_num       
          LEFT OUTER JOIN #porttags ptt 
           	 ON EndCOB.PortNum = ptt.port_num 
          LEFT OUTER JOIN dbo.icts_user u
             ON ptt.trader_init = u.user_init
	 where isnull(EndCOB.QuantityMT, 0) - isnull(StartCOB.QuantityMT, 0) <> 0              
   set @rows_affected = @@rowcount
	 if @debugon = 1
	 begin
      set @smsg = 'Result (DELTA): # of rows retrieved = ' + cast(@rows_affected as varchar) 
      RAISERROR(@smsg, 0, 1) WITH NOWAIT 
      set @time_finished = (select convert(varchar, getdate(), 109))
      set @smsg = '==> Started : ' + @time_started
      RAISERROR (@smsg, 0, 1) WITH NOWAIT
      set @smsg = '==> Finished: ' + @time_finished
      RAISERROR (@smsg, 0, 1) WITH NOWAIT     
   end 
GO
GRANT EXECUTE ON  [dbo].[usp_POSGRID_show_position_delta] TO [next_usr]
GO
