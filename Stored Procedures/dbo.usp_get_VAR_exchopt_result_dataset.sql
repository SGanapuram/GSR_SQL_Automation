SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_get_VAR_exchopt_result_dataset] 
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

   /* The local variable @sql stores the following TSQL statement:
      select distinct 
         ti.trade_num, 
         ti.order_num, 
         ti.item_num, 
         ti.cmdty_code, 
         ti.risk_mkt_code, 
         ti.trading_prd, 
         tid.p_s_ind, 
         tid.dist_qty,    
         tid.alloc_qty, 
         tid.qty_uom_code, 
         tid.pos_num, 
         tid.real_port_num, 
         ti.opt_exp_date,
         ti.last_trade_date, 
         ti.opt_type, 
         ti.put_call_ind, 
         ti.strike_price,
         ti.strike_price_uom_code, 
         ti.strike_price_curr_code, 
         ti.commkt_curr_code, 
         ti.commkt_price_uom_code, 
         ti.commkt_key, 
         ti.mtm_price_source_code, 
         ti.mkt_type, 
         ti.sec_price_source_code, 
         ti.inhouse_ind,
         ti.real_port_num, 
         ti.first_del_date, 
         ti.last_del_date, 
         ti.trader_init,
         ti.acct_num,
         ti.creator_init,
         ti.booking_comp_num, 
         ti.order_type_code, 
         ti.brkr_num, 
         ti.clr_brkr_num 
      from (select trditm.*
            from dbo.v_VAR_exchange_options trditm
                    INNER JOIN dbo.icts_user iuser
                       ON trditm.trader_init = iuser.user_init
                    INNER JOIN dbo.desk dsk 
                       ON iuser.desk_code = dsk.desk_code 
                    INNER JOIN dbo.department dept 
                       ON dsk.dept_code = dept.dept_code
            where isnull(dept.trading_entity_num, 0) = 0 and
                  trditm.contr_date <= '02/08/2012' and
                  trditm.opt_exp_date >= '02/08/2012' and
                  exists (select 1 
                          from #portnums t '
                          where t.trade_num > 0 and 
                                trditm.trade_num = t.trade_num)) ti
               INNER JOIN (select *
                           from dbo.v_VAR_distribution dist
                           where exists (select 1
                                         from #portnums p
                                         where dist.real_port_num = p.port_num)) tid
                   ON ti.trade_num = tid.trade_num and
                      ti.order_num = tid.order_num and
                      ti.item_num = tid.item_num
  */               
   set @sql = 'select distinct ti.trade_num, ti.order_num, ti.item_num, ti.cmdty_code, '
   set @sql = @sql + 'ti.risk_mkt_code, ti.trading_prd, tid.p_s_ind, tid.dist_qty, '   
   set @sql = @sql + 'tid.alloc_qty, tid.qty_uom_code, tid.pos_num, tid.real_port_num, '
   set @sql = @sql + 'ti.opt_exp_date, ti.last_trade_date,  ti.opt_type, ti.put_call_ind, '
   set @sql = @sql + 'ti.strike_price, ti.strike_price_uom_code, ti.strike_price_curr_code, '
   set @sql = @sql + 'ti.commkt_curr_code, ti.commkt_price_uom_code, ti.commkt_key, ' 
   set @sql = @sql + 'ti.mtm_price_source_code, ti.mkt_type, ti.sec_price_source_code, '
   set @sql = @sql + 'ti.inhouse_ind, ti.real_port_num, ti.first_del_date, ' 
   set @sql = @sql + 'ti.last_del_date, ti.trader_init, ti.acct_num, ti.creator_init, '
   set @sql = @sql + 'ti.booking_comp_num, ti.order_type_code, ti.brkr_num, ti.clr_brkr_num '
   set @sql = @sql + 'from (select trditm.* from dbo.v_VAR_exchange_options trditm '
   if @trading_entity_num > 0
   begin
      set @sql = @sql + 'INNER JOIN dbo.icts_user iuser ON trditm.trader_init = iuser.user_init '
      set @sql = @sql + 'INNER JOIN dbo.desk dsk ON iuser.desk_code = dsk.desk_code '
      set @sql = @sql + 'INNER JOIN dbo.department dept ON dsk.dept_code = dept.dept_code '
   end
   set @sql = @sql + 'where '
   if @trading_entity_num > 0
      set @sql = @sql + 'isnull(dept.trading_entity_num, 0) = ' + cast(@trading_entity_num as varchar) + ' and '
   set @sql = @sql + 'trditm.contr_date <= ''' + convert(varchar, @run_date, 101) + ''' and '
   set @sql = @sql + 'trditm.opt_exp_date >= ''' + convert(varchar, @run_date, 101) + ''' '
   if @trades_selected_flag = 1
   begin
      set @sql = @sql + 'and exists (select 1 from #portnums t '
      set @sql = @sql + 'where t.trade_num > 0 and trditm.trade_num = t.trade_num) '
   end
   set @sql = @sql + ') ti '
   set @sql = @sql + 'INNER JOIN (select * from dbo.v_VAR_distribution dist '
   set @sql = @sql + 'where exists (select 1 from #portnums p '
   set @sql = @sql + 'where dist.real_port_num = p.port_num)) tid '
   set @sql = @sql + 'ON ti.trade_num = tid.trade_num and ti.order_num = tid.order_num and '
   set @sql = @sql + 'ti.item_num = tid.item_num'
   
   print 'SP: @sql = ''' + @sql + ''''
   begin try
     set @start_time = getdate()
     insert into #exchopt_myrsdata
        exec(@sql)
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #exchopt_myrsdata due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     print '==> SQL: ' + @sql
     goto errexit
   end catch

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #exchopt_myrsdata'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end
   goto endofsp
   
errexit:
   set @status = 1
   
endofsp:
return @status
GO
GRANT EXECUTE ON  [dbo].[usp_get_VAR_exchopt_result_dataset] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_get_VAR_exchopt_result_dataset', NULL, NULL
GO
