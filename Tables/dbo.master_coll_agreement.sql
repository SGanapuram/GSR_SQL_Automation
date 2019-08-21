CREATE TABLE [dbo].[master_coll_agreement]
(
[mca_num] [int] NOT NULL,
[cr_analyst_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mca_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mca_enabled] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[main_curr] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[issue_date] [datetime] NOT NULL,
[expiration_date] [datetime] NULL,
[mca_review_date] [datetime] NULL,
[review_email_group] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mca_cmnt_num] [int] NULL,
[mca_formula_num] [int] NULL,
[mtm_amount] [float] NULL,
[mtm_amount_date] [datetime] NULL,
[coll_balance] [float] NULL,
[coll_balance_date] [datetime] NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[order_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tenor] [int] NULL,
[counterparty_inv_num] [int] NOT NULL,
[booking_inv_num] [int] NULL,
[b_contract_limit] [float] NULL,
[b_limit_curr_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[b_contract_increment] [float] NULL,
[b_increment_curr_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[b_pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[b_pay_method_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[c_contract_limit] [float] NOT NULL,
[c_limit_curr_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[c_contract_increment] [float] NOT NULL,
[c_increment_curr_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[c_pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[c_pay_method_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[master_coll_agreement_deltrg]
on [dbo].[master_coll_agreement]
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
   select @errmsg = '(master_coll_agreement) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_master_coll_agreement
   (mca_num,
    cr_analyst_init,
    mca_status,
    mca_enabled,
    main_curr,
    issue_date,
    expiration_date,
    mca_review_date,
    review_email_group,
    mca_cmnt_num,
    mca_formula_num,
    mtm_amount,
    mtm_amount_date,
    coll_balance,
    coll_balance_date,
    cmdty_code,
    order_type_code,
    tenor,
    counterparty_inv_num,
    booking_inv_num,
    b_contract_limit,
    b_limit_curr_code,
    b_contract_increment,
    b_increment_curr_code,
    b_pay_term_code,
    b_pay_method_code,
    c_contract_limit,
    c_limit_curr_code,
    c_contract_increment,
    c_increment_curr_code,
    c_pay_term_code,
    c_pay_method_code,
    trans_id,
    resp_trans_id)
select
   d.mca_num,
   d.cr_analyst_init,
   d.mca_status,
   d.mca_enabled,
   d.main_curr,
   d.issue_date,
   d.expiration_date,
   d.mca_review_date,
   d.review_email_group,
   d.mca_cmnt_num,
   d.mca_formula_num,
   d.mtm_amount,
   d.mtm_amount_date,
   d.coll_balance,
   d.coll_balance_date,
   d.cmdty_code,
   d.order_type_code,
   d.tenor,
   d.counterparty_inv_num,
   d.booking_inv_num,
   d.b_contract_limit,
   d.b_limit_curr_code,
   d.b_contract_increment,
   d.b_increment_curr_code,
   d.b_pay_term_code,
   d.b_pay_method_code,
   d.c_contract_limit,
   d.c_limit_curr_code,
   d.c_contract_increment,
   d.c_increment_curr_code,
   d.c_pay_term_code,
   d.c_pay_method_code,
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

create trigger [dbo].[master_coll_agreement_updtrg]
on [dbo].[master_coll_agreement]
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
   raiserror ('(master_coll_agreement) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(master_coll_agreement) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.mca_num = d.mca_num )
begin
   raiserror ('(master_coll_agreement) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(mca_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.mca_num = d.mca_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(master_coll_agreement) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_master_coll_agreement
      (mca_num,
       cr_analyst_init,
       mca_status,
       mca_enabled,
       main_curr,
       issue_date,
       expiration_date,
       mca_review_date,
       review_email_group,
       mca_cmnt_num,
       mca_formula_num,
       mtm_amount,
       mtm_amount_date,
       coll_balance,
       coll_balance_date,
       cmdty_code,
       order_type_code,
       tenor,
       counterparty_inv_num,
       booking_inv_num,
       b_contract_limit,
       b_limit_curr_code,
       b_contract_increment,
       b_increment_curr_code,
       b_pay_term_code,
       b_pay_method_code,
       c_contract_limit,
       c_limit_curr_code,
       c_contract_increment,
       c_increment_curr_code,
       c_pay_term_code,
       c_pay_method_code,
       trans_id,
       resp_trans_id)
   select
      d.mca_num,
      d.cr_analyst_init,
      d.mca_status,
      d.mca_enabled,
      d.main_curr,
      d.issue_date,
      d.expiration_date,
      d.mca_review_date,
      d.review_email_group,
      d.mca_cmnt_num,
      d.mca_formula_num,
      d.mtm_amount,
      d.mtm_amount_date,
      d.coll_balance,
      d.coll_balance_date,
      d.cmdty_code,
      d.order_type_code,
      d.tenor,
      d.counterparty_inv_num,
      d.booking_inv_num,
      d.b_contract_limit,
      d.b_limit_curr_code,
      d.b_contract_increment,
      d.b_increment_curr_code,
      d.b_pay_term_code,
      d.b_pay_method_code,
      d.c_contract_limit,
      d.c_limit_curr_code,
      d.c_contract_increment,
      d.c_increment_curr_code,
      d.c_pay_term_code,
      d.c_pay_method_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.mca_num = i.mca_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[master_coll_agreement] ADD CONSTRAINT [master_coll_agreement_pk] PRIMARY KEY CLUSTERED  ([mca_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[master_coll_agreement] ADD CONSTRAINT [master_coll_agreement_fk1] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[master_coll_agreement] ADD CONSTRAINT [master_coll_agreement_fk3] FOREIGN KEY ([cr_analyst_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[master_coll_agreement] ADD CONSTRAINT [master_coll_agreement_fk5] FOREIGN KEY ([b_pay_method_code]) REFERENCES [dbo].[mca_payment_method] ([pay_method_code])
GO
ALTER TABLE [dbo].[master_coll_agreement] ADD CONSTRAINT [master_coll_agreement_fk6] FOREIGN KEY ([c_pay_method_code]) REFERENCES [dbo].[mca_payment_method] ([pay_method_code])
GO
ALTER TABLE [dbo].[master_coll_agreement] ADD CONSTRAINT [master_coll_agreement_fk7] FOREIGN KEY ([order_type_code]) REFERENCES [dbo].[order_type] ([order_type_code])
GO
GRANT DELETE ON  [dbo].[master_coll_agreement] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[master_coll_agreement] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[master_coll_agreement] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[master_coll_agreement] TO [next_usr]
GO
