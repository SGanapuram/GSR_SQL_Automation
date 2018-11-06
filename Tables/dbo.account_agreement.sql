CREATE TABLE [dbo].[account_agreement]
(
[agreement_num] [int] NOT NULL,
[acct_num] [int] NOT NULL,
[trade_group_num] [int] NOT NULL,
[product_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__account_a__produ__07F6335A] DEFAULT ('F'),
[agreement_code] [char] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ext_agreement_code] [char] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[confirm_by] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[target_book_comp_num] [int] NULL,
[forward_netting_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__account_a__forwa__09DE7BCC] DEFAULT ('N'),
[voucher_netting_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__account_a__vouch__0BC6C43E] DEFAULT ('N'),
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[account_agreement_deltrg]
on [dbo].[account_agreement]
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
   select @errmsg = '(account_agreement) Failed to obtain a valid responsible trans_id.'
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


/* AUDIT_CODE_BEGIN */
insert dbo.aud_account_agreement
   (agreement_num,
    acct_num, 
    trade_group_num,  
    product_type,
    agreement_code,  
    ext_agreement_code,  
    confirm_by,
    target_book_comp_num,
    forward_netting_ind,
    voucher_netting_ind,
    trans_id,
    resp_trans_id)
select
   d.agreement_num,
   d.acct_num, 
   d.trade_group_num,  
   d.product_type,
   d.agreement_code,  
   d.ext_agreement_code,  
   d.confirm_by,
   d.target_book_comp_num,
   d.forward_netting_ind,
   d.voucher_netting_ind,
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

create trigger [dbo].[account_agreement_updtrg]
on [dbo].[account_agreement]
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
   raiserror ('(account_agreement) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(account_agreement) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.agreement_num = d.agreement_num )
begin
   raiserror ('(account_agreement) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(agreement_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.agreement_num = d.agreement_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(account_agreement) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_account_agreement
   (agreement_num,
    acct_num, 
    trade_group_num,  
    product_type,
    agreement_code,  
    ext_agreement_code,  
    confirm_by,
    target_book_comp_num,
    forward_netting_ind,
    voucher_netting_ind,
    trans_id,
    resp_trans_id)
   select
      d.agreement_num,
      d.acct_num, 
      d.trade_group_num,  
      d.product_type,
      d.agreement_code,  
      d.ext_agreement_code,  
      d.confirm_by,
      d.target_book_comp_num,
      d.forward_netting_ind,
      d.voucher_netting_ind,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.agreement_num = i.agreement_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[account_agreement] ADD CONSTRAINT [CK__account_a__forwa__0AD2A005] CHECK (([forward_netting_ind]='N' OR [forward_netting_ind]='Y'))
GO
ALTER TABLE [dbo].[account_agreement] ADD CONSTRAINT [CK__account_a__produ__08EA5793] CHECK (([product_type]='E' OR [product_type]='T' OR [product_type]='S' OR [product_type]='P' OR [product_type]='F'))
GO
ALTER TABLE [dbo].[account_agreement] ADD CONSTRAINT [CK__account_a__vouch__0CBAE877] CHECK (([voucher_netting_ind]='N' OR [voucher_netting_ind]='Y'))
GO
ALTER TABLE [dbo].[account_agreement] ADD CONSTRAINT [account_agreement_pk] PRIMARY KEY CLUSTERED  ([agreement_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[account_agreement] ADD CONSTRAINT [account_agreement_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[account_agreement] ADD CONSTRAINT [account_agreement_fk2] FOREIGN KEY ([trade_group_num]) REFERENCES [dbo].[trade_group] ([trade_group_num])
GO
ALTER TABLE [dbo].[account_agreement] ADD CONSTRAINT [account_agreement_fk3] FOREIGN KEY ([target_book_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
GRANT DELETE ON  [dbo].[account_agreement] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[account_agreement] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[account_agreement] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[account_agreement] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'account_agreement', NULL, NULL
GO
