CREATE TABLE [dbo].[inventory_history]
(
[asof_date] [datetime] NOT NULL,
[real_port_num] [int] NOT NULL,
[inv_num] [int] NOT NULL,
[cost_num] [int] NOT NULL,
[cost_due_date] [datetime] NOT NULL,
[inv_balance_period] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_trade_num] [int] NOT NULL,
[cost_order_num] [int] NOT NULL,
[cost_item_num] [int] NOT NULL,
[rcpt_alloc_num] [int] NOT NULL,
[rcpt_alloc_item_num] [int] NOT NULL,
[cost_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_acct_num] [int] NOT NULL,
[r_cost_amt] [float] NULL,
[unr_cost_amt] [float] NULL,
[cost_amt_ratio] [float] NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[inventory_history_deltrg]
on [dbo].[inventory_history]
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
   select @errmsg = '(inventory_history) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_inventory_history
   (asof_date,
    real_port_num,
    inv_num,
    cost_num,
    cost_due_date,
    inv_balance_period,
    cost_trade_num,
    cost_order_num,
    cost_item_num,
    rcpt_alloc_num,
    rcpt_alloc_item_num,
    cost_type_code,
    cost_acct_num,
    r_cost_amt,
    unr_cost_amt,
    cost_amt_ratio,
    trans_id,
    resp_trans_id)
select
   d.asof_date,
   d.real_port_num,
   d.inv_num,
   d.cost_num,
   d.cost_due_date,
   d.inv_balance_period,
   d.cost_trade_num,
   d.cost_order_num,
   d.cost_item_num,
   d.rcpt_alloc_num,
   d.rcpt_alloc_item_num,
   d.cost_type_code,
   d.cost_acct_num,
   d.r_cost_amt,
   d.unr_cost_amt,
   d.cost_amt_ratio,
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

create trigger [dbo].[inventory_history_updtrg]
on [dbo].[inventory_history]
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
   raiserror ('(inventory_history) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(inventory_history) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.asof_date = d.asof_date and
                 i.real_port_num = d.real_port_num and
                 i.inv_num = d.inv_num and 
                 i.cost_num = d.cost_num and
                 i.rcpt_alloc_num = d.rcpt_alloc_num )
begin
   raiserror ('(inventory_history) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(asof_date) or  
   update(real_port_num) or
   update(inv_num) or
   update(cost_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.asof_date = d.asof_date and
                                   i.real_port_num = d.real_port_num and
                                   i.inv_num = d.inv_num and 
                                   i.cost_num = d.cost_num and
                                   i.rcpt_alloc_num = d.rcpt_alloc_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(inventory_history) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[inventory_history] ADD CONSTRAINT [inventory_history_pk] PRIMARY KEY CLUSTERED  ([asof_date], [real_port_num], [inv_num], [cost_num], [rcpt_alloc_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [inventory_history_idx1] ON [dbo].[inventory_history] ([real_port_num], [asof_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[inventory_history] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[inventory_history] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[inventory_history] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[inventory_history] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'inventory_history', NULL, NULL
GO
