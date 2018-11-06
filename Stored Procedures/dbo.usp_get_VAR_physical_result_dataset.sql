SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_get_VAR_physical_result_dataset] 
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
   create table #physical
   (
      trade_num                 int            NOT NULL,
      order_num                 smallint       NOT NULL,
      item_num                  smallint       NOT NULL,
      cmdty_code                char(8)        NULL,
      risk_mkt_code             char(8)        NULL,
      trading_prd               varchar(40)    NULL,
      inhouse_ind               char(1)        NULL,
      port_num                  int            NULL, 
      mat                       datetime       NULL,
      commkt_key                int            NULL,
      mtm_price_source_code     char(8)        NULL,
      mkt_type                  char(1)        NULL,
      physpricesourcecode       char(8)        NULL,
      physcurrcode              char(8)        NULL,
      physuomcode               char(4)        NULL,
      futpricesourcecode        char(8)        NULL,
      futcurrcode               char(8)        NULL,
      futuomcode                char(4)        NULL,
      real_port_num             int            NULL,
      first_del_date            datetime       NULL, 
      last_del_date             datetime       NULL,
      qty_uom_code              char(4)        NULL,
      qty_uom_code_conv_to      char(4)        NULL,
      qty_uom_conv_rate         float          NULL,
      trader_init               char(3)        NULL, 
      acct_num                  int            NULL, 
      creator_init              char(3)        NULL, 
      booking_comp_num          int            NULL,
      order_type_code           char(8)        NULL,
      p_s_ind                   char(1)        NULL, 
      real_synth_ind            char(1)        NULL,
      dist_qty                  float          NULL,
      alloc_qty                 float          NULL
   )

   set @trades_selected_flag = 0
   if (select count(*) from #portnums where trade_num > 0) > 0
      set @trades_selected_flag = 1
      
   /* ORIGINAL

      select distinct 
         ti.trade_num, 
         ti.order_num, 
         ti.item_num, 
         ti.cmdty_code, 
         ti.risk_mkt_code, 
         ti.trading_prd, 
         ti.inhouse_ind, 
         tid.real_port_num, 
         ti.mat, 
         ti.commkt_key, 
         ti.mtm_price_source_code, 
         ti.mkt_type, 
         ti.phy_sec_price_source_code, 
         ti.phy_commkt_curr_code, 
         ti.phy_commkt_price_uom_code, 
         ti.fut_sec_price_source_code, 
         ti.fut_commkt_curr_code, 
         ti.fut_commkt_price_uom_code, 
         ti.real_port_num, 
         ti.first_del_date, 
         ti.last_del_date, 
         tid.qty_uom_code, 
         tid.qty_uom_code_conv_to, 
         tid.qty_uom_conv_rate, 
         ti.trader_init, 
         ti.acct_num, 
         ti.creator_init, 
         ti.booking_comp_num,
         ti.order_type_code,
         tid.p_s_ind, 
         tid.real_synth_ind,
         tid.dist_qty,
         tid.alloc_qty
     from (select trditm.*
            from dbo.v_VAR_physical_trades trditm
                    INNER JOIN dbo.icts_user iuser
                       ON trditm.trader_init = iuser.user_init
                    INNER JOIN dbo.desk dsk 
                       ON iuser.desk_code = dsk.desk_code 
                    INNER JOIN dbo.department dept 
                       ON dsk.dept_code = dept.dept_code
            where isnull(dept.trading_entity_num, 0) = 0 and
                  trditm.contr_date <= '02/13/2012' and
                  dateadd(day, 31, trditm.last_del_date) >= '02/13/2012' and
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
   
   set @sql = 'select distinct '
   set @sql = @sql + 'ti.trade_num, '
   set @sql = @sql + 'ti.order_num, '
   set @sql = @sql + 'ti.item_num, '
   set @sql = @sql + 'ti.cmdty_code, '
   set @sql = @sql + 'ti.risk_mkt_code, '
   set @sql = @sql + 'ti.trading_prd, ' 
   set @sql = @sql + 'ti.inhouse_ind, '
   set @sql = @sql + 'tid.real_port_num, '
   set @sql = @sql + 'ti.mat, '
   set @sql = @sql + 'ti.commkt_key, '
   set @sql = @sql + 'ti.mtm_price_source_code, '
   set @sql = @sql + 'ti.mkt_type, '
   set @sql = @sql + 'ti.phy_sec_price_source_code, '
   set @sql = @sql + 'ti.phy_commkt_curr_code, '
   set @sql = @sql + 'ti.phy_commkt_price_uom_code, '
   set @sql = @sql + 'ti.fut_sec_price_source_code, '
   set @sql = @sql + 'ti.fut_commkt_curr_code, '
   set @sql = @sql + 'ti.fut_commkt_price_uom_code, '
   set @sql = @sql + 'ti.real_port_num, '
   set @sql = @sql + 'ti.first_del_date, '
   set @sql = @sql + 'ti.last_del_date, '
   set @sql = @sql + 'tid.qty_uom_code, '
   set @sql = @sql + 'tid.qty_uom_code_conv_to, '
   set @sql = @sql + 'tid.qty_uom_conv_rate, '
   set @sql = @sql + 'ti.trader_init, '
   set @sql = @sql + 'ti.acct_num, '
   set @sql = @sql + 'ti.creator_init, '
   set @sql = @sql + 'ti.booking_comp_num, '
   set @sql = @sql + 'ti.order_type_code, '
   set @sql = @sql + 'tid.p_s_ind, '
   set @sql = @sql + 'tid.real_synth_ind, '
   set @sql = @sql + 'tid.dist_qty, '
   set @sql = @sql + 'tid.alloc_qty '
   set @sql = @sql + 'from (select trditm.* from dbo.v_VAR_physical_trades trditm '
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
   set @sql = @sql + 'dateadd(day, 31, trditm.last_del_date) >= ''' + convert(varchar, @run_date, 101) + ''' '
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
   
   begin try
     set @start_time = getdate()
     insert into #physical
        exec(@sql)
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #physical due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     print '==> SQL: ' + @sql
     goto errexit
   end catch

   create clustered index xxx99191_physical_idx
      on #physical (trade_num, order_num, item_num, port_num)

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #physical'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end
        
   begin try
     set @start_time = getdate()
     insert into #physical_myrsdata
     select 
        trade_num, 
        order_num, 
        item_num, 
        cmdty_code, 
        risk_mkt_code, 
        trading_prd, 
        inhouse_ind, 
        port_num, 
        mat, 
        commkt_key, 
        mtm_price_source_code, 
        mkt_type, 
        physpricesourcecode,
        physcurrcode,
        physuomcode,
        futpricesourcecode,
        futcurrcode,
        futuomcode,
        real_port_num, 
        first_del_date, 
        last_del_date, 
        qty_uom_code, 
        qty_uom_code_conv_to, 
        qty_uom_conv_rate, 
        trader_init, 
        acct_num, 
        creator_init, 
        booking_comp_num,
        order_type_code
     from #physical
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #physical_myrsdata due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #physical_myrsdata'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end

   begin try
     set @start_time = getdate()
     insert into #physical_myrsquant1
     select 
        trade_num,
        order_num,
        item_num,
        dist_qty,
        alloc_qty,
        qty_uom_code
     from #physical
     where real_synth_ind = 'R'
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #physical_myrsquant1 due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #physical_myrsquant1'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end
   
   begin try
     set @start_time = getdate()
     insert into #physical_myrsquant2
     select 
        trade_num,
        order_num,
        item_num,
        port_num,
        p_s_ind,
        dist_qty,
        alloc_qty,
        qty_uom_code
     from #physical
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #physical_myrsquant2 due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #physical_myrsquant2'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end
   
   begin try
     set @start_time = getdate()
     insert into #physical_myrsalloc
     select distinct
        phy.trade_num,
        phy.order_num,
        phy.item_num,
        alloc.alloc_type_code 
     from #physical phy
             INNER JOIN dbo.allocation_item ai 
                ON phy.trade_num = ai.trade_num and
                   phy.order_num = ai.order_num and
                   phy.item_num = ai.item_num
             INNER JOIN dbo.allocation alloc
                ON alloc.alloc_num = ai.alloc_num
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #physical_myrsalloc due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #physical_myrsalloc'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end       
   goto endofsp
   
errexit:
   set @status = 1
   
endofsp:
drop table #physical
return @status
GO
GRANT EXECUTE ON  [dbo].[usp_get_VAR_physical_result_dataset] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_get_VAR_physical_result_dataset', NULL, NULL
GO
