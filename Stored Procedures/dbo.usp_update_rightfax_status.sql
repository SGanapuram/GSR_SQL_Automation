SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_update_rightfax_status]   
(                 
   @unique_id    char(13),  
   @fax_num      varchar(15),  
   @email_id     varchar(40),                             
   @faxstatus    int  
)
as  
set nocount on  
set xact_abort on
                           
create table #tempenttagdef  
(  
 oid int not null,  
 entity_tag_name varchar(16),  
 tag_status char(1),  
 entity_id int not null                              
)  
  
create table #tempenttag  
(  
entity_tag_id int,  
entity_tag_name varchar(16),  
key1 varchar(16),  
key2 varchar(16),  
target_key1 varchar(16),  
target_key7 varchar(16)  
)  
  
declare @status char(1),  
@isbulkconfirm char(1),  
@updtrdcheck char(1),  
@updatestatus varchar(10),  
@fax_mail char(1),  
@faxormail varchar(40),  
@docid varchar(13),  
@entity_tag_id int,  
@key1 varchar(16),  
@key2 varchar(16),  
@target_key7 varchar(16),  
@entity_id int,  
@entity_name varchar(30),  
@event_num int,  
@evtowner varchar(30),  
@evtdesc varchar(4),  
@trans_id int  
  
if len(@fax_num) > 0  
begin  
 select @faxormail = @fax_num  
end  
else  
begin  
 select @faxormail = @email_id  
end  
  
 insert into #tempenttagdef  
   select oid,entity_tag_name,tag_status,entity_id from entity_tag_definition  
 where entity_tag_name IN ('RF_T_E_STSDOCID','RF_T_F_STSDOCID','RF_AI_E_STSDOCID',  
 'RF_AI_F_STSDOCID','RF_V_E_STSDOCID','RF_V_F_STSDOCID')                              
   
 insert into #tempenttag(entity_tag_id,entity_tag_name,target_key1,key1,key2,target_key7 )                              
   select et.entity_tag_id,etdef.entity_tag_name,et.target_key1,et.key1,et.key2,et.target_key7         
 from entity_tag et inner join #tempenttagdef etdef on et.entity_tag_id = etdef.oid         
 where target_key1 like 'P%' and substring(et.target_key1,3,len(et.target_key1)-1)= @unique_id                              
  
