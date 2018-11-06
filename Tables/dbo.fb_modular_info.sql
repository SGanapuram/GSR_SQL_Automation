CREATE TABLE [dbo].[fb_modular_info]
(
[formula_num] [int] NOT NULL,
[formula_body_num] [int] NOT NULL,
[basis_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[risk_mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[risk_trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_deduct_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cross_ref_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ref_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_pcnt_string] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_pcnt_value] [float] NOT NULL,
[price_quote_string] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[last_computed_value] [float] NULL,
[last_computed_asof_date] [datetime] NULL,
[line_item_contr_desc] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[line_item_invoice_desc] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qp_start_date] [datetime] NULL,
[qp_end_date] [datetime] NULL,
[qp_election_date] [datetime] NULL,
[qp_desc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qp_election_opt] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qp_elected] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[fb_modular_info_deltrg]    
on [dbo].[fb_modular_info]    
instead of delete    
as    
declare @num_rows    int,    
        @errmsg      varchar(255),    
        @atrans_id   int    
    
select @num_rows = @@rowcount    
if @num_rows = 0    
   return    
    
delete dbo.fb_modular_info
from deleted d
where fb_modular_info.formula_num = d.formula_num and
      fb_modular_info.formula_body_num = d.formula_body_num

/* AUDIT_CODE_BEGIN */    
select @atrans_id = max(trans_id)    
from dbo.icts_transaction WITH (INDEX=icts_transaction_idx4)    
where spid = @@spid and    
      tran_date >= (select top 1 login_time    
                    from master.dbo.sysprocesses (nolock)    
                    where spid = @@spid)    
    
if @atrans_id is null    
begin    
   select @errmsg = '(fb_modular_info) Failed to obtain a valid responsible trans_id.'    
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
  
insert dbo.aud_fb_modular_info    
  (formula_num,  
	 formula_body_num,  
	 basis_cmdty_code,  
	 risk_mkt_code,  
	 risk_trading_prd,  
	 pay_deduct_ind,  
	 cross_ref_ind,  
	 ref_cmdty_code,  
	 price_pcnt_string,  
	 price_pcnt_value,  
	 price_quote_string,  
	 trans_id,  
	 resp_trans_id,  
	 last_computed_value,  
	 last_computed_asof_date,
	 line_item_contr_desc,
	 line_item_invoice_desc,
   qp_start_date,
   qp_end_date,
   qp_election_date,
   qp_desc,
   qp_election_opt,
   qp_elected)    
select  
	 d.formula_num,  
	 d.formula_body_num,  
	 d.basis_cmdty_code,  
	 d.risk_mkt_code,  
	 d.risk_trading_prd,  
	 d.pay_deduct_ind,  
	 d.cross_ref_ind,  
	 d.ref_cmdty_code,  
	 d.price_pcnt_string,  
	 d.price_pcnt_value,  
	 d.price_quote_string,  
	 d.trans_id,  
	 @atrans_id,  
	 d.last_computed_value,  
	 d.last_computed_asof_date,
	 d.line_item_contr_desc,
	 d.line_item_invoice_desc,
   d.qp_start_date,
   d.qp_end_date,
   d.qp_election_date,
   d.qp_desc,
   d.qp_election_opt,
   d.qp_elected    
from deleted d     
    
/* AUDIT_CODE_END */    
  
