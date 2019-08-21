SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[triggerFX4OldCosts]
(
   @port_num          int,                   -- we iterate through all the real portfolio under this portfolio
   @book_comp_num     int = 0,               -- if given, only costs for that booking company are processed
   @lock_vouched_ind  char(1) = 'N',         -- if Y, we lock the FX exposure for these costs
   @max_due_date      datetime = '1/1/1999', -- if given we set the costs with dueDate <= maxDueDate as Locked for FX exposure.
   @debugon           bit = 0
)
as
--V13 ANSI
set nocount on
declare @pl_curr_code		       char(8),
        @trans_id			         int,
        @trans_id1			       int,
			  @fx_rate 	             numeric(20, 8),
			  @my_parent_cost_num 	 int,
			  @parent_cost_num 	     int,
			  @temp_cost_num 	       int,
			  @cost_num 	           int,
		    @errcode		           int,
		    @rows_affected         int,
		    @cost_creation_date    datetime,
		    @cost_due_date         datetime,
		    @cost_price_curr_code  char(8),
		    @calc_operator         char(1),
		    @smsg                  varchar(255),
		    @status                int

   select @errcode = 0,
          @status = 0
       
   if not exists (select 1
                  from dbo.portfolio
                  where port_num = @port_num)
   begin
      select @smsg = '=> Please provide a valid port # for the argument @port_num!'
      goto reportusage
   end

   if @book_comp_num is null
      select @book_comp_num = 0
        
   if @book_comp_num > 0
   begin
      if not exists (select 1
                     from dbo.account
                     where acct_num = @book_comp_num)
      begin
         select @smsg = '=> Please provide an acct # for the argument @book_comp_num!'
         goto reportusage
      end     
   end
    
   create table #children 
   (
      port_num int, 
      port_type char(2)
   )

   create table #costToUpdate
   (
      cost_num               int null,
      port_num               int not null,
      pl_curr_code           char(8) null,
      parent_cost_num        int null,
      fx_rate                numeric(20, 8) null,
      cost_due_date          datetime null,
      cost_status            char(8) null,
      cost_book_exch_rate    numeric(20, 8) null,
      creation_date          datetime null, 
      cost_price_curr_code   char(8) null, 
	    trade_num				       int null,
      cost_type_code		     char(8)	null,
      fx_locking_status      char(1) null,
      fx_exp_num             int null,
      creation_rate_m_d_ind  char(1) null
   )

   create nonclustered index xx510804_cost_idx1
      on #costToUpdate (cost_num, pl_curr_code)
   create nonclustered index xx510804_cost_idx2
      on #costToUpdate (parent_cost_num, cost_num)
   create nonclustered index xx510804_cost_idx3
      on #costToUpdate (parent_cost_num, cost_status)
      
   exec dbo.usp_get_child_port_nums @port_num
   
   if (select count(*) from #children) = 0
   begin
      drop table #children
      if @debugon = 1
      begin
         select @smsg = '=> The hierarchy headed by the port #' + cast(@port_num as varchar) + ' is empty!'
         print @smsg
         goto endofsp
      end
   end
   
   if @debugon = 1
   begin
      select @smsg = 'DEBUG: Copying records into the #costToUpdate table ... ' + convert(varchar, getdate(), 109)
      print '************************'
      print @smsg
   end
   
   if @book_comp_num = 0
      insert into #costToUpdate
           (cost_num, port_num, pl_curr_code, parent_cost_num, fx_rate,
            cost_due_date, cost_status, cost_book_exch_rate, creation_date, 
            cost_price_curr_code, trade_num, cost_type_code, fx_locking_status, 
            fx_exp_num,creation_rate_m_d_ind)
         select c.cost_num, p.port_num, p.desired_pl_curr_code, 
                isnull(c.parent_cost_num,0), cei.creation_fx_rate,
                c.cost_due_date, c.cost_status, isnull(c.cost_book_exch_rate, 0.0),
                c.creation_date, c.cost_price_curr_code, 
                c.cost_owner_key6, c.cost_type_code, cei.fx_locking_status,
                cei.fx_exp_num, cei.creation_rate_m_d_ind
         from dbo.portfolio p 
                INNER JOIN dbo.cost c 
                   ON c.port_num=p.port_num
	              LEFT OUTER JOIN dbo.cost_ext_info cei 
	                 ON cei.cost_num=c.cost_num
         where exists (select 1
                       from #children a
                       where p.port_num = a.port_num) and
               c.cost_price_curr_code != p.desired_pl_curr_code and
               (c.cost_book_curr_code is null or
                c.cost_book_curr_code = p.desired_pl_curr_code) 
   else
      insert into #costToUpdate
           (cost_num, port_num, pl_curr_code, parent_cost_num, fx_rate,
            cost_due_date, cost_status, cost_book_exch_rate, creation_date, 
            cost_price_curr_code, trade_num, cost_type_code, fx_locking_status, 
            fx_exp_num,creation_rate_m_d_ind)
         select c.cost_num, p.port_num, p.desired_pl_curr_code, c.parent_cost_num, 
                cei.creation_fx_rate, c.cost_due_date, c.cost_status, 
                isnull(c.cost_book_exch_rate, 0.0), c.creation_date, 
                c.cost_price_curr_code, c.cost_owner_key6, c.cost_type_code, 
                cei.fx_locking_status,cei.fx_exp_num, cei.creation_rate_m_d_ind
         from dbo.portfolio p 
                 INNER JOIN dbo.cost c 
                    ON c.port_num = p.port_num
	               LEFT OUTER JOIN dbo.cost_ext_info cei 
	                  ON cei.cost_num=c.cost_num
         where exists (select 1
                       from #children a
                       where p.port_num = a.port_num) and
               c.cost_price_curr_code != p.desired_pl_curr_code and
               (c.cost_book_curr_code is null or
                c.cost_book_curr_code = p.desired_pl_curr_code) and
               c.cost_book_comp_num = @book_comp_num 
   select @rows_affected = @@rowcount,
          @errcode = @@error
   if @errcode > 0
   begin
      drop table #children
      select @smsg = '==> Failed to copy cost data into the temp. table'
      print @smsg
      goto errexit
   end
   drop table #children
   
   if @rows_affected = 0
   begin
      select @smsg = '==> No records were added into temp table ''#costToUpdate''!'
      print @smsg
      goto endofsp
   end
   
   if @debugon = 1
   begin
      if @rows_affected > 0
         select @smsg = '==> Added ' + cast(@rows_affected as varchar) + ' records into temp table'
      print @smsg
   end

   -- Update creation_date with trade.conct_date if creation_date is null	  
   update #costToUpdate
   set creation_date = contr_date
   from dbo.trade t, 
        #costToUpdate c
   where t.trade_num = c.trade_num and
         c.creation_date is null      
   select @rows_affected = @@rowcount,
          @errcode = @@error
   if @errcode > 0
   begin
      select @smsg = '==> Failed to update creation date with contract date'
      print @smsg
      goto errexit
   end
     
   if @rows_affected > 0
   begin
      select @smsg = '==> Updated ' + cast(@rows_affected as varchar) + 'records with contract date for those cost creation date is null'
      print @smsg
   end 

  if @debugon = 1
   begin
      select @smsg = 'DEBUG: Removing records with a NULL cost # from the #costToUpdate table ... ' + convert(varchar, getdate(), 109)
      print '************************'
      print @smsg
   end

   delete #costToUpdate
   where cost_num is null
   
   select @rows_affected = @@rowcount,
          @errcode = @@error
   if @errcode > 0
   begin
      select @smsg = '==> Failed to delete records with NULL cost_num from temp. table.'
      print @smsg
      goto errexit
   end
   if @debugon = 1
   begin
      if @rows_affected > 0
         select @smsg = '==> ' + cast(@rows_affected as varchar) + ' records with NULL cost_num were deleted from temp. table'
      else
         select @smsg = '==> No records with NULL cost_num were deleted from temp. table'
      print @smsg
   end

	 -- For the cost, if it has a parent_cost_num, then navigate the hierarchy to
	 -- find the ROOT parent_cost_num - @my_parent_cost_num  

   if @debugon = 1
   begin
      select @smsg = 'DEBUG: Finding ROOT parent cost # for the cost #' + cast(@parent_cost_num as varchar) + ' ... ' + convert(varchar, getdate(), 109)
      print '************************'
      print @smsg
	 end
	 
	 create table #parentcostnums
	 (
	    parent_cost_num   int primary key
	 )
	 
	 insert into #parentcostnums
	    select distinct parent_cost_num
      from #costToUpdate
      where parent_cost_num is not null and
            parent_cost_num > 0

   select @parent_cost_num = min(parent_cost_num)
   from #parentcostnums
             
   while @parent_cost_num is not null
   begin
	    select @temp_cost_num = @parent_cost_num
	    
	    if @debugon = 1
	    begin
         select @smsg = 'DEBUG: parent cost # ' + cast(@temp_cost_num as varchar) + ' ... finding ROOT parent cost #'
         print '*****'
         print @smsg
      end
      
	    while @temp_cost_num is not null
	    begin
	       select @my_parent_cost_num = @temp_cost_num
	        
	       select @temp_cost_num = parent_cost_num 
	       from dbo.cost 
	       where cost_num = @temp_cost_num
	    end
	     
	    if @my_parent_cost_num is not null
	    begin
	       if @debugon = 1
	       begin
            print '==> ROOT parent cost # found is ' + cast(@my_parent_cost_num as varchar)
         end
         
	       update #costToUpdate
	       set parent_cost_num = @my_parent_cost_num
	       where parent_cost_num = @parent_cost_num	            
	    end
	     
      select @parent_cost_num = min(parent_cost_num)
      from #parentcostnums
      where parent_cost_num > @parent_cost_num
   end
   drop table #parentcostnums

   if @debugon = 1
   begin
      select @smsg = 'DEBUG: Adding cost_ext_info records if possible ... ' + convert(varchar, getdate(), 109)
      print '************************'
      print @smsg
	 end
   
   begin tran
   exec dbo.gen_new_transaction_NOI
   select @trans_id = null
   select @trans_id = last_num
   from dbo.icts_trans_sequence
   where oid = 1
   
   if @trans_id is null
   begin
      select @smsg = '==> Failed to obtain the first trans_id for DML operations later'
      goto errexit
   end

   /*exec dbo.gen_new_transaction_NOI
   select @trans_id1 = null
   select @trans_id1 = last_num
   from dbo.icts_trans_sequence
   where oid = 1
   
   if @trans_id1 is null
   begin
      select @smsg = '==> Failed to obtain the second trans_id for DML operations later'
      goto errexit
   end   */
   insert into dbo.cost_ext_info
       (cost_num, pr_cost_num, prepayment_ind, voyage_code, trans_id,
        qty_adj_rule_num, qty_adj_factor, orig_voucher_num,
        pay_term_override_ind, vat_rate, discount_rate, cost_pl_contribution_ind,
        material_code, related_cost_num)
      select c.cost_num, null, null, null, @trans_id, 
             null, null, null, 
             null, null, null, 'Y', 
             null, null
	    from #costToUpdate c
	    where not exists (select 1
	                      from dbo.cost_ext_info ext
	                      where c.cost_num = ext.cost_num)
   select @rows_affected = @@rowcount,
          @errcode = @@error
   if @errcode > 0
   begin
      select @smsg = '==> Failed to add cost_ext_info records'
      goto errexit
   end
   if @debugon = 1
   begin
      if @rows_affected > 0
         select @smsg = '==> ' + cast(@rows_affected as varchar) + ' cost_ext_info records were added'
      else
         select @smsg = '==> No cost_ext_info records were added'
      print @smsg
   end

   -- when locking vouched prior to max_due_date, ignore all new costs
   if @lock_vouched_ind='Y'
   begin
      exec dbo.gen_new_transaction_NOI
      select @trans_id = last_num
      from dbo.icts_trans_sequence
      where oid = 1

      update dbo.cost_ext_info 
      set fx_locking_status = 'L',
          trans_id = @trans_id 
      where exists (select 1
                    from #costToUpdate a
                    where a.cost_num = cost_ext_info.cost_num and
                          a.cost_status in ('PAID') and 
			  (a.fx_locking_status !='L' or a.fx_locking_status is null)
			  and a.cost_due_date <@max_due_date) 
   end

   if @debugon = 1
   begin
      select @smsg = 'DEBUG: Updating cost records to set cost_book_curr_code to NULL ... ' + convert(varchar, getdate(), 109)
      print '************************'
      print @smsg
	 end
	                   
	 -- for the costs which have the cost_book_curr_code set, we need to 
	 -- change it to trigger ALS. So, set it to null and back
	 update dbo.cost 
	 set cost_book_curr_code = null, 
	     trans_id = @trans_id 
	 where exists (select 1
	               from #costToUpdate c1
	               where cost.cost_num = c1.cost_num and 
	                     cost.cost_book_curr_code = c1.pl_curr_code and 
			     (c1.fx_locking_status!='L' or c1.fx_locking_status is null)
			     and c1.fx_exp_num is null) and cost_status !='CLOSED'
   select @rows_affected = @@rowcount,
          @errcode = @@error
   if @errcode > 0
   begin
      select @smsg = '==> Failed to set ''cost_book_curr_code'' to NULL for the cost table'
      goto errexit
   end
   if @debugon = 1
   begin
      if @rows_affected > 0
         select @smsg = '==> ' + cast(@rows_affected as varchar) + ' cost_ext_info records were added'
      else
         select @smsg = '==> No cost_ext_info records were added'
      print @smsg
   end
   	       
	 -- if a cost does not have a parent cost, then the rate comes from creation date of this cost
   if @debugon = 1
   begin
      select @smsg = 'DEBUG: Updating FX rate in temp table for costs without parent costs  ... ' + convert(varchar, getdate(), 109)
      print '************************'
      print @smsg
	 end

   select @cost_num = min(cost_num)
   from #costToUpdate
   where (parent_cost_num = 0 or 
         (creation_date is null and 
          cost_type_code = 'WO') ) 
	  and fx_rate is null
    
   while @cost_num is not null
   begin
      select @fx_rate = null,
             @calc_operator = null

      select @cost_creation_date = creation_date, 
             @cost_due_date = cost_due_date, 
             @cost_price_curr_code = cost_price_curr_code ,
             @pl_curr_code = pl_curr_code
      from #costToUpdate 
      where cost_num = @cost_num
	   
	       exec @status = dbo.usp_currency_exch_rate 
	                                  @asof_date = @cost_creation_date, 
	                                  @curr_code_from = @cost_price_curr_code, 
	                                  @curr_code_to = @pl_curr_code, 
	                                  @eff_date = @cost_due_date, 
	                                  @est_final_ind = 'E',
                                    @use_out_args_flag = 1,
                                    @conv_rate = @fx_rate OUTPUT,
                                    @calc_oper = @calc_operator OUTPUT
     
      update #costToUpdate
      set fx_rate = @fx_rate, creation_rate_m_d_ind = @calc_operator
      where parent_cost_num = 0  and
            cost_num = @cost_num
      select @rows_affected = @@rowcount,
             @errcode = @@error
      if @errcode > 0
      begin
         select @smsg = '==> Failed to get conversion rate for the cost #' + cast(@cost_num as varchar) + ' which does not have a parent cost #'
         goto errexit
      end
      if @debugon = 1
      begin
         if @rows_affected > 0
            select @smsg = '==> ' + cast(@rows_affected as varchar) + ' records in temp. table were updated for fx_rate (cost #' + cast(@cost_num as varchar) + ')'
         else
            select @smsg = '==> No records in temp. table were updated for fx_rate (cost #' + cast(@cost_num as varchar) + ')'
         print @smsg
      end
       
      select @cost_num = min(cost_num)
      from #costToUpdate
      where (parent_cost_num = 0 or 
            (creation_date is null and 
             cost_type_code = 'WO')) and
            cost_num > @cost_num and fx_rate is null
   end

	 -- if a cost has a parent cost, then the rate comes from creation date of the ROOT parent cost
   if @debugon = 1
   begin
      select @smsg = 'DEBUG: Updating FX rate in temp table for costs having parent costs ... ' + convert(varchar, getdate(), 109)
      print '************************'
      print @smsg
	 end

   select @cost_num = min(cost_num)
   from #costToUpdate
   where (parent_cost_num > 0 or
         (creation_date is null and 
          cost_type_code = 'WO')) and fx_rate is null
    
   while @cost_num is not null
   begin
      select @fx_rate = null,
             @calc_operator = null
          
      select @parent_cost_num = parent_cost_num
      from #costToUpdate
      where cost_num = @cost_num and fx_rate is null and
            parent_cost_num > 0
            
      select @cost_creation_date = creation_date, 
             @cost_due_date = cost_due_date, 
             @cost_price_curr_code = cost_price_curr_code
      from dbo.cost 
      where cost_num = @parent_cost_num
       
      select @pl_curr_code = pl_curr_code
      from #costToUpdate
      where cost_num = @cost_num and
            parent_cost_num = @parent_cost_num 
	  
	    exec @status = dbo.usp_currency_exch_rate @asof_date = @cost_creation_date, 
	                                              @curr_code_from = @cost_price_curr_code, 
	                                              @curr_code_to = @pl_curr_code, 
	                                              @eff_date = @cost_due_date, 
	                                              @est_final_ind = 'E',
                                                @use_out_args_flag = 1,
                                                @conv_rate = @fx_rate OUTPUT,
                                                @calc_oper = @calc_operator OUTPUT
      update #costToUpdate
      set fx_rate = @fx_rate, creation_rate_m_d_ind=@calc_operator
      where parent_cost_num = @parent_cost_num and
            cost_num = @cost_num
      select @rows_affected = @@rowcount,
             @errcode = @@error
      if @errcode > 0
      begin
         select @smsg = '==> Failed to get conversion rate for the parent cost #' + cast(@parent_cost_num as varchar) + ', cost #' + cast(@cost_num as varchar)
         goto errexit
      end
      if @debugon = 1
      begin
         if @rows_affected > 0
            select @smsg = '==> ' + cast(@rows_affected as varchar) + ' records in temp. table were updated for fx_rate (parent cost #' + cast(@parent_cost_num as varchar) + ', cost #' + cast(@cost_num as varchar) + ')'
         else
            select @smsg = '==> No records in temp. table were updated for fx_rate (parent cost #' + cast(@parent_cost_num as varchar) + ', cost #' + cast(@cost_num as varchar) + ')'
         print @smsg
      end

      select @cost_num = min(cost_num)
      from #costToUpdate
      where (parent_cost_num > 0 or 
            (creation_date is null and 
             cost_type_code = 'WO')) and
            cost_num > @cost_num and fx_rate is null
   end

   if @debugon = 1
   begin
      select @smsg = 'DEBUG: Updating cost records to reset cost_book_curr_code back ... ' + convert(varchar, getdate(), 109)
      print '************************'
      print @smsg
	 end
    
   update dbo.cost 
   set cost_book_curr_code = a.pl_curr_code, 
       trans_id = @trans_id   
   from #costToUpdate a
   where a.cost_num = cost.cost_num and cost.cost_status !='CLOSED' 
   and exists (select 1
	               from #costToUpdate c1
	               where cost.cost_num = c1.cost_num and 
	                     cost.cost_book_curr_code = c1.pl_curr_code 
			     and c1.fx_exp_num is null and (c1.fx_locking_status!='L' or c1.fx_locking_status is null)) 

   select @rows_affected = @@rowcount,
          @errcode = @@error
   if @errcode > 0
   begin
      select @smsg = '==> Failed to update the ''cost_book_curr_code'' column in the cost table!'
      goto errexit
   end
   if @debugon = 1
   begin
      if @rows_affected > 0
         select @smsg = '==> ' + cast(@rows_affected as varchar) + ' cost records were updated for cost_book_curr_code'
      else
         select @smsg = '==> No cost records were updated for cost_book_curr_code'
      print @smsg
   end

	 -- costs due prior to @max_due_date should get FX locked but need the creation rate set on them
   if @lock_vouched_ind = 'Y'
   begin
      if @debugon = 1
      begin
         select @smsg = 'DEBUG: Updating cost_ext_info records to fx_locking_status to ''L'' (@lock_vouched_ind = ''Y'') ... ' + convert(varchar, getdate(), 109)
         print '************************'
         print @smsg
      end

      exec dbo.gen_new_transaction_NOI
      select @trans_id = last_num
      from dbo.icts_trans_sequence
      where oid = 1

      update dbo.cost_ext_info 
      set creation_fx_rate = a.fx_rate, 
	        creation_rate_m_d_ind = a.creation_rate_m_d_ind,
          fx_compute_ind = 'N', 
          trans_id = @trans_id 
      from #costToUpdate a
      where a.cost_num = cost_ext_info.cost_num and
            a.cost_status in ('PAID') and 
            cost_due_date < @max_due_date and 
            cost_ext_info.fx_locking_status = 'L' and 
            a.fx_exp_num is null
      select @rows_affected = @@rowcount,
             @errcode = @@error
      if @errcode > 0
      begin
         select @smsg = '==> Failed to update cost_ext_info records to set fx_locking_status to ''L'' (cost_status)!'
         goto errexit
      end
      if @debugon = 1
      begin
         if @rows_affected > 0
            select @smsg = '==> ' + cast(@rows_affected as varchar) + ' cost_ext_info records to set fx_locking_status to ''L'' (cost_status)'
         else
            select @smsg = '==> No cost_ext_info records were updated to set fx_locking_status to ''L'' (cost_status)'
         print @smsg
      end

      delete #costToUpdate where cost_due_date >= @max_due_date
   end
   else
   begin
      delete #costToUpdate where cost_due_date < @max_due_date
   end

   -- set O or unlocked based on the cost_book_exch_rate
   if @debugon = 1
   begin
      select @smsg = 'DEBUG: Updating cost_ext_info records to fx_locking_status to ''O'' ... ' + convert(varchar, getdate(), 109)
      print '************************'
      print @smsg
   end

   update dbo.cost_ext_info 
   set fx_locking_status = 'O', 
       creation_fx_rate = a.fx_rate, 
	     creation_rate_m_d_ind = a.creation_rate_m_d_ind,
       fx_compute_ind = 'N', 
       trans_id = @trans_id 
   from #costToUpdate a
	 where cost_ext_info.cost_num = a.cost_num and 
	       a.cost_book_exch_rate = 0.0 and a.cost_status !='CLOSED' and 
		     (cost_ext_info.fx_locking_status!='L' or 
		      cost_ext_info.fx_locking_status is null) and 
		     a.fx_exp_num is null		  
   select @rows_affected = @@rowcount,
          @errcode = @@error
   if @errcode > 0
   begin
      select @smsg = '=> Failed to update cost_ext_info records to set fx_locking_status to ''O'' (cost_book_exch_rate = 0.0)!'
      goto errexit
   end
   if @debugon = 1
   begin
      if @rows_affected > 0
         select @smsg = '=> ' + cast(@rows_affected as varchar) + ' cost_ext_info records to set fx_locking_status to ''O'' (cost_book_exch_rate = 0.0)'
      else
         select @smsg = '=> No cost_ext_info records were updated to set fx_locking_status to ''O'' (cost_book_exch_rate = 0.0)'
      print @smsg
   end

   if @debugon = 1
   begin
      select @smsg = 'DEBUG: Updating cost_ext_info records to fx_locking_status to ''U'' ... ' + convert(varchar, getdate(), 109)
      print '************************'
      print @smsg
	 end
    
   update dbo.cost_ext_info 
   set fx_locking_status = 'U', 
       creation_fx_rate = a.fx_rate, 
       creation_rate_m_d_ind = a.creation_rate_m_d_ind,
       fx_compute_ind = 'N', 
       trans_id = @trans_id 
   from #costToUpdate a
	 where cost_ext_info.cost_num = a.cost_num and
		     a.cost_status!='CLOSED' and 
		     (cost_ext_info.fx_locking_status not in ('L' , 'O') or 
		      cost_ext_info.fx_locking_status is null)
   select @rows_affected = @@rowcount,
          @errcode = @@error
   if @errcode > 0
   begin
      select @smsg = '==> Failed to update cost_ext_info records to set fx_locking_status to ''U''!'
      goto errexit
   end
   commit tran
   if @debugon = 1
   begin
      if @rows_affected > 0
         select @smsg = '==> ' + cast(@rows_affected as varchar) + ' cost_ext_info records to set fx_locking_status to ''U'''
      else
         select @smsg = '==> No cost_ext_info records were updated to set fx_locking_status to ''U'''
      print @smsg
   end
   goto endofsp

reportusage:
   print @smsg
   print 'Usage: exec @status = dbo.triggerFX4OldCosts'
   print '                               @port_num = ?'
   print '                               [, @book_comp_num = ? ]' 
   print '                               [, @lock_vouched_ind  = ''?'' ]'
   print '                               [, @max_due_date = ''?'' ]'
   print '                               [, @debugon = ? ]'
   return 2

errexit:
   if @@trancount > 0
      rollback tran
   print @smsg
   select @status = 1
   goto endofsp
   
endofsp:
drop table #costToUpdate 
return @status
GO
GRANT EXECUTE ON  [dbo].[triggerFX4OldCosts] TO [next_usr]
GO
