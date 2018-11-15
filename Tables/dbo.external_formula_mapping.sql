CREATE TABLE [dbo].[external_formula_mapping]
(
[oid] [int] NOT NULL,
[quote_string] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_source] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_key] [int] NULL,
[price_point] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[ui_index] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ui_source] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ui_point] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ui_formula_str] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[element_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[element_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[per_spec_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
                                                                                                                                                          
create trigger [dbo].[external_formula_mapping_deltrg]                                                                                                                       
on [dbo].[external_formula_mapping]                                                                                                                                          
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
   set @errmsg = '(external_formula_mapping) Failed to obtain a valid responsible trans_id.'                                                                        
   if exists (select 1                                                                                                                                    
              from master.dbo.sysprocesses (nolock)                                                                                                       
              where spid = @@spid and                                                                                                                     
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR                                             
                     program_name like 'Microsoft SQL Server Management Studio%') )                                                                     
      set @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror(@errmsg,16,1)                                                                                                                               
   rollback tran                                                                                                                                          
   return                                                                                                                                                 
end                                                                                                                                                       
                                                                                                                                                          
                                                                                                                                                          
insert dbo.aud_external_formula_mapping                                                                                                                                  
(
	oid,
	quote_string,
	price_source,
	commkt_key,
	price_point,
	trans_id,
	resp_trans_id,
	ui_index,
	ui_source,
	ui_point,
	ui_formula_str,
	spec_code,
	spec_uom_code,
	per_spec_uom_code

)                                                                                                                                                        
select                                                                                                                                                    
	d.oid,
	d.quote_string,
	d.price_source,
	d.commkt_key,
	d.price_point,
	d.trans_id,
	@atrans_id,
	d.ui_index,
	d.ui_source,
	d.ui_point,
	d.ui_formula_str,
	d.spec_code,
	d.spec_uom_code,
	d.per_spec_uom_code
from deleted d                                                                                                                                            
                                                                                                                                                          
/* AUDIT_CODE_END */                                                                                                                                      
                                                                                                                                                          
declare @the_sequence       numeric(32, 0),                                                                                                               
        @the_tran_type      char(1),                                                                                                                      
        @the_entity_name    varchar(30)                                                                                                                   
                                                                                                                                                          
   set @the_entity_name = 'ExternalFormulaMapping'                                                                                                           
                                                                                                                                                          
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
                                                                                                         
create trigger [dbo].[external_formula_mapping_instrg]                                                                   
on [dbo].[external_formula_mapping]                                                                                      
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
                                                                                                         
   set @the_entity_name = 'ExternalFormulaMapping'                                                             
                                                                                                         
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
                                                                                                                             
create trigger [dbo].[external_formula_mapping_updtrg]                                                                                       
on [dbo].[external_formula_mapping]                                                                                                          
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
   raiserror ('(external_formula_mapping) The change needs to be attached with a new trans_id',16,1)                                   
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
      set @errmsg = '(external_formula_mapping) New trans_id must be larger than original trans_id.'                                
      set @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'  
      raiserror(@errmsg,16,1)                                                                                               
      rollback tran                                                                                                          
      return                                                                                                                 
   end                                                                                                                       
end                                                                                                                          
                                                                                                                             
if exists (select * from inserted i, deleted d                                                                               
           where i.trans_id < d.trans_id and                                                                                 
                 i.oid = d.oid)                                                                                             
begin                                                                                                                        
   raiserror ('(external_formula_mapping) new trans_id must not be older than current trans_id.',16,1)                                 
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
      raiserror ('(external_formula_mapping) primary key can not be changed.',16,1)                                                    
      rollback tran                                                                                                          
      return                                                                                                                 
   end                                                                                                                       
end                                                                                                                          
                                                                                                                             
/* AUDIT_CODE_BEGIN */                                                                                                       
                                                                                                                             
if @dummy_update = 0                                                                                                         
   insert dbo.aud_external_formula_mapping                                                                                                                                  
     (
	  oid,
	  quote_string,
	  price_source,
	  commkt_key,
	  price_point,
	  trans_id,
	  resp_trans_id,
	  ui_index,
	  ui_source,
	  ui_point,
	  ui_formula_str,
	  spec_code,
	  spec_uom_code,
	  per_spec_uom_code	
     )                                                                                                                           
  select
	 d.oid,
	 d.quote_string,
	 d.price_source,
	 d.commkt_key,
	 d.price_point,
	 d.trans_id,
	 i.trans_id,
	 d.ui_index,
	 d.ui_source,
	 d.ui_point,
	 d.ui_formula_str,
	 d.spec_code,
	 d.spec_uom_code,
	 d.per_spec_uom_code	
  from deleted d, inserted i                                                                                                
  where d.oid = i.oid                                                                                                       
                                                                                                                             
/* AUDIT_CODE_END */                                                                                                         
                                                                                                                             
declare @the_sequence       numeric(32, 0),                                                                                  
        @the_tran_type      char(1),                                                                                         
        @the_entity_name    varchar(30)                                                                                      
                                                                                                                             
   set @the_entity_name = 'PricingRule'                                                                                 
                                                                                                                             
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
ALTER TABLE [dbo].[external_formula_mapping] ADD CONSTRAINT [external_formula_mapping_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[external_formula_mapping] ADD CONSTRAINT [external_formula_mapping_fk1] FOREIGN KEY ([price_source]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
ALTER TABLE [dbo].[external_formula_mapping] ADD CONSTRAINT [external_formula_mapping_fk2] FOREIGN KEY ([commkt_key]) REFERENCES [dbo].[commodity_market] ([commkt_key])
GO
ALTER TABLE [dbo].[external_formula_mapping] ADD CONSTRAINT [external_formula_mapping_fk3] FOREIGN KEY ([ui_source]) REFERENCES [dbo].[market] ([mkt_code])
GO
ALTER TABLE [dbo].[external_formula_mapping] ADD CONSTRAINT [external_formula_mapping_fk4] FOREIGN KEY ([spec_code]) REFERENCES [dbo].[specification] ([spec_code])
GO
ALTER TABLE [dbo].[external_formula_mapping] ADD CONSTRAINT [external_formula_mapping_fk5] FOREIGN KEY ([spec_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[external_formula_mapping] ADD CONSTRAINT [external_formula_mapping_fk6] FOREIGN KEY ([per_spec_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[external_formula_mapping] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[external_formula_mapping] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[external_formula_mapping] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[external_formula_mapping] TO [next_usr]
GO
