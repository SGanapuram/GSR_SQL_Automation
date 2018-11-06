SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_get_VAR_phyfloat_result_dataset] 
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
   create table #phyfloat
   (
      trade_num                 int            NOT NULL,
      order_num                 smallint       NOT NULL,
      item_num                  smallint       NOT NULL,
      cmdty_code                char(8)        NULL,
      risk_mkt_code             char(8)        NULL,
      inhouse_ind               char(1)        NULL,
      port_num                  int            NULL, 
      commkt_key                int            NULL,
      real_port_num             int            NULL,
      dist_qty                  float          NULL,
      alloc_qty                 float          NULL,
      real_synth_ind            char(1)        NULL,
      qty_uom_code              char(4)        NULL,
      qty_uom_code_conv_to      char(4)        NULL,
      qty_uom_conv_rate         float          NULL,
      trader_init               char(3)        NULL, 
      acct_num                  int            NULL, 
      creator_init              char(3)        NULL, 
      booking_comp_num          int            NULL, 
      order_type_code           char(8)        NULL,
      p_s_ind                   char(1)        NULL
   )

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
        ti.inhouse_ind,
        tid.real_port_num as port_num,
        ti.commkt_key, 
        ti.real_port_num, 
        tid.dist_qty,
        tid.alloc_qty,
        tid.real_synth_ind,
        tid.qty_uom_code, 
        tid.qty_uom_code_conv_to, 
        tid.qty_uom_conv_rate, 
        ti.trader_init, 
        ti.acct_num, 
        ti.creator_init, 
        ti.booking_comp_num, 
        ti.order_type_code,
        tid.p_s_ind 
     from (select trditm.*
           from dbo.v_VAR_physical_float_trades trditm
                   INNER JOIN dbo.icts_user iuser
                      ON trditm.trader_init = iuser.user_init
                   INNER JOIN dbo.desk dsk 
                      ON iuser.desk_code = dsk.desk_code 
                   INNER JOIN dbo.department dept 
                      ON dsk.dept_code = dept.dept_code
           where isnull(dept.trading_entity_num, 0) = @trading_entity_num and
                 trditm.contr_date <= @run_date and
                 exists (select 1
                         from #portnums t
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
   set @sql = @sql + 'ti.risk_mkt_code, ti.inhouse_ind, tid.real_port_num, ti.commkt_key, '
   set @sql = @sql + 'ti.real_port_num, tid.dist_qty, tid.alloc_qty, tid.real_synth_ind, '
   set @sql = @sql + 'tid.qty_uom_code, tid.qty_uom_code_conv_to, tid.qty_uom_conv_rate, '
   set @sql = @sql + 'ti.trader_init, ti.acct_num, ti.creator_init, ti.booking_comp_num, ' 
   set @sql = @sql + 'ti.order_type_code, tid.p_s_ind from (select trditm.* from '
   set @sql = @sql + 'dbo.v_VAR_physical_float_trades trditm '
   if @trading_entity_num > 0
   begin
      set @sql = @sql + 'INNER JOIN dbo.icts_user iuser ON trditm.trader_init = iuser.user_init '
      set @sql = @sql + 'INNER JOIN dbo.desk dsk ON iuser.desk_code = dsk.desk_code '
      set @sql = @sql + 'INNER JOIN dbo.department dept ON dsk.dept_code = dept.dept_code '
   end
   set @sql = @sql + 'where '
   if @trading_entity_num > 0
      set @sql = @sql + 'isnull(dept.trading_entity_num, 0) = ' + cast(@trading_entity_num as varchar) + ' and '
   set @sql = @sql + 'trditm.contr_date <= ''' + convert(varchar, @run_date, 101) + ''' '
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
     insert into #phyfloat
        exec(@sql)
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #phyfloat due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     print '==> SQL: ' + @sql
     goto errexit
   end catch

   create clustered index xxx99191_phyfloat_idx
      on #phyfloat (trade_num, order_num, item_num, port_num)

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #phyfloat'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end
     
   begin try
     set @start_time = getdate()
     insert into #phyfloat_myrsdata
     select 
        trade_num,
        order_num,
        item_num,
        cmdty_code,
        risk_mkt_code,
        inhouse_ind,
        port_num,
        commkt_key, 
        real_port_num, 
        qty_uom_code, 
        qty_uom_code_conv_to, 
        qty_uom_conv_rate, 
        trader_init, 
        acct_num, 
        creator_init, 
        booking_comp_num, 
        order_type_code 
     from #phyfloat
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #phyfloat_myrsdata due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #phyfloat_myrsdata'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end

   begin try
     set @start_time = getdate()
     insert into #phyfloat_myrsquant1
     select 
        trade_num,
        order_num,
        item_num,
        dist_qty,
        alloc_qty,
        qty_uom_code
     from #phyfloat
     where real_synth_ind = 'R'
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #phyfloat_myrsquant1 due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #phyfloat_myrsquant1'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end

   begin try
     set @start_time = getdate()
     insert into #phyfloat_myrsquant2
     select 
        trade_num,
        order_num,
        item_num,
        port_num,
        p_s_ind,
        dist_qty,
        qty_uom_code 
     from #phyfloat
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #phyfloat_myrsquant2 due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #phyfloat_myrsquant2'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end

   begin try
     set @start_time = getdate()
     insert into #phyfloat_myrsalloc
     select distinct
        phy.trade_num,
        phy.order_num,
        phy.item_num,
        alloc.alloc_type_code 
     from #phyfloat phy
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
     print '=> Failed to build data set in the temp table #phyfloat_myrsalloc due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #phyfloat_myrsalloc'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end

   begin try
     set @start_time = getdate()
     insert into #phyfloat_myrsaccum
     select distinct
        phy.trade_num,
        phy.order_num,
        phy.item_num,
        acc.accum_num,
        acc.formula_num,
        acc.accum_qty,
        acc.accum_qty_uom_code,
        acc.accum_creation_type 
     from #phyfloat phy
             INNER JOIN dbo.accumulation acc 
                ON phy.trade_num = acc.trade_num and
                   phy.order_num = acc.order_num and
                   phy.item_num = acc.item_num
     where acc.accum_creation_type not in ('R', 'K') 
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #phyfloat_myrsaccum due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #phyfloat_myrsaccum'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end

   begin try
     set @start_time = getdate()
     insert into #phyfloat_myrsqpp
     select distinct
        phy.trade_num, 
        phy.order_num, 
        phy.item_num, 
        acc.accum_num, 
        qpp.qpp_num, 
        qpp.formula_num, 
        qpp.formula_body_num,
        qpp.formula_comp_num, 
        qpp.num_of_pricing_days, 
        qpp.num_of_days_priced, 
        qpp.risk_trading_prd, 
        qpp.total_qty, 
        qpp.qty_uom_code, 
        cm.mkt_type,
        cm.phy_commkt_curr_code, 
        cm.phy_commkt_price_uom_code,
        cm.phy_sec_price_source_code, 
        cm.fut_commkt_curr_code, 
        cm.fut_commkt_price_uom_code, 
        cm.fut_sec_price_source_code
   from #phyfloat phy
           INNER JOIN dbo.accumulation AS acc 
              ON phy.trade_num = acc.trade_num AND 
                 phy.order_num = acc.order_num AND
                 phy.item_num = acc.item_num 
           INNER JOIN dbo.quote_pricing_period AS qpp 
              ON acc.trade_num = qpp.trade_num AND 
                 acc.order_num = qpp.order_num AND 
                 acc.item_num = qpp.item_num AND
                 acc.accum_num = qpp.accum_num 
           INNER JOIN dbo.formula_component AS fc 
              ON qpp.formula_num = fc.formula_num AND 
                 qpp.formula_body_num = fc.formula_body_num AND
                 qpp.formula_comp_num = fc.formula_comp_num 
           INNER JOIN dbo.v_VAR_commkt_info cm
              ON fc.commkt_key = cm.commkt_key 
     where acc.accum_creation_type not in ('R', 'K') and
           fc.formula_comp_type <> 'C'
     set @rows_affected = @@rowcount
   end try
   begin catch
     print '=> Failed to build data set in the temp table #phyfloat_myrsqpp due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #phyfloat_myrsqpp'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end

   begin try
     set @start_time = getdate()
     insert into #phyfloat_myrsfrm
     select 
        formula_num,
        formula_curr_code,
        formula_uom_code,
        use_alt_source_ind  
     from dbo.formula frm 
     where exists (select 1
                   from #phyfloat phy
                           INNER JOIN dbo.accumulation AS acc 
                              ON phy.trade_num = acc.trade_num AND 
                                 phy.order_num = acc.order_num AND
                                 phy.item_num = acc.item_num 
                           INNER JOIN dbo.quote_pricing_period AS qpp 
                              ON acc.trade_num = qpp.trade_num AND 
                                 acc.order_num = qpp.order_num AND 
                                 acc.item_num = qpp.item_num AND
                                 acc.accum_num = qpp.accum_num 
                   where frm.formula_num = qpp.formula_num and 
                         acc.accum_creation_type not in ('R', 'K')) 
     union 
     select  
        formula_num,
        formula_curr_code,
        formula_uom_code,
        use_alt_source_ind 
     from dbo.formula frm 
     where exists (select 1
                   from #phyfloat phy
                           INNER JOIN dbo.accumulation acc 
                              ON phy.trade_num = acc.trade_num AND 
                                 phy.order_num = acc.order_num AND
                                 phy.item_num = acc.item_num 
                           INNER JOIN dbo.quote_pricing_period qpp 
                              ON acc.trade_num = qpp.trade_num AND 
                                 acc.order_num = qpp.order_num AND 
                                 acc.item_num = qpp.item_num AND
                                 acc.accum_num = qpp.accum_num 
                   where frm.formula_num = acc.formula_num and 
                         acc.accum_creation_type not in ('R', 'K')) 
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #phyfloat_myrsfrm due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #phyfloat_myrsfrm'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end

   begin try
     set @start_time = getdate()
     insert into #phyfloat_myrsfb
     select
        formula_num,
        formula_body_num, 
        complexity_ind, 
        formula_body_type,
        formula_parse_string,
        formula_qty_pcnt_val,
        formula_qty_uom_code,
        formula_body_string 
     from dbo.formula_body fb
     where exists (select 1
                   from #phyfloat_myrsfrm frm 
                   where fb.formula_num = frm.formula_num)
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #phyfloat_myrsfb due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #phyfloat_myrsfb'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end

   begin try
     set @start_time = getdate()
     insert into #phyfloat_myrsfbfc
     select distinct
        fc.formula_num,
        fb.formula_body_type,
        fc.formula_comp_cmnt,
        fc.formula_comp_val,
        fc.formula_comp_val_type,
        fc.formula_comp_curr_code,
        fc.formula_comp_uom_code 
     from dbo.formula_component fc
             INNER JOIN #phyfloat_myrsfb fb
                ON fb.formula_num = fc.formula_num and
                   fb.formula_body_num = fc.formula_body_num
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #phyfloat_myrsfbfc due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #phyfloat_myrsfbfc'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end

   begin try
     set @start_time = getdate()
     insert into #phyfloat_myrsfc
     select distinct 
        fc.formula_num,
        fc.formula_body_num,
        fc.formula_comp_num,
        fc.formula_comp_val,
        fc.formula_comp_curr_code, 
        fc.formula_comp_uom_code, 
        fc.formula_comp_type, 
        fc.commkt_key, 
        fc.price_source_code, 
        fc.formula_comp_name, 
        fc.formula_comp_ref, 
        cms.calendar_code 
     from dbo.formula_component fc 
             LEFT OUTER JOIN dbo.commodity_market_source cms with (nolock)
                ON cms.commkt_key = fc.commkt_key and 
                   cms.price_source_code = fc.price_source_code 
     where exists (select 1
                   from #phyfloat_myrsfb fb
                   where fb.formula_num = fc.formula_num and
                         fb.formula_body_num = fc.formula_body_num)
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #phyfloat_myrsfc due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #phyfloat_myrsfc'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end

   begin try
     set @start_time = getdate()
     insert into #phyfloat_myrscmdtymkt
     select distinct
        commkt_key,
        cmdty_code,
        mkt_code 
     from dbo.commodity_market cm
     where exists (select 1
                   from #phyfloat_myrsfc fc
                   where fc.commkt_key = cm.commkt_key)
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #phyfloat_myrscmdtymkt due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #phyfloat_myrscmdtymkt'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end

   begin try
     set @start_time = getdate()
     insert into #phyfloat_myrstrdprd
     select 
        commkt_key,
        trading_prd,
        first_del_date,
        last_del_date,
        convert(datetime, convert(varchar, last_del_date, 101)) as mat 
     from dbo.trading_period trdprd
     where exists (select 1
                   from #phyfloat phy
                           INNER JOIN dbo.accumulation acc 
                              ON phy.trade_num = acc.trade_num AND 
                                 phy.order_num = acc.order_num AND
                                 phy.item_num = acc.item_num 
                           INNER JOIN dbo.quote_pricing_period qpp 
                              ON acc.trade_num = qpp.trade_num AND 
                                 acc.order_num = qpp.order_num AND 
                                 acc.item_num = qpp.item_num AND
                                 acc.accum_num = qpp.accum_num 
                           INNER JOIN dbo.formula_component fc
                              ON fc.formula_num = qpp.formula_num and 
                                 fc.formula_body_num = qpp.formula_body_num and 
                                 fc.formula_comp_num = qpp.formula_comp_num 
                   where acc.accum_creation_type not in ('R', 'K') and
                         trdprd.commkt_key = fc.commkt_key and 
                         trdprd.trading_prd = qpp.risk_trading_prd) 
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #phyfloat_myrstrdprd due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #phyfloat_myrstrdprd'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end

   begin try
     set @start_time = getdate()
     insert into #phyfloat_myrsqp
     select 
        phy.trade_num,
        phy.order_num,
        phy.item_num,
        acc.accum_num,
        qpp.qpp_num,
        count(qp.price_quote_date) as idaycount 
     from #phyfloat phy
             INNER JOIN dbo.accumulation acc 
                ON phy.trade_num = acc.trade_num and 
                   phy.order_num = acc.order_num and
                   phy.item_num = acc.item_num 
             INNER JOIN dbo.quote_pricing_period qpp 
                ON acc.trade_num = qpp.trade_num and 
                   acc.order_num = qpp.order_num and 
                   acc.item_num = qpp.item_num and
                   acc.accum_num = qpp.accum_num 
             INNER JOIN dbo.quote_price qp 
                ON qp.trade_num = qpp.trade_num and 
                   qp.order_num = qpp.order_num and 
                   qp.item_num = qpp.item_num and 
                   qp.accum_num = qpp.accum_num and 
                   qp.qpp_num = qpp.qpp_num 
     where acc.accum_creation_type not in ('R', 'K') and
           qp.price_quote_date <= @run_date and
           (qp.manual_override_type is null or 
            qp.manual_override_type <> 'D') 
     group by phy.trade_num,
              phy.order_num,
              phy.item_num,
              acc.accum_num,
              qpp.qpp_num 
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #phyfloat_myrsqp due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #phyfloat_myrsqp'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end

   begin try
     set @start_time = getdate()
     insert into #phyfloat_myrsaccumrf
     select distinct
        phy.trade_num,
        phy.order_num,
        phy.item_num,
        acc.accum_num,
        acc.formula_num,
        acc.accum_qty,
        acc.accum_qty_uom_code,
        acc.accum_creation_type 
     from #phyfloat phy
        INNER JOIN dbo.accumulation acc 
           ON phy.trade_num = acc.trade_num and
              phy.order_num = acc.order_num and
              phy.item_num = acc.item_num
     where acc.accum_creation_type in ('R', 'K')
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #phyfloat_myrsaccumrf due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #phyfloat_myrsaccumrf'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end

   begin try
     set @start_time = getdate()
     insert into #phyfloat_myrsqpprf
     select distinct
        phy.trade_num, 
        phy.order_num, 
        phy.item_num, 
        acc.accum_num, 
        qpp.qpp_num, 
        qpp.formula_num, 
        qpp.formula_body_num,
        qpp.formula_comp_num, 
        qpp.num_of_pricing_days, 
        qpp.num_of_days_priced, 
        qpp.risk_trading_prd, 
        qpp.total_qty, 
        qpp.qty_uom_code, 
        cm.mkt_type,
        cm.phy_commkt_curr_code, 
        cm.phy_commkt_price_uom_code,
        cm.phy_sec_price_source_code, 
        cm.fut_commkt_curr_code, 
        cm.fut_commkt_price_uom_code, 
        cm.fut_sec_price_source_code
     from #phyfloat phy
             INNER JOIN dbo.accumulation acc 
                ON phy.trade_num = acc.trade_num AND 
                   phy.order_num = acc.order_num AND
                   phy.item_num = acc.item_num 
             INNER JOIN dbo.quote_pricing_period qpp 
                ON acc.trade_num = qpp.trade_num AND 
                   acc.order_num = qpp.order_num AND 
                   acc.item_num = qpp.item_num AND
                   acc.accum_num = qpp.accum_num 
             INNER JOIN dbo.formula_component AS fc 
                ON qpp.formula_num = fc.formula_num AND 
                   qpp.formula_body_num = fc.formula_body_num AND
                   qpp.formula_comp_num = fc.formula_comp_num 
             INNER JOIN dbo.v_VAR_commkt_info cm
                ON fc.commkt_key = cm.commkt_key 
     where acc.accum_creation_type in ('R', 'K')
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #phyfloat_myrsqpprf due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #phyfloat_myrsqpprf'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end

   begin try
     set @start_time = getdate()
     insert into #phyfloat_myrsfrmrf
     select 
        formula_num,
        formula_curr_code,
        formula_uom_code,
        use_alt_source_ind  
     from dbo.formula frm 
     where exists (select 1
                   from #phyfloat phy
                           INNER JOIN dbo.accumulation acc 
                              ON phy.trade_num = acc.trade_num AND 
                                 phy.order_num = acc.order_num AND
                                 phy.item_num = acc.item_num 
                           INNER JOIN dbo.quote_pricing_period qpp 
                              ON acc.trade_num = qpp.trade_num AND 
                                 acc.order_num = qpp.order_num AND 
                                 acc.item_num = qpp.item_num AND
                                 acc.accum_num = qpp.accum_num 
                   where frm.formula_num = qpp.formula_num and 
                         acc.accum_creation_type in ('R', 'K')) 
     union 
     select  
        formula_num,
        formula_curr_code,
        formula_uom_code,
        use_alt_source_ind 
     from dbo.formula frm 
     where exists (select 1
                   from #phyfloat phy
                           INNER JOIN dbo.accumulation acc 
                              ON phy.trade_num = acc.trade_num AND 
                                 phy.order_num = acc.order_num AND
                                 phy.item_num = acc.item_num 
                           INNER JOIN dbo.quote_pricing_period qpp 
                              ON acc.trade_num = qpp.trade_num AND 
                                 acc.order_num = qpp.order_num AND 
                                 acc.item_num = qpp.item_num AND
                                 acc.accum_num = qpp.accum_num 
                   where frm.formula_num = acc.formula_num and 
                         acc.accum_creation_type in ('R', 'K')) 
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #phyfloat_myrsfrmrf due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #phyfloat_myrsfrmrf'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end

   begin try
     set @start_time = getdate()
     insert into #phyfloat_myrsfbrf
     select
        formula_num,
        formula_body_num, 
        complexity_ind, 
        formula_body_type,
        formula_parse_string,
        formula_qty_pcnt_val,
        formula_qty_uom_code,
        formula_body_string 
     from dbo.formula_body fb
     where exists (select 1
                   from #phyfloat_myrsfrmrf frm 
                   where fb.formula_num = frm.formula_num)
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #phyfloat_myrsfbrf due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #phyfloat_myrsfbrf'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end

   begin try
     set @start_time = getdate()
     insert into #phyfloat_myrsfbfcrf
     select distinct
        fc.formula_num,
        fb.formula_body_type,
        fc.formula_comp_cmnt,
        fc.formula_comp_val,
        fc.formula_comp_val_type,
        fc.formula_comp_curr_code,
        fc.formula_comp_uom_code 
     from dbo.formula_component fc
             INNER JOIN #phyfloat_myrsfbrf fb
                ON fb.formula_num = fc.formula_num and
                   fb.formula_body_num = fc.formula_body_num
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #phyfloat_myrsfbfcrf due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #phyfloat_myrsfbfcrf'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end

   begin try
     set @start_time = getdate()
     insert into #phyfloat_myrsfcrf
     select distinct 
        fc.formula_num,
        fc.formula_body_num,
        fc.formula_comp_num,
        fc.formula_comp_val,
        fc.formula_comp_curr_code, 
        fc.formula_comp_uom_code, 
        fc.formula_comp_type, 
        fc.commkt_key, 
        fc.price_source_code, 
        fc.formula_comp_name, 
        fc.formula_comp_ref, 
        cms.calendar_code 
     from dbo.formula_component fc 
             LEFT OUTER JOIN dbo.commodity_market_source cms with (nolock)
                ON cms.commkt_key = fc.commkt_key and 
                   cms.price_source_code = fc.price_source_code 
     where exists (select 1
                   from #phyfloat_myrsfbrf fb
                   where fb.formula_num = fc.formula_num and
                         fb.formula_body_num = fc.formula_body_num)
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #phyfloat_myrsfcrf due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #phyfloat_myrsfcrf'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end

   begin try
     set @start_time = getdate()
     insert into #phyfloat_myrscmdtymktrf
     select 
        commkt_key,
        cmdty_code,
        mkt_code 
     from dbo.commodity_market cm
     where exists (select 1
                   from #phyfloat_myrsfcrf fc
                   where fc.commkt_key = cm.commkt_key)
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #phyfloat_myrscmdtymktrf due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #phyfloat_myrscmdtymktrf'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end
   
   begin try
     set @start_time = getdate()
     insert into #phyfloat_myrstrdprdrf
     select 
        commkt_key,
        trading_prd,
        first_del_date,
        last_del_date,
        convert(datetime, convert(varchar, last_del_date, 101)) as mat 
     from dbo.trading_period trdprd
     where exists (select 1
                   from #phyfloat phy
                           INNER JOIN dbo.accumulation AS acc 
                              ON phy.trade_num = acc.trade_num AND 
                                 phy.order_num = acc.order_num AND
                                 phy.item_num = acc.item_num 
                           INNER JOIN dbo.quote_pricing_period AS qpp 
                              ON acc.trade_num = qpp.trade_num AND 
                                 acc.order_num = qpp.order_num AND 
                                 acc.item_num = qpp.item_num AND
                                 acc.accum_num = qpp.accum_num 
                           INNER JOIN dbo.formula_component fc
                              ON fc.formula_num = qpp.formula_num and 
                                 fc.formula_body_num = qpp.formula_body_num and 
                                 fc.formula_comp_num = qpp.formula_comp_num 
                   where acc.accum_creation_type in ('R', 'K') and
                         trdprd.commkt_key = fc.commkt_key and 
                         trdprd.trading_prd = qpp.risk_trading_prd) 
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #phyfloat_myrstrdprdrf due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch

   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #phyfloat_myrstrdprdrf'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end

   begin try
     set @start_time = getdate()
     insert into #phyfloat_myrsqprf
     select 
        phy.trade_num,
        phy.order_num,
        phy.item_num,
        acc.accum_num,
        qpp.qpp_num,
        count(qp.price_quote_date) as idaycount 
     from #phyfloat phy
             INNER JOIN dbo.accumulation acc 
                ON phy.trade_num = acc.trade_num and 
                   phy.order_num = acc.order_num and
                   phy.item_num = acc.item_num 
             INNER JOIN dbo.quote_pricing_period qpp 
                ON acc.trade_num = qpp.trade_num and 
                   acc.order_num = qpp.order_num and 
                   acc.item_num = qpp.item_num and
                   acc.accum_num = qpp.accum_num 
             INNER JOIN dbo.quote_price qp 
                ON qp.trade_num = qpp.trade_num and 
                   qp.order_num = qpp.order_num and 
                   qp.item_num = qpp.item_num and 
                   qp.accum_num = qpp.accum_num and 
                   qp.qpp_num = qpp.qpp_num
     where acc.accum_creation_type in ('R', 'K') and
           qp.price_quote_date <= @run_date and
           (qp.manual_override_type is null or 
            qp.manual_override_type <> 'D') 
     group by phy.trade_num,
              phy.order_num,
              phy.item_num,
              acc.accum_num,
              qpp.qpp_num 
     set @rows_affected = @@rowcount
     set @end_time = getdate()
   end try
   begin catch
     print '=> Failed to build data set in the temp table #phyfloat_myrsqprf due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch
 
   if @debugon = 1
   begin
      print '=> ' + cast(@rows_affected as varchar) + ' records saved into the temp table #phyfloat_myrsqprf'
      print '==> Start Time: ' + convert(varchar, @start_time, 109)
      print '==> End Time  : ' + convert(varchar, @end_time, 109)
   end
   goto endofsp
   
errexit:
   set @status = 1
   
endofsp:
drop table #phyfloat
return @status
GO
GRANT EXECUTE ON  [dbo].[usp_get_VAR_phyfloat_result_dataset] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_get_VAR_phyfloat_result_dataset', NULL, NULL
GO
