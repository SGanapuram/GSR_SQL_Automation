CREATE TABLE [dbo].[trade_item_curr]
(
[trade_num] [int] NOT NULL,
[order_num] [int] NOT NULL,
[item_num] [int] NOT NULL,
[payment_date] [datetime] NULL,
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ref_spot_rate] [numeric] (20, 8) NULL,
[pay_curr_amt] [numeric] (20, 8) NOT NULL,
[pay_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rec_curr_amt] [numeric] (20, 8) NOT NULL,
[rec_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_item_curr_deltrg]
on [dbo].[trade_item_curr]
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
   select @errmsg = '(trade_item_curr) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_trade_item_curr
   (trade_num,
    order_num,
    item_num,
    payment_date,
    credit_term_code,
    ref_spot_rate,
    pay_curr_amt,
    pay_curr_code,
    rec_curr_amt,
    rec_curr_code,
    trans_id,
    resp_trans_id)
select
   d.trade_num,
   d.order_num,
   d.item_num,
   d.payment_date,
   d.credit_term_code,
   d.ref_spot_rate,
   d.pay_curr_amt,
   d.pay_curr_code,
   d.rec_curr_amt,
   d.rec_curr_code,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'DELETE',
       'TradeItemCurr',
       'DIRECT',
       convert(varchar(40), d.trade_num),
       convert(varchar(40), d.order_num),
       convert(varchar(40), d.item_num),
       null,
       null,
       null,
       null,
       null,
       @atrans_id,
       it.sequence
from deleted d, dbo.icts_transaction it
where it.trans_id = @atrans_id

/* END_TRANSACTION_TOUCH */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_item_curr_instrg]
on [dbo].[trade_item_curr]
for insert
as
declare @num_rows        int,
        @count_num_rows  int,
        @errmsg          varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

   /* BEGIN_TRANSACTION_TOUCH */

   insert dbo.transaction_touch
   select 'INSERT',
          'TradeItemCurr',
          'DIRECT',
          convert(varchar(40), i.trade_num),
          convert(varchar(40), i.order_num),
          convert(varchar(40), i.item_num),
          null,
          null,
          null,
          null,
          null,
          i.trans_id,
          it.sequence
   from inserted i, dbo.icts_transaction it
   where i.trans_id = it.trans_id

   /* END_TRANSACTION_TOUCH */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_item_curr_updtrg]
on [dbo].[trade_item_curr]
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
   raiserror ('(trade_item_curr) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(trade_item_curr) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.trade_num = d.trade_num and
                 i.order_num = d.order_num and
                 i.item_num = d.item_num )
begin
   raiserror ('(trade_item_curr) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(trade_num) or 
   update(order_num) or  
   update(item_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.trade_num = d.trade_num and
                                   i.order_num = d.order_num and 
                                   i.item_num = d.item_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(trade_item_curr) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_trade_item_curr
      (trade_num,
       order_num,
       item_num,
       payment_date,
       credit_term_code,
       ref_spot_rate,
       pay_curr_amt,
       pay_curr_code,
       rec_curr_amt,
       rec_curr_code,
       trans_id,
       resp_trans_id)
   select
      d.trade_num,
      d.order_num,
      d.item_num,
      d.payment_date,
      d.credit_term_code,
      d.ref_spot_rate,
      d.pay_curr_amt,
      d.pay_curr_code,
      d.rec_curr_amt,
      d.rec_curr_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.trade_num = i.trade_num and
         d.order_num = i.order_num and
         d.item_num = i.item_num

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'UPDATE',
       'TradeItemCurr',
       'DIRECT',
       convert(varchar(40), i.trade_num),
       convert(varchar(40), i.order_num),
       convert(varchar(40), i.item_num),
       null,
       null,
       null,
       null,
       null,
       i.trans_id,
       it.sequence
from inserted i, dbo.icts_transaction it
where i.trans_id = it.trans_id

/* END_TRANSACTION_TOUCH */

return
GO
ALTER TABLE [dbo].[trade_item_curr] ADD CONSTRAINT [trade_item_curr_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [item_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_curr] ADD CONSTRAINT [trade_item_curr_fk2] FOREIGN KEY ([credit_term_code]) REFERENCES [dbo].[credit_term] ([credit_term_code])
GO
ALTER TABLE [dbo].[trade_item_curr] ADD CONSTRAINT [trade_item_curr_fk3] FOREIGN KEY ([pay_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item_curr] ADD CONSTRAINT [trade_item_curr_fk4] FOREIGN KEY ([rec_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[trade_item_curr] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_item_curr] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_item_curr] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_item_curr] TO [next_usr]
GO
