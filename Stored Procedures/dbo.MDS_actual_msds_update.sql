SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[MDS_actual_msds_update]            
@alloc_num varchar(10),                
@alloc_item_num varchar(100)=NULL    ,            
@actual_num varchar(100)=NULL    ,            
@cas_num_desc varchar(255)=NULL,            
@date_of_msds datetime=NULL,            
@msds_reach_imp_flag varchar(3)=NULL,            
@registration_num varchar(100)=NULL ,        
@msds_method_desc varchar(100)=NULL,        
@cas_num_desc2 varchar(255)=NULL,            
@cas_num_desc3 varchar(255)=NULL,            
@cas_num_desc4 varchar(255)=NULL,            
@cas_num_desc5 varchar(255)=NULL,            
@cas_num_desc6 varchar(255)=NULL,            
@cas_num_desc7 varchar(255)=NULL,            
@cas_num_desc8 varchar(255)=NULL,            
@cas_num_desc9 varchar(255)=NULL,            
@cas_num_desc10 varchar(255)=NULL        
           
AS            
BEGIN            
            
 DECLARE @cntr int, @entity_tag_key int, @trans_id int  ,@cas_num varchar(100)  ,@msds_method varchar(15)  , @char_date_of_msds varchar(25)      
 select @char_date_of_msds=convert(char(2),@date_of_msds,106)+'-'+convert(char(3),datename(mm,@date_of_msds))+'-'+substring(datename(yy,@date_of_msds),3,2)      
      
     
     
 begin tran                
 begin try                     
               
    exec dbo.gen_new_transaction_NOI @app_name = 'upd_trader_entity_tag'                
  end try              
              
  begin catch                
    print '=> Failed to execute the ''gen_new_transaction_NOI'' stored procedure to create an icts_transaction record due to the error:'                
    print '==> ERROR: ' + ERROR_MESSAGE()                
    if @@trancount > 0                
    rollback tran                
    return -1                
  end catch                
                    
  select @trans_id = last_num                 
  from dbo.icts_trans_sequence                
  where oid = 1                
              
  --SELECT @trans_id            
   if @trans_id is null                
   begin                
     print '=> Unable to obatin a valid trans_id for update!'                
     if @@trancount > 0                
     rollback tran                
     return                
   end                
                     
if @cas_num_desc is not null            
BEGIN            
 SELECT @cas_num=tag_option From entity_tag_option where entity_tag_id=117 and tag_option_desc = @cas_num_desc          
           
    if not exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=117 )            
    BEGIN            
     exec get_new_num 'entity_tag_key'                
     select @entity_tag_key=last_num from new_num where num_col_name='entity_tag_key'                
               
  if @entity_tag_key is null                
  begin                
     print '=> Unable to obatin a valid entity_tag_key for update!'                
     if @@trancount > 0                
   rollback tran                
   return                  
  end                       
   --select 1            
   insert into entity_tag (entity_tag_key, entity_tag_id, key1,key2,key3, target_key1, trans_id)            
   SELECT @entity_tag_key,117,@alloc_num, @alloc_item_num, @actual_num,@cas_num, @trans_id            
              
   If @@rowcount=0            
   BEGIN            
    rollback            
    return -1            
   end             
                 
              
  END            
 ELSE            
    if exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=117 and isnull(target_key1,'')<>isnull(@cas_num,'NoCas') )            
 BEGIN            
   --select 11            
    update  entity_tag set trans_id=@trans_id, target_key1=@cas_num            
    where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=117            
              
    If @@rowcount=0            
    BEGIN            
     rollback            
     return -1            
    end           
  END                 
 END            
             
--------------------------------------------------------------------------------------------------------        
if @cas_num_desc2 is not null            
BEGIN            
        
 SELECT @cas_num=tag_option From entity_tag_option where entity_tag_id=140 and tag_option_desc = @cas_num_desc2         
         
    if not exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=140  )            
    BEGIN            
     exec get_new_num 'entity_tag_key'                
     select @entity_tag_key=last_num from new_num where num_col_name='entity_tag_key'                
               
    if @entity_tag_key is null                
    begin                
    print '=> Unable to obatin a valid entity_tag_key for update!'                
    if @@trancount > 0                
     rollback tran                
     return                  
    end                       
  -- select 1            
   insert into entity_tag (entity_tag_key, entity_tag_id, key1,key2,key3, target_key1, trans_id)            
   SELECT @entity_tag_key,140,@alloc_num, @alloc_item_num, @actual_num,@cas_num, @trans_id            
 where isnull(@cas_num_desc,'')<>isnull(@cas_num_desc2,'')    
              
   If @@rowcount=0            
   BEGIN            
    rollback            
    return -1            
   end             
                 
              
  END            
 ELSE            
    if exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=140 and isnull(target_key1,'')<>isnull(@cas_num,'NoCas') )            
 BEGIN            
   --select 11         
    update  entity_tag set trans_id=@trans_id, target_key1=@cas_num            
    where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=140            
 and isnull(@cas_num_desc,'')<>isnull(@cas_num_desc2,'')              
     
    If @@rowcount=0            
    BEGIN            
     rollback            
     return -1            
    end             
  END                 
 END            
             
        
