CREATE TABLE [dbo].[voucher_duedate]
(
[voucher_num] [int] NOT NULL,
[voudue_duedate] [datetime] NOT NULL,
[voudue_seq_num] [smallint] NOT NULL,
[voudue_amt] [float] NULL,
[voudue_pay_recv_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voudue_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voudue_tot_paid_amt] [float] NULL,
[voudue_revised_due_date] [datetime] NULL,
[voudue_cancel_corr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voudue_creation_date] [datetime] NULL,
[voudue_creator_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voudue_mod_date] [datetime] NULL,
[voudue_mod_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[voucher_duedate_deltrg]
on [dbo].[voucher_duedate]
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
   select @errmsg = '(voucher_duedate) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_voucher_duedate
   (voucher_num,
    voudue_duedate,
    voudue_seq_num,
    voudue_amt,
    voudue_pay_recv_ind,
    voudue_status,
    voudue_tot_paid_amt,
    voudue_revised_due_date,
    voudue_cancel_corr_code,
    voudue_creation_date,
    voudue_creator_init,
    voudue_mod_date,
    voudue_mod_init,
    trans_id,
    resp_trans_id)
select
   d.voucher_num,
   d.voudue_duedate,
   d.voudue_seq_num,
   d.voudue_amt,
   d.voudue_pay_recv_ind,
   d.voudue_status,
   d.voudue_tot_paid_amt,
   d.voudue_revised_due_date,
   d.voudue_cancel_corr_code,
   d.voudue_creation_date,
   d.voudue_creator_init,
   d.voudue_mod_date,
   d.voudue_mod_init,
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

create trigger [dbo].[voucher_duedate_updtrg]
on [dbo].[voucher_duedate]
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
   raiserror ('(voucher_duedate) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(voucher_duedate) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.voucher_num = d.voucher_num and 
                 i.voudue_duedate = d.voudue_duedate and 
                 i.voudue_seq_num = d.voudue_seq_num )
begin
   raiserror ('(voucher_duedate) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(voucher_num) or  
   update(voudue_duedate) or  
   update(voudue_seq_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.voucher_num = d.voucher_num and 
                                   i.voudue_duedate = d.voudue_duedate and 
                                   i.voudue_seq_num = d.voudue_seq_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(voucher_duedate) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_voucher_duedate
      (voucher_num,
       voudue_duedate,
       voudue_seq_num,
       voudue_amt,
       voudue_pay_recv_ind,
       voudue_status,
       voudue_tot_paid_amt,
       voudue_revised_due_date,
       voudue_cancel_corr_code,
       voudue_creation_date,
       voudue_creator_init,
       voudue_mod_date,
       voudue_mod_init,
       trans_id,
       resp_trans_id)
   select
      d.voucher_num,
      d.voudue_duedate,
      d.voudue_seq_num,
      d.voudue_amt,
      d.voudue_pay_recv_ind,
      d.voudue_status,
      d.voudue_tot_paid_amt,
      d.voudue_revised_due_date,
      d.voudue_cancel_corr_code,
      d.voudue_creation_date,
      d.voudue_creator_init,
      d.voudue_mod_date,
      d.voudue_mod_init,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.voucher_num = i.voucher_num and
         d.voudue_duedate = i.voudue_duedate and
         d.voudue_seq_num = i.voudue_seq_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[voucher_duedate] ADD CONSTRAINT [voucher_duedate_pk] PRIMARY KEY CLUSTERED  ([voucher_num], [voudue_duedate], [voudue_seq_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[voucher_duedate] ADD CONSTRAINT [voucher_duedate_fk1] FOREIGN KEY ([voudue_creator_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[voucher_duedate] ADD CONSTRAINT [voucher_duedate_fk2] FOREIGN KEY ([voudue_mod_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
GRANT DELETE ON  [dbo].[voucher_duedate] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[voucher_duedate] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[voucher_duedate] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[voucher_duedate] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'voucher_duedate', NULL, NULL
GO
