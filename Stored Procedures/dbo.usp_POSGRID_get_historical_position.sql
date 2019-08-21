SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_POSGRID_get_historical_position]  
(
   @asof_date         datetime,
   @show_time_spread  char(1) = 'N',
   @debugon           bit = 0
)            
as 
set nocount on
declare @rows_affected     int,
        @smsg              varchar(800),
        @time_started      varchar(20),
        @time_finished     varchar(20)
           
   set @time_started = (select convert(varchar, getdate(), 109))
      
   begin try   
	   select 
	      asof_date,                
	      trader_init,                      
		    contr_date,                      
		    trade_num,                      
		    trade_key,                      
		    counterparty,                      
		    order_type_code,                      
		    inhouse_ind,                      
		    pos_type_desc,                      
		    trading_entity,                      
		    port_group_tag,                      
		    profit_center,                      
		    real_port_num,                      
		    dist_num,                      
		    pos_num,                      
		    cmdty_group,                      
		    cmdty_code,                      
		    cmdty_short_name,                      
		    mkt_code,                      
		    mkt_short_name,                      
		    commkt_key,                      
		    pos.trading_prd,                      
		    pos_type,                      
		    position_p_s_ind,                      
		    pos_qty_uom_code,                      
		    primary_pos_qty,                      
		    secondary_qty_uom_code,                      
		    secondary_pos_qty,                      
		    is_equiv_ind,                      
		    contract_p_s_ind,                      
		    contract_qty_uom_code,                      
		    contract_qty,                      
		    mtm_price_source_code,                      
		    is_hedge_ind,                      
		    grid_position_month,                      
		    grid_position_qtr,                      
		    grid_position_year,                      
		    trading_prd_desc,                      
		    last_issue_date,                      
		    last_trade_date,                      
		    trade_mod_date,                      
		    trade_creation_date,                      
		    trans_id,                      
		    trading_entity_num,                      
		    pricing_risk_date,                      
		    product,                      
		    NULL,                 /* quantity_in_MT */             
		    NULL,                 /* quantity_in_BBL */
		    NULL,                 /* correlated_commkt_key */
		    NULL,                 /* correlated_commkt */
		    NULL,                 /* correlated_price */
		    NULL,                 /* correlated_price_diff */
		    'Historical',         /* position_mode */               
		    order_num,
		    item_num,
		    NULL,                 /* quantity_KG */
        isnull(ts_trading_prd_desc, pos.trading_prd_desc), 
        isnull(ts_last_issue_date, pos.last_issue_date)
	   from dbo.POSGRID_snapshot_pos_detail pos with(NOLOCK)                    
		         LEFT OUTER JOIN
		            (select cma.commkt_key 'ts_commkt_key',
		                    convert(char(6), quote_end_date, 112) trading_prd,
		                    dist_qty,
		                    tp.trading_prd_desc 'ts_trading_prd_desc', 
		                    tp.last_issue_date 'ts_last_issue_date'
			           from dbo.trade_item_dist tid 
			                   INNER JOIN dbo.trading_period tp 
			                      ON tp.trading_prd = tid.trading_prd and 
			                         tp.commkt_key = tid.commkt_key
			                   INNER join dbo.accumulation acc with (nolock) 
			                      ON tid.trade_num = acc.trade_num and 
			                         tid.order_num = acc.order_num and 
			                         tid.item_num = acc.item_num and 
			                         tid.accum_num = acc.accum_num                                 
			                   JOIN dbo.commodity_market_alias cma 
			                      ON tid.trade_num = convert(int, cma.commkt_alias_name) and 
			                         cma.alias_source_code = 'TIME_SPR' 
			           where dist_type = 'U' and 
			                 @show_time_spread = 'Y') time_spdr 
			        ON time_spdr.ts_commkt_key = pos.commkt_key and 
			           time_spdr.trading_prd = pos.trading_prd
     where exists (select 1 
	                 from #children c1 
	                 where c1.port_num = pos.real_port_num) and 
	         asof_date = @asof_date
	   set @rows_affected = @@rowcount
	 end try
	 begin catch
	   set @smsg = '=> Failed to fetch records from the POSGRID_snapshot_pos_detail table due to the error:'
	   RAISERROR(@smsg, 0, 1) WITH NOWAIT
	   set @smsg = '==> ERROR: ' + ERROR_MESSAGE()
	   RAISERROR(@smsg, 0, 1) WITH NOWAIT
     return 1	   
	 end catch
	 if @debugon = 1
	 begin
	    set @smsg = '=> ' + cast(@rows_affected as varchar) + ' POSGRID_snapshot_pos_detail records being fetched'
	    RAISERROR(@smsg, 0, 1) WITH NOWAIT
      set @time_finished = (select convert(varchar, getdate(), 109))
      set @smsg = '==> Started : ' + @time_started
      RAISERROR (@smsg, 0, 1) WITH NOWAIT
      set @smsg = '==> Finished: ' + @time_finished
      RAISERROR (@smsg, 0, 1) WITH NOWAIT     
	 end

endofsp:   
return 0                    
GO
GRANT EXECUTE ON  [dbo].[usp_POSGRID_get_historical_position] TO [next_usr]
GO
