CREATE TABLE [dbo].[voucher_pay_approval]
(
[voucher_pay_approval_num] [int] NOT NULL,
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[payment_approval_limit] [float] NOT NULL,
[book_comp_num] [int] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[voucher_pay_approval_deltrg]
on [dbo].[voucher_pay_approval]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   bigint

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
   select @errmsg = '(voucher_pay_approval) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,16,1)
   if @@trancount > 0 rollback tran

   return
end


insert dbo.aud_voucher_pay_approval
(   
    voucher_pay_approval_num,
    user_init,
    payment_approval_limit, 
    book_comp_num,
    trans_id,
    resp_trans_id
)
select
   d.voucher_pay_approval_num,
   d.user_init,
   d.payment_approval_limit, 
   d.book_comp_num,
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

create trigger [dbo].[voucher_pay_approval_updtrg]
on [dbo].[voucher_pay_approval]
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
   raiserror ('(voucher_pay_approval) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(voucher_pay_approval) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.voucher_pay_approval_num = d.voucher_pay_approval_num)
begin
   raiserror ('(voucher_pay_approval) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(voucher_pay_approval_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.voucher_pay_approval_num = d.voucher_pay_approval_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(voucher_pay_approval) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_voucher_pay_approval
      (voucher_pay_approval_num,
       user_init,
       payment_approval_limit, 
       book_comp_num,
       trans_id,
       resp_trans_id)
   select
      d.voucher_pay_approval_num,
      d.user_init,
      d.payment_approval_limit, 
      d.book_comp_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.voucher_pay_approval_num = i.voucher_pay_approval_num

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[voucher_pay_approval] ADD CONSTRAINT [voucher_pay_approval_pk] PRIMARY KEY CLUSTERED  ([voucher_pay_approval_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[voucher_pay_approval] ADD CONSTRAINT [voucher_pay_approval_fk1] FOREIGN KEY ([user_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[voucher_pay_approval] ADD CONSTRAINT [voucher_pay_approval_fk2] FOREIGN KEY ([book_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
GRANT DELETE ON  [dbo].[voucher_pay_approval] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[voucher_pay_approval] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[voucher_pay_approval] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[voucher_pay_approval] TO [next_usr]
GO
