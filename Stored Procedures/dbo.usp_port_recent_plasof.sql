SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_port_recent_plasof]    
( 
   @on_or_before      datetime,    
   @nth_previous      int,
   @debugon           bit = 0
)  
as  
set nocount on  
declare @errcode         int,
        @rows_affected   int,
        @smsg            varchar(255),
        @iterations      int

   select @errcode = 0
   if @on_or_before is null  
      select @on_or_before = getdate()   

   if @nth_previous is null    
      select @nth_previous = 1     

   if @debugon = 1
   begin
      print 'usp_port_recent_plasof (DEBUG): Argument values'
      select @smsg = '   @on_or_before   : ' + convert(varchar, @on_or_before, 101)
      print @smsg
      select @smsg = '   @nth_previous   : ' + convert(varchar, @nth_previous)
      print @smsg      
      print ' '  
   end
           
   if @debugon = 1
   begin
      print '***************'
      select @smsg = 'usp_port_recent_plasof - Debug 1: Adding records into the #portfolio_recent_plasof table ... '
      print @smsg
      select @smsg = '=> STARTED    : ' + convert(varchar, getdate(), 109)
      print @smsg
   end 
   insert into #portfolio_recent_plasof  
       (port_num,    
        last_asof_date,    
        last_trans_id,    
        nthprev_asof_date,    
        nthprev_trans_id)   
   select p.port_num,     
          max(pllast.pl_asof_date),     
          null,    
          max(pllast.pl_asof_date),     
          null    
   from #allportfolio p    
           join dbo.portfolio_profit_loss pllast on p.port_num = pllast.port_num    
   where pllast.pl_asof_date <= @on_or_before    
   group by p.port_num  
   select @rows_affected = @@rowcount,
          @errcode = @@error
   if @errcode > 0
   begin
      if @debugon = 1
         print 'usp_port_recent_plasof (DEBUG): Error occurred while filling the #portfolio_recent_plasof table!'         
      goto exitwitherror
   end

   if @debugon = 1
   begin
      select @smsg = 'DEBUG => The number of rows in the #portfolio_recent_plasof table = ' + cast(@rows_affected as varchar)
      print @smsg
      print ' '
   end  
   
   if @debugon = 1
   begin
      select @smsg = '=> FINISHED   : ' + convert(varchar, getdate(), 109)
      print @smsg
      print ' '
   end  
   
   if @rows_affected = 0
   begin
      if @debugon = 1
         print 'usp_port_recent_plasof (DEBUG): The #portfolio_recent_plasof table is empty!'         
      goto exitnoerror
   end
             
   if @debugon = 1
   begin
      print '***************'
      select @smsg = 'usp_port_recent_plasof - Debug 2: Updating last_trans_id in the #portfolio_recent_plasof table ... '
      print @smsg
      select @smsg = '=> STARTED    : ' + convert(varchar, getdate(), 109)
      print @smsg
   end 

   update #portfolio_recent_plasof      
   set last_trans_id = (select max(trans_id) 
                        from dbo.icts_transaction 
                        where tran_date < dateadd(day,1,#portfolio_recent_plasof.last_asof_date))    
   select @errcode = @@error
   if @errcode > 0
   begin
      if @debugon = 1
         print 'usp_port_recent_plasof (DEBUG): Error occurred while updating last_trans_id in the #portfolio_recent_plasof table!'         
      goto exitwitherror
   end
   if @debugon = 1
   begin
      select @smsg = '=> FINISHED   : ' + convert(varchar, getdate(), 109)
      print @smsg
      print ' '
   end  
       
   if @debugon = 1
   begin
      print '***************'
      select @smsg = 'usp_port_recent_plasof - Debug 3: Updating nthprev_asof_date in the #portfolio_recent_plasof table ... '
      print @smsg
      select @smsg = '=> STARTED    : ' + convert(varchar, getdate(), 109)
      print @smsg
   end 
   
   select @iterations = 0
   while @nth_previous > 0 
   begin    
      select @nth_previous = @nth_previous - 1    
      select @iterations = @iterations + 1
      
      select @smsg = '=> ITERATION #' + cast(@iterations as varchar)
      print ' '
      print @smsg
      insert into #portpl
      select lb1.port_num, max(lb1.pl_asof_date)
      from dbo.portfolio_profit_loss lb1,
           #portfolio_recent_plasof l  
      where lb1.port_num = l.port_num and 
            lb1.pl_asof_date < l.nthprev_asof_date
      group by lb1.port_num

      if @debugon = 1
      begin
         select @smsg = '==> Debug 3 - query #1: ' + convert(varchar, getdate(), 109)
         print @smsg
      end 
      
      update l     
      set nthprev_asof_date = (select pl_asof_date    
                               from #portpl lb1    
                               where lb1.port_num = l.port_num)
      from #portfolio_recent_plasof l
      select @rows_affected = @@rowcount,
             @errcode = @@error
      if @errcode > 0
      begin
         if @debugon = 1
            print 'usp_port_recent_plasof (DEBUG): Error occurred while updating nthprev_asof_date in the #portfolio_recent_plasof table!'         
         goto exitwitherror
      end   
      if @debugon = 1
      begin
         select @smsg = '==> Debug 3 - query #2: ' + convert(varchar, getdate(), 109)
         print @smsg
         select @smsg = 'DEBUG => #portfolio_recent_plasof rows updated for nthprev_asof_date = ' + cast(@rows_affected as varchar)
         print @smsg
      end 
   end  
   if @debugon = 1
   begin
      select @smsg = '=> FINISHED    : ' + convert(varchar, getdate(), 109)
      print @smsg
      print ' '
   end  
   
   if @debugon = 1
   begin
      print '***************'
      select @smsg = 'usp_port_recent_plasof - Debug 4: Updating nthprev_trans_id in the #portfolio_recent_plasof table ... '
      print @smsg
      select @smsg = '=> STARTED    : ' + convert(varchar, getdate(), 109)
      print @smsg
   end 

   update l     
   set nthprev_trans_id = (select min(trans_id) 
                           from dbo.icts_transaction 
                           where tran_date >= dateadd(day, 1, l.nthprev_asof_date))
   from #portfolio_recent_plasof l
   select @rows_affected = @@rowcount,
          @errcode = @@error
   if @errcode > 0
   begin
      if @debugon = 1
         print 'usp_port_recent_plasof (DEBUG): Error occurred while updating nthprev_trans_id in the #portfolio_recent_plasof table!'         
      goto exitwitherror
   end   
   if @debugon = 1
   begin
      select @smsg = '=> FINISHED   : ' + convert(varchar, getdate(), 109)
      print @smsg
      print ' '
   end   
   
exitnoerror:
   return 0

exitwitherror:
   return 1
GO
GRANT EXECUTE ON  [dbo].[usp_port_recent_plasof] TO [next_usr]
GO
