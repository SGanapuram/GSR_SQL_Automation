SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_RVFile_rcpt_ai_for_new_builds]
(
   @pl_asof_date         datetime = null,
   @top_port_num         int = 0,
   @debugon              bit = 0
)
as
set nocount on
declare @rows_affected     int,
        @smsg              varchar(255),
        @status            int,
        @oid               numeric(18, 0),
        @stepid            smallint,
        @my_pl_asof_date   datetime,
        @my_port_num       int,
	      @min_trans_id	     bigint,
	      @prev_min_trans_id bigint
        
   select @my_pl_asof_date = @pl_asof_date,
          @my_port_num = @top_port_num

   if @debugon = 1
   begin
      declare @times   table
      (
         oid                int,
         step               varchar(80),
         starttime          datetime null,
         endtime            datetime null,
         rows_affected      int default -1 null
      )
   end

   declare @port_num_list table 
   (
      real_port_num     int 
   )

   insert into @port_num_list
   select port_num 
   from dbo.udf_RVFile_child_port_nums(@my_port_num)
   where port_type = 'R'
   select @rows_affected = @@rowcount

   if @rows_affected > 0
   begin  
      if @debugon = 1
      begin
         print ' '
         print '***************************************'
         print ' real_port_nums'
         print '---------------------------------------'
         select real_port_num from @port_num_list order by real_port_num     
      end 
   end
   else
   begin
      print 'No real port_nums found!'
      goto endofsp
   end

   select @stepid = 0

   create table #allocationItems
   (  
	    alloc_num		            int,
	    alloc_item_num		      smallint,
	    sub_alloc_num		        smallint null,
	    trade_num		            int null,
	    order_num		            smallint null,
	    item_num		            smallint null,
	    inv_num			            int null,
	    alloc_item_type		      char(1) null,
	    nomin_qty_max		        float null, 
	    nomin_qty_max_uom_code	char(4) null,
	    actual_gross_qty	      float null, 
	    actual_gross_uom_code	  char(4) null
   )  
      
   select @stepid = 0  
   /* -----------------------------------------------  
       STEP: Populating min trans_id
      ----------------------------------------------- */     
   select @stepid = @stepid + 1  
   if @debugon = 1  
      insert into @times   
         (oid, step, starttime)  
        values(@stepid, 'Populating min trans_id', getdate())  
    
    select @min_trans_id = isnull(min(plh.trans_id), 0)
    from dbo.pl_history plh WITH (NOLOCK), 
         @port_num_list port
    where plh.pl_asof_date = @my_pl_asof_date AND
          plh.real_port_num = port.real_port_num

   select @rows_affected = @@rowcount  
   if @debugon = 1  
   begin  
      update @times   
      set endtime = getdate(),  
          rows_affected = @rows_affected  
      where oid = @stepid  
   end  

   if @rows_affected <= 0  
   begin  
      if @debugon = 1   
      begin  
         print 'Unable to obtain min trans_id!'  
      end  
   end  

   /* -----------------------------------------------  
       STEP: Populating previous min trans_id
      ----------------------------------------------- */     
   select @stepid = @stepid + 1  
   if @debugon = 1  
      insert into @times   
         (oid, step, starttime)  
        values(@stepid, 'Populating previous min trans_id', getdate())  

    select @prev_min_trans_id = isnull(min(plh.trans_id), 0)
    from dbo.pl_history plh WITH (NOLOCK)
    where plh.pl_asof_date = (select max(plh1.pl_asof_date) 
				                      from dbo.pl_history plh1 WITH (NOLOCK)
				                      where plh1.pl_asof_date < @my_pl_asof_date) 

    /* issue 14965 by Kishore    02/05/2007
    select @prev_min_trans_id = isnull(min(plh.trans_id), 0)
    from dbo.pl_history plh WITH (NOLOCK), 
         @port_num_list port
    where plh.real_port_num=port.real_port_num and 
          plh.pl_asof_date = (select max(plh1.pl_asof_date) 
				                      from dbo.pl_history plh1 WITH (NOLOCK)
				                      where plh1.pl_asof_date < @my_pl_asof_date and
				                            plh1.real_port_num = plh.real_port_num) 
    */      
          
   select @rows_affected = @@rowcount  
   if @debugon = 1  
   begin  
      update @times   
      set endtime = getdate(),  
          rows_affected = @rows_affected  
      where oid = @stepid  
   end  

   if @rows_affected <= 0  
   begin  
      if @debugon = 1   
      begin  
         print 'Unable to obtain previous min trans_id!'  
      end  
   end  

   /* -----------------------------------------------  
       STEP: Copying rows into #allocationItems table  
      ----------------------------------------------- */     
   select @stepid = @stepid + 1  
   if @debugon = 1  
      insert into @times   
         (oid, step, starttime)  
        values(@stepid, 'Copying rows into #allocationItems table', getdate())  
  
   insert into #allocationItems  
   (  
	    alloc_num,
	    alloc_item_num,
	    sub_alloc_num,
	    trade_num,
	    order_num,
	    item_num,
	    inv_num,
	    alloc_item_type,
	    nomin_qty_max, 
	    nomin_qty_max_uom_code,
	    actual_gross_qty, 
	    actual_gross_uom_code
   )  
   select ai.alloc_num,
	        ai.alloc_item_num,
	        ai.sub_alloc_num,
	        ai.trade_num,
	        ai.order_num,
	        ai.item_num,
	        ai.inv_num,
	        ai.alloc_item_type,
	        ai.nomin_qty_max, 
	        ai.nomin_qty_max_uom_code,
	        ai.actual_gross_qty, 
	        ai.actual_gross_uom_code
   from dbo.allocation_item ai WITH (NOLOCK)
   where ai.alloc_item_type in ('R', 'I', 'N') AND
  	     ai.alloc_num in (select aibd.alloc_num 
  	                      from dbo.inventory_build_draw aibd WITH (NOLOCK)
	                        where aibd.inv_b_d_num in (select aibd.inv_b_d_num 
	                                                   from dbo.aud_inventory_build_draw aibd WITH (NOLOCK)
						                                         where not exists (select 1 
						                                                           from dbo.aud_inventory_build_draw aibd2 WITH (NOLOCK)
								                                                       where aibd2.inv_b_d_num = aibd.inv_b_d_num AND
				                                                                     trans_id <= @prev_min_trans_id) AND							                                                                                                           aibd.inv_b_d_type = 'B' AND
			                                                     aibd.trans_id = (select max(aibd2.trans_id) 
			                                                                      from dbo.aud_inventory_build_draw aibd2 WITH (NOLOCK)
						                                                                where aibd2.inv_b_d_num = aibd.inv_b_d_num AND
			     	   						                                                        aibd2.trans_id <= @min_trans_id)))

   
   select @rows_affected = @@rowcount  
   if @debugon = 1  
   begin  
      update @times   
      set endtime = getdate(),  
          rows_affected = @rows_affected  
      where oid = @stepid  
   end  
  
   if @rows_affected <= 0  
   begin  
      if @debugon = 1   
      begin  
         print 'No allocation item records found!'  
      end  
      goto endofsp  
   end  

   create nonclustered index xx_allocationItems_xx_idx1  
      on #allocationItems(alloc_num, alloc_item_num)  

   create nonclustered index xx_allocationItems_xx_idx3  
      on #allocationItems(trade_num, order_num, item_num)  

   /* -----------------------------------------------
       STEP: Returns data back to caller
      ----------------------------------------------- */   
   select @stepid = @stepid + 1
   if @debugon = 1
      insert into @times 
         (oid, step, starttime)
        values(@stepid, 'Returns data back to caller', getdate())

   select	ai.alloc_num,
	        ai.alloc_item_num,
	        ai.sub_alloc_num,
	        ai.trade_num,
	        ai.order_num,
	        ai.item_num,
	        ai.inv_num,
	        ai.alloc_item_type,
        	ai.nomin_qty_max, 
	        ai.nomin_qty_max_uom_code,
	        ai.actual_gross_qty, 
	        ai.actual_gross_uom_code,
	        tid.pos_num, 
	        inv.pos_num
   from #allocationItems ai 
	         RIGHT OUTER JOIN dbo.trade_item_dist tid WITH (NOLOCK)
	            ON tid.trade_num = ai.trade_num AND
	               tid.order_num = ai.order_num AND
	               tid.item_num = ai.item_num AND
	               tid.dist_type = 'D' AND
	               tid.real_synth_ind = 'R' AND
	               tid.is_equiv_ind = 'N'
	         RIGHT OUTER JOIN dbo.inventory inv WITH (NOLOCK)
	            ON inv.inv_num = ai.inv_num
   select @rows_affected = @@rowcount
   if @debugon = 1
   begin
      update @times 
      set endtime = getdate(),
          rows_affected = @rows_affected
      where oid = @stepid
   end

   if @debugon = 1
   begin
      print ' '
      select @smsg = 'usp_RVFile_rcpt_ai_for_new_builds: ' + convert(varchar, @rows_affected) + ' rows returned.'
      print @smsg
      print ' '

      declare @step       varchar(80),
              @starttime  varchar(30),
              @endtime    varchar(30)

      select @oid = min(oid)
      from @times

      while @oid is not null
      begin
         select @step = step,
                @starttime = convert(varchar, starttime, 109),
                @endtime = convert(varchar, endtime, 109),
                @rows_affected = rows_affected
         from @times
         where oid = @oid

         select @smsg = convert(varchar, @oid) + '. ' + @step
         print @smsg
         select @smsg = '    STARTED  AT  : ' + @starttime
         print @smsg       
         select @smsg = '    FINISHED AT  : ' + @endtime
         print @smsg
         select @smsg = '    ROWS AFFECTED: ' + convert(varchar, @rows_affected)
         print @smsg
         
         select @oid = min(oid)
         from @times
         where oid > @oid
      end /* while */
   end /* debug */

endofsp:
return 0
GO
GRANT EXECUTE ON  [dbo].[usp_RVFile_rcpt_ai_for_new_builds] TO [next_usr]
GO