SELECT @cas_num=NULL, @entity_tag_key=NULL        
        
if @cas_num_desc3 is not null            
BEGIN            
        
 SELECT @cas_num=tag_option From entity_tag_option where entity_tag_id=141 and tag_option_desc = @cas_num_desc3        
           
    if not exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=141 )            
    BEGIN            
     exec get_new_num 'entity_tag_key'                
     select @entity_tag_key=last_num from new_num where num_col_name='entity_tag_key'                
               
  if @entity_tag_key is null                
  begin                
     print '=> Unable to obatin a valid entity_tag_key for update!'                
     if @@trancount > 0                
   rollback tran                
   return                  
  end                       
   --select 1            
   insert into entity_tag (entity_tag_key, entity_tag_id, key1,key2,key3, target_key1, trans_id)            
   SELECT @entity_tag_key,141,@alloc_num, @alloc_item_num, @actual_num,@cas_num, @trans_id            
              
   If @@rowcount=0            
   BEGIN            
    rollback            
    return -1            
   end             
                 
              
  END            
 ELSE            
    if exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=141 and isnull(target_key1,'')<>isnull(@cas_num,'NoCas') )            
 BEGIN            
   --select 11            
    update  entity_tag set trans_id=@trans_id, target_key1=@cas_num            
    where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=141            
              
    If @@rowcount=0            
    BEGIN            
     rollback            
     return -1     
    end             
  END                 
 END            
         
         
if @cas_num_desc4 is not null            
BEGIN            
        
 SELECT @cas_num=tag_option From entity_tag_option where entity_tag_id=142 and tag_option_desc = @cas_num_desc4        
           
    if not exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=142 )            
    BEGIN            
     exec get_new_num 'entity_tag_key'                
     select @entity_tag_key=last_num from new_num where num_col_name='entity_tag_key'                
               
  if @entity_tag_key is null                
  begin                
     print '=> Unable to obatin a valid entity_tag_key for update!'                
     if @@trancount > 0                
   rollback tran                
   return                  
  end                       
   --select 1            
   insert into entity_tag (entity_tag_key, entity_tag_id, key1,key2,key3, target_key1, trans_id)            
   SELECT @entity_tag_key,142,@alloc_num, @alloc_item_num, @actual_num,@cas_num, @trans_id            
              
   If @@rowcount=0            
   BEGIN            
    rollback            
    return -1            
   end             
                 
              
  END            
 ELSE            
    if exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=142 and isnull(target_key1,'')<>isnull(@cas_num,'NoCas') )            
 BEGIN            
   --select 11            
    update  entity_tag set trans_id=@trans_id, target_key1=@cas_num            
    where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=142            
            If @@rowcount=0            
    BEGIN            
     rollback            
     return -1            
    end             
  END                 
 END            
        
        
SELECT @cas_num=NULL, @entity_tag_key=NULL        
        
if @cas_num_desc5 is not null            
BEGIN            
        
 SELECT @cas_num=tag_option From entity_tag_option where entity_tag_id=143 and tag_option_desc = @cas_num_desc5        
           
    if not exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=143 )            
    BEGIN            
     exec get_new_num 'entity_tag_key'                
     select @entity_tag_key=last_num from new_num where num_col_name='entity_tag_key'                
               
  if @entity_tag_key is null                
  begin                
     print '=> Unable to obatin a valid entity_tag_key for update!'                
     if @@trancount > 0                
   rollback tran                
   return                  
  end                       
   --select 1            
   insert into entity_tag (entity_tag_key, entity_tag_id, key1,key2,key3, target_key1, trans_id)            
   SELECT @entity_tag_key,143,@alloc_num, @alloc_item_num, @actual_num,@cas_num, @trans_id            
              
   If @@rowcount=0            
   BEGIN            
    rollback            
    return -1            
   end             
                 
              
  END            
 ELSE            
    if exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=143 and isnull(target_key1,'')<>isnull(@cas_num,'NoCas') )            
 BEGIN            
   --select 11            
    update  entity_tag set trans_id=@trans_id, target_key1=@cas_num            
    where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=143            
              
    If @@rowcount=0            
    BEGIN            
     rollback            
     return -1            
    end             
  END                 
 END            
         
          
        
        
