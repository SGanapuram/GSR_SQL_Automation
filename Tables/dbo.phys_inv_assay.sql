CREATE TABLE [dbo].[phys_inv_assay]
(
[exec_inv_num] [int] NOT NULL,
[assay_group_num] [int] NOT NULL,
[assay_date] [datetime] NOT NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spec_actual_value] [float] NULL,
[spec_actual_value_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_opt_val] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_provisional_val] [float] NULL,
[spec_provisional_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_provisiional_opt_val] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[use_in_formula_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[use_in_cost_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[use_in_pl_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[owner_assay_oid] [int] NULL,
[owner_assay] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
                                                                                                                                                 
create trigger [dbo].[phys_inv_assay_deltrg]                                                                                                              
on [dbo].[phys_inv_assay]                                                                                                                              
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
   if exists (select 1                                                                                                                           
              from master.dbo.sysprocesses (nolock)                                                                                              
              where spid = @@spid and                                                                                                            
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR                                    
                     program_name like 'Microsoft SQL Server Management Studio%') )                                                            
      raiserror ('You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.',10,1)            
                                                                                                                                                 
   rollback tran                                                                                                                                 
   return                                                                                                                                        
end                                                                                                                                              
                                                                                                                                                 
                                                                                                                                                 
   insert dbo.aud_phys_inv_assay(                                                                                                                  
		 exec_inv_num				
		,assay_group_num				   
		,assay_date					   
		,spec_code					   
		,spec_actual_value			   
		,spec_actual_value_text		   
		,spec_opt_val				   
		,spec_provisional_val		   
		,spec_provisional_text		   
		,spec_provisiional_opt_val	   
		,use_in_formula_ind			   
		,use_in_cost_ind				   
		,trans_id					   
		,resp_trans_id
		,use_in_pl_ind
		,owner_assay_oid
		,owner_assay
	)	
  select
		 d.exec_inv_num				
		,d.assay_group_num				   
		,d.assay_date					   
		,d.spec_code					   
		,d.spec_actual_value			   
		,d.spec_actual_value_text		   
		,d.spec_opt_val				   
		,d.spec_provisional_val		   
		,d.spec_provisional_text		   
		,d.spec_provisiional_opt_val	   
		,d.use_in_formula_ind			   
		,d.use_in_cost_ind				   
		,d.trans_id					   
		,@atrans_id
		,use_in_pl_ind
		,owner_assay_oid
		,owner_assay		
 from deleted d                                                                                                                                  
                                                                                                                                                 
/* AUDIT_CODE_END */                                                                                                                             
                                                                                                                                                 
declare @the_sequence       numeric(32, 0),                                                                                                      
        @the_tran_type      char(1),                                                                                                             
        @the_entity_name    varchar(30)                                                                                                          
                                                                                                                                                 
   select @the_entity_name = 'PhysInvAssay'                                                                                                   
                                                                                                                                                 
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
             convert(varchar(40),exec_inv_num),
             convert(varchar(40),assay_group_num),
             convert(varchar(40),assay_date),
             spec_code,
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
             convert(varchar(40),exec_inv_num),
             convert(varchar(40),assay_group_num),
             convert(varchar(40),assay_date),
             spec_code,                                                                                                                               
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
             convert(varchar(40),exec_inv_num),
             convert(varchar(40),assay_group_num),
             convert(varchar(40),assay_date),
             spec_code,                                                                                                                              
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
             convert(varchar(40),exec_inv_num),
             convert(varchar(40),assay_group_num),
             convert(varchar(40),assay_date),
             spec_code,                                                                                                                               
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
 
 create trigger [dbo].[phys_inv_assay_instrg]
 on [dbo].[phys_inv_assay]
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
 
    select @the_entity_name = 'PhysInvAssay'
 
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
              convert(varchar(40),exec_inv_num),
              convert(varchar(40),assay_group_num),
              convert(varchar(40),assay_date),
              spec_code,
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
              convert(varchar(40),exec_inv_num),
              convert(varchar(40),assay_group_num),
              convert(varchar(40),assay_date),
              spec_code,
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
              convert(varchar(40),exec_inv_num),
              convert(varchar(40),assay_group_num),
              convert(varchar(40),assay_date),
              spec_code,
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
              convert(varchar(40),exec_inv_num),
              convert(varchar(40),assay_group_num),
              convert(varchar(40),assay_date),
              spec_code,
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
 
create trigger [dbo].[phys_inv_assay_updtrg]
on [dbo].[phys_inv_assay]
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
   raiserror ('phys_inv_assay) The change needs to be attached with a new trans_id',10,1)
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
      raiserror ('(phys_inv_assay) New trans_id must be larger than original trans_id.You can use the the gen_new_transaction procedure to obtain a new trans_id.',10,1)
     
      rollback tran
      return
   end
end
 
if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id 				and
                i.exec_inv_num 		= d.exec_inv_num    and
				i.assay_group_num 	= d.assay_group_num and
				i.assay_date 		= d.assay_date      and
				i.spec_code 		= d.spec_code )
begin
  raiserror ('(phys_inv_assay) new trans_id must not be older than current trans_id.',10,1)
   rollback tran
   return
end
 
/* RECORD_STAMP_END */
 
if 	update(exec_inv_num) or 
	update(assay_group_num) or
	update(assay_date) or
	update(spec_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.exec_inv_num 		= d.exec_inv_num    and
									i.assay_group_num 	= d.assay_group_num and
									i.assay_date 		= d.assay_date      and
									i.spec_code 		= d.spec_code )
if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('phys_inv_assay: primary key can not be changed.',10,1)
      rollback tran
      return
   end
end
 
/* AUDIT_CODE_BEGIN */
 
if @dummy_update = 0
   insert dbo.aud_phys_inv_assay(
		 exec_inv_num				
		,assay_group_num				   
		,assay_date					   
		,spec_code					   
		,spec_actual_value			   
		,spec_actual_value_text		   
		,spec_opt_val				   
		,spec_provisional_val		   
		,spec_provisional_text		   
		,spec_provisiional_opt_val	   
		,use_in_formula_ind			   
		,use_in_cost_ind				   
		,trans_id					   
		,resp_trans_id
		,use_in_pl_ind
		,owner_assay_oid
		,owner_assay		
	)	
  select
		 d.exec_inv_num				
		,d.assay_group_num				   
		,d.assay_date					   
		,d.spec_code					   
		,d.spec_actual_value			   
		,d.spec_actual_value_text		   
		,d.spec_opt_val				   
		,d.spec_provisional_val		   
		,d.spec_provisional_text		   
		,d.spec_provisiional_opt_val	   
		,d.use_in_formula_ind			   
		,d.use_in_cost_ind				   
		,d.trans_id					   
		,i.trans_id
		,d.use_in_pl_ind	
		,d.owner_assay_oid
		,d.owner_assay		
   from deleted d, inserted i
   where 	d.exec_inv_num 		= i.exec_inv_num    and
			d.assay_group_num 	= i.assay_group_num and
			d.assay_date 		= i.assay_date      and
			d.spec_code 		= i.spec_code 
 
/* AUDIT_CODE_END */
 
declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)
 
   select @the_entity_name = 'PhysInvAssay'
 
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
             convert(varchar(40),exec_inv_num),
             convert(varchar(40),assay_group_num),
             convert(varchar(40),assay_date),
             spec_code,
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
             convert(varchar(40),exec_inv_num),
             convert(varchar(40),assay_group_num),
             convert(varchar(40),assay_date),
             spec_code,
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
             convert(varchar(40),exec_inv_num),
             convert(varchar(40),assay_group_num),
             convert(varchar(40),assay_date),
             spec_code,
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
             convert(varchar(40),exec_inv_num),
             convert(varchar(40),assay_group_num),
             convert(varchar(40),assay_date),
             spec_code,
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
ALTER TABLE [dbo].[phys_inv_assay] ADD CONSTRAINT [phys_inv_assay_pk] PRIMARY KEY CLUSTERED  ([exec_inv_num], [assay_group_num], [assay_date], [spec_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[phys_inv_assay] ADD CONSTRAINT [phys_inv_assay_fk1] FOREIGN KEY ([exec_inv_num]) REFERENCES [dbo].[exec_phys_inv] ([exec_inv_num])
GO
GRANT DELETE ON  [dbo].[phys_inv_assay] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[phys_inv_assay] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[phys_inv_assay] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[phys_inv_assay] TO [next_usr]
GO
