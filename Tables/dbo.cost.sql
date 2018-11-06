CREATE TABLE [dbo].[cost]
(
[cost_num] [int] NOT NULL,
[cost_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_status] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_prim_sec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_est_final_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_pay_rec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bus_cost_type_num] [smallint] NULL,
[bus_cost_state_num] [smallint] NULL,
[bus_cost_fate_num] [smallint] NULL,
[bus_cost_fate_mod_date] [datetime] NULL,
[bus_cost_fate_mod_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_owner_code] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_owner_key1] [int] NULL,
[cost_owner_key2] [int] NULL,
[cost_owner_key3] [int] NULL,
[cost_owner_key4] [int] NULL,
[cost_owner_key5] [int] NULL,
[cost_owner_key6] [int] NULL,
[cost_owner_key7] [int] NULL,
[cost_owner_key8] [int] NULL,
[parent_cost_num] [int] NULL,
[port_num] [int] NULL,
[pos_group_num] [int] NULL,
[acct_num] [int] NULL,
[cost_qty] [float] NULL,
[cost_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_qty_est_actual_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_unit_price] [float] NULL,
[cost_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_price_est_actual_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_amt] [float] NULL,
[cost_amt_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_vouchered_amt] [float] NULL,
[cost_drawn_bal_amt] [float] NULL,
[pay_method_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_pay_days] [smallint] NULL,
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_book_comp_num] [int] NULL,
[cost_book_comp_short_name] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_book_prd_date] [datetime] NULL,
[cost_book_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_book_exch_rate] [float] NULL,
[cost_xrate_conv_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[creation_date] [datetime] NULL,
[creator_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_eff_date] [datetime] NULL,
[cost_due_date] [datetime] NULL,
[cost_due_date_mod_date] [datetime] NULL,
[cost_due_date_mod_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_approval_date] [datetime] NULL,
[cost_approval_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_gl_acct_cr_code] [varchar] (45) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_gl_acct_dr_code] [varchar] (45) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_gl_acct_mod_date] [datetime] NULL,
[cost_gl_acct_mod_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_gl_book_type_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_gl_book_date] [datetime] NULL,
[cost_gl_book_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_gl_offset_acct_code] [varchar] (45) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_short_cmnt] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[cost_accrual_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_price_mod_date] [datetime] NULL,
[cost_price_mod_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_partial_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[first_accrued_date] [datetime] NULL,
[cost_period_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_pl_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_paid_date] [datetime] NULL,
[cost_credit_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_center_code_debt] [char] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_center_code_credit] [char] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_send_id] [smallint] NULL,
[vc_acct_num] [int] NULL,
[cash_date] [datetime] NULL,
[po_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[eff_date_override_trans_id] [int] NULL,
[finance_bank_num] [int] NULL,
[tax_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[external_ref_key] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_rate_oid] [int] NULL,
[template_cost_num] [int] NULL,
[internal_cost_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[assay_final_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qty_type] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[cost_deltrg]
on [dbo].[cost]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   int

select @num_rows = @@rowcount
if @num_rows = 0
   return

/* This part of code was commented so that the transaction can delete cost record first, then
   delete cost_ext_info record next

if exists (select * from dbo.cost_ext_info, deleted
           where cost_ext_info.cost_num = deleted.cost_num)
begin
   raiserror ('The cost_num is still referred by cost_ext_info table (cost_num) .',10,1)
   if @@trancount > 0 rollback tran

   return
end


if exists (select * from dbo.cost_ext_info, deleted
           where cost_ext_info.pr_cost_num is NOT NULL and
                 cost_ext_info.pr_cost_num = deleted.cost_num)
begin
   raiserror ('The cost_num is still referred by cost_ext_info table (pr_cost_num).',10,1)
   if @@trancount > 0 rollback tran

   return
end
*/

/* AUDIT_CODE_BEGIN */
select @atrans_id = max(trans_id)
from dbo.icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(cost) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,10,1)
   if @@trancount > 0 rollback tran

   return
end

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @errcode            int,
        @num_touch_rows     int,
        @the_entity_name    varchar(30)

   select @the_entity_name = 'Cost'
   select @errcode = 0,
          @num_touch_rows = 0

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
             convert(varchar(40), d.cost_num),
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
                convert(varchar(40), d.cost_num),
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
         select @num_touch_rows = @@rowcount,
                @errcode = @@error

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
             convert(varchar(40), d.cost_num),
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
             convert(varchar(40), d.cost_num),
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
      select @num_touch_rows = @@rowcount,
             @errcode = @@error

      /* END_TRANSACTION_TOUCH */
   end

/* AUDIT_CODE_BEGIN */

insert dbo.aud_cost
   (cost_num,
    cost_code,
    cost_status,
    cost_prim_sec_ind,
    cost_est_final_ind,
    cost_pay_rec_ind,
    cost_type_code,
    bus_cost_type_num,
    bus_cost_state_num,
    bus_cost_fate_num,
    bus_cost_fate_mod_date,
    bus_cost_fate_mod_init,
    cost_owner_code,
    cost_owner_key1,
    cost_owner_key2,
    cost_owner_key3,
    cost_owner_key4,
    cost_owner_key5,
    cost_owner_key6,
    cost_owner_key7,
    cost_owner_key8,
    parent_cost_num,
    port_num,
    pos_group_num,
    acct_num,
    cost_qty,
    cost_qty_uom_code,
    cost_qty_est_actual_ind,
    cost_unit_price,
    cost_price_curr_code,
    cost_price_uom_code,
    cost_price_est_actual_ind,
    cost_amt,
    cost_amt_type,
    cost_vouchered_amt,
    cost_drawn_bal_amt,
    pay_method_code,
    pay_term_code,
    cost_pay_days,
    credit_term_code,
    cost_book_comp_num,
    cost_book_comp_short_name,
    cost_book_prd_date,
    cost_book_curr_code,
    cost_book_exch_rate,
    cost_xrate_conv_ind,
    creation_date,
    creator_init,
    cost_eff_date,
    cost_due_date,
    cost_due_date_mod_date,
    cost_due_date_mod_init,
    cost_approval_date,
    cost_approval_init,
    cost_gl_acct_cr_code,
    cost_gl_acct_dr_code,
    cost_gl_acct_mod_date,
    cost_gl_acct_mod_init,
    cost_gl_book_type_code,
    cost_gl_book_date,
    cost_gl_book_init,
    cost_gl_offset_acct_code,
    cost_short_cmnt,
    cmnt_num,
    cost_accrual_ind,
    cost_price_mod_date,
    cost_price_mod_init,
    cost_partial_ind,
    first_accrued_date,
    cost_period_ind,
    cost_pl_code,
    cost_paid_date,
    cost_credit_ind,
    cost_center_code_debt,
    cost_center_code_credit,
    cost_send_id,
    vc_acct_num,          
    cash_date, 
    po_number,  
    eff_date_override_trans_id,  
    finance_bank_num, 
    tax_status_code,
    external_ref_key,
    cost_rate_oid,
    template_cost_num,
    internal_cost_ind,
    assay_final_ind,
    qty_type,
    trans_id,
    resp_trans_id)
select
   d.cost_num,
   d.cost_code,
   d.cost_status,
   d.cost_prim_sec_ind,
   d.cost_est_final_ind,
   d.cost_pay_rec_ind,
   d.cost_type_code,
   d.bus_cost_type_num,
   d.bus_cost_state_num,
   d.bus_cost_fate_num,
   d.bus_cost_fate_mod_date,
   d.bus_cost_fate_mod_init,
   d.cost_owner_code,
   d.cost_owner_key1,
   d.cost_owner_key2,
   d.cost_owner_key3,
   d.cost_owner_key4,
   d.cost_owner_key5,
   d.cost_owner_key6,
   d.cost_owner_key7,
   d.cost_owner_key8,
   d.parent_cost_num,
   d.port_num,
   d.pos_group_num,
   d.acct_num,
   d.cost_qty,
   d.cost_qty_uom_code,
   d.cost_qty_est_actual_ind,
   d.cost_unit_price,
   d.cost_price_curr_code,
   d.cost_price_uom_code,
   d.cost_price_est_actual_ind,
   d.cost_amt,
   d.cost_amt_type,
   d.cost_vouchered_amt,
   d.cost_drawn_bal_amt,
   d.pay_method_code,
   d.pay_term_code,
   d.cost_pay_days,
   d.credit_term_code,
   d.cost_book_comp_num,
   d.cost_book_comp_short_name,
   d.cost_book_prd_date,
   d.cost_book_curr_code,
   d.cost_book_exch_rate,
   d.cost_xrate_conv_ind,
   d.creation_date,
   d.creator_init,
   d.cost_eff_date,
   d.cost_due_date,
   d.cost_due_date_mod_date,
   d.cost_due_date_mod_init,
   d.cost_approval_date,
   d.cost_approval_init,
   d.cost_gl_acct_cr_code,
   d.cost_gl_acct_dr_code,
   d.cost_gl_acct_mod_date,
   d.cost_gl_acct_mod_init,
   d.cost_gl_book_type_code,
   d.cost_gl_book_date,
   d.cost_gl_book_init,
   d.cost_gl_offset_acct_code,
   d.cost_short_cmnt,
   d.cmnt_num,
   d.cost_accrual_ind,
   d.cost_price_mod_date,
   d.cost_price_mod_init,
   d.cost_partial_ind,
   d.first_accrued_date,
   d.cost_period_ind,
   d.cost_pl_code,
   d.cost_paid_date,
   d.cost_credit_ind,
   d.cost_center_code_debt,
   d.cost_center_code_credit,
   d.cost_send_id,
   d.vc_acct_num,          
   d.cash_date, 
   d.po_number,    
   d.eff_date_override_trans_id,   
   d.finance_bank_num,
   d.tax_status_code,
   d.external_ref_key,
   d.cost_rate_oid,
   d.template_cost_num,
   d.internal_cost_ind,
   d.assay_final_ind,
   d.qty_type,
   d.trans_id,
   @atrans_id
from deleted d

if @num_rows != @@rowcount
begin
   raiserror ('# of rows added to the aud_cost table do not match the # of rows changed for <cost> table due to DELETION operation.',10,1)
   if @@trancount > 0 rollback tran
   return
end

/* AUDIT_CODE_END */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
create trigger [dbo].[cost_instrg]  
on [dbo].[cost]  
instead of insert  
as  
declare @num_rows       int,  
        @count_num_rows int,  
        @errmsg         varchar(255)  
  
select @num_rows = @@rowcount  
if @num_rows = 0  
   return  
   
insert into cost
(  cost_num,
cost_code,
cost_status,
cost_prim_sec_ind,
cost_est_final_ind,
cost_pay_rec_ind,
cost_type_code,
bus_cost_type_num,
bus_cost_state_num,
bus_cost_fate_num,
bus_cost_fate_mod_date,
bus_cost_fate_mod_init,
cost_owner_code,
cost_owner_key1,
cost_owner_key2,
cost_owner_key3,
cost_owner_key4,
cost_owner_key5,
cost_owner_key6,
cost_owner_key7,
cost_owner_key8,
parent_cost_num,
port_num,
pos_group_num,
acct_num,
cost_qty,
cost_qty_uom_code,
cost_qty_est_actual_ind,
cost_unit_price,
cost_price_curr_code,
cost_price_uom_code,
cost_price_est_actual_ind,
cost_amt,
cost_amt_type,
cost_vouchered_amt,
cost_drawn_bal_amt,
pay_method_code,
pay_term_code,
cost_pay_days,
credit_term_code,
cost_book_comp_num,
cost_book_comp_short_name,
cost_book_prd_date,
cost_book_curr_code,
cost_book_exch_rate,
cost_xrate_conv_ind,
creation_date,
creator_init,
cost_eff_date,
cost_due_date,
cost_due_date_mod_date,
cost_due_date_mod_init,
cost_approval_date,
cost_approval_init,
cost_gl_acct_cr_code,
cost_gl_acct_dr_code,
cost_gl_acct_mod_date,
cost_gl_acct_mod_init,
cost_gl_book_type_code,
cost_gl_book_date,
cost_gl_book_init,
cost_gl_offset_acct_code,
cost_short_cmnt,
cmnt_num,
cost_accrual_ind,
cost_price_mod_date,
cost_price_mod_init,
cost_partial_ind,
first_accrued_date,
cost_period_ind,
cost_pl_code,
cost_paid_date,
cost_credit_ind,
cost_center_code_debt,
cost_center_code_credit,
cost_send_id,
vc_acct_num,
cash_date,
po_number,
trans_id,
eff_date_override_trans_id,
finance_bank_num,
tax_status_code,
external_ref_key,
cost_rate_oid,
template_cost_num,
internal_cost_ind,
assay_final_ind,
qty_type )
select 
 cost_num,
cost_code,
cost_status,
cost_prim_sec_ind,
cost_est_final_ind,
cost_pay_rec_ind,
cost_type_code,
bus_cost_type_num,
bus_cost_state_num,
bus_cost_fate_num,
bus_cost_fate_mod_date,
bus_cost_fate_mod_init,
cost_owner_code,
cost_owner_key1,
cost_owner_key2,
cost_owner_key3,
cost_owner_key4,
cost_owner_key5,
cost_owner_key6,
cost_owner_key7,
cost_owner_key8,
parent_cost_num,
port_num,
pos_group_num,
acct_num,
cost_qty,
cost_qty_uom_code,
cost_qty_est_actual_ind,
cost_unit_price,
cost_price_curr_code,
cost_price_uom_code,
cost_price_est_actual_ind,
cost_amt,
cost_amt_type,
cost_vouchered_amt,
cost_drawn_bal_amt,
pay_method_code,
pay_term_code,
cost_pay_days,
credit_term_code,
cost_book_comp_num,
cost_book_comp_short_name,
cost_book_prd_date,
cost_book_curr_code,
cost_book_exch_rate,
cost_xrate_conv_ind,
creation_date,
creator_init,
cost_eff_date,
cost_due_date,
cost_due_date_mod_date,
cost_due_date_mod_init,
cost_approval_date,
cost_approval_init,
cost_gl_acct_cr_code,
cost_gl_acct_dr_code,
cost_gl_acct_mod_date,
cost_gl_acct_mod_init,
cost_gl_book_type_code,
cost_gl_book_date,
cost_gl_book_init,
cost_gl_offset_acct_code,
cost_short_cmnt,
cmnt_num,
cost_accrual_ind,
cost_price_mod_date,
cost_price_mod_init,
cost_partial_ind,
first_accrued_date,
cost_period_ind,
cost_pl_code,
cost_paid_date,
cost_credit_ind,
cost_center_code_debt,
cost_center_code_credit,
cost_send_id,
vc_acct_num,
cash_date,
po_number,
trans_id,
eff_date_override_trans_id,
finance_bank_num,
tax_status_code,
external_ref_key,
cost_rate_oid,
template_cost_num,
internal_cost_ind,
isnull(assay_final_ind,'Y'),
qty_type
from inserted   
  
declare @the_sequence       numeric(32, 0),  
        @the_tran_type      char(1),  
        @errcode            int,  
        @num_touch_rows     int,  
        @the_entity_name    varchar(30)  
  
   select @the_entity_name = 'Cost'  
   select @errcode = 0,  
          @num_touch_rows = 0  
  
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
             convert(varchar(40),cost_num),  
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
  
      if @the_tran_type != 'E'  
      begin  
         /* BEGIN_TRANSACTION_TOUCH */  
  
         insert dbo.transaction_touch  
         select 'INSERT',  
                @the_entity_name,  
                'DIRECT',  
                convert(varchar(40),cost_num),  
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
         select @num_touch_rows = @@rowcount,  
                @errcode = @@error  
  
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
             'I',  
             @the_entity_name,  
             convert(varchar(40),cost_num),  
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
             convert(varchar(40),cost_num),  
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
      select @num_touch_rows = @@rowcount,  
             @errcode = @@error  
  
      /* END_TRANSACTION_TOUCH */  
   end  
  
return  
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
create trigger [dbo].[cost_updtrg]
on [dbo].[cost]
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
   raiserror ('(cost) The change needs to be attached with a new trans_id',10,1)
   if @@trancount > 0 rollback tran

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
      select @errmsg = '(cost) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.cost_num = d.cost_num )
begin
   raiserror ('(cost) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(cost_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.cost_num = d.cost_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(cost) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end


/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
begin
   insert dbo.aud_cost
      (cost_num,
       cost_code,
       cost_status,
       cost_prim_sec_ind,
       cost_est_final_ind,
       cost_pay_rec_ind,
       cost_type_code,
       bus_cost_type_num,
       bus_cost_state_num,
       bus_cost_fate_num,
       bus_cost_fate_mod_date,
       bus_cost_fate_mod_init,
       cost_owner_code,
       cost_owner_key1,
       cost_owner_key2,
       cost_owner_key3,
       cost_owner_key4,
       cost_owner_key5,
       cost_owner_key6,
       cost_owner_key7,
       cost_owner_key8,
       parent_cost_num,
       port_num,
       pos_group_num,
       acct_num,
       cost_qty,
       cost_qty_uom_code,
       cost_qty_est_actual_ind,
       cost_unit_price,
       cost_price_curr_code,
       cost_price_uom_code,
       cost_price_est_actual_ind,
       cost_amt,
       cost_amt_type,
       cost_vouchered_amt,
       cost_drawn_bal_amt,
       pay_method_code,
       pay_term_code,
       cost_pay_days,
       credit_term_code,
       cost_book_comp_num,
       cost_book_comp_short_name,
       cost_book_prd_date,
       cost_book_curr_code,
       cost_book_exch_rate,
       cost_xrate_conv_ind,
       creation_date,
       creator_init,
       cost_eff_date,
       cost_due_date,
       cost_due_date_mod_date,
       cost_due_date_mod_init,
       cost_approval_date,
       cost_approval_init,
       cost_gl_acct_cr_code,
       cost_gl_acct_dr_code,
       cost_gl_acct_mod_date,
       cost_gl_acct_mod_init,
       cost_gl_book_type_code,
       cost_gl_book_date,
       cost_gl_book_init,
       cost_gl_offset_acct_code,
       cost_short_cmnt,
       cmnt_num,
       cost_accrual_ind,
       cost_price_mod_date,
       cost_price_mod_init,
       cost_partial_ind,
       first_accrued_date,
       cost_period_ind,
       cost_pl_code,
       cost_paid_date,
       cost_credit_ind,
       cost_center_code_debt,
       cost_center_code_credit,
       cost_send_id,
       vc_acct_num,          
       cash_date,  
       po_number,    
       eff_date_override_trans_id,   
       finance_bank_num,
       tax_status_code,
       external_ref_key,
       cost_rate_oid,
       template_cost_num,
       internal_cost_ind,
       assay_final_ind,
       qty_type,
       trans_id,
       resp_trans_id)
   select
      d.cost_num,
      d.cost_code,
      d.cost_status,
      d.cost_prim_sec_ind,
      d.cost_est_final_ind,
      d.cost_pay_rec_ind,
      d.cost_type_code,
      d.bus_cost_type_num,
      d.bus_cost_state_num,
      d.bus_cost_fate_num,
      d.bus_cost_fate_mod_date,
      d.bus_cost_fate_mod_init,
      d.cost_owner_code,
      d.cost_owner_key1,
      d.cost_owner_key2,
      d.cost_owner_key3,
      d.cost_owner_key4,
      d.cost_owner_key5,
      d.cost_owner_key6,
      d.cost_owner_key7,
      d.cost_owner_key8,
      d.parent_cost_num,
      d.port_num,
      d.pos_group_num,
      d.acct_num,
      d.cost_qty,
      d.cost_qty_uom_code,
      d.cost_qty_est_actual_ind,
      d.cost_unit_price,
      d.cost_price_curr_code,
      d.cost_price_uom_code,
      d.cost_price_est_actual_ind,
      d.cost_amt,
      d.cost_amt_type,
      d.cost_vouchered_amt,
      d.cost_drawn_bal_amt,
      d.pay_method_code,
      d.pay_term_code,
      d.cost_pay_days,
      d.credit_term_code,
      d.cost_book_comp_num,
      d.cost_book_comp_short_name,
      d.cost_book_prd_date,
      d.cost_book_curr_code,
      d.cost_book_exch_rate,
      d.cost_xrate_conv_ind,
      d.creation_date,
      d.creator_init,
      d.cost_eff_date,
      d.cost_due_date,
      d.cost_due_date_mod_date,
      d.cost_due_date_mod_init,
      d.cost_approval_date,
      d.cost_approval_init,
      d.cost_gl_acct_cr_code,
      d.cost_gl_acct_dr_code,
      d.cost_gl_acct_mod_date,
      d.cost_gl_acct_mod_init,
      d.cost_gl_book_type_code,
      d.cost_gl_book_date,
      d.cost_gl_book_init,
      d.cost_gl_offset_acct_code,
      d.cost_short_cmnt,
      d.cmnt_num,
      d.cost_accrual_ind,
      d.cost_price_mod_date,
      d.cost_price_mod_init,
      d.cost_partial_ind,
      d.first_accrued_date,
      d.cost_period_ind,
      d.cost_pl_code,
      d.cost_paid_date,
      d.cost_credit_ind,
      d.cost_center_code_debt,
      d.cost_center_code_credit,
      d.cost_send_id,
      d.vc_acct_num,          
      d.cash_date,  
      d.po_number,    
      d.eff_date_override_trans_id,  
      d.finance_bank_num,
      d.tax_status_code,
      d.external_ref_key,
      d.cost_rate_oid,
      d.template_cost_num,
      d.internal_cost_ind,
      d.assay_final_ind,
      d.qty_type,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.cost_num = i.cost_num 

   if @num_rows != @@rowcount
   begin
      raiserror ('# of rows added to the aud_cost table do not match the # of rows changed for <cost> table due to UPDATE operation.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @errcode            int,
        @num_touch_rows     int,
        @the_entity_name    varchar(30)

   select @the_entity_name = 'Cost'
   select @errcode = 0,
          @num_touch_rows = 0

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
             convert(varchar(40),cost_num),
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
                convert(varchar(40),cost_num),
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
         select @num_touch_rows = @@rowcount,
                @errcode = @@error

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
             convert(varchar(40),cost_num),
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
             convert(varchar(40),cost_num),
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
      select @num_touch_rows = @@rowcount,
             @errcode = @@error

      /* END_TRANSACTION_TOUCH */
   end

   -- The intention of the following code section is to capture
   -- the instance that no transaction_touch records were created
   -- for Cost records. This will help to debug the problem.

   if @num_touch_rows = 0
   begin
      if exists (select 1
                 from inserted i, dbo.icts_transaction it
                 where i.trans_id = it.trans_id and
                       it.type != 'E')
      begin
         insert into icts_trace_log
             (entity_name, key1, trans_id, opcode, errcode, note)
           select 'Cost',
                  convert(varchar, i.cost_num),
                  i.trans_id,
                  'U',
                  @errcode,
                  'Failed to write touch records'
           from inserted i, dbo.icts_transaction it
           where i.trans_id = it.trans_id and
                 it.type != 'E'
      end
   end

return
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [CK__cost__internal_c__02925FBF] CHECK (([internal_cost_ind]='N' OR [internal_cost_ind]='Y'))
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_pk] PRIMARY KEY CLUSTERED  ([cost_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cost_owner_idx] ON [dbo].[cost] ([cost_owner_code], [cost_owner_key1], [cost_owner_key2], [cost_owner_key3], [cost_owner_key4]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cost_idx2] ON [dbo].[cost] ([cost_owner_key6], [cost_owner_key7], [cost_owner_key8]) INCLUDE ([cost_amt], [cost_pay_rec_ind], [cost_prim_sec_ind], [cost_status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cost_idx3] ON [dbo].[cost] ([cost_type_code], [cost_owner_key1], [cost_status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cost_idx5] ON [dbo].[cost] ([parent_cost_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cost_idx4] ON [dbo].[cost] ([port_num], [cost_amt_type]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cost_idx6] ON [dbo].[cost] ([trans_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk10] FOREIGN KEY ([cost_center_code_credit]) REFERENCES [dbo].[cost_center] ([cost_center_code])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk11] FOREIGN KEY ([cost_owner_code]) REFERENCES [dbo].[cost_owner] ([cost_owner_code])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk12] FOREIGN KEY ([cost_status]) REFERENCES [dbo].[cost_status] ([cost_status_code])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk13] FOREIGN KEY ([cost_type_code]) REFERENCES [dbo].[cost_type] ([cost_type_code])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk14] FOREIGN KEY ([credit_term_code]) REFERENCES [dbo].[credit_term] ([credit_term_code])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk15] FOREIGN KEY ([bus_cost_fate_mod_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk16] FOREIGN KEY ([creator_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk17] FOREIGN KEY ([cost_due_date_mod_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk18] FOREIGN KEY ([cost_approval_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk19] FOREIGN KEY ([cost_gl_acct_mod_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk2] FOREIGN KEY ([cost_book_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk20] FOREIGN KEY ([cost_gl_book_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk21] FOREIGN KEY ([cost_price_mod_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk22] FOREIGN KEY ([pay_method_code]) REFERENCES [dbo].[payment_method] ([pay_method_code])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk23] FOREIGN KEY ([pay_term_code]) REFERENCES [dbo].[payment_term] ([pay_term_code])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk26] FOREIGN KEY ([cost_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk27] FOREIGN KEY ([cost_price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk29] FOREIGN KEY ([finance_bank_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk3] FOREIGN KEY ([bus_cost_fate_num]) REFERENCES [dbo].[bus_cost_fate] ([bc_fate_num])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk30] FOREIGN KEY ([tax_status_code]) REFERENCES [dbo].[tax_status] ([tax_status_code])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk31] FOREIGN KEY ([cost_rate_oid]) REFERENCES [dbo].[cost_rate] ([oid])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk32] FOREIGN KEY ([template_cost_num]) REFERENCES [dbo].[cost] ([cost_num])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk4] FOREIGN KEY ([bus_cost_state_num]) REFERENCES [dbo].[bus_cost_state] ([bc_state_num])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk5] FOREIGN KEY ([bus_cost_type_num]) REFERENCES [dbo].[bus_cost_type] ([bc_type_num])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk7] FOREIGN KEY ([cost_price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk8] FOREIGN KEY ([cost_book_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk9] FOREIGN KEY ([cost_center_code_debt]) REFERENCES [dbo].[cost_center] ([cost_center_code])
GO
GRANT DELETE ON  [dbo].[cost] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cost] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cost] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cost] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'cost', NULL, NULL
GO
