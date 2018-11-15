CREATE TABLE [dbo].[strategy_execution]
(
[oid] [int] NOT NULL,
[real_port_num] [int] NOT NULL,
[shipment_num] [int] NULL,
[alloc_num] [int] NULL,
[strategy_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[max_strategy_detail_num] [smallint] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
                                                                                                                                                 
create trigger [dbo].[strategy_execution_deltrg]                                                                                                              
on [dbo].[strategy_execution]                                                                                                                              
for delete                                                                                                                                       
as                                                                                                                                               
declare @num_rows    int,                                                                                                                        
        @errmsg      varchar(255),                                                                                                               
        @atrans_id   int                                                                                                                         
                                                                                                                                                 
set @num_rows = @@rowcount                                                                                                                    
if @num_rows = 0                                                                                                                                 
   return                                                                                                                                        
                                                                                                                                                 
/* AUDIT_CODE_BEGIN */                                                                                                                           
select @atrans_id = max(trans_id)                                                                                                                
from dbo.icts_transaction WITH (INDEX=icts_transaction_idx4)                                                                                     
where spid = @@spid and                                                                                                                          
      tran_date >= (select top 1 login_time                                                                                                      
                    from master.dbo.sysprocesses (nolock)                                                                                        
                    where spid = @@spid)                                                                                                         
                                                                                                                                                 
if @atrans_id is null                                                                                                                            
begin                                                                                                                                            
   if exists (select 1                                                                                                                           
              from master.dbo.sysprocesses (nolock)                                                                                              
              where spid = @@spid and                                                                                                            
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR                                    
                     program_name like 'Microsoft SQL Server Management Studio%') )                                                            
      raiserror ('You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.',16,1)            
                                                                                                                                                 
   rollback tran                                                                                                                                 
   return                                                                                                                                        
end                                                                                                                                              
                                                                                                                                                 
                                                                                                                                                 
insert dbo.aud_strategy_execution
   (                                                                                                                  
    oid,						
    real_port_num,			
    shipment_num,			
    alloc_num,				
    strategy_status,			
    max_strategy_detail_num,	
    trans_id,				
    resp_trans_id	
   )
select
   d.oid,						
   d.real_port_num,			
   d.shipment_num,			
   d.alloc_num,				
   d.strategy_status,			
   d.max_strategy_detail_num,	
   d.trans_id,				
   @atrans_id                                                                                                    
from deleted d                                                                                                                                  
                                                                                                                                                 
/* AUDIT_CODE_END */                                                                                                                             
                                                                                                                                                 
declare @the_sequence       numeric(32, 0),                                                                                                      
        @the_tran_type      char(1),                                                                                                             
        @the_entity_name    varchar(30)                                                                                                          
                                                                                                                                                 
   set @the_entity_name = 'StrategyExecution'                                                                                                   
                                                                                                                                                 
   if @num_rows = 1                                                                                                                              
   begin                                                                                                                                         
      select @the_tran_type = it.type,                                                                                                           
             @the_sequence = it.sequence                                                                                                         
      from dbo.icts_transaction it WITH (NOLOCK)                                                                                                 
      where it.trans_id = @atrans_id                                                                                                             
                                                                                                                                                 
      /* BEGIN_ALS_RUN_TOUCH */                                                                                                                  
                                                                                                                                                 
      insert into dbo.als_run_touch                                                                                                              
         (als_module_group_id, operation, entity_name,key1,key2,                                                                                 
          key3,key4,key5,key6,key7,key8,trans_id,sequence)                                                                                       
      select a.als_module_group_id,                                                                                                              
             'D',                                                                                                                              
             @the_entity_name,                                                                                                                   
             convert(varchar(40),d.oid),                                                                                                    
             null,                                                                                                                               
             null,                                                                                                                               
             null,                                                                                                                               
             null,                                                                                                                               
             null,                                                                                                                               
             null,                                                                                                                               
             null,                                                                                                                               
             @atrans_id,                                                                                                                         
             @the_sequence                                                                                                                       
      from dbo.als_module_entity a WITH (NOLOCK),                                                                                                
           dbo.server_config sc WITH (NOLOCK),                                                                                                   
           deleted d                                                                                                                             
      where a.als_module_group_id = sc.als_module_group_id AND                                                                                   
            ( ( ((sc.trans_type_mask &  1) =  1) and (@the_tran_type = 'E') ) OR                                                               
              ( ((sc.trans_type_mask &  2) =  2) and (@the_tran_type = 'U') ) OR                                                               
              ( ((sc.trans_type_mask &  4) =  4) and (@the_tran_type = 'S') ) OR                                                               
              ( ((sc.trans_type_mask &  8) =  8) and (@the_tran_type = 'P') ) OR                                                               
              ( ((sc.trans_type_mask & 16) = 16) and (@the_tran_type = 'I') ) OR                                                               
              ( ((sc.trans_type_mask & 32) = 32) and (@the_tran_type = 'A') )                                                                  
            ) AND                                                                                                                                
            (a.operation_type_mask & 4) = 4 AND                                                                                                  
            a.entity_name = @the_entity_name                                                                                                     
                                                                                                                                                 
      /* END_ALS_RUN_TOUCH */                                                                                                                    
                                                                                                                                                 
      /* BEGIN_TRANSACTION_TOUCH */                                                                                                              
                                                                                                                                                 
      insert dbo.transaction_touch                                                                                                               
      select 'DELETE',                                                                                                                         
             @the_entity_name,                                                                                                                   
             'DIRECT',                                                                                                                         
             convert(varchar(40),d.oid),                                                                                                    
             null,                                                                                                                               
             null,                                                                                                                               
             null,                                                                                                                               
             null,                                                                                                                               
             null,                                                                                                                               
             null,                                                                                                                               
             null,                                                                                                                               
             @atrans_id,                                                                                                                         
             @the_sequence                                                                                                                       
      from deleted d                                                                                                                             
                                                                                                                                                 
      /* END_TRANSACTION_TOUCH */                                                                                                                
   end                                                                                                                                           
   else                                                                                                                                          
   begin  /* if @num_rows > 1 */                                                                                                                 
      /* BEGIN_ALS_RUN_TOUCH */                                                                                                                  
                                                                                                                                                 
      insert into dbo.als_run_touch                                                                                                              
         (als_module_group_id, operation, entity_name,key1,key2,                                                                                 
          key3,key4,key5,key6,key7,key8,trans_id,sequence)                                                                                       
      select a.als_module_group_id,                                                                                                              
             'D',                                                                                                                              
             @the_entity_name,                                                                                                                   
             convert(varchar(40),d.oid),                                                                                                    
             null,                                                                                                                               
             null,                                                                                                                               
             null,                                                                                                                               
             null,                                                                                                                               
             null,                                                                                                                               
             null,                                                                                                                               
             null,                                                                                                                               
             @atrans_id,                                                                                                                         
             it.sequence                                                                                                                         
      from dbo.als_module_entity a WITH (NOLOCK),                                                                                                
           dbo.server_config sc WITH (NOLOCK),                                                                                                   
           deleted d,                                                                                                                            
           dbo.icts_transaction it WITH (NOLOCK)                                                                                                 
      where a.als_module_group_id = sc.als_module_group_id AND                                                                                   
            ( ( ((sc.trans_type_mask &  1) =  1) and (it.type = 'E') ) OR                                                                      
              ( ((sc.trans_type_mask &  2) =  2) and (it.type = 'U') ) OR                                                                      
              ( ((sc.trans_type_mask &  4) =  4) and (it.type = 'S') ) OR                                                                      
              ( ((sc.trans_type_mask &  8) =  8) and (it.type = 'P') ) OR                                                                      
              ( ((sc.trans_type_mask & 16) = 16) and (it.type = 'I') ) OR                                                                      
              ( ((sc.trans_type_mask & 32) = 32) and (it.type = 'A') )                                                                         
            ) AND                                                                                                                                
            (a.operation_type_mask & 4) = 4 AND                                                                                                  
            a.entity_name = @the_entity_name AND                                                                                                 
            it.trans_id = @atrans_id                                                                                                             
                                                                                                                                                 
      /* END_ALS_RUN_TOUCH */                                                                                                                    
                                                                                                                                                 
      /* BEGIN_TRANSACTION_TOUCH */                                                                                                              
                                                                                                                                                 
      insert dbo.transaction_touch                                                                                                               
      select 'DELETE',                                                                                                                         
             @the_entity_name,                                                                                                                   
             'DIRECT',                                                                                                                         
             convert(varchar(40),d.oid),                                                                                                    
             null,                                                                                                                               
             null,                                                                                                                               
             null,                                                                                                                               
             null,                                                                                                                               
             null,                                                                                                                               
             null,                                                                                                                               
             null,                                                                                                                               
             @atrans_id,                                                                                                                         
             it.sequence                                                                                                                         
      from dbo.icts_transaction it WITH (NOLOCK),                                                                                                
           deleted d                                                                                                                             
      where it.trans_id = @atrans_id                                                                                                             
                                                                                                                                                 
      /* END_TRANSACTION_TOUCH */                                                                                                                
   end                                                                                                                                           
                                                                                                                                                 
return                                                                                                                                           
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
 create trigger [dbo].[strategy_execution_instrg]
 on [dbo].[strategy_execution]
 for insert
 as
 declare @num_rows       int,
         @count_num_rows int,
         @errmsg         varchar(255)
 
 set @num_rows = @@rowcount
 if @num_rows = 0
    return
 
 declare @the_sequence       numeric(32, 0),
         @the_tran_type      char(1),
         @the_entity_name    varchar(30)
 
    set @the_entity_name = 'StrategyExecution'
 
    if @num_rows = 1
    begin
       select @the_tran_type = it.type,
              @the_sequence = it.sequence
       from dbo.icts_transaction it WITH (NOLOCK),
            inserted i
       where it.trans_id = i.trans_id
 
       /* BEGIN_ALS_RUN_TOUCH */
 
       insert into dbo.als_run_touch 
          (als_module_group_id, operation, entity_name,key1,key2,
           key3,key4,key5,key6,key7,key8,trans_id,sequence)
       select a.als_module_group_id,
              'I',
              @the_entity_name,
              convert(varchar(40),oid),
              null,
              null,
              null,
              null,
              null,
              null,
              null,
              i.trans_id,
              @the_sequence
       from dbo.als_module_entity a WITH (NOLOCK),
            dbo.server_config sc WITH (NOLOCK),
            inserted i
       where a.als_module_group_id = sc.als_module_group_id AND
             ( ( ((sc.trans_type_mask &  1) =  1) and (@the_tran_type = 'E') ) OR
               ( ((sc.trans_type_mask &  2) =  2) and (@the_tran_type = 'U') ) OR
               ( ((sc.trans_type_mask &  4) =  4) and (@the_tran_type = 'S') ) OR
               ( ((sc.trans_type_mask &  8) =  8) and (@the_tran_type = 'P') ) OR
               ( ((sc.trans_type_mask & 16) = 16) and (@the_tran_type = 'I') ) OR
               ( ((sc.trans_type_mask & 32) = 32) and (@the_tran_type = 'A') )
             ) AND
             (a.operation_type_mask & 1) = 1 AND
             a.entity_name = @the_entity_name
 
       /* END_ALS_RUN_TOUCH */
 
       /* BEGIN_TRANSACTION_TOUCH */
 
       insert dbo.transaction_touch
       select 'INSERT',
              @the_entity_name,
              'DIRECT',
              convert(varchar(40),oid),
              null,
              null,
              null,
              null,
              null,
              null,
              null,
              i.trans_id,
              @the_sequence
       from inserted i
 
       /* END_TRANSACTION_TOUCH */
    end
    else
    begin  /* if @num_rows > 1 */
       /* BEGIN_ALS_RUN_TOUCH */
 
       insert into dbo.als_run_touch 
          (als_module_group_id, operation, entity_name,key1,key2,
           key3,key4,key5,key6,key7,key8,trans_id,sequence)
       select a.als_module_group_id,
              'I',
              @the_entity_name,
              convert(varchar(40),oid),
              null,
              null,
              null,
              null,
              null,
              null,
              null,
              i.trans_id,
              it.sequence
       from dbo.als_module_entity a WITH (NOLOCK),
            dbo.server_config sc WITH (NOLOCK),
            inserted i,
            dbo.icts_transaction it WITH (NOLOCK)
       where a.als_module_group_id = sc.als_module_group_id AND
             ( ( ((sc.trans_type_mask &  1) =  1) and (it.type = 'E') ) OR
               ( ((sc.trans_type_mask &  2) =  2) and (it.type = 'U') ) OR
               ( ((sc.trans_type_mask &  4) =  4) and (it.type = 'S') ) OR
               ( ((sc.trans_type_mask &  8) =  8) and (it.type = 'P') ) OR
               ( ((sc.trans_type_mask & 16) = 16) and (it.type = 'I') ) OR
               ( ((sc.trans_type_mask & 32) = 32) and (it.type = 'A') )
             ) AND
             (a.operation_type_mask & 1) = 1 AND
             a.entity_name = @the_entity_name AND
             i.trans_id = it.trans_id
 
       /* END_ALS_RUN_TOUCH */
 
       /* BEGIN_TRANSACTION_TOUCH */
 
       insert dbo.transaction_touch
       select 'INSERT',
              @the_entity_name,
              'DIRECT',
              convert(varchar(40),oid),
              null,
              null,
              null,
              null,
              null,
              null,
              null,
              i.trans_id,
              it.sequence
       from dbo.icts_transaction it WITH (NOLOCK),
            inserted i
       where i.trans_id = it.trans_id
 
       /* END_TRANSACTION_TOUCH */
    end
 
 return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
create trigger [dbo].[strategy_execution_updtrg]
on [dbo].[strategy_execution]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errmsg           varchar(255)
 
set @num_rows = @@rowcount
if @num_rows = 0
   return
 
set @dummy_update = 0
 
/* RECORD_STAMP_BEGIN */
if not update(trans_id)
begin
   raiserror ('strategy_execution) The change needs to be attached with a new trans_id',16,1)
   rollback tran
   return
end
 
/* added by Peter Lo  Sep-4-2002 */
if exists (select 1
           from master.dbo.sysprocesses
           where spid = @@spid and
                (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                 program_name like 'Microsoft SQL Server Management Studio%') )
begin
   if (select count(*) from inserted, deleted where inserted.trans_id <= deleted.trans_id) > 0
   begin
      raiserror ('(strategy_execution) New trans_id must be larger than original trans_id.You can use the the gen_new_transaction procedure to obtain a new trans_id.',16,1)
     
      rollback tran
      return
   end
end
 
if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid)
begin
   raiserror ('(strategy_execution) new trans_id must not be older than current trans_id.',16,1)
   rollback tran
   return
