CREATE TABLE [dbo].[voucher]
(
[voucher_num] [int] NOT NULL,
[voucher_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_cat_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_pay_recv_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_num] [int] NULL,
[acct_instr_num] [smallint] NULL,
[voucher_tot_amt] [float] NULL,
[voucher_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_method_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_pay_days] [smallint] NULL,
[voch_tot_paid_amt] [float] NULL,
[voucher_creation_date] [datetime] NULL,
[voucher_creator_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_auth_reqd_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_auth_date] [datetime] NULL,
[voucher_auth_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_eff_date] [datetime] NULL,
[voucher_print_date] [datetime] NULL,
[voucher_send_to_cust_date] [datetime] NULL,
[voucher_book_date] [datetime] NULL,
[voucher_mod_date] [datetime] NULL,
[voucher_mod_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_writeoff_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_writeoff_date] [datetime] NULL,
[voucher_cust_inv_amt] [float] NULL,
[voucher_cust_inv_date] [datetime] NULL,
[voucher_short_cmnt] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[voucher_book_comp_num] [int] NULL,
[voucher_book_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_book_exch_rate] [float] NULL,
[voucher_xrate_conv_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_loi_num] [int] NULL,
[voucher_arap_acct_code] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_send_to_arap_date] [datetime] NULL,
[voucher_cust_ref_num] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_book_prd_date] [datetime] NULL,
[voucher_paid_date] [datetime] NULL,
[voucher_due_date] [datetime] NULL,
[voucher_acct_name] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_book_comp_name] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cash_date] [datetime] NULL,
[trans_id] [int] NOT NULL,
[ref_voucher_num] [int] NULL,
[custom_voucher_string] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_reversal_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [DF__voucher__voucher__62EF9734] DEFAULT ('N'),
[voucher_hold_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [DF__voucher__voucher__64D7DFA6] DEFAULT ('N'),
[max_line_num] [int] NOT NULL CONSTRAINT [DF__voucher__max_lin__66C02818] DEFAULT ((0)),
[book_comp_acct_bank_id] [int] NULL,
[cp_acct_bank_id] [int] NULL,
[voucher_inv_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_inv_exch_rate] [numeric] (20, 8) NULL,
[invoice_exch_rate_comment] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cust_inv_recv_date] [datetime] NULL,
[cust_inv_type_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[special_bank_instr] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[revised_book_comp_bank_id] [int] NULL,
[voucher_expected_pay_date] [datetime] NULL,
[external_ref_key] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cpty_inv_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_approval_date] [datetime] NULL,
[voucher_approval_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sap_invoice_number] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[voucher_deltrg]
on [dbo].[voucher]
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
from icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(voucher) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,10,1)
   if @@trancount > 0 rollback tran

   return
end


insert aud_voucher
   (voucher_num,
    voucher_status,
    voucher_type_code,
    voucher_cat_code,
    voucher_pay_recv_ind,
    acct_num,
    acct_instr_num,
    voucher_tot_amt,
    voucher_curr_code,
    credit_term_code,
    pay_method_code,
    pay_term_code,
    voucher_pay_days,
    voch_tot_paid_amt,
    voucher_creation_date,
    voucher_creator_init,
    voucher_auth_reqd_ind,
    voucher_auth_date,
    voucher_auth_init,
    voucher_eff_date,
    voucher_print_date,
    voucher_send_to_cust_date,
    voucher_book_date,
    voucher_mod_date,
    voucher_mod_init,
    voucher_writeoff_init,
    voucher_writeoff_date,
    voucher_cust_inv_amt,
    voucher_cust_inv_date,
    voucher_short_cmnt,
    cmnt_num,
    voucher_book_comp_num,
    voucher_book_curr_code,
    voucher_book_exch_rate,
    voucher_xrate_conv_ind,
    voucher_loi_num,
    voucher_arap_acct_code,
    voucher_send_to_arap_date,
    voucher_cust_ref_num,
    voucher_book_prd_date,
    voucher_paid_date,
    voucher_due_date,
    voucher_acct_name,
    voucher_book_comp_name,
    cash_date,        
    trans_id,
    resp_trans_id,
    voucher_reversal_ind,
    ref_voucher_num,
    custom_voucher_string,
    voucher_hold_ind,
    max_line_num,
    book_comp_acct_bank_id,
    cp_acct_bank_id,
    voucher_inv_curr_code,    
    voucher_inv_exch_rate, 
    invoice_exch_rate_comment,
    cust_inv_recv_date,
    cust_inv_type_ind,
    special_bank_instr,
    revised_book_comp_bank_id,
    voucher_expected_pay_date,
    external_ref_key,
    cpty_inv_curr_code,
    voucher_approval_date,
    voucher_approval_init,
    sap_invoice_number)
