SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_dump_fx_data_for_VAR_tradenum]
(
   @debugon          bit = 0
)
as 
set nocount on
declare @smsg              varchar(255)
declare @status            int
declare @errcode           int
declare @rows_affected     int

	 if (select count(*) from #fx_tradenums) = 0
	 begin
	    print '=> The table #fx_tradenums is empty!'
	    return 1
	 end 

	 set @status = 0
	 set @errcode = 0
	 set @rows_affected = 0

   create table #children
   (
	    port_num int PRIMARY KEY,
	    port_type char(2),
   )

   create table #fx_dump
   (
	    trade_number        varchar(40) null,
	    fx_exp_num          int null,
	    real_port_num       int null,
	    fx_type             varchar(15) null, 
	    fx_sub_type         varchar(15) null,
	    fx_currency	        char(8) null,
	    pl_currency	        char(8) null,
	    trading_prd	        varchar(15) null,
	    exp_date            varchar(15) null,
	    year	              char(4) null,
	    quarter             char(4) null,
	    month               char(4) null,
	    day                 char(4) null,
	    total_exp_by_id     decimal(20,8) null,
	    fx_amount           decimal(20,8) null,
	    fx_source           varchar(15) null,
	    cost_num            int null,
      trade_num           int null,
	    order_num           smallint null,
	    item_num            smallint null
   )

   create nonclustered index xx1333041_fx_dump_idx1
      on #fx_dump (trade_num, order_num, item_num)

   create table #tradeinfo
   (
      trade_num                 int          NOT NULL,
      order_num                 smallint     NOT NULL,
      item_num                  smallint     NOT NULL,
      inhouse_ind               char(1)      NULL,
      contr_date                datetime     NULL,
      first_del_date            datetime     NULL,
      last_del_date             datetime     NULL,
      trader_init               char(3)      NULL,
      acct_num                  int          NULL,
      creator_init              char(3)      NULL,
      booking_comp_num          int          NULL,
      order_type_code           char(8)      NULL,
      commkt_key                int          NULL,
      mtm_price_source_code     char(8)      NULL,
      mkt_type                  char(1)      NULL,
      sec_price_source_code     char(8)      NULL,
      commkt_curr_code          char(8)      NULL,
      commkt_price_uom_code     char(4)      NULL,
      cmdty_code                char(8)      NULL,
      risk_mkt_code             char(8)      NULL,
        primary key (trade_num, order_num, item_num)
   )
   
   begin try   
     insert into #children
     select distinct ti.real_port_num, 'R'
     from dbo.trade_item ti
     where exists (select 1
                   from #fx_tradenums t
                   where ti.trade_num = t.trade_num) and
           exists (select 1
                   from dbo.portfolio_tag ptag
                   where ptag.tag_name = 'CLASS' and
                         ptag.tag_value like '[A,a]%' and
                         ptag.port_num = ti.real_port_num)
     select @rows_affected = @@rowcount
   end try
   begin catch
     print '=> Failed to fill the #children table with REAL portnums from the trade_item table due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     set @errcode = ERROR_NUMBER()
     goto errexit
   end catch

   if @rows_affected = 0
   begin
      print '=> NO real port_nums were copied into the #children table!'
      goto endofsp
   end
   
   exec @status = dbo.usp_dump_fx_data @debugon
   if @status > 0
      goto endofsp

   insert into #tradeinfo
   select   
      ti.trade_num,
      ti.order_num,
      ti.item_num, 
      trd.inhouse_ind,
      trd.contr_date,
      tp.first_del_date,
      tp.last_del_date,
      trd.trader_init,
      trd.acct_num,
      trd.creator_init,
      ti.booking_comp_num,
      ord.order_type_code,
      cm.commkt_key,
      cm.mtm_price_source_code,
      m.mkt_type,
      case when m.mkt_type = 'F' then cfa.sec_price_source_code
           else cpa.sec_price_source_code
      end,
      case when m.mkt_type = 'F' then cfa.commkt_curr_code
           else cpa.commkt_curr_code
      end,
      case when m.mkt_type = 'F' then cfa.commkt_price_uom_code
           else cpa.commkt_price_uom_code
      end,
      ti.cmdty_code,
      ti.risk_mkt_code
   from dbo.trade_item ti
   	       join dbo.trade trd
	            on ti.trade_num = trd.trade_num 
	         join dbo.trade_order ord 
	            on ti.trade_num = ord.trade_num and
	               ti.order_num = ord.order_num
	         join dbo.commodity_market cm
	            on cm.cmdty_code = ti.cmdty_code and
	               cm.mkt_code = ti.risk_mkt_code
	         join dbo.market m
	            on m.mkt_code = ti.risk_mkt_code
	         left outer join dbo.trading_period tp
	            on cm.commkt_key = tp.commkt_key and
	               ti.trading_prd = tp.trading_prd
	         left outer join dbo.commkt_future_attr cfa
	            on cfa.commkt_key = cm.commkt_key
	         left outer join dbo.commkt_physical_attr cpa
	            on cpa.commkt_key = cm.commkt_key
   where exists (select 1
                 from #fx_dump fx
                 where ti.trade_num = fx.trade_num and
                       ti.order_num = fx.order_num and
                       ti.item_num = fx.item_num) and
         ord.strip_summary_ind <> 'Y' and
         trd.conclusion_type = 'C'

	 select 
	    trade_number,
	    fx_exp_num,
	    cost_num,
	    real_port_num,
	    fx_type,
	    exp_date,
	    year,
	    quarter,
	    month,
	    day,
	    fx_currency,
	    fx_amount,
	    fx_sub_type,
	    pl_currency,
	    fx.trading_prd,
	    total_exp_by_id,
	    fx_source,
	    'CLASS',
      ti.inhouse_ind,
      ti.contr_date,
      ti.first_del_date,
      ti.last_del_date,
      ti.trader_init,
      ti.acct_num,
      ti.creator_init,
      ti.booking_comp_num,
      ti.order_type_code,
      ti.commkt_key,
      ti.mtm_price_source_code,
      ti.mkt_type,
      ti.sec_price_source_code,
      ti.commkt_curr_code,
      ti.commkt_price_uom_code,
      ti.cmdty_code,
      ti.risk_mkt_code
	 from #fx_dump fx
	         left outer join #tradeinfo ti
	            on fx.trade_num = ti.trade_num and
	               fx.order_num = ti.order_num and
	               fx.item_num = ti.item_num
	 where fx_amount <> 0.0
	 order by real_port_num, trade_number, exp_date
	 
errexit:
   if @errcode > 0
      set @status = 1
   
endofsp:
if object_id('tempdb.dbo.#children', 'U') is not null
   exec('drop table #children')
if object_id('tempdb.dbo.#fx_dump', 'U') is not null
   exec('drop table #fx_dump')
if object_id('tempdb.dbo.#tradeinfo', 'U') is not null
   exec('drop table #tradeinfo')
return @status
GO
GRANT EXECUTE ON  [dbo].[usp_dump_fx_data_for_VAR_tradenum] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_dump_fx_data_for_VAR_tradenum', NULL, NULL
GO
