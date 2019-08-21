SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[find_sequence_quiesced]
(                  
   @als_module_group_id              int = 0,                    
   @dependent_als_module_group_desc  varchar(512) = null,                    
   @instance_num                     smallint,                    
   @debugon                          bit = 0,
   @executor_id	                     tinyint = 0
)
as                      
set nocount on                                        
set xact_abort on            
declare @sequence                            int,                      
        @als_pending_status_id               smallint,                      
        @als_working_status_id               smallint,              
        @als_no_pending_no_working_status_id smallint,                 
        @smsg                                varchar(512),                    
        @delimiter                           varchar(1),                    
        @errcode                             int,                    
        @rows_updated                        int,                    
        @xml                                 xml         
                    
   create table #als_module_groups                    
   (                          
      group_desc      varchar(255),          
      group_id        int default 0 null                         
   )                    
                    
   /* Check if we have all argument values */                      
   if @dependent_als_module_group_desc is null                      
   begin                      
      print '=> Please provide a value for the argument @dependent_als_module_group_desc!'                      
      goto usage                      
   end                      
                    
   if @instance_num <= 0                      
   begin                      
      print '=> Please provide a valid number for the argument @instance_num!'                      
      goto usage                      
   end                      
                    
   if @debugon = 1                      
      print 'DEBUG is turned on'                           
                    
   /* initialize everything */                
   select @sequence = -1,                    
          @als_pending_status_id = 0,                    
          @als_working_status_id = 1,            
          @als_no_pending_no_working_status_id = 2,                    
          @delimiter = ',',                    
          @errcode = 0                    
                    
   /* Spliting the input string and populating the child table */               
   set @xml = cast(('<X>' + replace(@dependent_als_module_group_desc, @delimiter,'</X><X>') + '</X>') as xml)          
   insert into #als_module_groups (group_desc, group_id)          
      select rtrim(ltrim(N.value('.', 'varchar(255)'))), 0 from @xml.nodes('X') as T(N)          
          
   update a           
   set group_id = (select als_module_group_id          
                   from dbo.server_config s          
                   where a.group_desc = s.als_module_group_desc)                 
   from #als_module_groups a           
                   
   /* Check to see if we can find a PENDING or WORKING als_run record for the given ALS modules */          
   set @sequence = -1             
   select @sequence = isnull(min(w.sequence), -1)                    
   from (select ar.sequence          
         from dbo.als_run ar with (nolock) 
                 inner join dbo.icts_transaction it with (nolock) 
                    on it.sequence = ar.sequence  	 
         where als_module_group_id = @als_module_group_id AND          
               1 = case when als_run_status_id = @als_working_status_id AND           
                             instance_num = @instance_num          
                           then 1          
                        else 0          
                   end and 
               it.executor_id = @executor_id  		   
         union all           
         select top 1 ar.sequence          
         from dbo.als_run ar with (nolock) 
                 inner join dbo.icts_transaction it with (nolock) 
                    on it.sequence = ar.sequence    	 
         where als_module_group_id = @als_module_group_id and          
               als_run_status_id = @als_pending_status_id and
	             it.executor_id = @executor_id
         order by ar.sequence) w             
   where not exists (select 1          
                     from dbo.als_run a          
                     where a.sequence = w.sequence and          
                           exists (select 1          
                                   from #als_module_groups b          
                                   where a.als_module_group_id = b.group_id) and          
                           a.als_run_status_id < @als_no_pending_no_working_status_id)                 
                                          
   if @sequence > 0  /* Yes, we found a PENDING/WORKING sequence */                      
   begin                                      
      if @debugon = 1                      
         print 'DEBUG: Found a PENDING/WORKING sequence #' + cast(@sequence as varchar) + ', let''s verify if this sequence # can be processed ...'       
     
      if exists (select 1                     
                 from dbo.als_run a with (nolock)           
                         join dbo.server_config sc           
                            on a.als_module_group_id = sc.als_module_group_id           
                         join #als_module_groups amg           
                            on sc.als_module_group_desc = amg.group_desc                    
                 where a.als_run_status_id < @als_no_pending_no_working_status_id and           
                       a.trans_id in (select trans_id           
                                      from dbo.als_run w with (nolock)           
                                      where w.sequence = @sequence          
                                      union all          
                                      select trans_id          
                                      from dbo.icts_transaction t          
                                      where t.parent_trans_id in (select trans_id           
                                                                  from dbo.als_run w with (nolock)           
                                                                  where w.sequence = @sequence)))          
      begin          
         if @debugon = 1                      
            print 'DEBUG: Sequence #' + cast(@sequence as varchar) + ' is NOT ready for processing'                      
         set @sequence = -1          
      end          
   end    
               
   if @sequence > 0   /* Yes, here we found a sequence # ready for processing */                   
   begin                                      
      if @debugon = 1                      
         print 'DEBUG: Sequence #' + cast(@sequence as varchar) + ' is ready for processing'                      
                       
      begin tran           
      begin try                   
        update w                     
        set w.als_run_status_id = @als_working_status_id,                    
            w.instance_num = @instance_num,          
            w.start_time = getdate()      -- nyera - updating time              
        from dbo.als_run w                    
        where w.sequence = @sequence and            
              w.als_module_group_id = @als_module_group_id and                   
              w.als_run_status_id = @als_pending_status_id and                            
              (w.instance_num = 0 or w.instance_num is null)                   
        set @rows_updated = @@rowcount          
      end try          
      begin catch          
        if @@trancount > 0          
           rollback tran                    
          
        print '=> Failed to update an als_run record for the sequence #' + cast(@sequence as varchar) + ' due to the error:'          
        print '==> ERROR: ' + ERROR_MESSAGE()          
        set @errcode = ERROR_NUMBER()        
        set @sequence = -1          
        goto endofsp          
      end catch           
      commit tran          
      if @rows_updated > 0          
      begin                   
         if @debugon = 1                    
            print '=> The als_run status was successfully set to ''WORKING'' for the sequence #' + cast(@sequence as varchar) + '!'                   
      end            
   end  /* if @sequence > 0 */    
   goto endofsp                       
    