end
 
/* RECORD_STAMP_END */
 
if update(oid)
begin
   set @count_num_rows = (select count(*) from inserted i, deleted d
                          where i.oid = d.oid)
   if (@count_num_rows = @num_rows)
      set @dummy_update = 1
   else
   begin
      raiserror ('strategy_execution: primary key can not be changed.',16,1)
      rollback tran
      return
   end
end
 
/* AUDIT_CODE_BEGIN */
 
if @dummy_update = 0
   insert dbo.aud_strategy_execution
      (
	   oid,						
       real_port_num,			
       shipment_num,			
       alloc_num,				
       strategy_status,			
       max_strategy_detail_num,	
       trans_id,				
       resp_trans_id	
	  )
   select
      d.oid,						
      d.real_port_num,			
      d.shipment_num,			
      d.alloc_num,				
      d.strategy_status,			
      d.max_strategy_detail_num,
      d.trans_id,				
      i.trans_id	
   from deleted d, inserted i
   where d.oid = i.oid
 
/* AUDIT_CODE_END */
 
declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)
 
   set @the_entity_name = 'StrategyExecution'
 
   if @num_rows = 1
   begin
      select @the_tran_type = it.type,
             @the_sequence = it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           inserted i
      where it.trans_id = i.trans_id
 
      /* BEGIN_ALS_RUN_TOUCH */
 
      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'U',
             @the_entity_name,
             convert(varchar(40),oid),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             @the_sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
           inserted i
      where a.als_module_group_id = sc.als_module_group_id AND
            ( ( ((sc.trans_type_mask &  1) =  1) and (@the_tran_type = 'E') ) OR
              ( ((sc.trans_type_mask &  2) =  2) and (@the_tran_type = 'U') ) OR
              ( ((sc.trans_type_mask &  4) =  4) and (@the_tran_type = 'S') ) OR
              ( ((sc.trans_type_mask &  8) =  8) and (@the_tran_type = 'P') ) OR
              ( ((sc.trans_type_mask & 16) = 16) and (@the_tran_type = 'I') ) OR
              ( ((sc.trans_type_mask & 32) = 32) and (@the_tran_type = 'A') )
            ) AND
            (a.operation_type_mask & 2) = 2 AND
            a.entity_name = @the_entity_name
 
      /* END_ALS_RUN_TOUCH */
 
      /* BEGIN_TRANSACTION_TOUCH */
 
      insert dbo.transaction_touch
      select 'UPDATE',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40),oid),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             @the_sequence
      from inserted i
 
      /* END_TRANSACTION_TOUCH */
   end
   else
   begin  /* if @num_rows > 1 */
      /* BEGIN_ALS_RUN_TOUCH */
 
      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'U',
             @the_entity_name,
             convert(varchar(40),oid),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
           inserted i,
           dbo.icts_transaction it WITH (NOLOCK)
      where a.als_module_group_id = sc.als_module_group_id AND
            ( ( ((sc.trans_type_mask &  1) =  1) and (it.type = 'E') ) OR
              ( ((sc.trans_type_mask &  2) =  2) and (it.type = 'U') ) OR
              ( ((sc.trans_type_mask &  4) =  4) and (it.type = 'S') ) OR
              ( ((sc.trans_type_mask &  8) =  8) and (it.type = 'P') ) OR
              ( ((sc.trans_type_mask & 16) = 16) and (it.type = 'I') ) OR
              ( ((sc.trans_type_mask & 32) = 32) and (it.type = 'A') )
            ) AND
            (a.operation_type_mask & 2) = 2 AND
            a.entity_name = @the_entity_name AND
            i.trans_id = it.trans_id
 
      /* END_ALS_RUN_TOUCH */
 
      /* BEGIN_TRANSACTION_TOUCH */
 
      insert dbo.transaction_touch
      select 'UPDATE',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40),oid),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           inserted i
      where i.trans_id = it.trans_id
 
      /* END_TRANSACTION_TOUCH */
   end
 
return
GO
ALTER TABLE [dbo].[strategy_execution] ADD CONSTRAINT [strategy_execution_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[strategy_execution] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[strategy_execution] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[strategy_execution] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[strategy_execution] TO [next_usr]
GO
