CREATE TABLE [dbo].[exec_phys_inv]
(
[exec_inv_num] [int] NOT NULL,
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[version_num] [varchar] (55) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_execution_oid] [int] NOT NULL,
[conc_del_item_oid] [int] NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[brand_id] [int] NULL,
[del_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[del_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[wsmd_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[real_port_num] [int] NOT NULL,
[pos_num] [int] NULL,
[inv_proj_qty] [float] NULL,
[inv_actual_qty] [float] NULL,
[inv_qty_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_sec_proj_qty] [float] NULL,
[inv_sec_actual_qty] [float] NULL,
[inv_adj_qty] [float] NULL,
[inv_sec_adj_qty] [float] NULL,
[inv_unit_price] [float] NULL,
[inv_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_price_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[inv_matched_qty] [float] NULL,
[inv_matched_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_sec_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
                                                                                                                                                 
create trigger [dbo].[exec_phys_inv_deltrg]                                                                                                              
on [dbo].[exec_phys_inv]                                                                                                                              
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
                                                                                                                                                                                                                                                                                                  
insert dbo.aud_exec_phys_inv
   (                                                                                                                  
	exec_inv_num,			
	trade_num,				
	order_num,				
	item_num,				
	version_num,				
	contract_execution_oid,	
    conc_del_item_oid,		
    cmdty_code,				
    brand_id,				
    del_term_code,			
    del_loc_code,			
    wsmd_loc_code,			
    real_port_num,			
    pos_num,					
    inv_proj_qty,			
    inv_actual_qty,			
    inv_qty_uom_code,		
	inv_sec_proj_qty,		
	inv_sec_actual_qty,		
    inv_adj_qty,				
    inv_sec_adj_qty,			
    inv_unit_price,			
    inv_price_curr_code,		
    inv_price_uom_code,		
    trans_id,			
    resp_trans_id,
    inv_matched_qty,
    inv_matched_qty_uom_code,
    inv_sec_qty_uom_code,
    p_s_ind	 
   )
select
   d.exec_inv_num,			
   d.trade_num,				
   d.order_num,				
   d.item_num,				
   d.version_num,				
   d.contract_execution_oid,	
   d.conc_del_item_oid,		
   d.cmdty_code,				
   d.brand_id,				
   d.del_term_code,			
   d.del_loc_code,			
   d.wsmd_loc_code,			
   d.real_port_num,			
   d.pos_num,					
   d.inv_proj_qty,			
   d.inv_actual_qty,			
   d.inv_qty_uom_code,		
   d.inv_sec_proj_qty,		
   d.inv_sec_actual_qty,		
   d.inv_adj_qty,				
   d.inv_sec_adj_qty,			
   d.inv_unit_price,			
   d.inv_price_curr_code,		
   d.inv_price_uom_code,		
   d.trans_id,				
   @atrans_id,
   d.inv_matched_qty,
   d.inv_matched_qty_uom_code,
   d.inv_sec_qty_uom_code,
   p_s_ind	
from deleted d                                                                                                                                  
                                                                                                                                                 
/* AUDIT_CODE_END */                                                                                                                             
                                                                                                                                                 
declare @the_sequence       numeric(32, 0),                                                                                                      
        @the_tran_type      char(1),                                                                                                             
        @the_entity_name    varchar(30)                                                                                                          
                                                                                                                                                 
   set @the_entity_name = 'ExecPhysInv'                                                                                                   
                                                                                                                                                 
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
             convert(varchar(40),d.exec_inv_num),                                                                                                    
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
             convert(varchar(40),d.exec_inv_num),                                                                                                    
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
             convert(varchar(40),d.exec_inv_num),                                                                                                    
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
             convert(varchar(40),d.exec_inv_num),                                                                                                    
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
 
create trigger [dbo].[exec_phys_inv_instrg]
on [dbo].[exec_phys_inv]
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
 
    set @the_entity_name = 'ExecPhysInv'
 
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
              exec_inv_num,
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
              exec_inv_num,
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
              exec_inv_num,
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
              exec_inv_num,
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
 
create trigger [dbo].[exec_phys_inv_updtrg]
on [dbo].[exec_phys_inv]
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
   raiserror ('exec_phys_inv) The change needs to be attached with a new trans_id',16,1)
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
      raiserror ('(exec_phys_inv) New trans_id must be larger than original trans_id.You can use the the gen_new_transaction procedure to obtain a new trans_id.',16,1)
     
      rollback tran
      return
   end
end
 
if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.exec_inv_num = d.exec_inv_num)
begin
   raiserror ('(exec_phys_inv) new trans_id must not be older than current trans_id.',16,1)
   rollback tran
   return
end
 
/* RECORD_STAMP_END */
 
if update(exec_inv_num)
begin
   set @count_num_rows = (select count(*) from inserted i, deleted d
                          where i.exec_inv_num = d.exec_inv_num)
   if (@count_num_rows = @num_rows)
      set @dummy_update = 1
   else
   begin
      raiserror ('exec_phys_inv: primary key can not be changed.',16,1)
      rollback tran
      return
   end
end
 
/* AUDIT_CODE_BEGIN */
 
if @dummy_update = 0
   insert dbo.aud_exec_phys_inv
   (
	  exec_inv_num,			
	  trade_num,				
	  order_num,				
	  item_num,				
	  version_num,				
	  contract_execution_oid,	
	  conc_del_item_oid,		
	  cmdty_code,				
	  brand_id,				
	  del_term_code,			
	  del_loc_code,			
	  wsmd_loc_code,			
	  real_port_num,			
	  pos_num,					
	  inv_proj_qty,			
	  inv_actual_qty,			
	  inv_qty_uom_code,		
	  inv_sec_proj_qty,		
	  inv_sec_actual_qty,		
	  inv_adj_qty,				
	  inv_sec_adj_qty,			
	  inv_unit_price,			
	  inv_price_curr_code,		
	  inv_price_uom_code,		
	  trans_id,			
	  resp_trans_id,
	  inv_matched_qty,
	  inv_matched_qty_uom_code,
	  inv_sec_qty_uom_code,
      p_s_ind	 
	)
   select
	  d.exec_inv_num,			
	  d.trade_num,				
	  d.order_num,				
	  d.item_num,				
	  d.version_num,				
	  d.contract_execution_oid,	
	  d.conc_del_item_oid,		
	  d.cmdty_code,				
	  d.brand_id,				
	  d.del_term_code,			
	  d.del_loc_code,			
	  d.wsmd_loc_code,			
	  d.real_port_num,			
	  d.pos_num,					
	  d.inv_proj_qty,			
	  d.inv_actual_qty,			
	  d.inv_qty_uom_code,		
	  d.inv_sec_proj_qty,		
	  d.inv_sec_actual_qty,		
	  d.inv_adj_qty,				
	  d.inv_sec_adj_qty,			
	  d.inv_unit_price,			
	  d.inv_price_curr_code,		
	  d.inv_price_uom_code,		
	  d.trans_id,				
	  i.trans_id,
	  d.inv_matched_qty,
	  d.inv_matched_qty_uom_code,
	  d.inv_sec_qty_uom_code,
      d.p_s_ind	 
   from deleted d, inserted i
   where d.exec_inv_num = i.exec_inv_num
 
/* AUDIT_CODE_END */
 
declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)
 
   set @the_entity_name = 'ExecPhysInv'
 
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
             convert(varchar(40),exec_inv_num),
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
             convert(varchar(40),exec_inv_num),
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
             convert(varchar(40),exec_inv_num),
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
ALTER TABLE [dbo].[exec_phys_inv] ADD CONSTRAINT [exec_phys_inv_pk] PRIMARY KEY CLUSTERED  ([exec_inv_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[exec_phys_inv] ADD CONSTRAINT [exec_phys_inv_fk1] FOREIGN KEY ([trade_num], [order_num], [item_num]) REFERENCES [dbo].[trade_item] ([trade_num], [order_num], [item_num])
GO
ALTER TABLE [dbo].[exec_phys_inv] ADD CONSTRAINT [exec_phys_inv_fk2] FOREIGN KEY ([contract_execution_oid]) REFERENCES [dbo].[contract_execution] ([oid])
GO
ALTER TABLE [dbo].[exec_phys_inv] ADD CONSTRAINT [exec_phys_inv_fk3] FOREIGN KEY ([conc_del_item_oid]) REFERENCES [dbo].[conc_delivery_item] ([oid])
GO
ALTER TABLE [dbo].[exec_phys_inv] ADD CONSTRAINT [exec_phys_inv_fk4] FOREIGN KEY ([inv_matched_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[exec_phys_inv] ADD CONSTRAINT [exec_phys_inv_fk5] FOREIGN KEY ([inv_sec_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[exec_phys_inv] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[exec_phys_inv] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[exec_phys_inv] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[exec_phys_inv] TO [next_usr]
GO
