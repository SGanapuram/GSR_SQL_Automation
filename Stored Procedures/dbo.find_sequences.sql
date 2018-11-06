SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[find_sequences]  
(      
   @als_module_group_id       int = null,              
   @debugon                   bit = 0,              
   @instance_num              smallint,              
   @sequence_block_size       int = 1,      
   @executor_id               tinyint = 0
)              
as                  
set nocount on 
set xact_abort on                 
declare @sequence           int,                  
        @sequence1          int,                  
        @smsg               varchar(255),                  
        @rows_updated       int,                  
        @pending_status_id  int,                  
        @working_status_id  int,                  
        @tries              smallint,                  
        @errcode            int,            
        @rows_affected      int          
                  
declare @touch              table              
(            
   sequence             int            NULL,            
   entity_name          varchar(30)    NULL,            
   key1                 varchar(30)    NULL,            
   key2                 varchar(30)    NULL,            
   key3                 varchar(30)    NULL,            
   key4                 varchar(30)    NULL,            
   key5                 varchar(30)    NULL,            
   key6                 varchar(30)    NULL,            
   key7                 varchar(30)    NULL,            
   key8                 varchar(30)    NULL            
)            
            
   select @sequence = -1,                  
          @tries = 0,                  
          @errcode = 0            
                     
   if @sequence_block_size is null                  
      select @sequence_block_size = 1                  
                     
   /* Check if we have all argument values */                  
   if @als_module_group_id is null                  
   begin                  
      print 'Please provide a value for the argument @als_module_group_id!'                  
      goto endofsp1                  
   end                  
                  
   if @instance_num is null                  
      select @instance_num = 0                  
                  
   if @instance_num = 0                  
   begin                  
      print 'Please provide a non-zero positive number for the argument @instance_num!'                  
      goto endofsp1                  
   end                  
                  
   if @debugon = 1                  
      print 'DEBUG is turned on'                  
                  
   select @pending_status_id = 0                  
   select @working_status_id = 1                  
                     
   /* Check to see if we can find a PENDING or a WORKING als_run record for the                   
      given ALS module group                   
   */                      
   while (1 = 1)                  
   begin                  
      select @sequence = -1                    
