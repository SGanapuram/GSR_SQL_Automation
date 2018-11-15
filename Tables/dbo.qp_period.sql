CREATE TABLE [dbo].[qp_period]
(
[oid] [int] NOT NULL,
[qp_option_oid] [int] NULL,
[time_unit] [int] NULL,
[time_frame] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [DF__qp_period__time___7248800B] DEFAULT ('D'),
[app_cond] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [DF__qp_period__app_c__7430C87D] DEFAULT ('OF'),
[trigger_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[default_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[avg_time_unit] [int] NULL,
[avg_time_frame] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [DF__qp_period__avg_t__761910EF] DEFAULT ('D'),
[trigger_event] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trigger_event_desc] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
                                                                                                                                                          
create trigger [dbo].[qp_period_deltrg]                                                                                                                       
on [dbo].[qp_period]                                                                                                                                          
for delete                                                                                                                                                
as                                                                                                                                                        
declare @num_rows    int,                                                                                                                                 
        @errmsg      varchar(255),                                                                                                                        
        @atrans_id   int                                                                                                                                  
                                                                                                                                                          
select @num_rows = @@rowcount                                                                                                                             
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
   select @errmsg = '(qp_period) Failed to obtain a valid responsible trans_id.'                                                                        
   if exists (select 1                                                                                                                                    
              from master.dbo.sysprocesses (nolock)                                                                                                       
              where spid = @@spid and                                                                                                                     
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR                                             
                     program_name like 'Microsoft SQL Server Management Studio%') )                                                                     
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,10,1)                                                                                                                               
   rollback tran                                                                                                                                          
   return                                                                                                                                                 
end                                                                                                                                                       
                                                                                                                                                          
                                                                                                                                                          
insert dbo.aud_qp_period                                                                                                                                  
   (
	oid,
	qp_option_oid,
	time_unit,
	time_frame,
	app_cond,	
	default_ind,
	avg_time_unit,
	avg_time_frame,
	trigger_event,	
	trigger_event_desc,
	trans_id,
	resp_trans_id
	)                                                                                                                                                        
select                                                                                                                                                    
	d.oid,
	d.qp_option_oid,
	d.time_unit,
	d.time_frame,
	d.app_cond,
	d.default_ind,
	d.avg_time_unit,
	d.avg_time_frame,	
	d.trigger_event,	
	d.trigger_event_desc,
	d.trans_id,
	@atrans_id
from deleted d                                                                                                                                            
                                                                                                                                                          
/* AUDIT_CODE_END */                                                                                                                                      
                                                                                                                                                          
declare @the_sequence       numeric(32, 0),                                                                                                               
        @the_tran_type      char(1),                                                                                                                      
        @the_entity_name    varchar(30)                                                                                                                   
                                                                                                                                                          
   select @the_entity_name = 'QpPeriod'                                                                                                           
                                                                                                                                                          
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
                                                                                                                                                          
      if @the_tran_type != 'E'                                                                                                                          
      begin                                                                                                                                               
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
      where it.trans_id = @atrans_id and                                                                                                                  
            it.type != 'E'                                                                                                                              
                                                                                                                                                          
      /* END_TRANSACTION_TOUCH */                                                                                                                         
   end                                                                                                                                                    
                                                                                                                                                          
return                                                                                                                                                    
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                                                                         
CREATE trigger [dbo].[qp_period_instrg]                                                                   
on [dbo].[qp_period]                                                                                      
for insert                                                                                               
as                                                                                                       
declare @num_rows       int,                                                                             
        @count_num_rows int,                                                                             
        @errmsg         varchar(255)                                                                     
                                                                                                         
select @num_rows = @@rowcount                                                                            
if @num_rows = 0                                                                                         
   return                                                                                                
                                                                                                         
declare @the_sequence       numeric(32, 0),                                                              
        @the_tran_type      char(1),                                                                     
        @the_entity_name    varchar(30)                                                                  
                                                                                                         
   select @the_entity_name = 'QpPeriod'                                                              
                                                                                                         
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
             convert(varchar(40), oid),                                                                  
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
                                                                                                                             
create trigger [dbo].[qp_period_updtrg]                                                                                       
on [dbo].[qp_period]                                                                                                          
for update                                                                                                                   
as                                                                                                                           
declare @num_rows         int,                                                                                               
        @count_num_rows   int,                                                                                               
        @dummy_update     int,                                                                                               
        @errmsg           varchar(255)                                                                                       
                                                                                                                             
select @num_rows = @@rowcount                                                                                                
if @num_rows = 0                                                                                                             
   return                                                                                                                    
                                                                                                                             
