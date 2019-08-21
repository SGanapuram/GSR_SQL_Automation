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
declare @asof_trans_id bigint,      
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
        @temp_trans_id bigint,      
        @my_instance_num               int        
                          
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
   trans_id bigint              
)        
      
   create nonclustered index XX10191_related_trans_ids_idx      
      on #related_trans_ids (trans_id)      
         
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
          @errcode = 0,      
          @my_instance_num = @instance_num                              
         
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
                   from dbo.server_config s with(nolock)       
                   where a.group_desc = s.als_module_group_desc)               
   from #als_module_groups a        
         
   /* Check to see if we can find a unprocessed wakeup record for the           
      given ALS modules */              
    while (@wakeup_num < 0)      
    begin      
      select top 1 @temp_wakeup_num = isnull(wakeup_num, -1)    
      from dbo.wakeup w   
      where exists (select 1  
                 from #als_module_names amn   
                    where w.als_decision_class_name = amn.module_name) and  
         w.exception_flag = @wakeup_pending_exception_flag AND       
            ((w.status = @wakeup_working_status_id AND   
              w.instance_num = @instance_num) OR   
             w.status = @wakeup_pending_status_id OR   
             w.status is null) AND    
            w.wakeup_num > @temp_wakeup_num     
      order by w.status desc, w.wakeup_num    
      
      if @debugon = 1      
      begin      
         if @temp_wakeup_num = -1        
            RAISERROR('DEBUG: No PENDING Wakeup record was found for ALS modules ''%s''!', 0, 1, @als_decision_class_names) with nowait    
         else      
            RAISERROR('DEBUG: Found the PENDING Wakeup #%d', 0, 1, @temp_wakeup_num) with nowait      
   end      
          
      if @temp_wakeup_num > 0  /* Yes, a PENDING Wakeup record is found */          
            begin /* block #1 */   
         select @asof_trans_id = asof_trans_id,   
                @related_asof_transids = isnull(w.related_asof_transids, asof_trans_id)   
         from dbo.wakeup w   
         where w.wakeup_num = @temp_wakeup_num    
         if @debugon = 1
			begin
			 declare @asof_string varchar(25)
			 set @asof_string=convert(varchar,@asof_trans_id)
			 
            RAISERROR('DEBUG: Checking the als_run status for the Wakeup #%d with asof_trans_id #%s', 0, 1,
			@temp_wakeup_num, @asof_string) with nowait    
			end
     
         -- In most of cases, the @related_asof_transids would store a single trans_id, in this case,  
   -- we should not need to extract elements (trans_ids) from @related_asof_transids  
        if CHARINDEX(@delimiter, @related_asof_transids) > 0  
        begin     
            insert into #related_trans_ids (trans_id)     
            select m.splitdata from (select cast('<X>' + replace(@related_asof_transids, @delimiter, '</X><X>') + '</X>'   
   as XML) as xmlfilter) F1 CROSS APPLY (select fdata.D.value('.','varchar(255)') as splitdata   
   from F1.xmlfilter.nodes('X') as fdata(D)) m    
         end  
  else  
   begin  
      insert into #related_trans_ids (trans_id)   
      select convert(bigint, @related_asof_transids)  
   end  
     
   -- Since the icts_transaction table is a busy table, we want to limit to access this table  
   -- in a query which performs conditional checking for als_run records. So, to make it simple,   
   -- let remove invalid trans_ids existed in #related_trans_ids table first  
   delete a  
   from #related_trans_ids a  
   where not exists (select 1  
                     from dbo.icts_transaction t with (readpast)  
         where a.trans_id = t.trans_id)--ADSO-15225  
         
         /* Make sure that the parent user transaction was completely processed by other ALSs. */          
          
  if (select count(*) from #related_trans_ids) > 0  
         begin /* block #2 */    
            if exists (select 1     
                       from dbo.als_run a   
                       where exists (select 1  
                      from #als_module_groups amg   
                                     where a.als_module_group_id = amg.group_id) and  
              a.als_run_status_id in (@als_pending_status_id, @als_working_status_id) and     
        exists (select 1  
                from #related_trans_ids b  
          where a.trans_id = b.trans_id))  
            begin    
               if @debugon = 1      
                  RAISERROR('DEBUG: Wakeup #%d  is not ready to process!', 0, 1, @temp_wakeup_num) with nowait     
               set @asof_trans_id = -1    
               truncate table #related_trans_ids    
            end    
            else    
            begin  /* block #3 */  
               if @debugon = 1      
                  RAISERROR('DEBUG: Wakeup #%d  is ready to process.', 0, 1, @temp_wakeup_num) with nowait    
       
               if exists (select 1   
                          from dbo.wakeup   
                          where wakeup_num = @temp_wakeup_num and   
                                status <> @wakeup_working_status_id)  
               begin /* block #4 */  
                  if @debugon = 1   
                print 'Found wakeup to update '  
        
                  begin tran    
                  begin try    
                    exec dbo.gen_new_transaction_NOI @app_name = 'findWakeupForAlsmodules_SP'    
                  end try    
                  begin catch    
        set @errcode = ERROR_NUMBER()  
     set @smsg = ERROR_MESSAGE()  
                    if @@trancount > 0    
                       rollback tran    
                    RAISERROR('=> Failed to execute the ''gen_new_transaction_NOI'' stored procedure due to the error below:', 0, 1) with nowait   
                    RAISERROR('==> ERROR %d: %s', 0, 1, @errcode, @smsg) with nowait   
                    goto endofsp    
                  end catch    
                            
                  set @temp_trans_id = null    
                  select @temp_trans_id = last_num     
                  from dbo.icts_trans_sequence     
                  where oid = 1    
                  if @temp_trans_id is null    
                  begin    
                     RAISERROR('=> Failed to obtain a new trans_id for update!', 0, 1) with nowait     
                     goto endofsp    
                  end    
  
    begin try  
                    update w     
                    set w.status = @wakeup_working_status_id,    
                        w.instance_num = @instance_num,    
                        w.trans_id = @temp_trans_id    
                    from dbo.wakeup w    
                    where w.wakeup_num = @temp_wakeup_num and     
                          (w.instance_num is null or w.instance_num = 0) and    
                          (w.status = @wakeup_pending_status_id or w.status is null)      
                    set @rows_updated = @@rowcount  
     commit tran  
                    if @debugon = 1    
                       RAISERROR('=> The wakeup status was successfully set to ''WORKING''!', 0, 1) with nowait    
    end try  
    begin catch  
                    set @errcode = ERROR_NUMBER()  
                    set @smsg = ERROR_MESSAGE()  
                    if @@trancount > 0  
                       rollback tran  
                    if @debugon = 1    
     begin  
                       RAISERROR('=> Failed to update the wakeup status due to the error below:', 0, 1) with nowait  
          RAISERROR('==> ERROR %d: %s', 0, 1, @errcode, @smsg) with nowait  
          RAISERROR('===> The wakeup status was NOT set to ''WORKING''. It is possible that the record', 0, 1) with nowait    
          RAISERROR('===> is a left behind record in ''WORKING'' status already!', 0, 1) with nowait    
                    end             
                    set @temp_wakeup_num = -1    
                    goto endofsp    
                end catch    
               end /* block #4 */  
               set @wakeup_num = @temp_wakeup_num    
            end  /* block #3 */  
         end /* block #2 */  
   end /* block #1 */  
         else    
         begin    
            break    
         end    
  -- end /* block #1 */   
   end  /* while */      
          
   if (@wakeup_num > 0)          
      select @wakeup_num as 'wakeup_num'          
   else          
      select 0 as 'wakeup_num'          
          
   goto endofsp            
               
endofsp1:            
   print 'Usage: exec dbo.find_wakeup_for_alsmodules'            
  print ' @als_decision_class_names = ?'            
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
