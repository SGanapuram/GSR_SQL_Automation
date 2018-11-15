CREATE TABLE [dbo].[phys_inv_time_sheet]
(
[oid] [int] NOT NULL,
[exec_inv_num] [int] NOT NULL,
[logistic_event_order_num] [smallint] NOT NULL,
[logistic_event] [varchar] (55) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[document_id] [int] NULL,
[event_from_date] [datetime] NULL,
[from_date_actual_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_to_date] [datetime] NULL,
[to_date_actual_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[short_comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[trans_id] [int] NOT NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
                                                                                                                                                 
create trigger [dbo].[phys_inv_time_sheet_deltrg]                                                                                                              
on [dbo].[phys_inv_time_sheet]                                                                                                                              
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
                                                                                                                                                 
                                                                                                                                                 
   insert dbo.aud_phys_inv_time_sheet(                                                                                                                  
		 oid						
		,exec_inv_num			   
		,logistic_event_order_num   
		,logistic_event			   
		,loc_code				   
		,mot_code				   
		,document_id				   
		,event_from_date			   
		,from_date_actual_ind	   
		,event_to_date			   
		,to_date_actual_ind		   
		,short_comment			   
		,cmnt_num
		,spec_code
		,trans_id				   
		,resp_trans_id
	)
  select
		 d.oid						
		,d.exec_inv_num			   
		,d.logistic_event_order_num   
		,d.logistic_event			   
		,d.loc_code				   
		,d.mot_code				   
		,d.document_id				   
		,d.event_from_date			   
		,d.from_date_actual_ind	   
		,d.event_to_date			   
		,d.to_date_actual_ind		   
		,d.short_comment			   
		,d.cmnt_num
		,d.spec_code
		,d.trans_id				   
		,@atrans_id                                                                                                       
 from deleted d                                                                                                                                  
                                                                                                                                                 
/* AUDIT_CODE_END */                                                                                                                             
                                                                                                                                                 
declare @the_sequence       numeric(32, 0),                                                                                                      
        @the_tran_type      char(1),                                                                                                             
        @the_entity_name    varchar(30)                                                                                                          
                                                                                                                                                 
   select @the_entity_name = 'PhysInvTimeSheet'                                                                                                   
                                                                                                                                                 
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
 
 create trigger [dbo].[phys_inv_time_sheet_instrg]
 on [dbo].[phys_inv_time_sheet]
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
 
    select @the_entity_name = 'PhysInvTimeSheet'
 
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
 
create trigger [dbo].[phys_inv_time_sheet_updtrg]
on [dbo].[phys_inv_time_sheet]
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
   raiserror ('phys_inv_time_sheet) The change needs to be attached with a new trans_id',10,1)
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
      raiserror ('(phys_inv_time_sheet) New trans_id must be larger than original trans_id.You can use the the gen_new_transaction procedure to obtain a new trans_id.',10,1)
     
      rollback tran
      return
   end
end
 
if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid )
begin
  raiserror ('(phys_inv_time_sheet) new trans_id must not be older than current trans_id.',10,1)
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
      raiserror ('phys_inv_time_sheet: primary key can not be changed.',10,1)
      rollback tran
      return
   end
end
 
/* AUDIT_CODE_BEGIN */
 
if @dummy_update = 0
   insert dbo.aud_phys_inv_time_sheet(
		 oid						
		,exec_inv_num			   
		,logistic_event_order_num   
		,logistic_event			   
		,loc_code				   
		,mot_code				   
		,document_id				   
		,event_from_date			   
		,from_date_actual_ind	   
		,event_to_date			   
		,to_date_actual_ind		   
		,short_comment			   
		,cmnt_num
		,spec_code
		,trans_id				   
		,resp_trans_id
	)
  select
		 d.oid						
		,d.exec_inv_num			   
		,d.logistic_event_order_num   
		,d.logistic_event			   
		,d.loc_code				   
		,d.mot_code				   
		,d.document_id				   
		,d.event_from_date			   
		,d.from_date_actual_ind	   
		,d.event_to_date			   
		,d.to_date_actual_ind		   
		,d.short_comment			   
		,d.cmnt_num	
		,d.spec_code
		,d.trans_id				   
		,i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid
 
/* AUDIT_CODE_END */
 
declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)
 
   select @the_entity_name = 'PhysInvTimeSheet'
 
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
ALTER TABLE [dbo].[phys_inv_time_sheet] ADD CONSTRAINT [phys_inv_time_sheet_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[phys_inv_time_sheet] ADD CONSTRAINT [phys_inv_time_sheet_fk1] FOREIGN KEY ([exec_inv_num]) REFERENCES [dbo].[exec_phys_inv] ([exec_inv_num])
GO
ALTER TABLE [dbo].[phys_inv_time_sheet] ADD CONSTRAINT [phys_inv_time_sheet_fk2] FOREIGN KEY ([loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[phys_inv_time_sheet] ADD CONSTRAINT [phys_inv_time_sheet_fk3] FOREIGN KEY ([spec_code]) REFERENCES [dbo].[specification] ([spec_code])
GO
GRANT DELETE ON  [dbo].[phys_inv_time_sheet] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[phys_inv_time_sheet] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[phys_inv_time_sheet] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[phys_inv_time_sheet] TO [next_usr]
GO
