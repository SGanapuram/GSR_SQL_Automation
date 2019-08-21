CREATE TABLE [dbo].[account_credit_limit]
(
[acct_num] [int] NOT NULL,
[acct_limit_num] [smallint] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inc_out_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[limit_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[limit_eff_date] [datetime] NOT NULL,
[limit_exp_date] [datetime] NOT NULL,
[limit_qty] [float] NULL,
[limit_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[limit_amt] [float] NULL,
[limit_amt_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[prim_cr_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sec_cr_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cr_anly_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[account_credit_limit_deltrg]
on [dbo].[account_credit_limit]
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
   select @errmsg = '(account_credit_limit) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_account_credit_limit
   (acct_num,
    acct_limit_num,
    cmdty_code,
    mot_code,
    inc_out_ind,
    limit_type_code,
    limit_eff_date,
    limit_exp_date,
    limit_qty,
    limit_qty_uom_code,
    limit_amt,
    limit_amt_curr_code,
    prim_cr_term_code,
    sec_cr_term_code,
    cr_anly_init,
    trans_id,
    resp_trans_id)
select
   d.acct_num,
   d.acct_limit_num,
   d.cmdty_code,
   d.mot_code,
   d.inc_out_ind,
   d.limit_type_code,
   d.limit_eff_date,
   d.limit_exp_date,
   d.limit_qty,
   d.limit_qty_uom_code,
   d.limit_amt,
   d.limit_amt_curr_code,
   d.prim_cr_term_code,
   d.sec_cr_term_code,
   d.cr_anly_init,
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

create trigger [dbo].[account_credit_limit_updtrg]
on [dbo].[account_credit_limit]
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
   raiserror ('(account_credit_limit) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(account_credit_limit) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.acct_num = d.acct_num and 
                 i.acct_limit_num = d.acct_limit_num )
begin
   raiserror ('(account_credit_limit) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(acct_num) or 
   update(acct_limit_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.acct_num = d.acct_num and 
                                   i.acct_limit_num = d.acct_limit_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(account_credit_limit) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_account_credit_limit
      (acct_num,
       acct_limit_num,
       cmdty_code,
       mot_code,
       inc_out_ind,
       limit_type_code,
       limit_eff_date,
       limit_exp_date,
       limit_qty,
       limit_qty_uom_code,
       limit_amt,
       limit_amt_curr_code,
       prim_cr_term_code,
       sec_cr_term_code,
       cr_anly_init,
       trans_id,
       resp_trans_id)
   select
      d.acct_num,
      d.acct_limit_num,
      d.cmdty_code,
      d.mot_code,
      d.inc_out_ind,
      d.limit_type_code,
      d.limit_eff_date,
      d.limit_exp_date,
      d.limit_qty,
      d.limit_qty_uom_code,
      d.limit_amt,
      d.limit_amt_curr_code,
      d.prim_cr_term_code,
      d.sec_cr_term_code,
      d.cr_anly_init,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.acct_num = i.acct_num and
         d.acct_limit_num = i.acct_limit_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[account_credit_limit] ADD CONSTRAINT [account_credit_limit_pk] PRIMARY KEY CLUSTERED  ([acct_num], [acct_limit_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[account_credit_limit] ADD CONSTRAINT [account_credit_limit_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[account_credit_limit] ADD CONSTRAINT [account_credit_limit_fk2] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[account_credit_limit] ADD CONSTRAINT [account_credit_limit_fk3] FOREIGN KEY ([limit_amt_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[account_credit_limit] ADD CONSTRAINT [account_credit_limit_fk4] FOREIGN KEY ([prim_cr_term_code]) REFERENCES [dbo].[credit_term] ([credit_term_code])
GO
ALTER TABLE [dbo].[account_credit_limit] ADD CONSTRAINT [account_credit_limit_fk5] FOREIGN KEY ([sec_cr_term_code]) REFERENCES [dbo].[credit_term] ([credit_term_code])
GO
ALTER TABLE [dbo].[account_credit_limit] ADD CONSTRAINT [account_credit_limit_fk6] FOREIGN KEY ([cr_anly_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[account_credit_limit] ADD CONSTRAINT [account_credit_limit_fk7] FOREIGN KEY ([limit_type_code]) REFERENCES [dbo].[limit_type] ([limit_type_code])
GO
ALTER TABLE [dbo].[account_credit_limit] ADD CONSTRAINT [account_credit_limit_fk8] FOREIGN KEY ([mot_code]) REFERENCES [dbo].[mot] ([mot_code])
GO
ALTER TABLE [dbo].[account_credit_limit] ADD CONSTRAINT [account_credit_limit_fk9] FOREIGN KEY ([limit_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[account_credit_limit] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[account_credit_limit] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[account_credit_limit] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[account_credit_limit] TO [next_usr]
GO