declare @the_sequence       numeric(32, 0),  
        @the_tran_type      char(1),  
        @the_entity_name    varchar(30)  
  
   select @the_entity_name = 'FbModularInfo'  
  
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
             convert(varchar(40),d.formula_num),  
             convert(varchar(40),d.formula_body_num),  
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
             convert(varchar(40),d.formula_num),  
             convert(varchar(40),d.formula_body_num),  
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
             convert(varchar(40),d.formula_num),  
             convert(varchar(40),d.formula_body_num),  
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
             convert(varchar(40),d.formula_num),  
             convert(varchar(40),d.formula_body_num),  
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
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[fb_modular_info_instrg]
on [dbo].[fb_modular_info]
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

   select @the_entity_name = 'FbModularInfo'

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
             convert(varchar(40),formula_num),
             convert(varchar(40),formula_body_num),
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
             convert(varchar(40),formula_num),
             convert(varchar(40),formula_body_num),
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
             convert(varchar(40),formula_num),
             convert(varchar(40),formula_body_num),
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
             convert(varchar(40),formula_num),
             convert(varchar(40),formula_body_num),
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
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[fb_modular_info_updtrg]  
on [dbo].[fb_modular_info]  
instead of update  
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
   raiserror  ('(fb_modular_info) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(fb_modular_info) New trans_id must be larger than original trans_id.'  
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'  
      raiserror  (@errmsg  ,10,1)
      rollback tran  
      return  
   end  
end  
  
if exists (select * from inserted i, deleted d  
           where i.trans_id < d.trans_id and  
                 i.formula_num = d.formula_num and
		             i.formula_body_num = d.formula_body_num )  
begin  
   raiserror  ('(fb_modular_info) new trans_id must not be older than current trans_id.', 10, 1)
   rollback tran  
   return  
end  
  
/* RECORD_STAMP_END */
  
if update(formula_num) or  
   update(formula_body_num)
begin  
   select @count_num_rows = (select count(*) from inserted i, deleted d  
                             where i.formula_num = d.formula_num and
			                             i.formula_body_num = d.formula_body_num)  
   if (@count_num_rows = @num_rows)  
   begin  
      select @dummy_update = 1  
   end  
   else  
   begin  
      raiserror  ('(fb_modular_info) primary key can not be changed.'  ,10,1)
      rollback tran  
      return  
   end  
end  

update dbo.fb_modular_info    
set basis_cmdty_code = i.basis_cmdty_code,  
    risk_mkt_code = i.risk_mkt_code,  
    risk_trading_prd = i.risk_trading_prd,  
    pay_deduct_ind = i.pay_deduct_ind,  
    cross_ref_ind = i.cross_ref_ind,  
    ref_cmdty_code = i.ref_cmdty_code,  
    price_pcnt_string = i.price_pcnt_string,  
    price_pcnt_value = i.price_pcnt_value,  
    price_quote_string = i.price_quote_string,  
    last_computed_value = i.last_computed_value,  
    last_computed_asof_date = i.last_computed_asof_date, 
    line_item_contr_desc = i.line_item_contr_desc,
    line_item_invoice_desc = i.line_item_invoice_desc,
    qp_start_date = i.qp_start_date,
    qp_end_date = i.qp_end_date,
    qp_election_date = i.qp_election_date,
    qp_desc = i.qp_desc,
    qp_election_opt = i.qp_election_opt,
    qp_elected = i.qp_elected,		
    trans_id = i.trans_id  
from deleted d, inserted i    
where fb_modular_info.formula_num = d.formula_num and    
      fb_modular_info.formula_body_num = d.formula_body_num and    
      d.formula_num = i.formula_num and    
      d.formula_body_num = i.formula_body_num   

/* AUDIT_CODE_BEGIN */  
  
if @dummy_update = 0  
   insert dbo.aud_fb_modular_info  
      (formula_num,
	     formula_body_num,
	     basis_cmdty_code,
	     risk_mkt_code,
	     risk_trading_prd,
	     pay_deduct_ind,
	     cross_ref_ind,
	     ref_cmdty_code,
	     price_pcnt_string,
	     price_pcnt_value,
	     price_quote_string,
	     trans_id,
       resp_trans_id,
       last_computed_value,
	     last_computed_asof_date,
	     line_item_contr_desc,
	     line_item_invoice_desc,
       qp_start_date,
       qp_end_date,
       qp_election_date,
       qp_desc,
       qp_election_opt,
       qp_elected)  
   select
	    d.formula_num,
	    d.formula_body_num,
	    d.basis_cmdty_code,
	    d.risk_mkt_code,
	    d.risk_trading_prd,
	    d.pay_deduct_ind,
	    d.cross_ref_ind,
	    d.ref_cmdty_code,
	    d.price_pcnt_string,
	    d.price_pcnt_value,
	    d.price_quote_string,
	    d.trans_id,
      i.trans_id,
      d.last_computed_value,
	    d.last_computed_asof_date,
      d.line_item_contr_desc,
	    d.line_item_invoice_desc,
      d.qp_start_date,
      d.qp_end_date,
      d.qp_election_date,
      d.qp_desc,
      d.qp_election_opt,
      d.qp_elected  
   from deleted d, inserted i  
   where d.formula_num = i.formula_num and
         d.formula_body_num = i.formula_body_num  
  
/* AUDIT_CODE_END */  

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'FbModularInfo'

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
             convert(varchar(40),formula_num),
             convert(varchar(40),formula_body_num),
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
             convert(varchar(40),formula_num),
             convert(varchar(40),formula_body_num),
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
             convert(varchar(40),formula_num),
             convert(varchar(40),formula_body_num),
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
             convert(varchar(40),formula_num),
             convert(varchar(40),formula_body_num),
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
ALTER TABLE [dbo].[fb_modular_info] ADD CONSTRAINT [CK__fb_modula__pay_d__1922560A] CHECK (([pay_deduct_ind]='D' OR [pay_deduct_ind]='P'))
GO
ALTER TABLE [dbo].[fb_modular_info] ADD CONSTRAINT [fb_modular_info_pk] PRIMARY KEY CLUSTERED  ([formula_num], [formula_body_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fb_modular_info] ADD CONSTRAINT [fb_modular_info_fk1] FOREIGN KEY ([risk_mkt_code]) REFERENCES [dbo].[market] ([mkt_code])
GO
GRANT DELETE ON  [dbo].[fb_modular_info] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[fb_modular_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[fb_modular_info] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[fb_modular_info] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'fb_modular_info', NULL, NULL
GO
