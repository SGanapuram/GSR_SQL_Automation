SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[find_wakeup_for_alsmodules]
(
   @als_decision_class_names         varchar(512) = null,
   @dependent_als_module_group_desc  varchar(512) = null,
   @instance_num                     int = 0,
   @debugon                          bit = 0
)
as
set nocount on
declare @asof_trans_id                 int,
        @wakeup_num                    int,
        @temp_wakeup_num               int,
        @wakeup_pending_exception_flag int,
        @wakeup_pending_status_id      int,
        @wakeup_working_status_id      int,
        @als_pending_status_id         int,
        @als_working_status_id         int,
        @smsg                          varchar(512),
        @next                          int,
        @lenStringArray                int,
        @lenDelimiter                  int,
        @ii                            int,
        @delimiter                     varchar(1),
        @related_asof_transids         varchar(512),
        @errcode                       int,
        @rows_updated                  int,
        @temp_trans_id                 int
  
create table #als_module_names       
(        
   module_name      varchar(255)        
)  
  
create table #als_module_groups  
(        
   group_desc      varchar(255),  
   group_id        int default 0 null                       
)  
  
create table #related_trans_ids       
(        
   trans_id      int        
)  

   /* Check if we have all argument values */    
   if @als_decision_class_names is null    
   begin    
      print 'Please provide a value for the argument @als_decision_class_names!'    
      goto endofsp1    
   end    
  
   if @dependent_als_module_group_desc is null    
   begin    
      print 'Please provide a value for the argument @dependent_als_module_group_desc!'    
      goto endofsp1    
   end    
  
   if @instance_num <= 0    
   begin    
      print 'Please provide a valid number for the argument @instance_num!'    
      goto endofsp1    
   end    
  
   if @debugon = 1    
      print 'DEBUG is turned on'         
  
   /* initialise everything */  
   select @wakeup_num = -1,  
          @temp_wakeup_num = -1,  
          @asof_trans_id = -1,  
          @wakeup_pending_exception_flag = 0,    
          @wakeup_pending_status_id = 0,  
          @wakeup_working_status_id = 1,  
          @als_pending_status_id = 0,  
          @als_working_status_id = 1,  
          @delimiter = ',',  
          @lenDelimiter = 1,  
          @errcode = 0  
  
   /* Spliting the input string and populating the child table */  
   insert into #als_module_names (module_name)   
   select m.splitdata   
   from (select cast('<X>' + replace(@als_decision_class_names, @delimiter, '</X><X>') + '</X>' as XML) as xmlfilter) F1  
           CROSS APPLY (select fdata.D.value('.','varchar(255)') as splitdata   
                        from F1.xmlfilter.nodes('X') as fdata(D)) m  
  
   insert into #als_module_groups (group_desc,group_id)   
   select m.splitdata,0   
   from (select cast('<X>' + replace(@dependent_als_module_group_desc, @delimiter, '</X><X>') + '</X>' as XML) as xmlfilter) F1  
           CROSS APPLY (select fdata.D.value('.','varchar(255)') as splitdata   
                        from F1.xmlfilter.nodes('X') as fdata(D)) m  
     
   update a   
   set group_id = (select als_module_group_id  
                   from dbo.server_config s  
                   where a.group_desc = s.als_module_group_desc)         
   from #als_module_groups a  
   
   /* Check to see if we can find a unprocessed wakeup record for the     
      given ALS modules */        
   while (@wakeup_num < 0)    
   begin    
      --select @temp_wakeup_num = isnull(min(wakeup_num), -1)     
      select top 1 @temp_wakeup_num = isnull(wakeup_num, -1)  
      from dbo.wakeup w 
              join #als_module_names amn 
                 on w.als_decision_class_name = amn.module_name  
      where w.exception_flag = @wakeup_pending_exception_flag AND     
            ((w.status = @wakeup_working_status_id AND 
              w.instance_num = @instance_num) OR 
             w.status = @wakeup_pending_status_id OR 
             w.status is null) AND  
            w.wakeup_num > @temp_wakeup_num   
      order by w.status desc, w.wakeup_num  
    
      if @debugon = 1    
      begin    
         if @temp_wakeup_num = -1      
            set @smsg = 'DEBUG: No PENDING Wakeup record was found for ALS modules ' + @als_decision_class_names  
         else    
            set @smsg = 'DEBUG: Found the PENDING Wakeup #' + convert(varchar, @temp_wakeup_num)    
         print @smsg    
      end    
    
      if @temp_wakeup_num > 0  /* Yes, a PENDING Wakeup record is found */    
      begin    
         select @asof_trans_id = asof_trans_id, 
                @related_asof_transids = w.related_asof_transids 
         from dbo.wakeup w 
         where w.wakeup_num = @temp_wakeup_num  
         if @debugon = 1    
         begin    
            set @smsg = 'DEBUG: Cheking the als_run status for the Wakeup #' + convert(varchar, @temp_wakeup_num)    
            set @smsg = @smsg + ' with asof_trans_id #' + convert(varchar, @asof_trans_id)     
            print @smsg    
         end    
    
         if @related_asof_transids is null  
         begin  
            set @related_asof_transids = convert(varchar, @asof_trans_id)  
         end  
   
         /*select @lenStringArray = LEN(@related_asof_transids),@ii = 1,@next = 1  
         while @ii <= @lenStringArray        
         begin --find the next occurrence of the delimiter in the related_asof_transids        
            select @next = CHARINDEX(@delimiter, @related_asof_transids + @delimiter, @ii)        
            insert into #related_trans_ids (trans_id) 
               select SUBSTRING(@related_asof_transids, @ii, @next - @ii)        
            select @ii = @next + @lenDelimiter  
         end*/   
         insert into #related_trans_ids (trans_id)   
         select m.splitdata   
         from (select cast('<X>' + replace(@related_asof_transids, @delimiter, '</X><X>') + '</X>' as XML) as xmlfilter) F1  
                  CROSS APPLY (select fdata.D.value('.','varchar(255)') as splitdata   
                               from F1.xmlfilter.nodes('X') as fdata(D)) m  
  
         /* Make sure that the parent user transaction was completely processed by other ALSs. */    
         if exists (select 1   
                    from dbo.als_run a 
                            join #als_module_groups amg 
                               on a.als_module_group_id = amg.group_id  
                    where a.als_run_status_id in (@als_pending_status_id, @als_working_status_id) and   
                          a.trans_id in (select t.trans_id 
                                         from dbo.icts_transaction t 
                                                 join #related_trans_ids rt 
                                                    on t.parent_trans_id = rt.trans_id or 
                                                       t.trans_id = rt.trans_id))  
         begin  
            if @debugon = 1    
            begin    
               set @smsg = 'DEBUG: Wakeup #' + convert(varchar, @temp_wakeup_num)    
               set @smsg = @smsg + ' is not ready to process'    
               print @smsg    
            end    
            set @asof_trans_id = -1  
            truncate table #related_trans_ids  
         end  
         else  
         begin  
            if @debugon = 1    
            begin    
               set @smsg = 'DEBUG: Wakeup #' + convert(varchar, @temp_wakeup_num)    
               set @smsg = @smsg + ' is ready to process'    
               print @smsg    
            end    
     
            if exists (select 1 
                       from dbo.wakeup 
                       where wakeup_num = @temp_wakeup_num and 
                             status <> @wakeup_working_status_id)
            begin
               if @debugon = 1 
		              print 'Found wakeup to update '
      
               begin tran  
               begin try  
                 exec dbo.gen_new_transaction_NOI @app_name = 'findWakeupForAlsmodules_SP'  
               end try  
               begin catch  
                 if @@trancount > 0  
                    rollback tran  
                 print '=> Error occurred while executing the ''gen_new_transaction_NOI'' stored procedure!'  
                 print '==> ERROR: ' + ERROR_MESSAGE()  
                 goto endofsp  
               end catch  
                          
               set @temp_trans_id = null  
               select @temp_trans_id = last_num   
               from dbo.icts_trans_sequence   
               where oid = 1  
               if @temp_trans_id is null  
               begin  
                  print '=> Failed to obtain a new trans_id for insert!'  
                  goto endofsp  
               end  
     
               update w   
               set w.status = @wakeup_working_status_id,  
                   w.instance_num = @instance_num,  
                   w.trans_id = @temp_trans_id  
               from dbo.wakeup w  
               where w.wakeup_num = @temp_wakeup_num and   
                     (w.instance_num is null or w.instance_num = 0) and  
                     (w.status = @wakeup_pending_status_id or w.status is null)    
               select @rows_updated = @@rowcount,  
                      @errcode = @@error  
               if @rows_updated > 0  
               begin  
                  commit tran  
                  if @debugon = 1  
                     print 'wakeup status was successfully set to ''WORKING''!'  
               end  
               else  
               begin  
                  rollback tran  
                  if @errcode > 0  
                  begin  
                     if @debugon = 1  
                        print 'Error occurred when updating the wakeup status!'  
                     set @temp_wakeup_num = -1  
                     goto endofsp  
                  end  
                  if @debugon = 1  
                  begin  
                     print 'The wakeup status was NOT set to ''WORKING''. It is possible '  
                     print 'that the record is a left behing record in ''WORKING'' status already!'  
                  end  
               end  
            end
            set @wakeup_num = @temp_wakeup_num  
         end  
      end  
      else  
      begin  
         break  
      end  
   end  /* while */     
  
   if (@wakeup_num > 0)  
      select @wakeup_num as 'wakeup_num'  
   else  
      select 0 as 'wakeup_num'  
  
   goto endofsp    
       
endofsp1:    
   print 'Usage: exec dbo.find_wakeup_for_alsmodules'    
   print '              @als_decision_class_names = ?'    
   print '              ,@dependent_als_module_group_desc = ?'    
   print '              ,@instance_num = ?'  
   print '              [ ,@debugon = ?]'    

       
endofsp:  
drop table #als_module_names  
drop table #als_module_groups  
drop table #related_trans_ids
GO
GRANT EXECUTE ON  [dbo].[find_wakeup_for_alsmodules] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'find_wakeup_for_alsmodules', NULL, NULL
GO
