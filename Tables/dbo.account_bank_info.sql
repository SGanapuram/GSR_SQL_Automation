CREATE TABLE [dbo].[account_bank_info]
(
[acct_bank_id] [int] NOT NULL,
[acct_num] [int] NOT NULL,
[bank_name] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bank_acct_num] [int] NULL,
[addr_acct_num] [int] NULL,
[addr_acct_addr_num] [smallint] NULL,
[vc_acct_num] [int] NULL,
[gl_acct_code] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[gl_acct_descr] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[p_or_r_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bank_acct_no] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bank_addr] [varchar] (90) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[swift_code] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_method_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_send_id] [smallint] NULL,
[acct_bank_routing_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_bank_info_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__account_b__acct___1273C1CD] DEFAULT ('A'),
[corresp_bank_name] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[corresp_bank_routing_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[further_credit_to] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[currency_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[corresp_swift_code] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[corresp_bank_acct_no] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[corresp_bank_instr_type_id] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[book_comp_num] [int] NULL,
[further_credit_to_ext_acct_key] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[selling_office_num] [smallint] NULL,
[bank_short_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_bank_iban_num] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_bank_city] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_bank_country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[corresp_bank_iban_num] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[corresp_bank_city] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[corresp_bank_country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[special_payment_instr] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[account_bank_info_deltrg]
on [dbo].[account_bank_info]
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
   select @errmsg = '(account_bank_info) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_account_bank_info
   (acct_bank_id,
    acct_num,
    bank_name,
    bank_acct_num,
    addr_acct_num,
    addr_acct_addr_num,
    vc_acct_num,
    gl_acct_code,
    gl_acct_descr,
    p_or_r_ind,
    bank_acct_no,
    bank_addr,
    swift_code,
    pay_method_code,
    cost_send_id,
    acct_bank_routing_num,
    acct_bank_info_status,
    corresp_bank_name,
    corresp_bank_routing_num,
    further_credit_to,
    currency_code,      
    corresp_swift_code,
    corresp_bank_acct_no,
    corresp_bank_instr_type_id,
    book_comp_num,
    further_credit_to_ext_acct_key,
    selling_office_num,
    bank_short_name,
    acct_bank_iban_num,
    acct_bank_city,
    acct_bank_country_code,
    corresp_bank_iban_num,
    corresp_bank_city,
    corresp_bank_country_code,
    special_payment_instr,
    trans_id,
    resp_trans_id)
select
   d.acct_bank_id,
   d.acct_num,
   d.bank_name,
   d.bank_acct_num,
   d.addr_acct_num,
   d.addr_acct_addr_num,
   d.vc_acct_num,
   d.gl_acct_code,
   d.gl_acct_descr,
   d.p_or_r_ind,
   d.bank_acct_no,
   d.bank_addr,
   d.swift_code,
   d.pay_method_code,
   d.cost_send_id,
   d.acct_bank_routing_num,
   d.acct_bank_info_status,
   d.corresp_bank_name,
   d.corresp_bank_routing_num,
   d.further_credit_to,
   d.currency_code,      
   d.corresp_swift_code,
   d.corresp_bank_acct_no,
   d.corresp_bank_instr_type_id,
   d.book_comp_num,
   d.further_credit_to_ext_acct_key,
   d.selling_office_num,
   d.bank_short_name,
   d.acct_bank_iban_num,
   d.acct_bank_city,
   d.acct_bank_country_code,
   d.corresp_bank_iban_num,
   d.corresp_bank_city,
   d.corresp_bank_country_code,
   d.special_payment_instr,
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

create trigger [dbo].[account_bank_info_updtrg]
on [dbo].[account_bank_info]
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
   raiserror ('(account_bank_info) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(account_bank_info) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.acct_bank_id = d.acct_bank_id )
begin
   raiserror ('(account_bank_info) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(acct_bank_id) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.acct_bank_id = d.acct_bank_id )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(account_bank_info) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_account_bank_info
      (acct_bank_id,
       acct_num,
       bank_name,
       bank_acct_num,
       addr_acct_num,
       addr_acct_addr_num,
       vc_acct_num,
       gl_acct_code,
       gl_acct_descr,
       p_or_r_ind,
       bank_acct_no,
       bank_addr,
       swift_code,
       pay_method_code,
       cost_send_id,
       acct_bank_routing_num,
       acct_bank_info_status,
       corresp_bank_name,
       corresp_bank_routing_num,
       further_credit_to,
       currency_code,      
       corresp_swift_code,
       corresp_bank_acct_no,
       corresp_bank_instr_type_id,
       book_comp_num,
       further_credit_to_ext_acct_key,
       selling_office_num,
       bank_short_name,
       acct_bank_iban_num,
       acct_bank_city,
       acct_bank_country_code,
       corresp_bank_iban_num,
       corresp_bank_city,
       corresp_bank_country_code,
       special_payment_instr,
       trans_id,
       resp_trans_id)
   select
      d.acct_bank_id,
      d.acct_num,
      d.bank_name,
      d.bank_acct_num,
      d.addr_acct_num,
      d.addr_acct_addr_num,
      d.vc_acct_num,
      d.gl_acct_code,
      d.gl_acct_descr,
      d.p_or_r_ind,
      d.bank_acct_no,
      d.bank_addr,
      d.swift_code,
      d.pay_method_code,
      d.cost_send_id,
      d.acct_bank_routing_num,
      d.acct_bank_info_status,
      d.corresp_bank_name,
      d.corresp_bank_routing_num,
      d.further_credit_to,
      d.currency_code,      
      d.corresp_swift_code,
      d.corresp_bank_acct_no,
      d.corresp_bank_instr_type_id,
      d.book_comp_num,
      d.further_credit_to_ext_acct_key,
      d.selling_office_num,
      d.bank_short_name,
      d.acct_bank_iban_num,
      d.acct_bank_city,
      d.acct_bank_country_code,
      d.corresp_bank_iban_num,
      d.corresp_bank_city,
      d.corresp_bank_country_code,
      d.special_payment_instr,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.acct_bank_id = i.acct_bank_id 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[account_bank_info] ADD CONSTRAINT [CK__account_b__acct___1367E606] CHECK (([acct_bank_info_status]='I' OR [acct_bank_info_status]='A'))
GO
ALTER TABLE [dbo].[account_bank_info] ADD CONSTRAINT [CK__account_b__p_or___117F9D94] CHECK (([p_or_r_ind]='r' OR [p_or_r_ind]='p' OR [p_or_r_ind]='R' OR [p_or_r_ind]='P'))
GO
ALTER TABLE [dbo].[account_bank_info] ADD CONSTRAINT [account_bank_info_pk] PRIMARY KEY CLUSTERED  ([acct_bank_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [account_bank_info_idx2] ON [dbo].[account_bank_info] ([acct_num], [vc_acct_num], [p_or_r_ind], [pay_method_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[account_bank_info] ADD CONSTRAINT [account_bank_info_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[account_bank_info] ADD CONSTRAINT [account_bank_info_fk2] FOREIGN KEY ([pay_method_code]) REFERENCES [dbo].[payment_method] ([pay_method_code])
GO
ALTER TABLE [dbo].[account_bank_info] ADD CONSTRAINT [account_bank_info_fk3] FOREIGN KEY ([currency_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[account_bank_info] ADD CONSTRAINT [account_bank_info_fk6] FOREIGN KEY ([book_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
GRANT DELETE ON  [dbo].[account_bank_info] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[account_bank_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[account_bank_info] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[account_bank_info] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'account_bank_info', NULL, NULL
GO
