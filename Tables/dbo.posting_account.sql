CREATE TABLE [dbo].[posting_account]
(
[posting_account_num] [int] NOT NULL,
[cost_period_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[gl_acct_dr_code] [char] (45) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[gl_acct_cr_code] [char] (45) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_book_comp_num] [int] NULL,
[profit_center] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_num] [int] NULL,
[port_num] [int] NULL,
[pos_group_num] [int] NULL,
[cost_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_status] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_type_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_prim_sec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_est_final_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_pay_rec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_price_curr_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_book_curr_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[order_type_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bus_cost_type_num] [int] NULL,
[vc_acct_num] [int] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[posting_account_deltrg]
on [dbo].[posting_account]
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
   select @errmsg = '(posting_account) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_posting_account
   (posting_account_num,
    cost_period_ind,
    gl_acct_dr_code,
    gl_acct_cr_code,
    cost_book_comp_num,
    profit_center,
    acct_num,
    port_num,
    pos_group_num,
    cost_code,
    cost_status,
    cost_type_code,
    cost_prim_sec_ind,
    cost_est_final_ind,
    cost_pay_rec_ind,
    cost_price_curr_code,
    cost_book_curr_code,
    order_type_code,
    bus_cost_type_num,
    vc_acct_num,
    trans_id,
    resp_trans_id)
select
   d.posting_account_num,
   d.cost_period_ind,
   d.gl_acct_dr_code,
   d.gl_acct_cr_code,
   d.cost_book_comp_num,
   d.profit_center,
   d.acct_num,
   d.port_num,
   d.pos_group_num,
   d.cost_code,
   d.cost_status,
   d.cost_type_code,
   d.cost_prim_sec_ind,
   d.cost_est_final_ind,
   d.cost_pay_rec_ind,
   d.cost_price_curr_code,
   d.cost_book_curr_code,
   d.order_type_code,
   d.bus_cost_type_num,
   d.vc_acct_num,
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

create trigger [dbo].[posting_account_updtrg]
on [dbo].[posting_account]
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
   raiserror ('(posting_account) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(posting_account) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.posting_account_num = d.posting_account_num )
begin
   raiserror ('(posting_account) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(posting_account_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.posting_account_num = d.posting_account_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(posting_account) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_posting_account
      (posting_account_num,
       cost_period_ind,
       gl_acct_dr_code,
       gl_acct_cr_code,
       cost_book_comp_num,
       profit_center,
       acct_num,
       port_num,
       pos_group_num,
       cost_code,
       cost_status,
       cost_type_code,
       cost_prim_sec_ind,
       cost_est_final_ind,
       cost_pay_rec_ind,
       cost_price_curr_code,
       cost_book_curr_code,
       order_type_code,
       bus_cost_type_num,
       vc_acct_num,
       trans_id,
       resp_trans_id)
   select
      d.posting_account_num,
      d.cost_period_ind,
      d.gl_acct_dr_code,
      d.gl_acct_cr_code,
      d.cost_book_comp_num,
      d.profit_center,
      d.acct_num,
      d.port_num,
      d.pos_group_num,
      d.cost_code,
      d.cost_status,
      d.cost_type_code,
      d.cost_prim_sec_ind,
      d.cost_est_final_ind,
      d.cost_pay_rec_ind,
      d.cost_price_curr_code,
      d.cost_book_curr_code,
      d.order_type_code,
      d.bus_cost_type_num,
      d.vc_acct_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.posting_account_num = i.posting_account_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[posting_account] ADD CONSTRAINT [posting_account_pk] PRIMARY KEY CLUSTERED  ([posting_account_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[posting_account] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[posting_account] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[posting_account] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[posting_account] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'posting_account', NULL, NULL
GO