bk1:              
      --delete @touch           
      insert into @touch        
          (sequence, entity_name, key1, key2, key3, key4, key5, key6, key7, key8)        
      select sequence,        
             entity_name,        
             isnull(key1, '0'),        
             isnull(key2, '0'),        
             isnull(key3, '0'),        
             isnull(key4, '0'),        
             isnull(key5, '0'),        
             isnull(key6, '0'),        
             isnull(key7, '0'),        
             isnull(key8, '0')        
      from dbo.als_run_touch with (nolock)        
      where sequence = (select isnull(min(sequence), -1)               
                        from (select top 1 ar.sequence        
                              from dbo.als_run ar    
                                      inner join dbo.icts_transaction it with (nolock) 
                                         on it.sequence = ar.sequence      
                              where ar.als_module_group_id = @als_module_group_id AND               
                                    ar.als_run_status_id = @pending_status_id and      
                                    ar.sequence > @sequence and      
                                    it.executor_id = @executor_id      
                              order by ar.sequence asc                                      
                              union all        
                              select top 1 ar.sequence               
                              from dbo.als_run ar with (nolock)              
                                      inner join dbo.icts_transaction it with (nolock) 
                                         on it.sequence = ar.sequence      
                              where ar.als_module_group_id = @als_module_group_id AND               
                                    ar.als_run_status_id = @working_status_id and              
                                    ar.instance_num = @instance_num and          
                                    ar.sequence > @sequence  and      
                                    it.executor_id = @executor_id      
                              order by ar.sequence asc) a) and   
            als_module_group_id = @als_module_group_id               
                     
      select @rows_affected = @@rowcount            
      if @rows_affected = 0            
         set @sequence = -1            
      else            
      begin            
         set @sequence = (select isnull(max(sequence), -1) from @touch)             
         /* The following IF block was added to verify if the sequence found is allowed.               
            The sequence is not allowed if there is any other sequence is in process               
            (working status) with earlier versions of the same entities and with same ALS.               
         */              
         if exists (select 1              
                    from (select ar.als_run_status_id, 
                                 ar.als_module_group_id, 
                                 entity_name, 
                                 isnull(key1,0) as key1, 
                                 isnull(key2,0) as key2, 
                                 isnull(key3,0) as key3, 
                                 isnull(key4,0) as key4,         
                                 isnull(key5,0) as key5, 
                                 isnull(key6,0) as key6, 
                                 isnull(key7,0) as key7, 
                                 isnull(key8,0) as key8, 
                                 art.sequence         
                          from dbo.als_run_touch art with (nolock)       
                                  inner join dbo.als_run ar with (nolock) 
                                     on ar.sequence = art.sequence and 
                                        ar.als_module_group_id = art.als_module_group_id      
                          where ar.als_module_group_id = @als_module_group_id and 
                                ar.als_run_status_id in (@working_status_id, @pending_status_id) and 
                                ar.sequence < @sequence) inProgressSequences              
                    where exists (select 1            
                                  from @touch t              
                                  where inProgressSequences.als_module_group_id = @als_module_group_id and            
                                        inProgressSequences.entity_name = t.entity_name and            
                                        inProgressSequences.key1 = t.key1 and              
                                        inProgressSequences.key2 = t.key2 and              
                                        inProgressSequences.key3 = t.key3 and              
                                        inProgressSequences.key4 = t.key4 and              
                                        inProgressSequences.key5 = t.key5 and              
                                        inProgressSequences.key6 = t.key6 and              
                                        inProgressSequences.key7 = t.key7 and              
                                        inProgressSequences.key8 = t.key8 and 
                                        t.sequence = @sequence) )             
            goto bk1            
      end              
              
      if @debugon = 1                  
      begin                  
         if @sequence = -1                    
         begin                         
            select @smsg = 'DEBUG: No PENDING and WORKING als_run record was found for ALS module group #'                   
            select @smsg = @smsg + convert(varchar, @als_module_group_id) + '!'                  
         end                  
         else             
            select @smsg = 'DEBUG: Found the PENDING or WORKING sequence #' + convert(varchar, @sequence)                  
         print @smsg                  
      end                
              
      /* end verify that the entities for this sequence are not in any working sequence */              
              
      select @rows_updated = 0                  
      if @sequence > 0  /* Yes, a PENDING or WORKING als_run record is found */                  
      begin                  
         select @sequence1 = @sequence + @sequence_block_size - 1           
               
         if @debugon = 1                  
         begin                  
            select @smsg = 'DEBUG: The als_run record with the sequence #'                  
            select @smsg = @smsg + convert(varchar, @sequence)                   
            select @smsg = @smsg + ' is picked. Change its status to WORKING.'                  
            print @smsg                  
         end                  
         /* Make sure that only the PENDING can be changed to WORKING.                   
            This will avoid two callers pick the same record                  
         */                  
         begin tran                  
         update dbo.als_run                  
         set als_run_status_id = @working_status_id,                  
             instance_num = @instance_num,                  
             start_time = getdate()                  
         where (sequence between @sequence and @sequence1) and                   
               als_module_group_id = @als_module_group_id and                  
               instance_num is null and                  
               als_run_status_id = @pending_status_id                  
         select @rows_updated = @@rowcount,                  
                @errcode = @@error                  
         if @rows_updated > 0                  
         begin                  
            commit tran                  
            if @debugon = 1                  
               print 'als_run status was successfully set to ''WORKING''!'                  
         end                  
         else                  
         begin                  
            rollback tran                  
            if @errcode > 0                  
            begin                  
               if @debugon = 1                  
                  print 'Error occurred when updating the als_run status!'                  
               select @sequence = -1                  
               break                  
            end                  
            if @debugon = 1                  
            begin                  
               print 'The als_run status was NOT set to ''WORKING''. It is possible '            
               print 'that the record is a left behind record in ''WORKING'' status already!'            
            end            
         end            
      end            
                           
      if @sequence > 0            
         break            
                        
      select @tries = @tries + 1            
      if @tries > 3            
         break            
                        
      /* wait for 0.5 second before retry */            
      WAITFOR DELAY '00:00:00:500'            
   end  /* while */            
                  
   /* Here, we want to return als_run_touch records for all            
      WORKING sequences for the given als_module_group and            
      instance #, not just the one we picked at this session,            
      or no PENDING sequence was found            
   */                               
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
   from (select als_module_group_id, 
                operation, 
                entity_name, 
                isnull(key1,'0') as key1, 
                isnull(key2,'0') as key2, 
                isnull(key3,'0') as key3, 
                isnull(key4,'0') as key4,         
                isnull(key5,'0') as key5, 
                isnull(key6,'0') as key6, 
                isnull(key7,'0') as key7, 
                isnull(key8,'0') as key8,         
                trans_id, 
                sequence, 
                touch_key, 
                'DIRECT' as touch_type 
         from als_run_touch with (nolock) ) tt            
   where exists (select 1            
                 from als_run als (nolock)            
                 where als.sequence = tt.sequence and            
                       als.als_module_group_id = @als_module_group_id and            
                       als.instance_num = @instance_num and            
                       als_run_status_id = @working_status_id) and            
         exists (select 1            
                 from als_module_entity e (nolock)            
                 where e.als_module_group_id = @als_module_group_id and            
                       e.entity_name = tt.entity_name) and            
         als_module_group_id = @als_module_group_id and            
         tt.touch_key = (select max(touch_key)            
                         from (select sequence, 
                                      entity_name, 
                                      operation, 
                                      isnull(key1,'0') as key1, 
                                      isnull(key2,'0') as key2, 
                                      isnull(key3,'0') as key3, 
                                      isnull(key4,'0') as key4,         
                                      isnull(key5,'0') as key5, 
                                      isnull(key6,'0') as key6, 
                                      isnull(key7,'0') as key7, 
                                      isnull(key8,'0') as key8, 
                                      touch_key,        
                                      trans_id         
                               from dbo.als_run_touch with (nolock) 
                               where als_module_group_id = @als_module_group_id) tt2           
                         where tt2.sequence = tt.sequence and            
                               tt2.entity_name = tt.entity_name and            
                               tt2.operation = tt.operation and            
                               tt2.key1 = tt.key1 and            
                               tt2.key2 = tt.key2 and            
                               tt2.key3 = tt.key3 and            
                               tt2.key4 = tt.key4 and            
                               tt2.key5 = tt.key5 and            
                               tt2.key6 = tt.key6 and            
                               tt2.key7 = tt.key7 and            
                               tt2.key8 = tt.key8 and            
                               tt2.trans_id = tt.trans_id)            
   goto endofsp            
                     
endofsp1:            
   print 'Usage: exec dbo.find_sequences'            
   print '                  @als_module_group_id = ?'            
   print '                  [ ,@debugon = ?]'            
   print '                  ,@instance_num = ?'            
   print '                  [,@sequence_block_size = ?]'            

endofsp: 
GO
GRANT EXECUTE ON  [dbo].[find_sequences] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'find_sequences', NULL, NULL
GO