select
   d.voucher_num,
   d.voucher_status,
   d.voucher_type_code,
   d.voucher_cat_code,
   d.voucher_pay_recv_ind,
   d.acct_num,
   d.acct_instr_num,
   d.voucher_tot_amt,
   d.voucher_curr_code,
   d.credit_term_code,
   d.pay_method_code,
   d.pay_term_code,
   d.voucher_pay_days,
   d.voch_tot_paid_amt,
   d.voucher_creation_date,
   d.voucher_creator_init,
   d.voucher_auth_reqd_ind,
   d.voucher_auth_date,
   d.voucher_auth_init,
   d.voucher_eff_date,
   d.voucher_print_date,
   d.voucher_send_to_cust_date,
   d.voucher_book_date,
   d.voucher_mod_date,
   d.voucher_mod_init,
   d.voucher_writeoff_init,
   d.voucher_writeoff_date,
   d.voucher_cust_inv_amt,
   d.voucher_cust_inv_date,
   d.voucher_short_cmnt,
   d.cmnt_num,
   d.voucher_book_comp_num,
   d.voucher_book_curr_code,
   d.voucher_book_exch_rate,
   d.voucher_xrate_conv_ind,
   d.voucher_loi_num,
   d.voucher_arap_acct_code,
   d.voucher_send_to_arap_date,
   d.voucher_cust_ref_num,
   d.voucher_book_prd_date,
   d.voucher_paid_date,
   d.voucher_due_date,
   d.voucher_acct_name,
   d.voucher_book_comp_name,
   d.cash_date,        
   d.trans_id,
   @atrans_id,
   d.voucher_reversal_ind,
   d.ref_voucher_num,
   d.custom_voucher_string,
   d.voucher_hold_ind,
   d.max_line_num,
   d.book_comp_acct_bank_id,
   d.cp_acct_bank_id,
   d.voucher_inv_curr_code,    
   d.voucher_inv_exch_rate, 
   d.invoice_exch_rate_comment,
   d.cust_inv_recv_date,
   d.cust_inv_type_ind,
   d.special_bank_instr,
   d.revised_book_comp_bank_id,
   d.voucher_expected_pay_date,
   d.external_ref_key,
   d.cpty_inv_curr_code,
   d.voucher_approval_date,
   d.voucher_approval_init,
   d.sap_invoice_number
from deleted d

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'Voucher'

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
             convert(varchar(40),voucher_num),
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
                convert(varchar(40),voucher_num),
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
             convert(varchar(40),voucher_num),
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
             convert(varchar(40),voucher_num),
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

