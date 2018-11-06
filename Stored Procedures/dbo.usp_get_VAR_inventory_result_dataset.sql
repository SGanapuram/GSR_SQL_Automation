SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_get_VAR_inventory_result_dataset] 
(
   @run_date               datetime,
   @trading_entity_num     int = 0,
   @debugon                bit = 0
)
as
set nocount on
declare @sql                    varchar(max),
        @rows_affected          int,
        @trades_selected_flag   bit,
        @status                 int,
        @start_time             datetime,
        @end_time               datetime

   set @status = 0
   set @trades_selected_flag = 0
   if (select count(*) from #portnums where trade_num > 0) > 0
      set @trades_selected_flag = 1
      
   /* ORIGINAL

       SELECT DISTINCT
          trditm.trade_num, 
          trditm.order_num, 
          trditm.item_num, 
          trditm.cmdty_code, 
          trditm.risk_mkt_code, 
          trditm.trading_prd, 
          trdprd.first_del_date, 
          trdprd.last_del_date, 
          inv.inv_curr_proj_qty, 
          inv.inv_curr_actual_qty, 
          inv.inv_qty_uom_code, 
          jms.port_num, 
          CONVERT(datetime, CONVERT(varchar, trdprd.last_del_date, 101)),
          commkt.commkt_key, 
          commkt.mtm_price_source_code, 
          mkt.mkt_type, 
          commktpattr.sec_price_source_code, 
          commktpattr.commkt_curr_code, 
          commktpattr.commkt_price_uom_code,
          commktfattr.sec_price_source_code, 
          commktfattr.commkt_curr_code, 
          commktfattr.commkt_price_uom_code, 
          trd.inhouse_ind, 
          trditm.real_port_num, 
          inv.next_inv_num, 
          inv.open_close_ind,
          inv.inv_cnfrmd_qty,
          inv.inv_adj_qty,
          inv.inv_open_prd_proj_qty,
          inv.inv_open_prd_actual_qty, 
          pre_inv.open_close_ind,
          inv.prev_inv_num,
          trd.trader_init, 
          trd.acct_num, 
          trd.creator_init, 
          trditm.booking_comp_num, 
          trdord.order_type_code 
       FROM dbo.trade_item trditm 
               INNER JOIN dbo.trade_order trdord 
                  ON trditm.trade_num = trdord.trade_num AND 
                     trditm.order_num = trdord.order_num 
               INNER JOIN dbo.trade trd 
                  ON trditm.trade_num = trd.trade_num 
               INNER JOIN dbo.jms_reports jms 
                  ON trditm.real_port_num = jms.port_num 
               INNER JOIN dbo.commodity_market commkt 
                  ON trditm.cmdty_code = commkt.cmdty_code AND 
                     trditm.risk_mkt_code = commkt.mkt_code 
               INNER JOIN dbo.inventory inv 
                  ON trditm.trade_num = inv.trade_num AND 
                     trditm.order_num = inv.order_num AND 
                     trditm.item_num = inv.sale_item_num 
               LEFT OUTER JOIN inventory pre_inv 
                  ON inv.prev_inv_num = pre_inv.inv_num 
               INNER JOIN dbo.market mkt 
                  ON trditm.risk_mkt_code = mkt.mkt_code 
               LEFT OUTER JOIN dbo.commkt_physical_attr commktpattr 
                  ON commkt.commkt_key = commktpattr.commkt_key 
               LEFT OUTER JOIN dbo.commkt_future_attr commktfattr 
                  ON commkt.commkt_key = commktfattr.commkt_key 
               LEFT OUTER JOIN dbo.trading_period trdprd 
                  ON commkt.commkt_key = trdprd.commkt_key AND 
                     trditm.trading_prd = trdprd.trading_prd 
               INNER JOIN dbo.icts_user iuser 
                  ON trd.trader_init = iuser.user_init 
               INNER JOIN dbo.desk dsk 
                  ON iuser.desk_code = dsk.desk_code 
               INNER JOIN dbo.department dept 
                  ON dsk.dept_code = dept.dept_code
       WHERE exists (select 1
                     from #portnums p
                     where trditm.real_port_num = p.port_num) and
            jms.classification_code like '[A,a]%' AND 
            trdord.strip_summary_ind <> 'Y' AND 
            trd.conclusion_type = 'C' AND 
            inv.open_close_ind NOT IN ('C', 'R') AND 
            inv.inv_type IN ('S', 'T') and 
            trd.contr_date <= '02/15/2012' and
            isnull(dept.trading_entity_num, 0) = 0
        */
   
   set @sql = 'select distinct '
   set @sql = @sql + 'trditm.trade_num, '
   set @sql = @sql + 'trditm.order_num, '
   set @sql = @sql + 'trditm.item_num, '
   set @sql = @sql + 'trditm.cmdty_code, '
   set @sql = @sql + 'trditm.risk_mkt_code, '
   set @sql = @sql + 'trditm.trading_prd, '
   set @sql = @sql + 'trdprd.first_del_date, '
   set @sql = @sql + 'trdprd.last_del_date, '
   set @sql = @sql + 'inv.inv_curr_proj_qty, '
   set @sql = @sql + 'inv.inv_curr_actual_qty, '
   set @sql = @sql + 'inv.inv_qty_uom_code, '
   set @sql = @sql + 'jms.port_num, '
   set @sql = @sql + 'CONVERT(datetime, CONVERT(varchar, trdprd.last_del_date, 101)), '
   set @sql = @sql + 'commkt.commkt_key, '
   set @sql = @sql + 'commkt.mtm_price_source_code, '
   set @sql = @sql + 'mkt.mkt_type, '
   set @sql = @sql + 'cp.sec_price_source_code, '
   set @sql = @sql + 'cp.commkt_curr_code, '
   set @sql = @sql + 'cp.commkt_price_uom_code, '
   set @sql = @sql + 'cf.sec_price_source_code, ' 
   set @sql = @sql + 'cf.commkt_curr_code, '
   set @sql = @sql + 'cf.commkt_price_uom_code, '
   set @sql = @sql + 'trd.inhouse_ind, '
   set @sql = @sql + 'trditm.real_port_num, '
   set @sql = @sql + 'inv.next_inv_num, '
   set @sql = @sql + 'inv.open_close_ind, '
   set @sql = @sql + 'inv.inv_cnfrmd_qty, '
   set @sql = @sql + 'inv.inv_adj_qty, '
   set @sql = @sql + 'inv.inv_open_prd_proj_qty, '
   set @sql = @sql + 'inv.inv_open_prd_actual_qty, '
   set @sql = @sql + 'pre_inv.open_close_ind, '
   set @sql = @sql + 'inv.prev_inv_num, '
   set @sql = @sql + 'trd.trader_init, '
   set @sql = @sql + 'trd.acct_num, '
   set @sql = @sql + 'trd.creator_init, '
   set @sql = @sql + 'trditm.booking_comp_num, '
   set @sql = @sql + 'trdord.order_type_code '

   set @sql = @sql + 'from dbo.trade_item trditm '
   set @sql = @sql + 'INNER JOIN dbo.trade_order trdord '
   set @sql = @sql + 'ON trditm.trade_num = trdord.trade_num AND '
   set @sql = @sql + 'trditm.order_num = trdord.order_num '
   set @sql = @sql + 'INNER JOIN dbo.trade trd '
   set @sql = @sql + 'ON trditm.trade_num = trd.trade_num '
   set @sql = @sql + 'INNER JOIN dbo.jms_reports jms '
   set @sql = @sql + 'ON trditm.real_port_num = jms.port_num '
   set @sql = @sql + 'INNER JOIN dbo.commodity_market commkt '
   set @sql = @sql + 'ON trditm.cmdty_code = commkt.cmdty_code AND '
   set @sql = @sql + 'trditm.risk_mkt_code = commkt.mkt_code '
   set @sql = @sql + 'INNER JOIN dbo.inventory inv '
   set @sql = @sql + 'ON trditm.trade_num = inv.trade_num AND '
   set @sql = @sql + 'trditm.order_num = inv.order_num AND '
   set @sql = @sql + 'trditm.item_num = inv.sale_item_num '
   set @sql = @sql + 'LEFT OUTER JOIN inventory pre_inv '
   set @sql = @sql + 'ON inv.prev_inv_num = pre_inv.inv_num '
   set @sql = @sql + 'INNER JOIN dbo.market mkt '
   set @sql = @sql + 'ON trditm.risk_mkt_code = mkt.mkt_code '
   set @sql = @sql + 'LEFT OUTER JOIN dbo.commkt_physical_attr cp '
   set @sql = @sql + 'ON commkt.commkt_key = cp.commkt_key '
   set @sql = @sql + 'LEFT OUTER JOIN dbo.commkt_future_attr cf '
   set @sql = @sql + 'ON commkt.commkt_key = cf.commkt_key '
   set @sql = @sql + 'LEFT OUTER JOIN dbo.trading_period trdprd '
   set @sql = @sql + 'ON commkt.commkt_key = trdprd.commkt_key AND '
   set @sql = @sql + 'trditm.trading_prd = trdprd.trading_prd '
   if @trading_entity_num > 0
   begin
      set @sql = @sql + 'INNER JOIN dbo.icts_user iuser ON trditm.trader_init = iuser.user_init '
      set @sql = @sql + 'INNER JOIN dbo.desk dsk ON iuser.desk_code = dsk.desk_code '
      set @sql = @sql + 'INNER JOIN dbo.department dept ON dsk.dept_code = dept.dept_code '
   end

   set @sql = @sql + 'where exists (select 1 from #portnums p '
   set @sql = @sql + 'where trditm.real_port_num = p.port_num) and '
   if @trades_selected_flag = 1
   begin
      set @sql = @sql + 'exists (select 1 from #portnums t '
      set @sql = @sql + 'where t.trade_num > 0 and trditm.trade_num = t.trade_num) and '
   end
   set @sql = @sql + 'jms.classification_code like ''[A,a]%'' AND '
   set @sql = @sql + 'trdord.strip_summary_ind <> ''Y'' AND '
   set @sql = @sql + 'trd.conclusion_type = ''C'' AND '
   set @sql = @sql + 'inv.open_close_ind NOT IN (''C'', ''R'') AND '
   set @sql = @sql + 'inv.inv_type IN (''S'', ''T'') and '
   set @sql = @sql + 'trd.contr_date <= ''' + convert(varchar, @run_date, 101) + ''' '
   if @trading_entity_num > 0
      set @sql = @sql + 'and isnull(dept.trading_entity_num, 0) = ' + cast(@trading_entity_num as varchar)
   
   
   begin try
     set @start_time = getdate()
     insert into #inventory_myrsdata
        exec(@sql)
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #inventory_myrsdata due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     print '==> SQL: ' + @sql
     goto errexit
   end catch

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #inventory_myrsdata'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end
     
   goto endofsp
   
errexit:
   set @status = 1
   
endofsp:
return @status
GO
GRANT EXECUTE ON  [dbo].[usp_get_VAR_inventory_result_dataset] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_get_VAR_inventory_result_dataset', NULL, NULL
GO