if @cas_num_desc6 is not null            
BEGIN            
        
 SELECT @cas_num=tag_option From entity_tag_option where entity_tag_id=144 and tag_option_desc = @cas_num_desc6        
           
    if not exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=144 )            
    BEGIN            
     exec get_new_num 'entity_tag_key'                
     select @entity_tag_key=last_num from new_num where num_col_name='entity_tag_key'                
               
  if @entity_tag_key is null                
  begin                
     print '=> Unable to obatin a valid entity_tag_key for update!'                
     if @@trancount > 0                
   rollback tran                
   return                  
  end                       
   --select 1            
   insert into entity_tag (entity_tag_key, entity_tag_id, key1,key2,key3, target_key1, trans_id)            
   SELECT @entity_tag_key,144,@alloc_num, @alloc_item_num, @actual_num,@cas_num, @trans_id            
              
   If @@rowcount=0            
   BEGIN            
    rollback            
    return -1            
   end             
                 
              
  END            
 ELSE            
    if exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=144 and isnull(target_key1,'')<>isnull(@cas_num,'NoCas') )            
 BEGIN            
   --select 11            
    update  entity_tag set trans_id=@trans_id, target_key1=@cas_num            
    where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=144            
              
    If @@rowcount=0            
    BEGIN            
     rollback            
     return -1            
    end             
  END                 
 END            
         
         
SELECT @cas_num=NULL, @entity_tag_key=NULL        
        
if @cas_num_desc7 is not null            
BEGIN            
        
 SELECT @cas_num=tag_option From entity_tag_option where entity_tag_id=146 and tag_option_desc = @cas_num_desc7        
           
    if not exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=146 )            
    BEGIN            
     exec get_new_num 'entity_tag_key'                
     select @entity_tag_key=last_num from new_num where num_col_name='entity_tag_key'                
               
  if @entity_tag_key is null                
  begin                
     print '=> Unable to obatin a valid entity_tag_key for update!'                
     if @@trancount > 0                
   rollback tran                
   return                  
  end                       
   --select 1            
   insert into entity_tag (entity_tag_key, entity_tag_id, key1,key2,key3, target_key1, trans_id)            
   SELECT @entity_tag_key,146,@alloc_num, @alloc_item_num, @actual_num,@cas_num, @trans_id            
              
   If @@rowcount=0            
   BEGIN            
    rollback            
    return -1            
   end             
                 
              
  END            
 ELSE            
    if exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=146 and isnull(target_key1,'')<>isnull(@cas_num,'NoCas') )            
 BEGIN            
   --select 11            
    update  entity_tag set trans_id=@trans_id, target_key1=@cas_num            
    where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=146            
              
    If @@rowcount=0            
    BEGIN            
     rollback            
     return -1            
    end             
  END                 
 END            
        
        
SELECT @cas_num=NULL, @entity_tag_key=NULL        
        
if @cas_num_desc8 is not null            
BEGIN            
        
 SELECT @cas_num=tag_option From entity_tag_option where entity_tag_id=147 and tag_option_desc = @cas_num_desc8        
           
    if not exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=147 )            
    BEGIN            
     exec get_new_num 'entity_tag_key'                
     select @entity_tag_key=last_num from new_num where num_col_name='entity_tag_key'                
               
  if @entity_tag_key is null                
  begin                
     print '=> Unable to obatin a valid entity_tag_key for update!'                
     if @@trancount > 0                
   rollback tran                
   return                  
  end                       
   --select 1            
   insert into entity_tag (entity_tag_key, entity_tag_id, key1,key2,key3, target_key1, trans_id)            
   SELECT @entity_tag_key,147,@alloc_num, @alloc_item_num, @actual_num,@cas_num, @trans_id            
              
   If @@rowcount=0            
   BEGIN       
    rollback            
    return -1            
   end             
                 
              
  END            
 ELSE            
    if exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=147 and isnull(target_key1,'')<>isnull(@cas_num,'NoCas') )            
 BEGIN            
   --select 11            
    update  entity_tag set trans_id=@trans_id, target_key1=@cas_num            
    where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=147            
              
    If @@rowcount=0            
    BEGIN            
     rollback            
     return -1            
    end             
  END                 
 END            
        
