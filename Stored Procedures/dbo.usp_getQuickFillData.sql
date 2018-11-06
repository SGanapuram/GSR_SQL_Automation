SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_getQuickFillData] 
as
set nocount on
declare @asofDate	    varchar(10)

   create table #output
   (
	    acct_short_name	nvarchar(30),
	    book_group_name	varchar(16),
	    cmdty_code	    char(8),
	    risk_mkt_code	  char(8),
	    trading_prd	    varchar(40),
	    long_qty	      float,
	    short_qty	      float,
	    total_qty	      float,
	    mtm_pl	        float		
   )

   insert into #output
   select clrbr.acct_short_name, 
          pt.tag_value, 
          ti.cmdty_code, 
          ti.risk_mkt_code, 
          ti.trading_prd, 
          isnull(SUM(CASE ti.p_s_ind 
                        WHEN 'P' THEN Isnull(tif.total_fill_qty, 0) 
                     END), 0), 
          isnull(SUM(CASE ti.p_s_ind 
                        WHEN 'S' THEN Isnull(tif.total_fill_qty, 0) * -1.0 
                     END), 0), 
          SUM(CASE ti.p_s_ind 
                 WHEN 'P' THEN Isnull(tif.total_fill_qty, 0) 
                 ELSE Isnull(tif.total_fill_qty, 0) * -1.0 
              END), 
          SUM(Isnull(tipl.mtm_pl, 0)) 
   from dbo.trade_item AS ti 
           INNER JOIN dbo.trade AS tr 
              ON ti.trade_num = tr.trade_num 
           INNER JOIN dbo.trade_order AS tor 
              ON ti.trade_num = tor.trade_num AND 
                 ti.order_num = tor.order_num 
           INNER JOIN dbo.trade_item_fut AS tif 
              ON ti.trade_num = tif.trade_num AND 
                 ti.order_num = tif.order_num AND 
                 ti.item_num = tif.item_num 
           LEFT OUTER JOIN dbo.trade_item_pl AS tipl 
              ON ti.trade_num = tipl.trade_num AND 
                 tipl.order_num = ti.order_num AND 
                 tipl.item_num = ti.item_num 
           INNER JOIN dbo.portfolio_tag AS pt 
              ON ti.real_port_num = pt.port_num 
           INNER JOIN dbo.commodity_market AS cm 
              ON ti.cmdty_code = cm.cmdty_code AND 
                 ti.risk_mkt_code = cm.mkt_code 
           INNER JOIN dbo.trading_period AS tprd 
              ON cm.commkt_key = tprd.commkt_key AND 
                 ti.trading_prd = tprd.trading_prd 
           INNER JOIN dbo.account AS clrbr 
              ON clrbr.acct_num = tif.clr_brkr_num 
   where (ti.item_type = 'F' AND 
          ti.parent_item_num IS NULL) AND 
         tr.inhouse_ind = 'N' AND 
         (tor.order_type_code NOT IN ('EFPEXCH', 'EXCHGOPT')) AND 
         pt.tag_name = 'GROUP' AND 
         tprd.last_trade_date >= CONVERT(DATETIME, CONVERT(VARCHAR, Getdate(), 103), 103) AND 
         NOT EXISTS (select 1 
                     from dbo.commodity_alias cma 
                     where alias_source_code = 'QFREPORT' and 
                           cmdty_alias_name = 'USEBASEPL' and 
                           ti.cmdty_code = cma.cmdty_code)
   group by clrbr.acct_short_name, 
            pt.tag_value, 
            ti.cmdty_code, 
            ti.risk_mkt_code, 
            ti.trading_prd 
   union 
   select clrbr.acct_short_name, 
          pt.tag_value, 
          ti.cmdty_code, 
          ti.risk_mkt_code, 
          ti.trading_prd, 
          isnull(SUM(CASE ti.p_s_ind 
                        WHEN 'P' THEN Isnull(tif.total_fill_qty, 0) 
                     END), 0), 
          isnull(SUM(CASE ti.p_s_ind 
                        WHEN 'S' THEN Isnull(tif.total_fill_qty, 0) * -1.0 
                     END), 0), 
          SUM(CASE ti.p_s_ind 
                 WHEN 'P' THEN Isnull(tif.total_fill_qty, 0) 
                 ELSE Isnull(tif.total_fill_qty, 0) * -1.0 
              END), 
          SUM(Isnull(tipl.mtm_pl, 0)) 
   from dbo.trade_item AS ti 
           INNER JOIN dbo.trade AS tr 
              ON ti.trade_num = tr.trade_num 
           INNER JOIN dbo.trade_order AS tor 
              ON ti.trade_num = tor.trade_num AND 
                 ti.order_num = tor.order_num 
           INNER JOIN dbo.trade_item_dist AS tid 
              ON ti.trade_num = tid.trade_num AND 
                 ti.order_num = tid.order_num AND 
                 ti.item_num = tid.item_num 
           INNER JOIN dbo.trade_item_fut AS tif 
              ON ti.trade_num = tif.trade_num AND 
                 ti.order_num = tif.order_num AND 
                 ti.item_num = tif.item_num 
           LEFT OUTER JOIN dbo.trade_item_pl AS tipl 
              ON ti.trade_num = tipl.trade_num AND 
                 tipl.order_num = ti.order_num AND 
                 tipl.item_num = ti.item_num 
           INNER JOIN dbo.portfolio_tag AS pt 
              ON ti.real_port_num = pt.port_num 
           INNER JOIN dbo.commodity_market AS cm 
              ON ti.cmdty_code = cm.cmdty_code AND 
                 ti.risk_mkt_code = cm.mkt_code 
           INNER JOIN dbo.trading_period AS tprd 
              ON cm.commkt_key = tprd.commkt_key AND 
                 ti.trading_prd = tprd.trading_prd 
           INNER JOIN dbo.account AS clrbr 
              ON clrbr.acct_num = tif.clr_brkr_num 
   where (ti.item_type = 'F') AND 
         tr.inhouse_ind = 'N' AND 
         (tor.order_type_code IN ('EFPEXCH', 'EXCHGOPT')) AND 
         tid.what_if_ind = 'N' AND 
         tid.is_equiv_ind = 'N' AND 
         tid.real_synth_ind = 'R' AND 
         tid.dist_type = 'D' AND 
         ti.item_type <> 'W' AND 
         pt.tag_name = 'GROUP' AND 
         tprd.last_trade_date >= CONVERT(DATETIME, CONVERT(VARCHAR, Getdate(), 103), 103) AND 
         NOT EXISTS (select 1 
                     from dbo.commodity_alias cma 
                     where alias_source_code = 'QFREPORT' and 
                           cmdty_alias_name = 'USEBASEPL' and 
                           ti.cmdty_code = cma.cmdty_code)
   group by clrbr.acct_short_name, 
            pt.tag_value, 
            ti.cmdty_code, 
            ti.risk_mkt_code, 
            ti.trading_prd 
   union 
   select clrbr.acct_short_name, 
          pt.tag_value, 
          ti.cmdty_code, 
          ti.risk_mkt_code, 
          ti.trading_prd, 
          isnull(SUM(CASE ti.p_s_ind 
                        WHEN 'P' THEN Isnull(tif.total_fill_qty, 0) 
                     END), 0), 
          isnull(SUM(CASE ti.p_s_ind 
                        WHEN 'S' THEN Isnull(tif.total_fill_qty, 0) * -1.0 
                     END), 0), 
          SUM(CASE ti.p_s_ind 
                 WHEN 'P' THEN Isnull(tif.total_fill_qty, 0) 
                 ELSE Isnull(tif.total_fill_qty, 0) * -1.0 
              END), 
          SUM(Isnull(tipl.mtm_pl, 0)) 
   from dbo.trade_item AS ti 
           INNER JOIN dbo.trade AS tr 
              ON ti.trade_num = tr.trade_num 
           INNER JOIN dbo.trade_item_fut AS tif 
              ON ti.trade_num = tif.trade_num AND 
                 ti.order_num = tif.order_num AND 
                 ti.item_num = tif.item_num 
           LEFT OUTER JOIN dbo.trade_item_pl AS tipl 
              ON ti.trade_num = tipl.trade_num AND 
                 tipl.order_num = ti.order_num AND 
                 tipl.item_num = ti.item_num 
           INNER JOIN dbo.portfolio_tag AS pt 
              ON ti.real_port_num = pt.port_num 
           INNER JOIN dbo.commodity_market AS cm 
              ON ti.cmdty_code = cm.cmdty_code AND 
                 ti.risk_mkt_code = cm.mkt_code 
           INNER JOIN dbo.trading_period AS tprd 
              ON cm.commkt_key = tprd.commkt_key AND 
                 ti.trading_prd = tprd.trading_prd 
           INNER JOIN dbo.account AS clrbr 
              ON clrbr.acct_num = tif.clr_brkr_num 
   where (ti.item_type = 'X') AND 
         tr.inhouse_ind = 'N' AND 
         pt.tag_name = 'GROUP' AND 
         tprd.last_trade_date >= CONVERT(DATETIME, CONVERT(VARCHAR, Getdate(), 103), 103) AND 
         NOT EXISTS (select 1 
                     from dbo.commodity_alias cma 
                     where alias_source_code = 'QFREPORT' and 
                           cmdty_alias_name = 'USEBASEPL' and 
                           ti.cmdty_code = cma.cmdty_code)
   group by clrbr.acct_short_name, 
            pt.tag_value, 
            ti.cmdty_code, 
            ti.risk_mkt_code, 
            ti.trading_prd 
   order by clrbr.acct_short_name, 
            tag_value, 
            ti.cmdty_code, 
            ti.risk_mkt_code, 
            ti.trading_prd 

   create table #temp
   (
	    acct_short_name	   nvarchar(30),
	    book_group_name	   varchar(16),
	    cmdty_code	       char(8),
  	  risk_mkt_code	     char(8),
	    trading_prd	       varchar(40),
	    trade_num	         int,
	    order_num	         int,
	    item_num	         int,
	    real_port_num	     int,
	    long_qty	         float,
	    short_qty	         float,
	    total_qty	         float,
	    mtm_pl	           float		
   )

   select @asofDate = convert(varchar, max(pl_asof_date), 101) 
   from dbo.portfolio_profit_loss 
   where pl_asof_date < getDate()

   insert into #temp
   select clrbr.acct_short_name, 
          pt.tag_value, 
          ti.cmdty_code, 
          ti.risk_mkt_code, 
          ti.trading_prd,
	        ti.trade_num, 
	        ti.order_num,
	        ti.item_num,
	        ti.real_port_num,
          isnull((CASE ti.p_s_ind 
                     WHEN 'P' THEN Isnull(tif.total_fill_qty, 0) 
                  END), 0), 
          isnull((CASE ti.p_s_ind 
                     WHEN 'S' THEN Isnull(tif.total_fill_qty, 0) * -1.0 
                  END), 0), 
          isnull((CASE ti.p_s_ind 
                     WHEN 'P' THEN Isnull(tif.total_fill_qty, 0) 
                     ELSE isnull(tif.total_fill_qty, 0) * -1.0 
                  END), 0), 
	        null	   
   from dbo.trade_item AS ti 
           INNER JOIN trade AS tr 
              ON ti.trade_num = tr.trade_num 
           INNER JOIN dbo.trade_order AS tor 
              ON ti.trade_num = tor.trade_num AND 
                 ti.order_num = tor.order_num 
           INNER JOIN dbo.trade_item_fut AS tif 
              ON ti.trade_num = tif.trade_num AND 
                 ti.order_num = tif.order_num AND 
                 ti.item_num = tif.item_num 
           INNER JOIN dbo.portfolio_tag AS pt 
              ON ti.real_port_num = pt.port_num 
           INNER JOIN dbo.commodity_market AS cm 
              ON ti.cmdty_code = cm.cmdty_code AND 
                 ti.risk_mkt_code = cm.mkt_code 
           INNER JOIN dbo.trading_period AS tprd 
              ON cm.commkt_key = tprd.commkt_key AND 
                 ti.trading_prd = tprd.trading_prd 
           INNER JOIN dbo.account AS clrbr 
              ON clrbr.acct_num = tif.clr_brkr_num 
	         INNER JOIN (select cmdty_code 
	                     from dbo.commodity_alias 
	                     where alias_source_code = 'QFREPORT' and 
	                           cmdty_alias_name = 'USEBASEPL') cma
		          on ti.cmdty_code = cma.cmdty_code
   where (ti.item_type = 'F' AND ti.parent_item_num IS NULL) AND 
         tr.inhouse_ind = 'N' AND 
         (tor.order_type_code NOT IN ('EFPEXCH', 'EXCHGOPT')) AND 
         pt.tag_name = 'GROUP' AND 
         tprd.last_trade_date >= CONVERT(DATETIME, CONVERT(VARCHAR, Getdate(), 103), 103) 
   union 
   select clrbr.acct_short_name, 
          pt.tag_value, 
          ti.cmdty_code, 
          ti.risk_mkt_code, 
          ti.trading_prd, 
	        ti.trade_num, 
	        ti.order_num,
	        ti.item_num,
	        ti.real_port_num,
          isnull((CASE ti.p_s_ind 
                     WHEN 'P' THEN Isnull(tif.total_fill_qty, 0) 
                  END), 0), 
          isnull((CASE ti.p_s_ind 
                     WHEN 'S' THEN Isnull(tif.total_fill_qty, 0) * -1.0 
                  END), 0), 
          isnull((CASE ti.p_s_ind 
                     WHEN 'P' THEN Isnull(tif.total_fill_qty, 0) 
                     ELSE Isnull(tif.total_fill_qty, 0) * -1.0 
                  END), 0), 
	        null	   
   from dbo.trade_item AS ti 
           INNER JOIN dbo.trade AS tr 
              ON ti.trade_num = tr.trade_num 
           INNER JOIN dbo.trade_order AS tor 
              ON ti.trade_num = tor.trade_num AND 
                 ti.order_num = tor.order_num 
           INNER JOIN dbo.trade_item_dist AS tid 
              ON ti.trade_num = tid.trade_num AND 
                 ti.order_num = tid.order_num AND 
                 ti.item_num = tid.item_num 
           INNER JOIN dbo.trade_item_fut AS tif 
              ON ti.trade_num = tif.trade_num AND 
                 ti.order_num = tif.order_num AND 
                 ti.item_num = tif.item_num 
           INNER JOIN dbo.portfolio_tag AS pt 
              ON ti.real_port_num = pt.port_num 
           INNER JOIN dbo.commodity_market AS cm 
              ON ti.cmdty_code = cm.cmdty_code AND 
                 ti.risk_mkt_code = cm.mkt_code 
           INNER JOIN dbo.trading_period AS tprd 
              ON cm.commkt_key = tprd.commkt_key AND 
                 ti.trading_prd = tprd.trading_prd 
           INNER JOIN dbo.account AS clrbr 
              ON clrbr.acct_num = tif.clr_brkr_num 
	         INNER JOIN (select cmdty_code 
	                     from dbo.commodity_alias 
	                     where alias_source_code = 'QFREPORT' and 
	                           cmdty_alias_name = 'USEBASEPL') cma
		          on ti.cmdty_code = cma.cmdty_code
   where (ti.item_type = 'F') AND 
         tr.inhouse_ind = 'N' AND 
         (tor.order_type_code IN ( 'EFPEXCH', 'EXCHGOPT')) AND 
         tid.what_if_ind = 'N' AND 
         tid.is_equiv_ind = 'N' AND 
         tid.real_synth_ind = 'R' AND 
         tid.dist_type = 'D' AND 
         ti.item_type <> 'W' AND 
         pt.tag_name = 'GROUP' AND 
         tprd.last_trade_date >= CONVERT(DATETIME, CONVERT(VARCHAR, Getdate(), 103), 103) 
   union 
   select clrbr.acct_short_name, 
          pt.tag_value, 
          ti.cmdty_code, 
          ti.risk_mkt_code, 
          ti.trading_prd, 
	        ti.trade_num, 
	        ti.order_num,
	        ti.item_num,
	        ti.real_port_num,
          isnull((CASE ti.p_s_ind 
                     WHEN 'P' THEN Isnull(tif.total_fill_qty, 0) 
                  END), 0), 
          isnull((CASE ti.p_s_ind 
                     WHEN 'S' THEN Isnull(tif.total_fill_qty, 0) * -1.0 
                  END), 0), 
          isnull((CASE ti.p_s_ind 
                     WHEN 'P' THEN Isnull(tif.total_fill_qty, 0) 
                     ELSE Isnull(tif.total_fill_qty, 0) * -1.0 
                  END), 0), 
	        null	   
   from dbo.trade_item AS ti 
           INNER JOIN dbo.trade AS tr 
              ON ti.trade_num = tr.trade_num 
           INNER JOIN dbo.trade_item_fut AS tif 
              ON ti.trade_num = tif.trade_num AND 
                 ti.order_num = tif.order_num AND 
                 ti.item_num = tif.item_num 
           INNER JOIN dbo.portfolio_tag AS pt 
              ON ti.real_port_num = pt.port_num 
           INNER JOIN dbo.commodity_market AS cm 
              ON ti.cmdty_code = cm.cmdty_code AND 
                 ti.risk_mkt_code = cm.mkt_code 
           INNER JOIN dbo.trading_period AS tprd 
              ON cm.commkt_key = tprd.commkt_key AND 
                 ti.trading_prd = tprd.trading_prd 
           INNER JOIN dbo.account AS clrbr 
              ON clrbr.acct_num = tif.clr_brkr_num 
	         INNER JOIN (select cmdty_code 
	                     from dbo.commodity_alias 
	                     where alias_source_code = 'QFREPORT' and 
	                           cmdty_alias_name = 'USEBASEPL') cma
		          on ti.cmdty_code = cma.cmdty_code
   where (ti.item_type = 'X') AND 
         tr.inhouse_ind = 'N' AND 
         pt.tag_name = 'GROUP' AND 
         tprd.last_trade_date >= CONVERT(DATETIME, CONVERT(VARCHAR, Getdate(), 103), 103) 
   order by clrbr.acct_short_name, 
            tag_value, 
            ti.cmdty_code, 
            ti.risk_mkt_code, 
            ti.trading_prd 

   create table #plhist
   (
	    pl_secondary_owner_key1	int,
	    pl_secondary_owner_key2	int,
    	pl_secondary_owner_key3	int,
	    real_port_num	          int,
	    pl_amt	                float
   )

   insert into #plhist
   select pl_secondary_owner_key1,
          pl_secondary_owner_key2,
          pl_secondary_owner_key3,
          plh.real_port_num,
          sum(pl_amt) 
	 from dbo.pl_history AS plh
	         join #temp t1
              on t1.trade_num = plh.pl_secondary_owner_key1 AND 
                 t1.order_num = plh.pl_secondary_owner_key2 AND 
                 t1.item_num = plh.pl_secondary_owner_key3 AND 
                 t1.real_port_num = plh.real_port_num AND 
                 plh.pl_asof_date = @asofDate AND 
                 plh.pl_type in ('R', 'W') AND
                 ((plh.pl_owner_code = 'T' and pl_category_type = 'R') or
				          (plh.pl_owner_code = 'C' and pl_category_type = 'R' and pl_cost_prin_addl_ind = 'P') or
			         	  (plh.pl_owner_code = 'C' and pl_cost_prin_addl_ind=  'P')) 
	 group by pl_secondary_owner_key1,
	          pl_secondary_owner_key2,
	          pl_secondary_owner_key3,
	          plh.real_port_num

   update t1
   set mtm_pl = pl_amt
   from #temp t1
           join #plhist t2
              ON t1.trade_num = t2.pl_secondary_owner_key1 AND 
                 t1.order_num = t2.pl_secondary_owner_key2 AND 
                 t1.item_num = t2.pl_secondary_owner_key3 AND 
                 t1.real_port_num = t2.real_port_num

   insert into #output
   select acct_short_name,
          book_group_name, 
          cmdty_code, 
          risk_mkt_code,
          trading_prd, 
          sum(long_qty),
          sum(short_qty),
          sum(total_qty),
          sum(mtm_pl) 
   from #temp
   group by acct_short_name, book_group_name, cmdty_code, risk_mkt_code, trading_prd
   order by acct_short_name, book_group_name, cmdty_code, risk_mkt_code, trading_prd

   select 	
      acct_short_name,
	    book_group_name,
	    cmdty_code,
	    risk_mkt_code,
	    trading_prd,
	    long_qty,
	    short_qty,
	    total_qty,
      mtm_pl 
   from #output 
   order by acct_short_name, book_group_name, cmdty_code, risk_mkt_code, trading_prd

   drop table #plhist
   drop table #temp
   drop table #output

endofsp:  
return 0  
GO
GRANT EXECUTE ON  [dbo].[usp_getQuickFillData] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_getQuickFillData', NULL, NULL
GO
