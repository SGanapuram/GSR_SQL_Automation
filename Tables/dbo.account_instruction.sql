CREATE TABLE [dbo].[account_instruction]
(
[acct_num] [int] NOT NULL,
[acct_instr_num] [smallint] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_method_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_instr_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_addr_num] [smallint] NOT NULL,
[acct_cont_num] [int] NOT NULL,
[bank_acct_num] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[num_of_doc_copies] [tinyint] NULL,
[send_doc_by_media] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[instr_analyst_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[book_comp_num] [int] NULL,
[currency_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_group] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[confirm_template_oid] [int] NULL,
[confirm_method_oid] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[account_instruction_deltrg]
on [dbo].[account_instruction]
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
   select @errmsg = '(account_instruction) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_account_instruction
   (acct_num,
    acct_instr_num,
    cmdty_code,
    del_term_code,
    mot_code,
    pay_term_code,
    pay_method_code,
    acct_instr_type_code,
    acct_addr_num,
    acct_cont_num,
    bank_acct_num,
    num_of_doc_copies,
    send_doc_by_media,
    instr_analyst_init,
    book_comp_num,
    currency_code,
    cmdty_group,
    confirm_template_oid,
    confirm_method_oid,
    trans_id,
    resp_trans_id)
select
   d.acct_num,
   d.acct_instr_num,
   d.cmdty_code,
   d.del_term_code,
   d.mot_code,
   d.pay_term_code,
   d.pay_method_code,
   d.acct_instr_type_code,
   d.acct_addr_num,
   d.acct_cont_num,
   d.bank_acct_num,
   d.num_of_doc_copies,
   d.send_doc_by_media,
   d.instr_analyst_init,
   d.book_comp_num,
   d.currency_code,
   d.cmdty_group,
   d.confirm_template_oid,
   d.confirm_method_oid,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[account_instruction_updtrg]
on [dbo].[account_instruction]
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
   raiserror ('(account_instruction) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(account_instruction) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.acct_num = d.acct_num and 
                 i.acct_instr_num = d.acct_instr_num)
begin
   raiserror ('(account_instruction) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(acct_num) or 
   update(acct_instr_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.acct_num = d.acct_num and 
                                   i.acct_instr_num = d.acct_instr_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(account_instruction) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_account_instruction
      (acct_num,
       acct_instr_num,
       cmdty_code,
       del_term_code,
       mot_code,
       pay_term_code,
       pay_method_code,
       acct_instr_type_code,
       acct_addr_num,
       acct_cont_num,
       bank_acct_num,
       num_of_doc_copies,
       send_doc_by_media,
       instr_analyst_init,
       book_comp_num,
       currency_code,
       cmdty_group,
       confirm_template_oid,
       confirm_method_oid,
       trans_id,
       resp_trans_id)
   select
      d.acct_num,
      d.acct_instr_num,
      d.cmdty_code,
      d.del_term_code,
      d.mot_code,
      d.pay_term_code,
      d.pay_method_code,
      d.acct_instr_type_code,
      d.acct_addr_num,
      d.acct_cont_num,
      d.bank_acct_num,
      d.num_of_doc_copies,
      d.send_doc_by_media,
      d.instr_analyst_init,
      d.book_comp_num,
      d.currency_code,
      d.cmdty_group,
      d.confirm_template_oid,
      d.confirm_method_oid,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.acct_num = i.acct_num and
         d.acct_instr_num = i.acct_instr_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[account_instruction] ADD CONSTRAINT [account_instruction_pk] PRIMARY KEY CLUSTERED  ([acct_num], [acct_instr_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [account_instr_idx2] ON [dbo].[account_instruction] ([acct_num], [acct_instr_type_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[account_instruction] ADD CONSTRAINT [account_instruction_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[account_instruction] ADD CONSTRAINT [account_instruction_fk10] FOREIGN KEY ([instr_analyst_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[account_instruction] ADD CONSTRAINT [account_instruction_fk11] FOREIGN KEY ([book_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[account_instruction] ADD CONSTRAINT [account_instruction_fk12] FOREIGN KEY ([currency_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[account_instruction] ADD CONSTRAINT [account_instruction_fk13] FOREIGN KEY ([cmdty_group]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[account_instruction] ADD CONSTRAINT [account_instruction_fk14] FOREIGN KEY ([confirm_template_oid]) REFERENCES [dbo].[confirm_template] ([oid])
GO
ALTER TABLE [dbo].[account_instruction] ADD CONSTRAINT [account_instruction_fk15] FOREIGN KEY ([confirm_method_oid]) REFERENCES [dbo].[confirm_method] ([oid])
GO
ALTER TABLE [dbo].[account_instruction] ADD CONSTRAINT [account_instruction_fk2] FOREIGN KEY ([acct_num], [acct_addr_num]) REFERENCES [dbo].[account_address] ([acct_num], [acct_addr_num])
GO
ALTER TABLE [dbo].[account_instruction] ADD CONSTRAINT [account_instruction_fk3] FOREIGN KEY ([acct_num], [acct_cont_num]) REFERENCES [dbo].[account_contact] ([acct_num], [acct_cont_num])
GO
ALTER TABLE [dbo].[account_instruction] ADD CONSTRAINT [account_instruction_fk4] FOREIGN KEY ([acct_instr_type_code]) REFERENCES [dbo].[account_instr_type] ([acct_instr_type_code])
GO
ALTER TABLE [dbo].[account_instruction] ADD CONSTRAINT [account_instruction_fk5] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[account_instruction] ADD CONSTRAINT [account_instruction_fk6] FOREIGN KEY ([del_term_code]) REFERENCES [dbo].[delivery_term] ([del_term_code])
GO
ALTER TABLE [dbo].[account_instruction] ADD CONSTRAINT [account_instruction_fk7] FOREIGN KEY ([mot_code]) REFERENCES [dbo].[mot] ([mot_code])
GO
ALTER TABLE [dbo].[account_instruction] ADD CONSTRAINT [account_instruction_fk8] FOREIGN KEY ([pay_method_code]) REFERENCES [dbo].[payment_method] ([pay_method_code])
GO
ALTER TABLE [dbo].[account_instruction] ADD CONSTRAINT [account_instruction_fk9] FOREIGN KEY ([pay_term_code]) REFERENCES [dbo].[payment_term] ([pay_term_code])
GO
GRANT DELETE ON  [dbo].[account_instruction] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[account_instruction] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[account_instruction] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[account_instruction] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'account_instruction', NULL, NULL
GO