SELECT @cas_num=NULL, @entity_tag_key=NULL        
        
if @cas_num_desc9 is not null            
BEGIN            
        
 SELECT @cas_num=tag_option From entity_tag_option where entity_tag_id=148 and tag_option_desc = @cas_num_desc9        
           
    if not exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=148 )            
    BEGIN            
     exec get_new_num 'entity_tag_key'                
     select @entity_tag_key=last_num from new_num where num_col_name='entity_tag_key'                
               
  if @entity_tag_key is null                
  begin                
     print '=> Unable to obatin a valid entity_tag_key for update!'                
     if @@trancount > 0                
   rollback tran                
   return                  
  end                       
   --select 1            
   insert into entity_tag (entity_tag_key, entity_tag_id, key1,key2,key3, target_key1, trans_id)            
   SELECT @entity_tag_key,148,@alloc_num, @alloc_item_num, @actual_num,@cas_num, @trans_id            
              
   If @@rowcount=0            
   BEGIN            
    rollback            
    return -1            
   end             
                 
              
  END            
 ELSE            
    if exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=148 and isnull(target_key1,'')<>isnull(@cas_num,'NoCas') )            
 BEGIN            
   --select 11            
    update  entity_tag set trans_id=@trans_id, target_key1=@cas_num            
    where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=148            
              
    If @@rowcount=0            
    BEGIN            
     rollback            
     return -1            
    end             
  END                 
 END            
        
        
SELECT @cas_num=NULL, @entity_tag_key=NULL        
        
if @cas_num_desc10 is not null            
BEGIN            
        
 SELECT @cas_num=tag_option From entity_tag_option where entity_tag_id=149 and tag_option_desc = @cas_num_desc10        
           
    if not exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=149 )            
    BEGIN            
     exec get_new_num 'entity_tag_key'                
     select @entity_tag_key=last_num from new_num where num_col_name='entity_tag_key'                
               
  if @entity_tag_key is null                
  begin                
     print '=> Unable to obatin a valid entity_tag_key for update!'                
     if @@trancount > 0                
   rollback tran                
   return                  
  end                       
   --select 1            
   insert into entity_tag (entity_tag_key, entity_tag_id, key1,key2,key3, target_key1, trans_id)            
   SELECT @entity_tag_key,149,@alloc_num, @alloc_item_num, @actual_num,@cas_num, @trans_id            
              
   If @@rowcount=0            
   BEGIN            
    rollback            
    return -1            
   end             
                 
              
  END            
 ELSE            
    if exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=149 and isnull(target_key1,'')<>isnull(@cas_num,'NoCas') )            
 BEGIN            
   --select 11            
    update  entity_tag set trans_id=@trans_id, target_key1=@cas_num            
    where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=149            
              
    If @@rowcount=0            
    BEGIN            
     rollback            
     return -1            
    end             
  END                 
 END            
           
        
        
        
        
if @msds_method_desc is not null            
BEGIN            
        
 SELECT @msds_method=tag_option From entity_tag_option where entity_tag_id=150 and tag_option_desc = @msds_method_desc         
        
    --SELECT @msds_method  ,@msds_method_desc    
     --SELECT tag_option From entity_tag_option where entity_tag_id=150 and tag_option_desc = @msds_method_desc         
    if not exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=150 )            
    BEGIN            
   exec get_new_num 'entity_tag_key'                
   select @entity_tag_key=last_num from new_num where num_col_name='entity_tag_key'                
               
    if @entity_tag_key is null                
    begin                
    print '=> Unable to obatin a valid entity_tag_key for update!'                
    if @@trancount > 0                
     rollback tran                
     return                  
    end                       
     --select 1            
     insert into entity_tag (entity_tag_key, entity_tag_id, key1,key2,key3, target_key1, trans_id)            
     SELECT @entity_tag_key,150,@alloc_num, @alloc_item_num, @actual_num,@msds_method, @trans_id            
                
     If @@rowcount=0            
     BEGIN            
   rollback            
   return -1            
     end             
                 
              
 END            
 ELSE            
 if exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=150 and isnull(target_key1,'')<>isnull(@cas_num,'NoCas') )            
 BEGIN            
   --select 11            
    update  entity_tag set trans_id=@trans_id, target_key1=@msds_method            
    where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=150            
              
    If @@rowcount=0            
    BEGIN            
     rollback            
     return -1            
    end             
  END                 
 END            
         
         
        
