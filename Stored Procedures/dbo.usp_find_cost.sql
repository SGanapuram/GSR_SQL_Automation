SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_find_cost]  
(
   @asof_date      datetime = NULL,  
   @task_code      varchar(20) = null,  
   @port_num       int = -1,  
   @eod_ind        char(1) = 'Y',  
   @debugon        bit = 0
)  
as  
set nocount on  
declare @my_asof_date      datetime,  
        @my_port_num       int,  
        @time1             varchar(30),  
        @time2             varchar(30),  
        @time3             varchar(30),  
        @rows_fetched1     int,  
        @rows_fetched2     int,  
        @smsg              varchar(1000),  
        @sql               varchar(1000)  
  
   if @asof_date is null  
   begin  
      print 'Please provide a valid date string for the argument @asof_date!'  
      goto reportusage  
   end  
  
   if upper(@task_code) not in ('PRICETRADES', 'PRICEINVENTORIES', 'COMPUTEPL')  
   begin  
      print 'Please provide one of (''PRICETRADES'', ''PRICEINVENTORIES'', ''COMPUTEPL'') for the argument @task_code!'  
      goto reportusage  
   end  
  
   if @eod_ind not in ('Y', 'N')  
      set @eod_ind = 'Y'  
         
   if @eod_ind = 'Y'  
   begin  
      if not exists (select 1  
                     from #children  
                     where port_num = @port_num)  
      begin  
         select @eod_ind = 'N'  
      end  
   end  
  
   if @debugon = 1  
      set @time1 = convert(varchar, getdate(), 109)  
         
   set @my_asof_date = @asof_date  
            
   create table #costnums   
   (   
      cost_num                    int primary key,   
      cost_type_code              varchar(8)  NULL,   
      cost_status                 varchar(8)  NULL,   
      cost_amt_type               char(1)     NULL,   
      cost_price_est_actual_ind   char(1)     NULL,   
      cost_owner_key6             int         NULL,  
      cost_owner_key7             int         NULL,  
      cost_owner_key8             int         NULL  
   )   
  
   if upper(@task_code) = 'PRICETRADES'  
   begin  
      -- In MS SQL Server, the following query run faster than the dynamical query listed above  
      insert into #costnums   
         (cost_num, cost_type_code, cost_status, cost_amt_type, cost_price_est_actual_ind)   
      select c2.cost_num,   
           c2.cost_type_code,   
           c2.cost_status,   
           c2.cost_amt_type,   
           c2.cost_price_est_actual_ind   
      from dbo.cost c2   
      where exists (select 1   
                    from dbo.trade_item ti, #children p  
                    where c2.cost_owner_key6 = ti.trade_num and   
                          c2.cost_owner_key7 = ti.order_num and   
                          c2.cost_owner_key8 = ti.item_num and   
                          ti.real_port_num = p.port_num)    
      set @rows_fetched1 = @@rowcount  
     
      if @debugon = 1  
         set @time2 = convert(varchar, getdate(), 109)  
     
      select c1.cost_num,   
             c1.cost_owner_key1,   
             c1.cost_owner_key2,   
             c1.cost_owner_key3,   
             c1.cost_owner_key4,   
             c1.cost_owner_key5,   
             c1.cost_owner_key6,   
             c1.cost_owner_key7,   
             c1.cost_owner_key8,   
             c1.cost_owner_code,   
             c1.cost_amt,   
             c1.cost_price_curr_code,   
             c1.cost_book_curr_code,   
             c1.cost_book_exch_rate,   
             c1.cost_xrate_conv_ind,   
             c1.port_num,   
             c1.pos_group_num,   
             c1.cost_pl_code,   
             c1.cost_pay_rec_ind,   
             c1.cost_type_code,   
             convert(char(16),c1.cost_due_date,101) as cost_due_date,   
             convert(char(16),c1.cost_due_date,101) as cost_realization_date,  
             convert(char(16),c1.creation_date,101) as creation_date,  
             c1.cost_status,   
             c1.tax_status_code,   
             c1.cost_prim_sec_ind,   
             c1.cost_code,   
             c1.cost_qty,   
             c1.cost_qty_uom_code,   
             c1.cost_price_uom_code,   
             c1.cost_unit_price,   
             c1.cost_price_est_actual_ind,   
             c1.cost_price_mod_init,   
             c1.cost_amt_type,   
             c1.acct_num,   
             c1.bus_cost_state_num,   
             convert(char(16),c1.cost_book_prd_date,101) as cost_book_prd_date,   
             convert(char(16),c1.cost_approval_date,101) as cost_approval_date,   
             c1.cost_approval_init,   
             c1.cost_est_final_ind,   
             c1.cost_book_comp_num,   
             c1.parent_cost_num,   
             c1.cost_qty_est_actual_ind,   
             datediff(dayofyear, @my_asof_date, c1.cost_due_date) as days_diff,
             c1.assay_final_ind
      from dbo.cost c1,   
           #costnums c2   
      where (c2.cost_type_code in ('WPP','BPP','BOAI','OPP','SWAP') and   
             c2.cost_status in ('OPEN','HELD')) and    
            c1.cost_num = c2.cost_num   
      union   
      select c1.cost_num,   
             c1.cost_owner_key1,   
             c1.cost_owner_key2,   
             c1.cost_owner_key3,   
             c1.cost_owner_key4,   
             c1.cost_owner_key5,   
             c1.cost_owner_key6,   
             c1.cost_owner_key7,   
             c1.cost_owner_key8,   
             c1.cost_owner_code,   
             c1.cost_amt,   
             c1.cost_price_curr_code,   
             c1.cost_book_curr_code,   
             c1.cost_book_exch_rate,   
             c1.cost_xrate_conv_ind,   
             c1.port_num,   
             c1.pos_group_num,   
             c1.cost_pl_code,   
             c1.cost_pay_rec_ind,   
             c1.cost_type_code,   
             convert(char(16),c1.cost_due_date,101) as cost_due_date,   
             convert(char(16),c1.cost_due_date,101) as cost_realization_date,  
             convert(char(16),c1.creation_date,101) as creation_date,  
             c1.cost_status,   
             c1.tax_status_code,  
             c1.cost_prim_sec_ind,   
             c1.cost_code,   
             c1.cost_qty,   
             c1.cost_qty_uom_code,   
             c1.cost_price_uom_code,   
             c1.cost_unit_price,   
             c1.cost_price_est_actual_ind,   
             c1.cost_price_mod_init,   
             c1.cost_amt_type,   
             c1.acct_num,   
             c1.bus_cost_state_num,   
             convert(char(16), c1.cost_book_prd_date, 101) as cost_book_prd_date,   
             convert(char(16), c1.cost_approval_date, 101) as cost_approval_date,   
             c1.cost_approval_init,   
             c1.cost_est_final_ind,   
             c1.cost_book_comp_num,   
             c1.parent_cost_num,   
             c1.cost_qty_est_actual_ind,   
             datediff(dayofyear, @my_asof_date, c1.cost_due_date) as days_diff,
	           c1.assay_final_ind
      from dbo.cost c1,   
           #costnums c2   
      where c2.cost_amt_type = 'f' and    
            c2.cost_price_est_actual_ind = 'E' and   
            c2.cost_num = c1.cost_num   
      set @rows_fetched2 = @@rowcount  
      goto endofsp  
   end  
  
   if upper(@task_code) = 'PRICEINVENTORIES'  
   begin  
      if @eod_ind = 'Y'   
      begin  
         insert into #costnums   
            (cost_num, cost_status, cost_owner_key6, cost_owner_key7, cost_owner_key8)  
         select cost_num, cost_status, cost_owner_key6, cost_owner_key7, cost_owner_key8    
         from dbo.cost c1,    
              dbo.inventory inv,          
              dbo.inventory_build_draw invbd,  
              #children p    
         where inv.port_num = p.port_num and    
               inv.inv_num = invbd.inv_num and    
               invbd.inv_b_d_type = 'B' and    
               (invbd.alloc_num = c1.cost_owner_key1 and    
                c1.cost_owner_code in ('AI', 'AA'))    
         union    
         select cost_num, cost_status, cost_owner_key6, cost_owner_key7, cost_owner_key8   
         from dbo.cost c1,    
              dbo.inventory inv,    
              dbo.inventory_build_draw invbd,  
              #children p    
         where inv.port_num = p.port_num and    
               inv.inv_num = invbd.inv_num and    
               (invbd.trade_num = c1.cost_owner_key1 and    
                invbd.order_num = c1.cost_owner_key2 and    
                c1.cost_owner_code = 'TI')  
         select @rows_fetched1 = @@rowcount  
      end  
      else  
      begin  
         select @my_port_num = @port_num  
         insert into #costnums   
            (cost_num, cost_status, cost_owner_key6, cost_owner_key7, cost_owner_key8)  
         select cost_num, cost_status, cost_owner_key6, cost_owner_key7, cost_owner_key8    
         from dbo.cost c1,    
              dbo.inventory inv,          
              dbo.inventory_build_draw invbd  
         where inv.port_num = @my_port_num and    
               inv.inv_num = invbd.inv_num and    
               invbd.inv_b_d_type = 'B' and    
               (invbd.alloc_num = c1.cost_owner_key1 and    
                c1.cost_owner_code in ('AI', 'AA'))    
         union    
         select cost_num, cost_status, cost_owner_key6, cost_owner_key7, cost_owner_key8   
         from dbo.cost c1,    
              dbo.inventory inv,    
              dbo.inventory_build_draw invbd  
         where inv.port_num = @my_port_num and    
               inv.inv_num = invbd.inv_num and    
               (invbd.trade_num = c1.cost_owner_key1 and    
                invbd.order_num = c1.cost_owner_key2 and    
                c1.cost_owner_code = 'TI')  
         set @rows_fetched1 = @@rowcount  
      end  
  
      create nonclustered index xxxo01_costnums_idx1 on  
          #costnums (cost_owner_key6, cost_owner_key7, cost_owner_key8)  
      create nonclustered index xxxo01_costnums_idx2 on  
          #costnums (cost_status, cost_num)  
        
      insert into #costnums (cost_num, cost_status)   
      select distinct c1.cost_num, c1.cost_status  
      from dbo.cost c1   
            join #costnums c2  
               on c1.cost_owner_key6 = c2.cost_owner_key6 and    
                    c1.cost_owner_key7 = c2.cost_owner_key7 and    
                    c1.cost_owner_key8 = c2.cost_owner_key8  
      where c1.cost_owner_code = 'CO'   
  
      -- Wei's test showed that re-written the WHERE clause would speed  
      -- up query performance from 10 minutes to 18.0 seconds. (Issue #582141)  
      --  (OLD)  
      --     where c1.cost_type_code = 'WPP' and    
      --           c1.cost_owner_code = 'TI' and  
      --           exists (select 1     
      --                   from #costnums c2     
      --                   where c1.cost_owner_key6 = c2.cost_owner_key6 and    
      --                         c1.cost_owner_key7 = c2.cost_owner_key7 and    
      --                         c1.cost_owner_key8 = c2.cost_owner_key8) and  
      --           not exists (select 1   
      --                       from #costnums c3  
      --                       where c3.cost_num = c1.cost_num)  
  
      insert into #costnums (cost_num, cost_status)     
      select distinct c1.cost_num, c1.cost_status    
      from dbo.cost c1     
            join #costnums c2  
               on c1.cost_owner_key6 = c2.cost_owner_key6 and    
                  c1.cost_owner_key7 = c2.cost_owner_key7 and    
                  c1.cost_owner_key8 = c2.cost_owner_key8  
            left join #costnums c3  
               on c3.cost_num = c1.cost_num  
      where c1.cost_type_code = 'WPP' and    
            c1.cost_owner_code = 'TI' and  
            c3.cost_num is null      
     
      if @debugon = 1  
         set @time2 = convert(varchar, getdate(), 109)  
  
      select c1.cost_num,   
             c1.cost_owner_key1,   
             c1.cost_owner_key2,   
             c1.cost_owner_key3,   
             c1.cost_owner_key4,   
             c1.cost_owner_key5,   
             c1.cost_owner_key6,   
             c1.cost_owner_key7,   
             c1.cost_owner_key8,   
             c1.cost_owner_code,   
             c1.cost_amt,   
             c1.cost_price_curr_code,   
             c1.cost_book_curr_code,   
             c1.cost_book_exch_rate,   
             c1.cost_xrate_conv_ind,    
             c1.port_num,   
             c1.pos_group_num,   
             c1.cost_pl_code,   
             c1.cost_pay_rec_ind,   
             c1.cost_type_code,   
             convert(char(16), c1.cost_due_date, 101),   
             convert(char(16), c1.cost_due_date, 101),   
             convert(char(16), c1.creation_date, 101),  
             c1.cost_status,   
             c1.tax_status_code,  
             c1.cost_prim_sec_ind,   
             c1.cost_code,   
             c1.cost_qty,   
             c1.cost_qty_uom_code,   
             c1.cost_price_uom_code,   
             c1.cost_unit_price,   
             c1.cost_price_est_actual_ind,   
             c1.cost_price_mod_init,   
             c1.cost_amt_type,   
             c1.acct_num,   
             c1.bus_cost_state_num,   
             convert(char(16), c1.cost_book_prd_date, 101),   
             convert(char(16), c1.cost_approval_date, 101),   
             c1.cost_approval_init,   
             c1.cost_est_final_ind,   
             c1.cost_book_comp_num,    
             c1.parent_cost_num,   
             c1.cost_qty_est_actual_ind,   
             datediff(dayofyear, @my_asof_date, c1.cost_due_date),
             c1.assay_final_ind
      from dbo.cost c1            
      where exists (select 1  
                    from #costnums c2   
                    where c2.cost_status IN ('OPEN', 'VOUCHED', 'PAID', 'HELD') and    
                          c1.cost_num = c2.cost_num)  
      set @rows_fetched2 = @@rowcount  
      goto endofsp  
   end  
  
endofsp:     
   drop table #costnums  
     
   if @debugon = 1  
   begin  
      set @time3 = convert(varchar, getdate(), 109)  
      print ' '  
      print ' '  
      print '*** ' + @task_code + ' RUNTIME STATISTICS ***'  
      set @smsg = 'Arguments: asof_date ''' + convert(varchar, @asof_date, 101) + ''''  
      print @smsg  
      set @smsg = null  
      select @my_port_num = min(port_num)  
      from #children  
        
      while @my_port_num is not null  
      begin  
         if @smsg is null  
            set @smsg = convert(varchar, @my_port_num)  
         else  
            set @smsg = @smsg + ',' + convert(varchar, @my_port_num)   
  
         select @my_port_num = min(port_num)  
         from #children  
         where port_num > @my_port_num  
      end  
  
      if upper(@task_code) = 'PRICEINVENTORIES'  
      begin  
         if @eod_ind = 'N'   
            set @smsg = convert(varchar, @port_num)  
      end  
  
      print '           port #(s) ' + @smsg  
      print '-----------------------------------------------------------------------'  
      print '   Started Time         = ' + @time1  
      print '   Temp Table Created   = ' + @time2  
      print '   Finished Time        = ' + @time3  
      print '   Rows in temp table   = ' + convert(varchar, @rows_fetched1)  
      print '   Rows in result set   = ' + convert(varchar, @rows_fetched2)  
   end      
   return 0  
     
reportusage:  
   print ' '  
   print 'Usage: exec dbo.usp_find_cost @asof_date = ''?'''  
   print '                              ,@task_code = ''?'''  
   print '                              [, @port_num = ? ]'  
   print '                              [, @eod_ind = ''?'' ]'  
   print '                              [, @debugon = ?]'  
   return 1  
GO
GRANT EXECUTE ON  [dbo].[usp_find_cost] TO [next_usr]
GO
