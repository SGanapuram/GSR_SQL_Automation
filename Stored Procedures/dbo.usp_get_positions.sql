SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_get_positions]
(
   @top_port_num         int,
   @debugon              bit = 0
)
as
set nocount on

CREATE TABLE #children
(  
  port_num int,  
  port_type char(2)  
)  
  
PRINT convert(varchar, getdate()) +  'Before fetching positions.'  
EXEC usp_get_child_port_nums   
       @top_port_num = @top_port_num,  
    @real_only_ind = 1  
PRINT convert(varchar, getdate()) +  'After fetching positions.'  
  
  SELECT  
      a.pos_num, a.real_port_num, a.pos_type, a.pos_status, a.is_equiv_ind, a.commkt_key, a.trading_prd, a.cmdty_code,  
      a.mkt_code, a.opt_start_date, a.opt_exp_date, a.formula_num, a.formula_body_num, a.option_type, a.settlement_type, a.strike_price,  
      a.sec_pos_uom_code, a.put_call_ind, a.acct_short_name, a.is_hedge_ind, a.long_qty, a.short_qty, a.discount_qty,  
      a.priced_qty, a.qty_uom_code, a.avg_purch_price, a.avg_sale_price, a.price_curr_code, a.sec_long_qty, a.sec_short_qty,  
      a.sec_discount_qty, a.sec_priced_qty, a.trans_id, a.equiv_source_ind, a.mkt_long_qty, a.mkt_short_qty, a.sec_mkt_long_qty,  
      a.sec_mkt_short_qty, p.trading_prd_desc, m.mtm_price_source_code, p.last_trade_date  
       INTO #allPos  
    FROM dbo.position a WITH (NOLOCK)  
       INNER JOIN #children c  
      ON a.real_port_num = c.port_num  
    left outer JOIN commodity_market m WITH (NOLOCK)  
      ON m.commkt_key = a.commkt_key  
    LEFT OUTER JOIN trading_period p WITH (NOLOCK)  
      ON p.commkt_key = a.commkt_key  
      AND p.trading_prd = a.trading_prd  
    WHERE a.pos_status != 'NNN' OPTION (MAXDOP 8)  
  
PRINT convert(varchar, getdate()) + 'Created temp table with active positions.'  
  
       SELECT t.pos_num, t.mtm_asof_date, t.mtm_mkt_price, t.volatility, t.delta, t.gamma,   
         t.theta, t.vega  
         INTO #posmtm_with_max_asof  
         FROM position_mark_to_market t WITH (NOLOCK)  
         INNER JOIN(SELECT  
              p.pos_num,  
              MAX(mtm_asof_date) AS max_mtm_asof_date  
         FROM position_mark_to_market p WITH (NOLOCK)  
         INNER JOIN #allPos a ON p.pos_num=a.pos_num  
       GROUP BY p.pos_num) pmtm ON pmtm.pos_num=t.pos_num  
       and pmtm.max_mtm_asof_date=t.mtm_asof_date OPTION (MAXDOP 8)  
  
PRINT convert(varchar, getdate()) +  'After finding max position mark to market.'  
  
/*this table has both realTradingPrd, SPOT prices filled in*/  
       SELECT p.commkt_key, p.trading_prd, p.price_source_code, p.price_quote_date, p.avg_closed_price  
       INTO #price_with_max_asof  
       FROM price p WITH (NOLOCK)  
       INNER JOIN (    
       SELECT  
              MAX(price_quote_date) maxQDate,  
              e.commkt_key, e.trading_prd, price_source_code  
              FROM price e WITH (NOLOCK)  
              inner join #allPos a on  
              e.commkt_key = a.commkt_key  
    AND e.trading_prd = a.trading_prd  
    AND e.price_source_code = a.mtm_price_source_code      
              WHERE price_quote_date >= DATEADD(YEAR, -5, GETDATE())  
              GROUP BY e.commkt_key, e.trading_prd, e.price_source_code  
       ) pr      
       ON pr.commkt_key = p.commkt_key  
    AND pr.trading_prd = p.trading_prd  
    AND pr.price_source_code = p.price_source_code  
    AND pr.maxQDate = p.price_quote_date  
 OPTION (MAXDOP 8)  
  
PRINT convert(varchar, getdate()) +  'After finding latest price from price table.'  
  
  SELECT  
     a.pos_num, a.real_port_num, a.pos_type, a.pos_status, a.is_equiv_ind, a.commkt_key, a.trading_prd, a.cmdty_code,  
      a.mkt_code, a.opt_start_date, a.opt_exp_date, a.formula_num, a.formula_body_num,  a.option_type, a.settlement_type, a.strike_price,  
      a.sec_pos_uom_code, a.put_call_ind, a.acct_short_name, a.is_hedge_ind, a.long_qty, a.short_qty, a.discount_qty,  
      a.priced_qty, a.qty_uom_code, a.avg_purch_price, a.avg_sale_price, a.price_curr_code, a.sec_long_qty, a.sec_short_qty,  
      a.sec_discount_qty, a.sec_priced_qty, a.trans_id, a.equiv_source_ind, a.mkt_long_qty, a.mkt_short_qty, a.sec_mkt_long_qty,  
      a.sec_mkt_short_qty, a.trading_prd_desc, a.mtm_price_source_code, a.last_trade_date,
         
       case when t.mtm_asof_date is not null then t.mtm_asof_date  
       when p.price_quote_date is not null then p.price_quote_date  
       when s.price_quote_date is not null then s.price_quote_date  
       else null  
       end as mtm_asof_date,  
  
       case when t.mtm_mkt_price is not null then t.mtm_mkt_price  
       when p.avg_closed_price is not null then p.avg_closed_price  
       when s.avg_closed_price is not null then s.avg_closed_price  
       else null  
       end as mtm_mkt_price,  
  
       case when t.volatility is not null then t.volatility  
       else null  
       end as volatility,  
  
       case when t.delta is not null then t.delta  
       else null  
       end as delta,  
         
       case when t.gamma is not null then t.gamma  
       else null  
       end as gamma,  
  
       case when t.theta is not null then t.theta  
       else null  
       end as theta,  
         
       case when t.vega is not null then t.vega  
       else null  
       end as vega  
  
  FROM #allPos a  
  left outer join #posmtm_with_max_asof t  
       on t.pos_num=a.pos_num  
  
       left outer join #price_with_max_asof p on   
       p.commkt_key=a.commkt_key and p.trading_prd=a.trading_prd and p.price_source_code=a.mtm_price_source_code and p.trading_prd <> 'SPOT'  
  
       left outer join #price_with_max_asof s on   
       s.commkt_key=a.commkt_key and s.price_source_code=a.mtm_price_source_code and s.trading_prd = 'SPOT'  
  
  ORDER BY a.pos_num   OPTION (MAXDOP 8)  
  
  
if object_id('tempdb..#children', 'U') is not null  
   exec('drop table #children')  
  
if object_id('tempdb..#allPos', 'U') is not null  
   exec('drop table #allPos')  
  
if object_id('tempdb..#posmtm_with_max_asof', 'U') is not null  
   exec('drop table #posmtm_with_max_asof')  
  
if object_id('tempdb..#price_with_max_asof', 'U') is not null  
   exec('drop table #price_with_max_asof')  
GO
GRANT EXECUTE ON  [dbo].[usp_get_positions] TO [next_usr]
GO