--------------------------------------------------------------------------------------------------------             
 if @date_of_msds is not null            
    BEGIN             
    if not exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=118   )            
    BEGIN            
      
    exec get_new_num 'entity_tag_key'                
    select @entity_tag_key=last_num from new_num where num_col_name='entity_tag_key'                
               
  if @entity_tag_key is null                
    begin                
      print '=> Unable to obatin a valid entity_tag_key for update!'                
      if @@trancount > 0                
      rollback tran                
      return                  
  end                       
  --select 2            
    if not exists (select 1 where isnull(@char_date_of_msds,'01-Jan-00') in ('01-Jan-00'  ,'01/01/2000') OR @date_of_msds<'01/01/2005' )    
    BEGIN    
       insert into entity_tag (entity_tag_key, entity_tag_id, key1,key2,key3, target_key1, trans_id)            
       SELECT @entity_tag_key,118,@alloc_num, @alloc_item_num, @actual_num,@char_date_of_msds, @trans_id        
          END    
              
  If @@rowcount=0            
  BEGIN            
   rollback            
   return -1            
  end             
                
              
 END            
 ELSE            
    if exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=118 and isnull(target_key1,'')<>isnull(@char_date_of_msds,'01-Jan-00') )           
 BEGIN            
  --select 22            
    if exists (select 1 where isnull(@date_of_msds,'01-Jan-00') in ('01-Jan-00'  ,'01/01/2000') OR isnull(@char_date_of_msds,'01-Jan-00') in ('01-Jan-00'  ,'01/01/2000') OR @date_of_msds<'01/01/2005')    
    BEGIN    
     SELECT @date_of_msds=NULL    
       update  entity_tag set trans_id=@trans_id, target_key1=NULL            
       where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=118           
    END       
    ELSE    
    update  entity_tag set trans_id=@trans_id, target_key1=@char_date_of_msds            
    where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=118            
    
              
  If @@rowcount=0            
  BEGIN           
   rollback            
   return -1            
  end               
 END            
 END            
             
             
 if @msds_reach_imp_flag is not null            
 BEGIN            
    if not exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=119 )            
    BEGIN            
                
    exec get_new_num 'entity_tag_key'                
    select @entity_tag_key=last_num from new_num where num_col_name='entity_tag_key'                
               
    if @entity_tag_key is null                
    begin                
   print '=> Unable to obatin a valid entity_tag_key for update!'                
   if @@trancount > 0                
   rollback tran                
   return                  
    end                       
  --select 3            
  insert into entity_tag (entity_tag_key, entity_tag_id, key1,key2,key3, target_key1, trans_id)            
  SELECT @entity_tag_key,119,@alloc_num, @alloc_item_num, @actual_num,@msds_reach_imp_flag, @trans_id            
            
  If @@rowcount=0            
  BEGIN            
   rollback            
   return -1            
  end             
              
 END            
 ELSE            
    if  exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=119 and isnull(target_key1,'')<>@msds_reach_imp_flag)            
 BEGIN            
  --select 33            
  update  entity_tag set trans_id=@trans_id, target_key1=@msds_reach_imp_flag            
  where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=119            
              
              
  If @@rowcount=0            
  BEGIN            
   rollback            
   return -1            
  end               
 END            
 END            
             
 if @registration_num is not null            
 BEGIN            
    if not exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=120   )            
    BEGIN            
    exec get_new_num 'entity_tag_key'                
    select @entity_tag_key=last_num from new_num where num_col_name='entity_tag_key'                
               
    if @entity_tag_key is null                
    begin                
   print '=> Unable to obatin a valid entity_tag_key for update!'                
   if @@trancount > 0                
   rollback tran                
   return                  
    end                       
  --select 4            
  insert into entity_tag (entity_tag_key, entity_tag_id, key1,key2,key3, target_key1, trans_id)            
  SELECT @entity_tag_key,120,@alloc_num, @alloc_item_num, @actual_num,@registration_num, @trans_id            
              
  If @@rowcount=0            
  BEGIN            
   rollback            
   return -1            
  end             
              
 END            
 ELSE            
    if exists (select 1 from entity_tag where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=120 and isnull(target_key1,'')<>@registration_num )            
 BEGIN            
  --select 44            
  update  entity_tag set trans_id=@trans_id, target_key1=@registration_num            
  where key1=@alloc_num and key2=@alloc_item_num and key3=@actual_num and entity_tag_id=120            
            
              
  If @@rowcount=0            
  BEGIN            
   rollback            
   return -1            
  end               
 END            
 END            
     
 commit tran            
 return 1            
            
END       
GO
GRANT EXECUTE ON  [dbo].[MDS_actual_msds_update] TO [next_usr]
GO
