SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
  
CREATE procedure [dbo].[usp_get_real_port_nums]        
(        
   @port_locked            smallint = -1,        
   @asof_date              datetime = null,        
   @positions_considered   smallint = 365,        
   @debugonoff             char(1) = 'N',        
   @top_port_num           int = null        
)        
as        
set nocount on        
declare @status                    int,        
        @rows_affected             int,        
        @errcode                   int,        
        @my_port_locked            smallint,        
        @my_asof_date              datetime,        
        @my_positions_considered   smallint,        
        @my_top_port_num           int        
       
   select @errcode = 0,        
          @rows_affected = 0,        
          @my_port_locked = @port_locked,        
          @my_asof_date = @asof_date,        
          @my_positions_considered = @positions_considered,        
          @my_top_port_num  = @top_port_num        
                  
   if (@my_port_locked <> 0) and (@my_port_locked <> 1)        
   begin        
      print 'You must provide a valid number (0 or 1) for the argument @port_locked!'        
      goto endofsp2        
   end        
        
   if @my_asof_date is null        
   begin        
      print 'You must provide a valid date for the argument @asof_date!'        
      goto endofsp2        
   end        
        
   if @my_top_port_num is not null        
   begin        
      if not exists (select 1        
                     from dbo.portfolio        
                     where port_num = @my_top_port_num)        
      begin        
         print 'You must provide a valid port # for the argument @top_port_num!'        
         goto endofsp2        
      end        
   end         
      
   if @my_positions_considered < 0        
      set @my_positions_considered = 0        
        
   declare @currenttime  varchar(30),        
           @smsg         varchar(255)        
        
   if @debugonoff = 'Y'        
   begin        
      print 'spid = ' + LTRIM(RTRIM(STR(@@spid)))        
      print ' '        
      set @currenttime = convert(varchar, getdate(), 109)        
      print 'DEBUG(1): Creating the temporary table #port_num_pool (time is ' + @currenttime + ')'        
   end        
        
   create table #port_num_pool        
   (        
      port_num                 int,        
      run_complex_formulas_ind bit default 0,
      run_price_inventory_ind  bit default 0,        
      run_otc_options_ind      bit default 0,         
      run_listed_options_ind   bit default 0,        
      run_expire_futures_ind   bit default 0,        
      run_underlying_equiv_ind bit default 0,        
      run_price_costs_ind      bit default 0,        
      run_cash_alloc_ind       bit default 0,        
      run_fifo_future_ind      bit default 0,        
      run_fifo_lopt_ind        bit default 0,        
      run_calc_options_ind     bit default 0,        
      run_calc_fxpl_ind        bit default 0,        
      run_price_fcrates_ind    bit default 0,        
	  run_qp_auto_optimize_ind	   bit default 0	  
   )        
      
   if @@error > 0        
      goto endofsp2         
      
   if @debugonoff = 'Y'        
   begin        
      set @currenttime = convert(varchar, getdate(), 109)        
      print 'DEBUG(1): Creating the index for the table #port_num_pool (time is ' + @currenttime + ')'        
   end        
      
   create unique nonclustered index port_num_idx         
      on #port_num_pool (port_num)        
      
   if @@error > 0        
      goto endofsp1            
      
   if @debugonoff = 'Y'        
   begin        
      set @currenttime = convert(varchar, getdate(), 109)        
      print 'DEBUG(2): START obtaining a list of REAL port_nums (time is ' + @currenttime + ')'        
   end        
        
  set @rows_affected = 0        
   if @my_top_port_num is not null        
   begin        
      create table #children         
      (        
         port_num  int PRIMARY KEY,        
         port_type char(2)        
      )          
      
      -- Here, we call the stored procedure to result a list of port_nums stored        
      -- in temporary table #children. In this case, a port_num can be a real        
      -- port_num (port_type = 'R'), or it can be a port_num whose port_type is        
      -- not 'R', 'G', 'and 'P'.         
      exec @status = usp_get_child_port_nums @my_top_port_num, 0        
      if @status <> 0        
      begin        
  drop table #children        
         goto endofsp1        
      end          
      
      -- 01/18/2010 change starts        
      -- no matter what, we want to process only unlocked portfolios for PASS tasks        
      insert into #port_num_pool (port_num)        
      select port_num         
      from #children a        
      where exists (select 1        
                    from dbo.portfolio p        
                    where a.port_num = p.port_num and        
                          p.port_locked = 0)        
      
      -- 01/18/2010 change ends        
      select @rows_affected = @@rowcount,        
             @errcode = @@error        
   end        
   else        
   begin        
      -- 01/18/2010 change starts        
      insert into #port_num_pool (port_num)        
      select port_num         
      from dbo.portfolio        
      where port_type not in ('G', 'P') and        
            port_locked = 0        
      -- 01/18/2010 change ends        
      select @rows_affected = @@rowcount,        
             @errcode = @@error        
   end         
      
   if @errcode > 0         
      goto endofsp1        
              
   if @rows_affected = 0        
   begin        
      if @debugonoff = 'Y'        
      begin        
         set @currenttime = convert(varchar, getdate(), 109)        
         print 'DEBUG(2): Could not obtain a REAL port_nums (time is ' + @currenttime + ')'        
      end        
      goto endofsp1              
   end        
      
   if @debugonoff = 'Y'        
   begin        
      set @currenttime = convert(varchar, getdate(), 109)        
      print 'DEBUG(2): Obtained ' + convert(varchar, @rows_affected) + ' REAL port_nums (time is ' + @currenttime + ')'        
   end        
      
   -- ================================        
   -- RealPort has Formulas:        
   -- ================================        
   if @debugonoff = 'Y'        
   begin        
      set @currenttime = convert(varchar, getdate(), 109)         
      print 'DEBUG(3): START updating the flag for formuals (time is ' + @currenttime + ')'        
   end        
        
   update pnp      
   set run_complex_formulas_ind = 1      
   from #port_num_pool pnp      
   where exists (select 1      
                 from dbo.trade_item ti,       
                      dbo.accumulation accu       
                 where ti.real_port_num = pnp.port_num and      
                       ti.trade_num = accu.trade_num and      
                       ti.order_num = accu.order_num and      
                       ti.item_num = accu.item_num and      
                       accu.formula_num is not null and      
                       accu.accum_creation_type not in ('C') and       
                       price_status <> 'F')           
   if @@error > 0      
      goto endofsp1      
      
   if @debugonoff = 'Y'        
   begin        
      set @currenttime = convert(varchar, getdate(), 109)         
      print 'DEBUG(3): STOP (time is ' + @currenttime + ')'        
   end        
        
   -- ================================        
   -- RealPort has inventories:        
   -- ================================        
   if @debugonoff = 'Y'       
   begin       
      set @currenttime = convert(varchar, getdate(), 109)       
      print 'DEBUG(4): START updating the flag price inventory (time is ' + @currenttime + ')'       
   end       
      
   update #port_num_pool       
   set run_price_inventory_ind = 1       
   where exists (select 1       
                 from dbo.inventory inv       
              where inv.port_num = #port_num_pool.port_num and       
                       inv.port_num is not null and       
                       ISNULL(inv.needs_repricing, 'Y') = 'Y')         
   if @@error > 0       
   goto endofsp1      
      
   if @debugonoff = 'Y'       
   begin       
      set @currenttime = convert(varchar, getdate(), 109)       
      print 'DEBUG(4): STOP (time is ' + @currenttime + ')'       
   end      
        
   -- ================================        
   -- RealPort has OTC positions:        
   -- ================================        
   if @debugonoff = 'Y'        
   begin        
      set @currenttime = convert(varchar, getdate(), 109)         
      print 'DEBUG(5): START updating the flag for OTC options (time is ' + @currenttime + ')'        
   end        
        
   -- changed expression to include the check on the pos_type 'X' and datediff expressions        
   -- Requested by Rama   10/11/2004        
   update #port_num_pool        
   set run_otc_options_ind = 1        
   where exists (select 1        
                 from dbo.position pos        
                 where pos.real_port_num = #port_num_pool.port_num and        
                       pos.pos_type in ('O', 'X') and        
                       (datediff(dayofyear, pos.opt_exp_date, @my_asof_date) <= 40 and         
                        datediff(dayofyear, pos.opt_exp_date, @my_asof_date) >= 0) )        
   if @@error > 0        
      goto endofsp1        
      
   if @debugonoff = 'Y'        
   begin        
      set @currenttime = convert(varchar, getdate(), 109)         
      print 'DEBUG(5): STOP (time is ' + @currenttime + ')'        
   end          
      
   -- ================================        
   -- RealPort has CALCOPTION positions:        
   -- ================================        
   if @debugonoff = 'Y'        
   begin        
      set @currenttime = convert(varchar, getdate(), 109)         
      print 'DEBUG(5a): START updating the flag for CALCOPTION options (time is ' + @currenttime + ')'        
   end        
        
   update #port_num_pool        
   set run_calc_options_ind = 1        
   where exists (select 1        
                 from dbo.position pos        
                 where pos.real_port_num = #port_num_pool.port_num and        
                       pos.pos_type in ('O', 'X') )        
      
   if @@error > 0        
      goto endofsp1        
      
   if @debugonoff = 'Y'        
   begin        
      set @currenttime = convert(varchar, getdate(), 109)         
      print 'DEBUG(5a): STOP (time is ' + @currenttime + ')'        
   end         
      
   -- ================================        
   -- RealPort has ListedOptions:        
   -- ================================        
   if @debugonoff = 'Y'        
   begin        
      set @currenttime = convert(varchar, getdate(), 109)         
      print 'DEBUG(6): START updating the flag for Listed options (time is ' + @currenttime + ')'        
   end        
      
   update #port_num_pool        
   set run_listed_options_ind = 1        
   where exists (select 1        
                 from dbo.position pos        
                 where pos.real_port_num = #port_num_pool.port_num and        
                       pos.pos_type = 'X')        
   if @@error > 0        
      goto endofsp1        
        
   if @debugonoff = 'Y'        
   begin        
      set @currenttime = convert(varchar, getdate(), 109)         
      print 'DEBUG(6): STOP (time is ' + @currenttime + ')'        
   end        
        
   -- ================================        
   -- RealPort has Underlying Equiv:        
   -- ================================        
   if @debugonoff = 'Y'        
   begin        
      set @currenttime = convert(varchar, getdate(), 109)         
      print 'DEBUG(7): START updating the flag for Underlying Equiv (time is ' + @currenttime + ')'        
   end        
      
   update #port_num_pool        
   set run_underlying_equiv_ind = 1        
   where exists (select 1        
                 from dbo.position pos        
                 where pos.real_port_num = #port_num_pool.port_num and        
                       pos.is_equiv_ind = 'Y')        
   if @@error > 0        
      goto endofsp1        
        
   if @debugonoff = 'Y'        
   begin        
      set @currenttime = convert(varchar, getdate(), 109)        
      print 'DEBUG(7): STOP (time is ' + @currenttime + ')'        
   end        
        
   -- ======================================        
   -- RealPort to be run for passpricecosts        
   -- ======================================        
   if @debugonoff = 'Y'        
   begin        
      set @currenttime = convert(varchar, getdate(), 109)         
      print 'DEBUG(8): START updating the flag for PASS price costs (time is ' + @currenttime + ')'        
   end        
      
   update #port_num_pool        
   set run_price_costs_ind = 1        
   where exists (select 1        
                 from dbo.cost c        
                 where c.port_num = #port_num_pool.port_num and        
                       c.port_num is not null and        
                       c.cost_amt_type in ('f', 'S', 'R', 'X')) or        
         exists (select 1        
                 from dbo.trade_item ti,         
                      dbo.trade_item_wet_phy tiwp        
                 where ti.real_port_num = #port_num_pool.port_num and        
                       ti.trade_num = tiwp.trade_num and        
                       ti.order_num = tiwp.order_num and        
                       ti.item_num = tiwp.item_num and        
                       tiwp.prelim_price_type = 'F')          
   if @@error > 0        
      goto endofsp1          
      
   if @debugonoff = 'Y'        
   begin        
      set @currenttime = convert(varchar, getdate(), 109)         
      print 'DEBUG(8): STOP (time is ' + @currenttime + ')'        
   end          
      
   -- ===========================================        
   -- RealPort to be run for passpricecashallocs        
   -- ===========================================        
      
   if @debugonoff = 'Y'        
   begin        
      set @currenttime = convert(varchar, getdate(), 109)         
      print 'DEBUG(9): START updating the flag for PASS price cash allocation (time is ' + @currenttime + ')'        
   end        
      
   update #port_num_pool        
   set run_cash_alloc_ind = 1        
   where exists (select 1         
                 from dbo.allocation a,         
                      dbo.allocation_pl apl        
                 where apl.pos_group_num = #port_num_pool.port_num and        
                       a.alloc_num = apl.alloc_num and        
                       a.alloc_type_code in ('O', 'B', 'N') and        
                       a.alloc_status in ('C', 'D'))          
   if @@error > 0        
      goto endofsp1        
      
   if @debugonoff = 'Y'        
   begin        
      set @currenttime = convert(varchar, getdate(), 109)         
      print 'DEBUG(9): STOP (time is ' + @currenttime + ')'        
   end        
        
   -- ==================================================        
   --  run_fifo_future_ind        
   --    the logic for setting the run_fifo_future_ind         
   --    is that the real portfolio should have         
   --      1. A position of type 'F' and         
   --      2. Its last_trade_date should be past and        
   --      3. It should has a trade_item_dist which is         
   --         not fully fifod.        
   --        
   --   provided by Davinder   7/26/2004        
   -- ==================================================        
   if @debugonoff = 'Y'        
   begin        
      set @currenttime = convert(varchar, getdate(), 109)         
      print 'DEBUG(10): START updating the flag ''run_fifo_future_ind'' (time is ' + @currenttime + ')'        
   end        
      
   if @my_positions_considered = 0        
   begin        
      update #port_num_pool        
      set run_fifo_future_ind = 1        
      where exists (select 1         
                    from dbo.position p            
                    where p.pos_type = 'F' and         
                          p.real_port_num = #port_num_pool.port_num and        
                          exists (select 1        
                                  from dbo.trading_period tp        
                                  where tp.commkt_key = p.commkt_key and         
                                        tp.trading_prd = p.trading_prd and        
                                        tp.last_trade_date < @my_asof_date) and         
                          exists (select 1        
                                  from dbo.trade_item_dist tid        
                                  where tid.pos_num = p.pos_num and         
                                        tid.dist_qty <> tid.alloc_qty and         
                                        tid.dist_type = 'D' and         
                                        tid.is_equiv_ind = 'N') )        
   end        
   else        
   begin        
      update #port_num_pool        
      set run_fifo_future_ind = 1        
      where exists (select 1         
                    from dbo.position p            
                    where p.pos_type = 'F' and         
                          p.real_port_num = #port_num_pool.port_num and        
                          exists (select 1        
                                  from dbo.trading_period tp        
                                  where tp.commkt_key = p.commkt_key and         
                                        tp.trading_prd = p.trading_prd and        
                                        datediff(day, tp.last_trade_date, @my_asof_date) < @my_positions_considered) and         
                          exists (select 1        
                                  from dbo.trade_item_dist tid        
                                  where tid.pos_num = p.pos_num and         
                                        tid.dist_qty <> tid.alloc_qty and         
                                        tid.dist_type = 'D' and         
                                        tid.is_equiv_ind = 'N')  )        
   end        
      
   if @@error > 0        
      goto endofsp1        
        
   if @debugonoff = 'Y'        
   begin        
      set @currenttime = convert(varchar, getdate(), 109)         
      print 'DEBUG(10): STOP (time is ' + @currenttime + ')'        
   end        
        
   -- ==================================================        
   --   run_fifo_lopt_ind        
   --     the logic for this is that the real portfolio         
   --     should have        
   --       1. a position of type 'X'        
   --       2. opt_exp_date should be past        
   --       3. trade_item_dist exists which is not         
   --          fully fifod.        
   --        
   --   provided by Davinder   7/26/2004        
   -- ==================================================        
      
   if @debugonoff = 'Y'        
   begin        
      set @currenttime = convert(varchar, getdate(), 109)         
      print 'DEBUG(11): START updating the flag ''run_fifo_lopt_ind'' (time is ' + @currenttime + ')'        
   end        
      
   if @my_positions_considered = 0        
   begin        
      update #port_num_pool        
      set run_fifo_lopt_ind = 1        
      where exists (select 1         
                    from dbo.position p            
                    where p.pos_type = 'X' and         
                          p.real_port_num = #port_num_pool.port_num and        
                          p.opt_exp_date < @my_asof_date and        
                          exists (select 1        
                                  from dbo.trade_item_dist tid        
                                  where tid.pos_num = p.pos_num and         
                                        tid.dist_qty <> tid.alloc_qty and        
                                        tid.dist_type = 'D' and         
                   tid.is_equiv_ind = 'N')  )        
      
   end        
   else        
   begin        
      update #port_num_pool        
      set run_fifo_lopt_ind = 1        
      where exists (select 1         
                    from dbo.position p            
                    where p.pos_type = 'X' and         
                          p.real_port_num = #port_num_pool.port_num and        
                          datediff(day, p.opt_exp_date, @my_asof_date) < @my_positions_considered and        
                          exists (select 1        
                                  from dbo.trade_item_dist tid        
                                  where tid.pos_num = p.pos_num and         
                                        tid.dist_qty <> tid.alloc_qty and        
                                        tid.dist_type = 'D' and         
                                        tid.is_equiv_ind = 'N')  )        
   end        
      
   if @@error > 0        
      goto endofsp1          
      
   if @debugonoff = 'Y'        
   begin        
      set @currenttime = convert(varchar, getdate(), 109)         
      print 'DEBUG(11): STOP (time is ' + @currenttime + ')'        
   end        
        
   -- ================================        
   -- RealPort has FUTURES:        
   -- ================================        
      
   if @debugonoff = 'Y'        
   begin        
      set @currenttime = convert(varchar, getdate(), 109)         
      print 'DEBUG(12): START updating the flag for FUTURES (time is ' + @currenttime + ')'        
   end        
      
   update #port_num_pool        
   set run_expire_futures_ind = 1        
   where exists (select 1        
                 from dbo.position pos        
                 where pos.real_port_num = #port_num_pool.port_num and        
                       pos.pos_type = 'F')        
   if @@error > 0        
      goto endofsp1          
      
   if @debugonoff = 'Y'        
   begin        
      set @currenttime = convert(varchar, getdate(), 109)         
      print 'DEBUG(12): STOP (time is ' + @currenttime + ')'        
   end         
      
   -- ==================================================        
   --  run_calc_fxpl_ind        
   -- ==================================================        
   if @debugonoff = 'Y'        
   begin        
      set @currenttime = convert(varchar, getdate(), 109)         
      print 'DEBUG(13): START updating the flag ''run_calc_fxpl_ind'' (time is ' + @currenttime + ')'        
   end        
      
   update #port_num_pool        
   set run_calc_fxpl_ind = 1        
   where exists (select 1         
                 from dbo.cost c,        
                      dbo.cost_ext_info p            
                 where c.port_num = #port_num_pool.port_num and        
                       c.cost_num = p.cost_num and        
   c.cost_book_curr_code <> c.cost_price_curr_code and        
                       p.fx_locking_status <> 'L')        
      
   if @@error > 0        
      goto endofsp1         
      
   if @debugonoff = 'Y'        
   begin        
      set @currenttime = convert(varchar, getdate(), 109)         
      print 'DEBUG(13): STOP (time is ' + @currenttime + ')'        
   end                
      
   -- ======================================          
   -- RealPort to be run for passpriceformulacostsrates          
   -- ======================================          
   if @debugonoff = 'Y'          
   begin          
      set @currenttime = convert(varchar, getdate(), 109)           
      print 'DEBUG(8): START updating the flag for PASS price formula cost rates(FMLcosts) (time is ' + @currenttime + ')'          
   end          
        
   update #port_num_pool          
   set run_price_fcrates_ind = 1          
   where exists (select 1          
                 from dbo.cost c,         
                      dbo.cost tempc,         
                      dbo.cost_rate cr         
                 where c.port_num = #port_num_pool.port_num and          
                       c.template_cost_num = tempc.cost_num and        
                       tempc.cost_num = cr.cost_num and        
                       c.port_num is not null and         
                       cr.formula_ind = 'Y' and        
                       (cr.is_fully_priced is  null or         
                        cr.is_fully_priced = 'N'))           
   if @@error > 0          
      goto endofsp1          
        
   if @debugonoff = 'Y'          
   begin          
      set @currenttime = convert(varchar, getdate(), 109)           
      print 'DEBUG(8): STOP (time is ' + @currenttime + ')'          
   end  
   
   -- ======================================          
   -- RealPort to be run for run_qp_auto_optimize          
   -- ======================================          
   if @debugonoff = 'Y'          
   begin          
      set @currenttime = convert(varchar, getdate(), 109)           
      print 'DEBUG(8): START updating the flag for PASS Auto Optimize QP Ind(DPP TIs) (time is ' + @currenttime + ')'          
   end          
        
   update #port_num_pool          
   set run_qp_auto_optimize_ind = 1          
   where exists (select 1          
                from dbo.trade_item ti 
				inner join dbo.trade_formula tf on ti.trade_num=tf.trade_num and ti.order_num=tf.order_num and ti.item_num=tf.item_num
				inner join dbo.formula f on f.formula_num=tf.formula_num 
                inner join dbo.fb_modular_info fbmi on f.formula_num=fbmi.formula_num
                 where ti.real_port_num = #port_num_pool.port_num and 
					ti.item_type='D' and 
					tf.fall_back_ind='N' and f.modular_ind='Y' and
                    fbmi.qp_election_date is null)
   if @@error > 0          
      goto endofsp1          
        
   if @debugonoff = 'Y'          
   begin          
      set @currenttime = convert(varchar, getdate(), 109)           
      print 'DEBUG(8): STOP (time is ' + @currenttime + ')'          
   end          
      
   -- 01/18/2010 change starts        
   -- now add all the locked portfolios        
   if @my_port_locked = 1        
   begin        
      -- only if locked portfolios are to be added to the list        
      if @my_top_port_num is not null        
      begin        
         insert into #port_num_pool (port_num)        
         select port_num         
         from #children a        
         where exists (select 1        
                       from dbo.portfolio p        
                       where a.port_num = p.port_num and        
                             p.port_locked = 1)        
      end        
      else        
      begin        
         insert into #port_num_pool (port_num)    
         select port_num         
         from dbo.portfolio        
         where port_type not in ('G', 'P') and         
               port_locked = 1         
      end -- for topPortNum null        
   end  -- for port locked          
      
   -- This would avoid getting the error saying that the #children does not exist        
   if @my_top_port_num is not null         
   begin        
      drop table #children          
   end        
           
   -- 01/18/2010 change ends             
   declare @rows_returned  int          
   select p.port_num,         
          p.port_type,         
          p.port_class,         
          p.num_history_days,         
          p.desired_pl_curr_code,         
          p.port_short_name,         
          pjv.acct_num,         
          pjv.pl_percentage,         
          pjv.due_date,         
          p.port_ref_key,        
          p.port_locked,        
          pnp.run_complex_formulas_ind,        
          pnp.run_price_inventory_ind,        
          pnp.run_otc_options_ind,         
          pnp.run_listed_options_ind,        
          pnp.run_expire_futures_ind,        
          pnp.run_underlying_equiv_ind,        
          pnp.run_price_costs_ind,        
          pnp.run_cash_alloc_ind,        
          pnp.run_fifo_future_ind,        
          pnp.run_fifo_lopt_ind,        
          pnp.run_calc_options_ind,        
          pnp.run_calc_fxpl_ind,        
          pnp.run_price_fcrates_ind,
		  pnp.run_qp_auto_optimize_ind,		  
          pjv.book_comp_num,        
          ppl.pass_run_detail_id,        
          (select dflt_book_curr_code        
           from dbo.booking_company_info bci        
           where pjv.book_comp_num = bci.acct_num),        
          case when p.port_type = 'R' and         
                    exists (select 1        
                            from dbo.position pos        
                                    JOIN dbo.trading_period tp        
                                       ON pos.commkt_key = tp.commkt_key and        
                                          pos.trading_prd = tp.trading_prd        
                            where p.port_num = pos.real_port_num and        
                                  pos.pos_type in ('V', 'B') and        
                                  isnull(tp.last_trade_date, '01/01/1990') >= getdate())        
                  then 1        
               else 0        
          end as runPricevesselInd        
   from dbo.portfolio p        
        inner join #port_num_pool pnp        
            on p.port_num = pnp.port_num        
        left outer join dbo.portfolio_jv pjv        
            on p.port_num = pjv.port_num        
        left outer join dbo.portfolio_profit_loss ppl        
            on p.port_num = ppl.port_num and         
               ppl.pl_asof_date = @my_asof_date and         
               ppl.is_official_run_ind = 'N'                         
   set @rows_returned = @@rowcount        
   if @debugonoff = 'Y'        
   begin        
      print ' '            print 'DEBUG: ' + LTRIM(RTRIM(Str(@rows_returned))) + ' rows returned.'        
   end         
   drop table #port_num_pool        
   return        
      
