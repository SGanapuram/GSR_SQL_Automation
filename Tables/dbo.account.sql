CREATE TABLE [dbo].[account]
(
[acct_num] [int] NOT NULL,
[acct_short_name] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_full_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_parent_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_sub_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_vat_code] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_fiscal_code] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_sub_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[contract_cmnt_num] [int] NULL,
[man_input_sec_qty_required] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [DF__account__man_inp__7E6CC920] DEFAULT ('N'),
[legal_entity_num] [int] NULL,
[risk_transfer_ind_code] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[govt_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[allows_netout] [bit] NOT NULL CONSTRAINT [DF__account__allows___00551192] DEFAULT ((0)),
[allows_bookout] [bit] NOT NULL CONSTRAINT [DF__account__allows___014935CB] DEFAULT ((0)),
[master_agreement_date] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[account_deltrg]
on [dbo].[account]
for delete
as
declare @num_rows   int,
        @errmsg     varchar(255),
        @atrans_id  int

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
   select @errmsg = '(account) Failed to obtain a valid responsible trans_id.'
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

   /* BEGIN_TRANSACTION_TOUCH */

   insert dbo.transaction_touch
   select 'DELETE',
          'Account',
          'DIRECT',
          convert(varchar(40), d.acct_num),
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          @atrans_id,
          it.sequence
   from deleted d, dbo.icts_transaction it
   where it.trans_id = @atrans_id and
         it.type != 'E'
 
   /* END_TRANSACTION_TOUCH */

   /* AUDIT_CODE_BEGIN */
   insert dbo.aud_account
      (acct_num,
       acct_short_name,
       acct_full_name,
       acct_status,
       acct_type_code,
       acct_parent_ind,
       acct_sub_ind,
       acct_vat_code,
       acct_fiscal_code,
       acct_sub_type_code,
       contract_cmnt_num,
       man_input_sec_qty_required,
       legal_entity_num,
       risk_transfer_ind_code,
       govt_code,
       allows_netout,
       allows_bookout,
       master_agreement_date,
       trans_id,
       resp_trans_id)
   select
      d.acct_num,
      d.acct_short_name,
      d.acct_full_name,
      d.acct_status,
      d.acct_type_code,
      d.acct_parent_ind,
      d.acct_sub_ind,
      d.acct_vat_code,
      d.acct_fiscal_code,
      d.acct_sub_type_code,
      d.contract_cmnt_num,
      d.man_input_sec_qty_required,
      d.legal_entity_num,
      d.risk_transfer_ind_code,
      d.govt_code,
      d.allows_netout,
      d.allows_bookout,
      d.master_agreement_date,
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

create trigger [dbo].[account_instrg]
on [dbo].[account]
for insert
as
declare @num_rows       int,
        @count_num_rows int,
        @errmsg         varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'INSERT',
       'Account',
       'DIRECT',
       convert(varchar(40), i.acct_num),
       null,
       null,
       null,
       null,
       null,
       null,
       null,
       i.trans_id,
       it.sequence
from inserted i, dbo.icts_transaction it
where i.trans_id = it.trans_id and
      it.type != 'E'
 
/* END_TRANSACTION_TOUCH */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[account_updtrg]
on [dbo].[account]
for update
as
declare @num_rows       int,
        @count_num_rows int,
        @dummy_update   int,
        @errmsg         varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

select @dummy_update = 0

/* RECORD_STAMP_BEGIN */
if not update(trans_id) 
begin
   raiserror ('(account) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(account) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.acct_num = d.acct_num )
begin
   raiserror ('(account) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(acct_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.acct_num = d.acct_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(account) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'UPDATE',
       'Account',
       'DIRECT',
       convert(varchar(40), i.acct_num),
       null,
       null,
       null,
       null,
       null,
       null,
       null,
       i.trans_id,
       it.sequence
from inserted i, dbo.icts_transaction it
where i.trans_id = it.trans_id and
      it.type != 'E'
  
/* END_TRANSACTION_TOUCH */

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_account
      (acct_num,
       acct_short_name,
       acct_full_name,
       acct_status,
       acct_type_code,
       acct_parent_ind,
       acct_sub_ind,
       acct_vat_code,
       acct_fiscal_code,
       acct_sub_type_code,
       contract_cmnt_num,
       man_input_sec_qty_required,
       legal_entity_num,
       risk_transfer_ind_code,
       govt_code,
       allows_netout,
       allows_bookout,
       master_agreement_date,
       trans_id,
       resp_trans_id)
   select
      d.acct_num,
      d.acct_short_name,
      d.acct_full_name,
      d.acct_status,
      d.acct_type_code,
      d.acct_parent_ind,
      d.acct_sub_ind,
      d.acct_vat_code,
      d.acct_fiscal_code,
      d.acct_sub_type_code,
      d.contract_cmnt_num,
      d.man_input_sec_qty_required,
      d.legal_entity_num,
      d.risk_transfer_ind_code,
      d.govt_code,
      d.allows_netout,
      d.allows_bookout,
      d.master_agreement_date,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.acct_num = i.acct_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[account] ADD CONSTRAINT [CK__account__man_inp__7F60ED59] CHECK (([man_input_sec_qty_required]='N' OR [man_input_sec_qty_required]='Y'))
GO
ALTER TABLE [dbo].[account] ADD CONSTRAINT [account_pk] PRIMARY KEY CLUSTERED  ([acct_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [account_TS_idx90] ON [dbo].[account] ([acct_num], [acct_short_name]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [account] ON [dbo].[account] ([acct_short_name], [acct_type_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[account] ADD CONSTRAINT [account_fk1] FOREIGN KEY ([acct_type_code]) REFERENCES [dbo].[account_type] ([acct_type_code])
GO
ALTER TABLE [dbo].[account] ADD CONSTRAINT [account_fk3] FOREIGN KEY ([contract_cmnt_num]) REFERENCES [dbo].[comment] ([cmnt_num])
GO
ALTER TABLE [dbo].[account] ADD CONSTRAINT [account_fk4] FOREIGN KEY ([risk_transfer_ind_code]) REFERENCES [dbo].[risk_transfer_indicator] ([risk_transfer_ind_code])
GO
GRANT DELETE ON  [dbo].[account] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[account] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[account] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[account] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'account', NULL, NULL
GO