select @dummy_update = 0                                                                                                     
                                                                                                                             
/* RECORD_STAMP_BEGIN */                                                                                                     
if not update(trans_id)                                                                                                      
begin                                                                                                                        
   raiserror ('(qp_period) The change needs to be attached with a new trans_id',10,1)                                   
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
      select @errmsg = '(qp_period) New trans_id must be larger than original trans_id.'                                
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'  
      raiserror (@errmsg,10,1)                                                                                               
      rollback tran                                                                                                          
      return                                                                                                                 
   end                                                                                                                       
end                                                                                                                          
                                                                                                                             
if exists (select * from inserted i, deleted d                                                                               
           where i.trans_id < d.trans_id and                                                                                 
                 i.oid = d.oid )                                                                                             
begin                                                                                                                        
   raiserror ('(qp_period) new trans_id must not be older than current trans_id.',10,1)                                 
   rollback tran                                                                                                             
   return                                                                                                                    
end                                                                                                                          
                                                                                                                             
/* RECORD_STAMP_END */                                                                                                       
                                                                                                                             
if update(oid)                                                                                                               
begin                                                                                                                        
   select @count_num_rows = (select count(*) from inserted i, deleted d                                                      
                             where i.oid = d.oid )                                                                           
   if (@count_num_rows = @num_rows)                                                                                          
   begin                                                                                                                     
      select @dummy_update = 1                                                                                               
   end                                                                                                                       
   else                                                                                                                      
   begin                                                                                                                     
      raiserror ('(qp_period) primary key can not be changed.',10,1)                                                    
      rollback tran                                                                                                          
      return                                                                                                                 
   end                                                                                                                       
end                                                                                                                          
                                                                                                                             
/* AUDIT_CODE_BEGIN */                                                                                                       
                                                                                                                             
if @dummy_update = 0                                                                                                         
   insert dbo.aud_qp_period                                                                                               
   (
	oid,
	qp_option_oid,
	time_unit,
	time_frame,
	app_cond,
	default_ind,
	avg_time_unit,
	avg_time_frame,
	trigger_event,	
	trigger_event_desc,
	trans_id,
	resp_trans_id
	)                                                                                                                           
select
	d.oid,
	d.qp_option_oid,
	d.time_unit,
	d.time_frame,
	d.app_cond,
	d.default_ind,
	d.avg_time_unit,
	d.avg_time_frame,
	d.trigger_event,	
	d.trigger_event_desc,	
	d.trans_id,
	i.trans_id
   from deleted d, inserted i                                                                                                
   where d.oid = i.oid                                                                                                       
                                                                                                                             
/* AUDIT_CODE_END */                                                                                                         
                                                                                                                             
declare @the_sequence       numeric(32, 0),                                                                                  
        @the_tran_type      char(1),                                                                                         
        @the_entity_name    varchar(30)                                                                                      
                                                                                                                             
   select @the_entity_name = 'QpPeriod'                                                                                 
                                                                                                                             
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
                                                                                                                             
      if @the_tran_type != 'E'                                                                                             
      begin                                                                                                                  
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
      where i.trans_id = it.trans_id and                                                                                     
            it.type != 'E'                                                                                                 
                                                                                                                             
      /* END_TRANSACTION_TOUCH */                                                                                            
   end                                                                                                                       
                                                                                                                             
return                                                                                                                       
GO
ALTER TABLE [dbo].[qp_period] ADD CONSTRAINT [CK__qp_period__app_c__7524ECB6] CHECK (([app_cond]='BEFORE' OR [app_cond]='AFTER' OR [app_cond]='OF'))
GO
ALTER TABLE [dbo].[qp_period] ADD CONSTRAINT [CK__qp_period__avg_t__770D3528] CHECK (([avg_time_frame]='M' OR [avg_time_frame]='W' OR [avg_time_frame]='D'))
GO
ALTER TABLE [dbo].[qp_period] ADD CONSTRAINT [CK__qp_period__time___733CA444] CHECK (([time_frame]='M' OR [time_frame]='W' OR [time_frame]='D'))
GO
ALTER TABLE [dbo].[qp_period] ADD CONSTRAINT [qp_period_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[qp_period] ADD CONSTRAINT [qp_period_fk1] FOREIGN KEY ([qp_option_oid]) REFERENCES [dbo].[qp_option] ([oid])
GO
GRANT DELETE ON  [dbo].[qp_period] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[qp_period] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[qp_period] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[qp_period] TO [next_usr]
GO