if exists (select 1 from #tempenttag)  
begin  
  
  begin tran  
  begin try  
 exec gen_new_transaction_NOI @app_name='RFaxServerNotify', @trans_type='U'  
  end try  
  begin catch  
    if @@trancount > 0  
       rollback tran  
      print '=> Error occurred while executing the ''gen_new_transaction_NOI'' stored procedure!'      
      print ERROR_MESSAGE()  
 goto endofscript  
  end catch  
  commit tran  
  
select @trans_id = null  
  
  select @trans_id = last_num   
 from dbo.icts_trans_sequence where oid = 1  
   
/* entity_tag code*/  
  
  select @status = substring(target_key1,1,1),   
        @isbulkconfirm = substring(target_key1,2,1),    
        @docid = substring(target_key1,3,len(target_key1)-2),  
 @entity_tag_id = entity_tag_id, @key1 = key1, @key2 = key2,  
 @target_key7 = target_key7   
 from #tempenttag where substring(target_key1,3,len(target_key1)-1)= @unique_id          
       
 if @status='P'                              
 begin                    
 if @faxstatus=6                              
 begin                              
   select @updatestatus = 'C'                              
 end                               
 else                              
 begin                              
   select @updatestatus = 'F'                              
 end                                
 end                         
                          
  select @entity_id = entity_id  
 from #tempenttag etag inner join #tempenttagdef etdef                              
 on etag.entity_tag_id=etdef.oid and substring(etag.target_key1,3,len(etag.target_key1)-1) = @docid                              
                              
  select @entity_name=entity_name   
 from icts_entity_name where oid = @entity_id                              
  
 begin tran  
 begin try  
 if @entity_name ='Trade'                              
 begin                         
 select @evtdesc = 'T'                      
 update entity_tag set target_key1 = @updatestatus + @isbulkconfirm + @docid, target_key8='DONE',  
   trans_id = @trans_id where entity_tag_id = @entity_tag_id and key1 = @key1   
   and substring(target_key1,3,len(target_key1)-1)= @docid                            
 end                    
 else if @entity_name ='AllocationItem'                          
 begin                          
  select @evtdesc = 'AI'                      
 update entity_tag set target_key1 = @updatestatus + @isbulkconfirm + @docid, target_key8='DONE',  
   trans_id = @trans_id where entity_tag_id = @entity_tag_id and key1 = @key1 and key2 = @key2   
   and substring(target_key1,3,len(target_key1)-1)= @docid            
 end                             
 else if @entity_name ='Voucher'                              
 begin                            
  select @evtdesc = 'V'                      
 update entity_tag set target_key1 = @updatestatus + @isbulkconfirm + @docid, target_key8='DONE',  
   trans_id = @trans_id where entity_tag_id = @entity_tag_id and key1 = @key1   
   and substring(target_key1,3,len(target_key1)-1)= @docid                            
 end  
 end try  
 begin catch  
   if @@trancount > 0  
      rollback tran  
     print '=> Failed to update entity_tag table!'      
     print '==> ' + ERROR_MESSAGE()  
       goto endofscript  
 end catch  
 commit tran  
  
    /* event code */                  
  
 if @updatestatus = 'C'  
 begin  
 select @updatestatus='COMPLETED'  
 end  
 else  
 begin  
 select @updatestatus='FAILED'  
 end  
                      
 if exists (select 1 from #tempenttag where entity_tag_name in ('RF_T_E_STSDOCID','RF_AI_E_STSDOCID','RF_V_E_STSDOCID'))                    
 begin                    
  select @fax_mail='E'                    
 end                    
 else                    
 begin                    
  select @fax_mail='F'                    
 end                    
                   
 select @evtdesc = @evtdesc + '_' + @fax_mail  
 select @evtowner='RightFax'  
 select @updtrdcheck=''  
  
 select @event_num=isnull(max(event_num),0)+1 from event  
  
 --create event for all other cases except when trade updated       
  
if @target_key7 is not null     
begin      
  select @evtowner = @evtowner + '_' + @target_key7  
  
 if exists(select 1 from entity_tag   
  where entity_tag_id = @entity_tag_id   
  and target_key1 not like 'C%'  
  and target_key7 = @target_key7)    
 begin            
  select @updtrdcheck='N'    
 end           
 else    
 begin            
  select @updtrdcheck='Y'     
 end       
end    
             
 begin tran  
 begin try  
  insert into event(event_num,event_time,event_owner,event_code,event_asof_date,  
    event_owner_key1,event_owner_key2,event_description,event_controller,trans_id)  
       values (@event_num, getdate(), @evtowner, @updatestatus, getdate(), @key1, @key2, @faxormail,  
    @unique_id +'_'+ @evtdesc, @trans_id)  
 end try  
 begin catch  
   if @@trancount > 0  
      rollback tran  
     print '=> Failed to insert record in event table!'      
     print '==> ' + ERROR_MESSAGE()  
       goto endofscript  
 end catch  
 commit tran           
    
 if (@updatestatus = 'COMPLETED' and @isbulkconfirm = 'Y' and @updtrdcheck='Y')--update trade only for bulk confirm                              
 begin    
 begin tran  
 begin try         
  update trade set trade_status_code = 'CONFIRM', trans_id = @trans_id where trade_num = CONVERT(int, @key1)                    
 end try  
 begin catch  
   if @@trancount > 0  
      rollback tran  
  print '=> Failed to update trade table!'      
  print '==> ' + ERROR_MESSAGE()  
     goto endofscript  
 end catch  
 commit tran   
end    
end         
  
endofscript:  
  
 drop table #tempenttagdef                              
 drop table #tempenttag
GO
GRANT EXECUTE ON  [dbo].[usp_update_rightfax_status] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_update_rightfax_status', NULL, NULL
GO
