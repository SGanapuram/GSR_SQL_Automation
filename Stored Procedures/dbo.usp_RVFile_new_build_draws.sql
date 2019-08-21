SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_RVFile_new_build_draws]
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
    where plh.pl_asof_date = @my_pl_asof_date and
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
       STEP: Returns data back to caller
      ----------------------------------------------- */   
   select @stepid = @stepid + 1
   if @debugon = 1
      insert into @times 
         (oid, step, starttime)
        values(@stepid, 'Returns data back to caller', getdate())

   select DISTINCT	
	    pos.pos_num,
	    pos.commkt_key,
	    pos.trading_prd, 
	    aibd.inv_b_d_num,
	    aibd.inv_b_d_type,
	    aibd.alloc_num,
	    aibd.alloc_item_num,
	    aibd.inv_b_d_status,
	    aibd.inv_num, 
	    aibd.inv_b_d_qty, 
	    inv.inv_qty_uom_code,
	    ai.alloc_num,
	    ai.alloc_item_num,
	    ai.sub_alloc_num
   from dbo.aud_inventory_build_draw aibd WITH (NOLOCK), 
	      dbo.inventory inv WITH (NOLOCK), 
	      dbo.position pos WITH (NOLOCK), 
	      dbo.allocation_item ai WITH (NOLOCK)
   where not exists (select 1 
                     from dbo.aud_inventory_build_draw aibd2 WITH (NOLOCK)
		                 where aibd2.inv_b_d_num = aibd.inv_b_d_num and 
	                         aibd2.trans_id <= @prev_min_trans_id) and
         inv.inv_num = aibd.inv_num and
         pos.pos_num = inv.pos_num and
         aibd.trans_id = (select max(aibd2.trans_id) 
	                        from dbo.aud_inventory_build_draw aibd2 WITH (NOLOCK)
			                    where aibd2.inv_b_d_num = aibd.inv_b_d_num and 
			                          aibd2.trans_id <= @min_trans_id) and
	       ai.alloc_num = aibd.alloc_num and
	       ai.alloc_item_num = aibd.alloc_item_num
   order by	pos.pos_num,
	          aibd.inv_b_d_type

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
      select @smsg = 'usp_RVFile_new_build_draws: ' + convert(varchar, @rows_affected) + ' rows returned.'
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
GRANT EXECUTE ON  [dbo].[usp_RVFile_new_build_draws] TO [next_usr]
GO
