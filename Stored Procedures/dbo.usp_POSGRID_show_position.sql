SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_POSGRID_show_position]
(
   @debugon          bit = 0
)
as
set nocount on
declare @rows_affected    int,
        @smsg             varchar(800),
        @time_started     varchar(20),
        @time_finished    varchar(20)

   set @time_started = (select convert(varchar, getdate(), 109))
	 select                    
		  pos_type_desc 'PosType',                    
		  isnull(parent_cmdty_code, a.cmdty_group) CmdtyGroup,                    
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
		  a.real_port_num 'PortNum',                    
		  a.contract_p_s_ind 'Purch-SaleInd',                    
		  contract_qty as ContractQty,                    
		  is_hedge_ind as HedgeInd,                    
		  pricing_risk_date as PricingRiskDate,                    
		  order_type_code 'OrderTypeCode',                    
		  ptt.trader_init 'TraderInit', 
		  u.user_first_name + ' ' + u.user_last_name as 'Trader',                   
		  contr_date 'ContractDate',                    
		  trade_key 'TradeKey',                    
		  trade_num 'TradeNum',                    
		  counterparty 'Cpty',                    
		  inhouse_ind 'InhouseInd',                    
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
	    isnull(underlying_cmdty, a.cmdty_short_name) UnderlylingCmdty,                    
		  isnull(underlying_mkt, a.mkt_short_name) UnderlyingMkt,                    
		  isnull(underlying_source, a.mtm_price_source_code) UnderlyingSource,                    
		  isnull(underlying_trading_prd, a.trading_prd) UnderlyingTradingPrd,                    
		  underlying_quote_type UnderlyingQuoteType,                    
		  underlying_quote_diff UnderlyingQuoteDiff,                    
		  underlying_quote UnderlyingQuote,                    
		  prvpr_quote_date 'PrevPriceQuoteDate',                    
		  case when cma.alias_source_code is null then 'VERIFIED' 
		       else 'UNVERIFIED' 
		  end 'CurveStatus',              
		  a.pos_num PosNum,              
		  a.commkt_key 'CommktKey' ,              
		  case when position_mode = 'Historical' then asof_date
		       else null
		  end 'Historical',              
		  case when position_mode = 'Live' then asof_date
		       else null
		  end 'Live',              
		  correlated_commkt,          
		  correlated_price,          
		  correlated_price_diff,        
		  (correlated_price_diff) / case when isnull(correlated_price, 0) = 0 then 1 
		                                 else isnull(correlated_price, 0) 
		                            end 'CorrelatedDeltaPrice%',      
		  pt.division_desc 'PortDivision',
      a.order_num as OrderNum,      
      a.item_num as ItemNum,
      a.quantity_in_KG as QuantityKG,
      a.time_spread_period as TimeSpreadPeriod,
      a.time_spread_date as TimeSpreadMonth,
      datepart(yy, a.time_spread_date) as TimeSpreadYear		        
   from #pos a                    
		     LEFT OUTER JOIN #price pr 
		        ON a.commkt_key = pr.commkt_key and 
		           a.trading_prd = pr.trading_prd and 
		           a.mtm_price_source_code = pr.price_source_code 
		     LEFT OUTER JOIN dbo.v_risk_commodity_group under_grp 
		        ON pr.underlying_cmdty_code = under_grp.cmdty_code                    
	        LEFT OUTER JOIN dbo.v_curve_source cma 
	           ON a.commkt_key = cma.commkt_key                    
	        LEFT OUTER JOIN dbo.v_portfolio_division_info pt 
	           ON a.real_port_num = pt.real_port_num       
         LEFT OUTER JOIN #porttags ptt 
          	ON a.real_port_num = ptt.port_num 
         LEFT OUTER JOIN dbo.icts_user u
            ON ptt.trader_init = u.user_init
   set @rows_affected = @@rowcount
	 if @debugon = 1
	 begin
      set @smsg = 'Result (LIVE or HISTORICAL): # of rows retrieved = ' + cast(@rows_affected as varchar) 
      RAISERROR(@smsg, 0, 1) WITH NOWAIT 
      set @time_finished = (select convert(varchar, getdate(), 109))
      set @smsg = '==> Started : ' + @time_started
      RAISERROR (@smsg, 0, 1) WITH NOWAIT
      set @smsg = '==> Finished: ' + @time_finished
      RAISERROR (@smsg, 0, 1) WITH NOWAIT     
   end 
GO
GRANT EXECUTE ON  [dbo].[usp_POSGRID_show_position] TO [next_usr]
GO