usage:                      
   print 'Usage: exec dbo.find_sequence_quiesced'             
   print '              @als_module_group_id = ?'                      
   print '              ,@dependent_als_module_group_desc = ?'                      
   print '              ,@instance_num = ?'                    
   print '              [ ,@debugon = ?]'                      
   set @sequence = -1    
             
endofsp:                    
   if @sequence > 0    
      select tt.entity_name,        
             tt.key1,        
             tt.key2,        
             tt.key3,        
             tt.key4,        
             tt.key5,        
             tt.key6,        
             tt.key7,        
             tt.key8,        
             case when tt.operation = 'I' then 'INSERT'        
                  when tt.operation = 'U' then 'UPDATE'        
                  when tt.operation = 'D' then 'DELETE'        
             end as operation,        
             tt.sequence,        
             tt.touch_key,        
             'DIRECT' as touch_type,        
             tt.trans_id        
      from dbo.als_run_touch tt (nolock)        
      where exists (select 1        
                    from dbo.als_run als (nolock)        
                    where als.sequence = @sequence and    
                          als.sequence = tt.sequence and        
                          als.als_module_group_id = @als_module_group_id and        
                          als.instance_num = @instance_num and        
                          als_run_status_id = @als_working_status_id) and        
            exists (select 1        
                    from dbo.als_module_entity e (nolock)        
                    where e.als_module_group_id = @als_module_group_id and        
                          e.entity_name = tt.entity_name) and        
            tt.touch_key = (select max(touch_key)        
                            from dbo.als_run_touch tt2        
                            where tt2.als_module_group_id = @als_module_group_id and        
                                  tt2.sequence = tt.sequence and        
                                  tt2.entity_name = tt.entity_name and        
                                  tt2.operation = tt.operation and        
                                  isnull(tt2.key1, '0') = isnull(tt.key1, '0') and        
                                  isnull(tt2.key2, '0') = isnull(tt.key2, '0') and        
                                  isnull(tt2.key3, '0') = isnull(tt.key3, '0') and        
                                  isnull(tt2.key4, '0') = isnull(tt.key4, '0') and        
                                  isnull(tt2.key5, '0') = isnull(tt.key5, '0') and        
                                  isnull(tt2.key6, '0') = isnull(tt.key6, '0') and        
                                  isnull(tt2.key7, '0') = isnull(tt.key7, '0') and        
                                  isnull(tt2.key8, '0') = isnull(tt.key8, '0') and        
                                  tt2.trans_id = tt.trans_id)            
   else  
      select null,  /* entity_name */   
             null,  /* key1 */  
             null,  /* key2 */      
             null,  /* key3 */      
             null,  /* key4 */      
             null,  /* key5 */      
             null,  /* key6 */      
             null,  /* key7 */      
             null,  /* key8 */      
             null,  /* operation */      
             0,     /* sequence */      
             0,     /* touch_key */      
             null,  /* touch_type */      
             0      /* trans_id */  
                                              
   drop table #als_module_groups           
   if @errcode > 0          
      return 1          
   return 0    
GO
GRANT EXECUTE ON  [dbo].[find_sequence_quiesced] TO [next_usr]
GO
