SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_CHGHISTORY_trade_changed_report]
(
   @chghistory_search_xml_string      xml,
   @debugon                           bit = 0
)
as
set nocount on
SET QUOTED_IDENTIFIER ON
declare @oid                    int
declare @root_port_num          int
declare @mod_date_expr          varchar(512)
declare @rows_affected          int
declare @profit_center_count    int
declare @trading_entity_count   int
declare @errcode                int
declare @smsg                   varchar(512)
declare @status                 int
declare @sql                    varchar(max)
declare @dberrmsg               varchar(max)

   --insert into WhatsChangedTrace (logtime, search_xml_string)
   --   values(getdate(), @chghistory_search_xml_string)
      
   set @errcode = 0
   set @status = 0
   set @profit_center_count = 0
   set @trading_entity_count = 0
   set @root_port_num = null
   set @mod_date_expr = null

   create table #children
   (
      port_num    int,
      port_type   char(2)
   )

   create table #profitCntrs 
   (
      profit_center varchar(32)
   );

   create nonclustered index xx01010_profitCntrs_idx 
      on #profitCntrs (profit_center);

   create table #trading_entities 
   (
      trading_entity_name nvarchar(15)
   );

   create nonclustered index xx01010_trading_entities_idx 
      on #trading_entities (trading_entity_name);

   create table #result
   (
      port_num                 int,
      portfolio_name           varchar(25) null,
      trade_key                varchar(92) null,
      order_type_code          varchar(8) null,
      operation                varchar(15) null,
      data_element             varchar(50) null,
      old_value                varchar(255) null,
      new_value                varchar(255) null,
      creation_date            datetime null,
      mod_date                 datetime null,
      who_did                  varchar(40) null,      
      profit_center            varchar(16) null,
      counterparty_name        nvarchar(15) null,
      price_curr_code          char(8) null,
      p_s_ind                  char(1) null,
      trading_entity_name      nvarchar(15) null,
      change_id                int null
   );

   create nonclustered index xx01981_result_idx1
      on #result(port_num);

   create nonclustered index xx01981_result_idx2
      on #result(profit_center);

   create nonclustered index xx01981_result_idx3
      on #result(trading_entity_name);

   create table #tempholder
   (
      port_num             int,
      date_expr            varchar(255),
      profit_center_count  int default 0,
      trading_entity_count int default 0
   );

   exec @status = dbo.usp_CHGHISTORY_get_search_filters @chghistory_search_xml_string, @debugon
   if @status > 0
   begin
   	  if @debugon = 1
   	     RAISERROR('=> Failed to execute the ''usp_CHGHISTORY_get_search_filters'' procedure!', 0, 1) WITH NOWAIT
   	  set @errcode = 1
   	  goto endofsp
   end
   
   select @root_port_num = port_num,
          @mod_date_expr = date_expr,
          @profit_center_count = profit_center_count,
          @trading_entity_count = trading_entity_count
   from #tempholder
             
   if @root_port_num is null
   begin
   	  RAISERROR('=> No port_num provided in XML string', 0, 1) WITH NOWAIT
   	  set @errcode = 1
   	  goto endofsp
   end
   
   if @debugon = 1
   begin
   	  set @smsg = 'Get real portfolioes underneath the port #' + cast(@root_port_num as varchar)
   	  RAISERROR(@smsg, 0, 1) WITH NOWAIT
   end
   
   begin try                                                      
     exec dbo.usp_get_child_port_nums @root_port_num, 1                                                  
   end try                                                  
   begin catch                                                  
     set @smsg = '=> Failed to execute the ''usp_get_child_port_nums'' sp due to the following error:'  
     RAISERROR(@smsg, 0, 1) WITH NOWAIT
     set @dberrmsg = ERROR_MESSAGE()                                                
     set @smsg = '==> ERROR: ' + @dberrmsg                                                  
     RAISERROR(@smsg, 0, 1) WITH NOWAIT
     set @errcode = ERROR_NUMBER()
     exec dbo.usp_save_dashboard_error @report_name = 'WhatsChangedReport',  
                                       @occurred_at = 'SP: usp_CHGHISTORY_trade_changed_report', 
                                       @problem_desc = 'Failed to execute the stored procedure',                                           
                                       @dberror_msg = @dberrmsg,
                                       @sql_stmt = 'exec dbo.usp_get_child_port_nums @root_port_num, 1',
                                       @debugon = @debugon                                                                                                    
     goto endofsp                                                  
   end catch 


   set @smsg = ''
   if len(@mod_date_expr) > 0
      set @smsg = @mod_date_expr + ' and '
   set @smsg = @smsg + 'data_element not in (''Trading Period'', ''Portfolio'', ''EstimateInd'',
                              ''Includes Excise Tax'',''Includes Fuel Tax'',
                              ''Relative Declare Date Ind'',''Relative Declare Date Type'')'

   select * into #updates
   from dbo.v_CHGHISTORY_uic_updates
   where 1 = 2
   select * into #deletes
   from dbo.v_CHGHISTORY_uic_deletes
   where 1 = 2

   set @sql = 'insert into #updates
               select * from dbo.v_CHGHISTORY_uic_updates
               where dataset_name = ''TRADE'' and
                     isnull(old_value, ''@@@'') <> isnull(new_value, ''@@@'') '
                            + case when len(@smsg) > 0 then ' and ' + @smsg
                                   else ''
                              end   
   exec(@sql)
   
   set @sql = 'insert into #deletes
               select * from dbo.v_CHGHISTORY_uic_deletes
               where dataset_name = ''TRADE''' + case when len(@smsg) > 0 then ' and ' + @smsg
                                                      else ''
                                                 end
   exec(@sql)

   create nonclustered index xx9910_updates_idx1
       on #updates (trade_num, order_num, item_num)

   create nonclustered index xx9910_deletes_idx1
       on #deletes (trade_num, order_num, item_num, resp_trans_id)

   insert into #result
        (port_num,
         portfolio_name,
         trade_key,
         order_type_code,
         operation,
         data_element,
         old_value,
         new_value,
         creation_date,
         mod_date,
         who_did,      
         profit_center,
         counterparty_name,
         price_curr_code,
         p_s_ind,
         trading_entity_name,
         change_id)
   select ti.real_port_num,
          p.port_short_name,
          cast(urm.trade_num as varchar) + '/' + cast(urm.order_num as varchar) + '/' + cast(urm.item_num as varchar),
          ti.order_type_code,
          'Modified',
          urm.data_element,
          urm.old_value,
          urm.new_value,
          ti.creation_date,
          urm.mod_date,
          urm.who_did,      
          pt.profit_center,
          ti.counterparty_name,
          ti.price_curr_code,
          ti.p_s_ind,
          p.trading_entity_name,
          urm.change_id
   from #updates urm
           join dbo.v_CHGHISTORY_trade_item_info ti 
              on urm.trade_num = ti.trade_num and 
                 urm.order_num = ti.order_num and 
                 urm.item_num = ti.item_num
           left outer join dbo.v_CHGHISTORY_profit_center_tags pt 
              on ti.real_port_num = pt.real_port_num     
           join dbo.v_CHGHISTORY_portfolio_info p 
              on ti.real_port_num = p.port_num
   where exists (select 1 from #children where port_num = ti.real_port_num)
   union
   select ti.real_port_num,
          p.port_short_name,
          cast(urm.trade_num as varchar) + '/' + cast(urm.order_num as varchar) + '/' + cast(urm.item_num as varchar),
          ti.order_type_code,
          'Delete',
          urm.data_element,
          urm.old_value,
          null,
          ti.creation_date,
          urm.mod_date,
          urm.who_did,      
          pt.profit_center,
          ti.counterparty_name,
          ti.price_curr_code,
          ti.p_s_ind,
          p.trading_entity_name,
          urm.change_id
   from #deletes urm
           join dbo.v_CHGHISTORY_aud_trade_item_info ti 
              on urm.trade_num = ti.trade_num and 
                 urm.order_num = ti.order_num and 
                 urm.item_num = ti.item_num and
                 urm.resp_trans_id = ti.resp_trans_id
           left outer join dbo.v_CHGHISTORY_profit_center_tags pt 
              on ti.real_port_num = pt.real_port_num      
           join dbo.v_CHGHISTORY_portfolio_info p 
              on ti.real_port_num = p.port_num
   where exists (select 1 from #children where port_num = ti.real_port_num)

   --select * from #profitCntrs order by profit_center
   --select * from #trading_entities order by trading_entity_name
   
   --set @smsg = '@profit_center_count = ' + cast(@profit_center_count as varchar)
   --RAISERROR(@smsg, 1, 0) WITH NOWAIT
   --set @smsg = '@trading_entity_count = ' + cast(@trading_entity_count as varchar)
   --RAISERROR(@smsg, 1, 0) WITH NOWAIT

   if @profit_center_count > 0
   begin
   	  delete a
   	  from #result a
   	  where not exists (select 1
   	                    from #profitCntrs b
   	                    where a.profit_center = b.profit_center)   	                    
   end 

   if @trading_entity_count > 0
   begin
   	  delete a
   	  from #result a
   	  where not exists (select 1
   	                    from #trading_entities b
   	                    where a.trading_entity_name = b.trading_entity_name)   	                    
   end 
   
   select port_num as PortNum,
          portfolio_name as PortfolioName,
          trade_key as TradeKey,
          order_type_code as TradeType,
          operation as Operation,
          data_element as DataElement,
          old_value as OldValue,
          new_value as NewValue,
          creation_date as CreationDate,
          mod_date as ModDate,
          who_did as WhoDid,      
          profit_center as ProfitCenter,
          counterparty_name as Counterparty,
          price_curr_code as Currency,
          p_s_ind as PurchaseSaleInd,
          trading_entity_name as TradingEntity,
          change_id as ChangeID
   from #result
   order by port_num
      
endofsp:
if object_id('tempdb..#tempholder', 'U') is not null
   exec('drop table #tempholder')
if object_id('tempdb..#children', 'U') is not null
   exec('drop table #children')
if object_id('tempdb..#updates', 'U') is not null
   exec('drop table #updates')
if object_id('tempdb..#deletes', 'U') is not null
   exec('drop table #deletes')
if object_id('tempdb..#profitCntrs', 'U') is not null
   exec('drop table #profitCntrs')
if object_id('tempdb..#trading_entities', 'U') is not null
   exec('drop table #trading_entities')
if object_id('tempdb..#result', 'U') is not null
   exec('drop table #result')
GO
GRANT EXECUTE ON  [dbo].[usp_CHGHISTORY_trade_changed_report] TO [next_usr]
GO