endofsp1:        
   drop table #port_num_pool        
      
endofsp2:        
   select 0,           /* port_num */        
          'X',         /* port_type */        
          'X',         /* port_class */        
          0,           /* num_history_days */        
          'X',         /* desired_pl_curr_code */        
          'X',         /* port_short_name */        
          0,           /* acct_num */        
          0,           /* pl_percentage */        
          '01/01/90',  /* due_date */        
          'X',         /* port_ref_key */        
          0,           /* port_locked */        
          0,           /* run_complex_formulas_ind */        
          0,           /* run_price_inventory_ind */        
          0,           /* run_otc_options_ind */        
          0,           /* run_listed_options_ind */        
          0,           /* run_expire_futures_ind */        
          0,           /* run_underlying_equiv_ind */        
          0,           /* run_price_costs_ind */        
          0,           /* run_cash_alloc_ind */        
          0,           /* run_fifo_future_ind */        
          0,           /* run_fifo_lopt_ind */        
          0,           /* run_calc_options_ind */        
          0,           /* run_calc_fxpl_ind */        
          0,           /* run_price_fcrates_ind */
          0,           /* run_qp_auto_optimize_ind */
          0,           /* book_comp_num */        
          0,           /* pass_run_detail_id */        
          null,        /* dflt_book_curr_code */        
          0            /* runPricevesselInd */        
   if @debugonoff = 'Y'        
   begin        
      print ' '        
      print 'DEBUG: Returning a DUMMY record.'        
   end        
return              

GO
GRANT EXECUTE ON  [dbo].[usp_get_real_port_nums] TO [next_usr]
GO