create trigger [dbo].[voucher_instrg]
on [dbo].[voucher]
for insert
as
declare @num_rows        int,
        @count_num_rows  int,
        @errmsg          varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'Voucher'

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
             convert(varchar(40), i.voucher_num),
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
                convert(varchar(40), i.voucher_num),
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
             'I',
             @the_entity_name,
             convert(varchar(40), i.voucher_num),
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
             convert(varchar(40), i.voucher_num),
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
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[voucher_updtrg]
on [dbo].[voucher]
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
   raiserror ('(voucher) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(voucher) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.voucher_num = d.voucher_num )
begin
   select @errmsg = '(voucher) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.voucher_num) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(voucher_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.voucher_num = d.voucher_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(voucher) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_voucher
      (voucher_num,
       voucher_status,
       voucher_type_code,
       voucher_cat_code,
       voucher_pay_recv_ind,
       acct_num,
       acct_instr_num,
       voucher_tot_amt,
       voucher_curr_code,
       credit_term_code,
       pay_method_code,
       pay_term_code,
       voucher_pay_days,
       voch_tot_paid_amt,
       voucher_creation_date,
       voucher_creator_init,
       voucher_auth_reqd_ind,
       voucher_auth_date,
       voucher_auth_init,
       voucher_eff_date,
       voucher_print_date,
       voucher_send_to_cust_date,
       voucher_book_date,
       voucher_mod_date,
       voucher_mod_init,
       voucher_writeoff_init,
       voucher_writeoff_date,
       voucher_cust_inv_amt,
       voucher_cust_inv_date,
       voucher_short_cmnt,
       cmnt_num,
       voucher_book_comp_num,
       voucher_book_curr_code,
       voucher_book_exch_rate,
       voucher_xrate_conv_ind,
       voucher_loi_num,
       voucher_arap_acct_code,
       voucher_send_to_arap_date,
       voucher_cust_ref_num,
       voucher_book_prd_date,
       voucher_paid_date,
       voucher_due_date,
       voucher_acct_name,
       voucher_book_comp_name,
       cash_date,
       trans_id,
       resp_trans_id,
       voucher_reversal_ind,
       ref_voucher_num,
       custom_voucher_string,
       voucher_hold_ind,
       max_line_num,
       book_comp_acct_bank_id,
       cp_acct_bank_id,
       voucher_inv_curr_code,    
       voucher_inv_exch_rate, 
       invoice_exch_rate_comment,
       cust_inv_recv_date,
       cust_inv_type_ind,
       special_bank_instr,
       revised_book_comp_bank_id,
       voucher_expected_pay_date,
       external_ref_key,
       cpty_inv_curr_code,
       voucher_approval_date,
       voucher_approval_init,
       sap_invoice_number)
   select
      d.voucher_num,
      d.voucher_status,
      d.voucher_type_code,
      d.voucher_cat_code,
      d.voucher_pay_recv_ind,
      d.acct_num,
      d.acct_instr_num,
      d.voucher_tot_amt,
      d.voucher_curr_code,
      d.credit_term_code,
      d.pay_method_code,
      d.pay_term_code,
      d.voucher_pay_days,
      d.voch_tot_paid_amt,
      d.voucher_creation_date,
      d.voucher_creator_init,
      d.voucher_auth_reqd_ind,
      d.voucher_auth_date,
      d.voucher_auth_init,
      d.voucher_eff_date,
      d.voucher_print_date,
      d.voucher_send_to_cust_date,
      d.voucher_book_date,
      d.voucher_mod_date,
      d.voucher_mod_init,
      d.voucher_writeoff_init,
      d.voucher_writeoff_date,
      d.voucher_cust_inv_amt,
      d.voucher_cust_inv_date,
      d.voucher_short_cmnt,
      d.cmnt_num,
      d.voucher_book_comp_num,
      d.voucher_book_curr_code,
      d.voucher_book_exch_rate,
      d.voucher_xrate_conv_ind,
      d.voucher_loi_num,
      d.voucher_arap_acct_code,
      d.voucher_send_to_arap_date,
      d.voucher_cust_ref_num,
      d.voucher_book_prd_date,
      d.voucher_paid_date,
      d.voucher_due_date,
      d.voucher_acct_name,
      d.voucher_book_comp_name,
      d.cash_date,
      d.trans_id,
      i.trans_id,
      d.voucher_reversal_ind,
      d.ref_voucher_num,
      d.custom_voucher_string,
      d.voucher_hold_ind,
      d.max_line_num,
      d.book_comp_acct_bank_id,
      d.cp_acct_bank_id,
      d.voucher_inv_curr_code,    
      d.voucher_inv_exch_rate, 
      d.invoice_exch_rate_comment,
      d.cust_inv_recv_date,
      d.cust_inv_type_ind,
      d.special_bank_instr,
      d.revised_book_comp_bank_id,
      d.voucher_expected_pay_date,
      d.external_ref_key,
      d.cpty_inv_curr_code,
      d.voucher_approval_date,
      d.voucher_approval_init,
      d.sap_invoice_number
   from deleted d, inserted i
   where d.voucher_num = i.voucher_num 

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'Voucher'

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
             convert(varchar(40), i.voucher_num),
             NULL,
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
                convert(varchar(40), i.voucher_num),
                NULL,
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
             convert(varchar(40), i.voucher_num),
             NULL,
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
             convert(varchar(40), i.voucher_num),
             NULL,
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
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_voucher_hold_ind_chk] CHECK (([voucher_hold_ind]='M' OR [voucher_hold_ind]='Y' OR [voucher_hold_ind]='N'))
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [CK__voucher__voucher__63E3BB6D] CHECK (([voucher_reversal_ind]='N' OR [voucher_reversal_ind]='Y'))
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [CK__voucher__voucher__61FB72FB] CHECK (([voucher_status]='T' OR [voucher_status]='P' OR [voucher_status]='F' OR [voucher_status]=NULL))
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_pk] PRIMARY KEY CLUSTERED  ([voucher_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [voucher_idx1] ON [dbo].[voucher] ([ref_voucher_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk10] FOREIGN KEY ([voucher_mod_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk11] FOREIGN KEY ([voucher_writeoff_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk12] FOREIGN KEY ([pay_method_code]) REFERENCES [dbo].[payment_method] ([pay_method_code])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk13] FOREIGN KEY ([pay_term_code]) REFERENCES [dbo].[payment_term] ([pay_term_code])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk15] FOREIGN KEY ([book_comp_acct_bank_id]) REFERENCES [dbo].[account_bank_info] ([acct_bank_id])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk16] FOREIGN KEY ([cp_acct_bank_id]) REFERENCES [dbo].[account_bank_info] ([acct_bank_id])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk17] FOREIGN KEY ([voucher_inv_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk18] FOREIGN KEY ([revised_book_comp_bank_id]) REFERENCES [dbo].[account_bank_info] ([acct_bank_id])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk19] FOREIGN KEY ([cpty_inv_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk2] FOREIGN KEY ([voucher_book_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk20] FOREIGN KEY ([voucher_approval_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk3] FOREIGN KEY ([acct_num], [acct_instr_num]) REFERENCES [dbo].[account_instruction] ([acct_num], [acct_instr_num])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk5] FOREIGN KEY ([voucher_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk6] FOREIGN KEY ([voucher_book_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk7] FOREIGN KEY ([credit_term_code]) REFERENCES [dbo].[credit_term] ([credit_term_code])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk8] FOREIGN KEY ([voucher_creator_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk9] FOREIGN KEY ([voucher_auth_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
GRANT DELETE ON  [dbo].[voucher] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[voucher] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[voucher] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[voucher] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'voucher', NULL, NULL
GO
