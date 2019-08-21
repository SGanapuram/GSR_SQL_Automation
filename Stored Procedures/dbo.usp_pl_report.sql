SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_pl_report]
(
   @pl_asof_date         datetime = null, 
   @port_type            char(1),
   @top_port_num         int = 0,
   @real_port_nums       nvarchar(4000) = null,
   @debugon              bit = 0 
)
as
set nocount on
declare @rows_affected          int, 
        @smsg                   varchar(255), 
        @status                 int, 
        @oid                    numeric(18, 0), 
        @stepid                 smallint, 
        @session_started        varchar(30), 
        @session_ended          varchar(30), 
        @my_top_port_num        int, 
        @my_pl_asof_date        datetime,
        @my_port_type           char(1),
        @my_real_port_nums      nvarchar(4000)

   select @my_pl_asof_date = @pl_asof_date, 
          @my_top_port_num = @top_port_num,
          @my_port_type = @port_type,
          @my_real_port_nums = @real_port_nums

   create table #children
   (
      port_num int PRIMARY KEY,
      port_type char(2),
   )

   IF (@my_port_type = 'S')
      exec dbo.usp_get_child_port_nums @my_top_port_num, 1
   ELSE IF (@my_port_type = 'R')
      Insert into #children (port_num) select * from dbo.fnToSplit(@my_real_port_nums, ',')

   create table #plreportvalues
   ( 
      toi                               nvarchar(200),
      portfolio_strategy_name           nvarchar(50) null,
      port_num                          int null,
      portfolio_name                    nvarchar(150) null,
      type                              nvarchar(150) null,
      commodity_code                    nvarchar(150) null,
      market_code                       nvarchar(150) null,
      [month]                           char(20) null,
      last_trade_date                   varchar(20) null,
      seller                            nvarchar(150) null,
      buyer                             nvarchar(150) null,
      volume                            int null,
      price                             decimal(20, 8) null,
      pricing                           varchar(20) null,
      trader                            char(10) null,
      contractdate                      varchar(20) null,
      mtmprice                          decimal(20,8) null,
      pl                                decimal(20, 8) null,
      trade_no                          varchar(150) null,
      trade_fee                         varchar(50) null,
      comments                          varchar(200) null,
      inhouse_ind                       char(1) null,
      p_s_ind                           char(1) null,
      counterparty                      varchar(50) null,
      book                              varchar(50) null,
      opp_internal_toi                  varchar(200) null,
      inhouse_port_num                  int null,
      inhouse_portfolio_short_name      varchar(50) null,
      opp_internal_toi1                 varchar(200) null,
      opp_inhouse_port_num              int null,
      opp_inhouse_portfolio_short_name  varchar(50) null,
      realized_qty                      int null,
      unrealized_qty                    int null,
      realized_avg_price                decimal(20, 8) null,
      ratio                             decimal(20, 8) null, -- Added new for calculating settle and float
      is_pl_realized                    char(1),
      item_type                         char(1),
      trade_num                         int null,
      order_num                         int null,
      item_num                          int null,
      dist_num                          int null,
      dist_qty                          decimal(20, 8) null,
      order_type                        varchar(50) null
   )

   CREATE TABLE #trade_item
   (
		trade_num	INT,
		order_num	INT,
		item_num	INT,
		real_port_num int
   )

   --SWAP Query Started-------------------------------------------------------------------
	INSERT INTO [#trade_item] 
	SELECT	pl_secondary_owner_key1,
			pl_secondary_owner_key2,
			pl_secondary_owner_key3,
			real_port_num
	FROM dbo.pl_history plh
	JOIN #children t1 ON t1.port_num=plh.real_port_num
	WHERE pl_owner_code='C' AND
		  pl_owner_sub_code='SWAP' AND
		  [pl_asof_date] = @my_pl_asof_date 
		
   insert into #plreportvalues 
         (toi,
          portfolio_strategy_name,
          port_num,
          portfolio_name,
          type,
          commodity_code,
          market_code,
          [month],
          last_trade_date,
          seller,
          buyer,
          volume,
          price,
          pricing,
          trader,
          contractdate,
          mtmprice,
          pl,
          trade_no,
          trade_fee,
          comments,
          inhouse_ind,
          p_s_ind,
          counterparty,
          book,
          opp_internal_toi,
          inhouse_port_num,
          inhouse_portfolio_short_name,
          opp_internal_toi1,
          opp_inhouse_port_num,
          opp_inhouse_portfolio_short_name,
          realized_qty,
          unrealized_qty,
          realized_avg_price,
          ratio, -- Added new for calculating settle and float
          is_pl_realized,
          item_type,
          trade_num,
          order_num,
          item_num,
          dist_num,
          dist_qty,
          order_type) 
   select distinct
      convert(varchar, ti.trade_num) + '/' +convert(varchar, ti.order_num)+ '/' +convert(varchar, ti.item_num) 'toi',--ICTS
      ps.port_short_name portfolio_strategy_name,
      p.port_num,
      p.port_short_name,
      NULL,--rtrim(cm.cmdty_code) + ' ' + rtrim(cm.mkt_code) 'type', --Product
      NULL,--cm.cmdty_code 'commodity_code',
      NULL,--cm.mkt_code 'market_code', --Product
      NULL,--prd.trading_prd_desc 'month',
      NULL,--prd.last_trade_date 'last_trade_date',
      case when t.inhouse_ind = 'N' 
              then 
                 case when ti.p_s_ind = 'S' then bkcp.acct_short_name
                      else cp.acct_short_name
                 end
           when t.inhouse_ind in ('I', 'Y') 
              then
                 case when ti.p_s_ind = 'S' then p.port_short_name
                      else isnull(ip1.port_short_name, (select port_short_name 
                                                        from dbo.portfolio pp 
                                                        where pp.port_num = t.port_num))
                 end
      end 'seller',
      case when t.inhouse_ind = 'N' 
              then 
                 case when ti.p_s_ind = 'S' then cp.acct_short_name
                      else bkcp.acct_short_name
                 end
           when t.inhouse_ind in ('I', 'Y') 
              then
                 case when ti.p_s_ind = 'S' then isnull(ip1.port_short_name, (select port_short_name 
                                                                              from dbo.portfolio pp 
                                                                              where pp.port_num = t.port_num))
                      else p.port_short_name
                 end
      end 'buyer',
      case dtid.p_s_ind when 'S' then dtid.dist_qty * -1 
                        else dtid.dist_qty 
      end 'volume',
      convert(decimal(20,8),ABS(case isnull(dtidmtm.dist_qty, 0) when 0 then 0 
                                                                 else (isnull(dtidmtm.trade_value, 0) / isnull(dtidmtm.dist_qty, 1)) 
                                end)) 'price', --tradeprice (Price)
      NULL, --convert(varchar, qpp.quote_start_date, 101) 'Pricing',
      case when t.inhouse_ind = 'I' then 'Internal' 
           when t.inhouse_ind = 'Y' then 'Inhouse'
           when t.inhouse_ind = 'N' then t.trader_init 
      end 'trader',--Trader
      convert(varchar, t.contr_date, 101) 'contractdate',
      convert(decimal(20, 8), ABS(case isnull(dtidmtm.dist_qty, 0) when 0 then 0 
                                                                   else ((isnull(dtidmtm.trade_value, 0) - isnull(dtidmtm.market_value, 0)) / isnull(dtidmtm.dist_qty, 1)) 
                                  end)) 'mtmprice', --tradeprice (Price)
      convert(decimal(20, 8),(isnull(dtidmtm.open_pl, 0) + isnull(dtidmtm.closed_pl, 0))) 'pl', --P&L
      null 'trade_no',
      null 'trade_fee',
      (isnull(cmt.short_cmnt,'') + convert(varchar,isnull(cmt.cmnt_text,''))) 'comments',
      t.inhouse_ind,
      ti.p_s_ind,
      case t.inhouse_ind when 'Y' then convert(varchar, t.port_num) 
                         else cp.acct_short_name 
      end,
      --cp.acct_short_name 'counterparty',
      bkcp.acct_short_name 'book', 
      convert(varchar, ti.internal_parent_trade_num) + '/' +convert(varchar, ti.internal_parent_order_num)+
                    '/' +convert(varchar, ti.internal_parent_item_num) as 'opp_internal_toi', --ICTS
      iti.real_port_num as 'inhouse_port_num', --Inhouse Port num,
      ip.port_short_name as 'inhouse_portfolio_short_name', --Inhouse Portfolio short name
      convert(varchar, iti1.trade_num) + '/' + convert(varchar, iti1.order_num) + '/' + convert(varchar, iti1.item_num) as 'opp_internal_toi1', --ICTS
      iti1.real_port_num as 'opp_inhouse_port_num', 
      ip1.port_short_name as 'opp_inhouse_portfolio_short_name',
      dtidmtm.alloc_qty as 'realized_qty',
      (isnull(dtidmtm.dist_qty, 0) - isnull(dtidmtm.alloc_qty, 0)) as 'unrealized_qty',
      case isnull(dtidmtm.alloc_qty, 0) when 0 then 0 
                                        else (isnull(dtidmtm.trade_value, 0) / isnull(dtidmtm.alloc_qty, 1)) 
      end as 'realized_avg_price',
      1.0 'Ratio', -- Added new for calculating settle and float
      NULL /*case when datediff (dd, @my_pl_asof_date, acc.quote_end_date) >= 0 then 'N' 
           else 'Y' 
      end as*/  'is_pl_realized',
      ti.item_type,
      ti.trade_num,
      ti.order_num,
      ti.item_num,
      NULL,
      NULL,
      case tor.order_type_code when 'SWAP' then 'SWAP(fixed vs float)' 
                               when 'SWAPFLT' then 'SWAP(float vs float)' 
                               else tor.order_type_code 
      end 'order_type'
   from dbo.trade t
           join dbo.trade_order tor 
              on t.trade_num = tor.trade_num
           join dbo.trade_item ti 
              on tor.trade_num = ti.trade_num and 
                 tor.order_num = ti.order_num
           join dbo.trade_item_dist dtid 
              on dtid.trade_num = ti.trade_num and 
                 dtid.order_num = ti.order_num and 
                 dtid.item_num = ti.item_num and 
                 dtid.dist_type = 'D'
           JOIN #trade_item ti1 
              ON dtid.trade_num = ti1.trade_num and 
                 dtid.order_num = ti1.order_num and 
                 dtid.item_num = ti1.item_num and 
                 dtid.real_port_num = ti1.real_port_num
           left outer join dbo.account cp 
              on t.acct_num = cp.acct_num
           left outer join dbo.account bkcp 
              on ti.booking_comp_num = bkcp.acct_num
           join dbo.portfolio p 
              on dtid.real_port_num = p.port_num
           left outer join dbo.tid_mark_to_market dtidmtm 
              on dtidmtm.dist_num = dtid.dist_num and 
                 dtidmtm.mtm_pl_asof_date = @my_pl_asof_date 
           left outer join dbo.trade_item iti 
              on iti.trade_num = ti.internal_parent_trade_num and 
                 iti.order_num = ti.internal_parent_order_num and 
                 iti.item_num = ti.internal_parent_item_num
           left join dbo.portfolio ip 
              on iti.real_port_num = ip.port_num
           left outer join dbo.trade_item iti1 
              on iti1.internal_parent_trade_num = ti.trade_num and 
                 iti1.internal_parent_order_num = ti.order_num and 
                 iti1.internal_parent_item_num = ti.item_num
           left join dbo.portfolio ip1 
              on iti1.real_port_num = ip1.port_num
           join #children c 
              on c.port_num = dtid.real_port_num
           left outer join dbo.portfolio_group pg 
              on pg.port_num = dtid.real_port_num and 
                 is_link_ind = 'N'
           left outer join dbo.portfolio ps 
              on ps.port_num = pg.parent_port_num
                  left outer join dbo.trade_comment tcmt 
                        on tcmt.trade_num = t.trade_num
                  left outer join dbo.comment cmt 
                        on tcmt.cmnt_num = cmt.cmnt_num

	CREATE TABLE #swap_data (
		toi	VARCHAR(40),
		cmdty_code	CHAR(8),
		mkt_code	CHAR(8),
		trading_prd_desc	VARCHAR(40),
		last_trade_date	DATETIME,
		quote_start_date	DATETIME,
		quote_end_date	DATETIME		
	)
	
	INSERT INTO #swap_data
	SELECT   convert(varchar, ti.trade_num) + '/' +convert(varchar, ti.order_num)+ '/' +convert(varchar, ti.item_num) 'toi',
			cm.cmdty_code,
			cm.mkt_code,
			prd.trading_prd_desc,
			prd.last_trade_date,
			qpp.quote_start_date, 
			acc.quote_end_date
	FROM #trade_item ti
	   join dbo.accumulation acc 
		  on ti.trade_num = acc.trade_num and 
			 ti.order_num = acc.order_num and 
			 ti.item_num = acc.item_num
	   join dbo.quote_pricing_period qpp 
		  on acc.trade_num = qpp.trade_num and 
			 acc.order_num = qpp.order_num and 
			 acc.item_num = qpp.item_num and 
			 acc.accum_num = qpp.accum_num
	   join dbo.trade_item_dist utid 
		  on utid.trade_num = qpp.trade_num and 
			 utid.order_num = qpp.order_num and 
			 utid.item_num = qpp.item_num and 
			 utid.accum_num = qpp.accum_num and 
			 utid.qpp_num = qpp.qpp_num
	   join dbo.commodity_market cm 
		  on cm.commkt_key = utid.commkt_key 
	   join dbo.trading_period prd 
		  on prd.commkt_key = utid.commkt_key and 
			 prd.trading_prd = utid.trading_prd

	UPDATE ta1
	SET ta1.last_trade_date=ta2.last_trade_date,
		ta1.pricing=ta2.quote_start_date,
		ta1.is_pl_realized=ta2.realized_ind
	FROM #plreportvalues ta1
	JOIN (SELECT t1.toi,
				 MAX(last_trade_date) AS last_trade_date,
				 CONVERT(VARCHAR,MIN(quote_start_date),101) AS quote_start_date,
				 case when datediff (dd, @my_pl_asof_date, MAX(quote_end_date)) >= 0 then 'N' 
				else 'Y' end  AS realized_ind
    FROM #swap_data t1
    GROUP BY t1.toi) AS ta2 ON ta1.toi = ta2.toi
		   	
	UPDATE ta1
	SET ta1.commodity_code=ta2.cmdty_code,
		ta1.market_code=ta2.mkt_code,
		ta1.[month]=ta2.trading_prd_desc,
		ta1.type = ta2.type
	FROM #plreportvalues ta1
	JOIN (SELECT t1.toi,
		   REPLACE((SELECT RTRIM(t2.cmdty_code) + ' Vs ' AS 'data()' 
					FROM #swap_data t2 
					WHERE t1.toi=t2.toi ORDER BY t2.cmdty_code FOR XML PATH(''))+'$','Vs $','') AS cmdty_code,
		   REPLACE((SELECT RTRIM(t3.mkt_code) + ' Vs ' AS 'data()' 
					FROM #swap_data t3 
					WHERE t1.toi=t3.toi ORDER BY t3.mkt_code FOR XML PATH(''))+'$','Vs $','') AS mkt_code,
		   REPLACE((SELECT RTRIM(t2.trading_prd_desc) + ' Vs ' AS 'data()' 
					FROM #swap_data t2 
					WHERE t1.toi=t2.toi ORDER BY t2.trading_prd_desc FOR XML PATH(''))+'$','Vs $','') AS trading_prd_desc,
		   REPLACE((SELECT RTRIM(t2.cmdty_code) + ' ' +RTRIM(t2.mkt_code) + ' Vs ' AS 'data()' 
					FROM #swap_data t2 
					WHERE t1.toi=t2.toi ORDER BY t2.cmdty_code, t2.mkt_code FOR XML PATH(''))+'$','Vs $','') AS type	
    FROM #swap_data t1) AS ta2 ON ta1.toi = ta2.toi
			

   --SWAP QUERY ENDED---------------------------------------------------------------------------------------
   insert into #plreportvalues 
          (toi,
           portfolio_strategy_name,
           port_num,
           portfolio_name,
           type,
           commodity_code,
           market_code,
           [month],
           last_trade_date,
           seller,
           buyer,
           volume,
           price,
           pricing,
           trader,
           contractdate,
           mtmprice,
           pl,
           trade_no,
           trade_fee,
           comments,
           inhouse_ind,
           p_s_ind,
           counterparty,
           book,
           opp_internal_toi,
           inhouse_port_num,
           inhouse_portfolio_short_name,
           opp_internal_toi1,
           opp_inhouse_port_num,
           opp_inhouse_portfolio_short_name,
           realized_qty,
           unrealized_qty,
           realized_avg_price,
           ratio, -- Added new for calculating settle and float
           is_pl_realized,
           item_type,
           trade_num,
           order_num,
           item_num,
           dist_num,
           dist_qty,
           order_type) 
   select 
      convert(varchar, ti.trade_num) + '/' + convert(varchar, ti.order_num) + '/' + convert(varchar, ti.item_num) 'toi',--ICTS
      ps.port_short_name portfolio_strategy_name,
      p.port_num,
      p.port_short_name,
      rtrim(cm.cmdty_code) + ' ' + rtrim(cm.mkt_code)  'type', --Product
      cm.cmdty_code 'commodity_code',
      cm.mkt_code 'market_code', --Product
      prd.trading_prd_desc 'month',
      prd.last_trade_date 'last_trade_date',
      case when t.inhouse_ind = 'N' 
              then 
                 case when ti.p_s_ind = 'S' then bkcp.acct_short_name
                      else isnull(cp.acct_short_name, p.port_short_name)
                 end
           when t.inhouse_ind in ('I', 'Y') 
              then
                 case when ti.p_s_ind = 'S' then p.port_short_name
                      else isnull(ip1.port_short_name,(select port_short_name 
                                                       from dbo.portfolio pp 
                                                       where pp.port_num = t.port_num))
                 end
      end 'seller',
      case when t.inhouse_ind = 'N' 
              then 
                 case when ti.p_s_ind = 'S' then cp.acct_short_name
                      else bkcp.acct_short_name
                 end
           when t.inhouse_ind in ('I', 'Y') 
              then
                 case when ti.p_s_ind = 'S' then isnull(ip1.port_short_name, (select port_short_name 
                                                                              from dbo.portfolio pp 
                                                                              where pp.port_num = t.port_num))
                      else p.port_short_name
                 end
      end 'buyer',
      (case dtid.p_s_ind when 'S' then dtid.dist_qty * -1 
                         else dtid.dist_qty 
       end) * dtid.qty_uom_conv_rate 'volume',
      convert(decimal(20,8), ti.avg_price) 'price', --tradeprice (Price)
      convert(varchar, prd.last_trade_date, 101) 'Pricing',
      case when t.inhouse_ind = 'I' then 'Internal' 
           when t.inhouse_ind = 'Y' then 'Inhouse'
           when t.inhouse_ind = 'N' then t.trader_init 
      end 'trader',--Trader
      convert(varchar, t.contr_date, 101) 'contractdate',
      convert(decimal(20,8),pl_mkt_price) 'mtmprice', --tradeprice (Price)
      convert(decimal(20,8), (isnull(dtidmtm.open_pl, 0) + isnull(dtidmtm.closed_pl, 0))) 'pl', --P&L
      null 'trade_no',
      null 'trade_fee',
      (isnull(cmt.short_cmnt,'') + convert(varchar,isnull(cmt.cmnt_text,''))) 'comments',
      t.inhouse_ind,
      ti.p_s_ind,
      case t.inhouse_ind when 'Y' then convert(varchar, t.port_num) 
                         else cp.acct_short_name 
      end 'counterparty',
      bkcp.acct_short_name 'book', --BOOK
      convert(varchar, ti.internal_parent_trade_num) + '/' +convert(varchar, ti.internal_parent_order_num)+ '/' 
                   +convert(varchar, ti.internal_parent_item_num) as 'opp_internal_toi' ,--ICTS
      iti.real_port_num as 'inhouse_port_num', --Inhouse Port num,
      ip.port_short_name as 'inhouse_portfolio_short_name', --Inhouse Portfolio short name
      convert(varchar, iti1.trade_num) + '/' +convert(varchar, iti1.order_num)+ '/' +
                convert(varchar, iti1.item_num) as 'opp_internal_toi1' ,--ICTS
      iti1.real_port_num as 'opp_inhouse_port_num', --Inhouse Port num,1
      ip1.port_short_name as 'opp_inhouse_portfolio_short_name',--Inhouse Portfolio short name1
      0 'realized_qty',
      0 'unrealized_qty',
      0 'realized_avg_price',
      1 as 'ratio',
      case when datediff (dd, @my_pl_asof_date, prd.last_trade_date) >= 0 then 'N' 
           else 'Y' 
      end as 'is_pl_realized',
      ti.item_type,
      ti.trade_num,
      ti.order_num,
      ti.item_num,
      dtid.dist_num,
      null,
      case tor.order_type_code when 'SWAP' then 'SWAP(fixed vs float)' 
                               when 'SWAPFLT' then 'SWAP(float vs float)' 
                               else tor.order_type_code 
      end 'order_type'
   from dbo.pl_history plh
           join dbo.trade t
              on plh.pl_secondary_owner_key1 = t.trade_num
           join dbo.trade_order tor 
              on plh.pl_secondary_owner_key1 = tor.trade_num and
                 plh.pl_secondary_owner_key2 = tor.order_num
           join dbo.trade_item ti 
              on plh.pl_secondary_owner_key1 = ti.trade_num and 
                 plh.pl_secondary_owner_key2 = ti.order_num and
                 plh.pl_secondary_owner_key3 = ti.item_num
           join dbo.trade_item_dist dtid 
              on dtid.trade_num = ti.trade_num and 
                 dtid.order_num = ti.order_num and 
                 dtid.item_num = ti.item_num and 
                 dtid.real_port_num = plh.real_port_num and
                 dtid.dist_type = 'D'
           join dbo.commodity_market cm 
              on cm.commkt_key = dtid.commkt_key 
           left outer join dbo.account cp 
              on t.acct_num = cp.acct_num
           left outer join dbo.account bkcp 
              on ti.booking_comp_num = bkcp.acct_num
           join dbo.trading_period prd 
              on prd.commkt_key = dtid.commkt_key and 
                 prd.trading_prd = dtid.trading_prd
           join dbo.portfolio p 
              on dtid.real_port_num = p.port_num
           left outer join dbo.tid_mark_to_market dtidmtm 
              on dtidmtm.dist_num = dtid.dist_num and 
                 dtidmtm.mtm_pl_asof_date = @my_pl_asof_date 
           left outer join dbo.trade_item iti 
              on iti.trade_num = ti.internal_parent_trade_num and 
                 iti.order_num = ti.internal_parent_order_num and 
                 iti.item_num = ti.internal_parent_item_num
           left join dbo.portfolio ip 
              on iti.real_port_num = ip.port_num
           left outer join dbo.trade_item iti1 
              on iti1.internal_parent_trade_num = ti.trade_num and 
                 iti1.internal_parent_order_num = ti.order_num and 
                 iti1.internal_parent_item_num = ti.item_num
           left join dbo.portfolio ip1 
              on iti1.real_port_num = ip1.port_num
           left outer join dbo.portfolio_group pg 
              on pg.port_num = dtid.real_port_num and 
                 is_link_ind = 'N'
           left outer join dbo.portfolio ps 
              on ps.port_num = pg.parent_port_num
               left outer join dbo.trade_comment tcmt
                        on tcmt.trade_num = t.trade_num
                  left outer join dbo.comment cmt 
                        on tcmt.cmnt_num = cmt.cmnt_num
           join #children c 
              on c.port_num = dtid.real_port_num
   where plh.pl_asof_date = @my_pl_asof_date AND 
         ((plh.pl_owner_code = 'T' AND 
           plh.pl_type = 'U' AND 
           plh.pl_owner_sub_code in ('F', 'X') AND
           plh.pl_type not in ('W', 'I'))) AND 
         plh.pl_secondary_owner_key1 is not null AND 
         plh.pl_secondary_owner_key2 is not null AND 
         plh.pl_secondary_owner_key3 is not null 
   order by prd.last_trade_date, ti.trade_num, ti.order_num, ti.item_num

   select distinct 
      toi,
      portfolio_strategy_name,
      port_num,
      portfolio_name,
      type,
      commodity_code,
      market_code,
      [month],
      last_trade_date,
      seller,
      buyer,
      volume,
      price,
      pricing,
      trader,
      contractdate,
      mtmprice,
      pl,
      trade_no,
      trade_fee,
      comments,
      inhouse_ind,
      p_s_ind,
      counterparty,
      book,
      opp_internal_toi,
      inhouse_port_num,
      inhouse_portfolio_short_name,
      opp_internal_toi1,
      opp_inhouse_port_num,
      opp_inhouse_portfolio_short_name,
      realized_qty,
      unrealized_qty,
      realized_avg_price,
      ratio, -- Added new for calculating settle and float
      is_pl_realized,
      item_type,
      trade_num,
      order_num,
      item_num,
      dist_num,
      dist_qty,
      order_type
   from #plreportvalues

	DROP TABLE #plreportvalues
	DROP TABLE #children
	DROP TABLE #trade_item
	DROP TABLE #swap_data

endofsp: 
return 0
GO
GRANT EXECUTE ON  [dbo].[usp_pl_report] TO [next_usr]
GO
