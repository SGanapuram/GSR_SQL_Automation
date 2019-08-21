CREATE TABLE [dbo].[trade_item_fill]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[item_fill_num] [smallint] NOT NULL,
[fill_qty] [float] NULL,
[fill_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fill_price] [float] NULL,
[fill_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fill_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fill_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fill_date] [datetime] NULL,
[bsi_fill_num] [int] NULL,
[efp_post_date] [datetime] NULL,
[inhouse_trade_num] [int] NULL,
[inhouse_order_num] [smallint] NULL,
[inhouse_item_num] [smallint] NULL,
[inhouse_fill_num] [smallint] NULL,
[in_out_house_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[outhouse_profit_center] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[outhouse_acct_alloc] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fill_closed_qty] [float] NULL,
[trans_id] [int] NOT NULL,
[broker_fifo_qty] [numeric] (20, 8) NULL,
[port_match_qty] [numeric] (20, 8) NULL,
[fifo_qty] [numeric] (20, 8) NULL,
[external_trade_num] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_item_fill_deltrg]
on [dbo].[trade_item_fill]
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
   select @errmsg = '(trade_item_fill) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_trade_item_fill
   (trade_num,
    order_num,
    item_num,
    item_fill_num,
    fill_qty,
    fill_qty_uom_code,
    fill_price,
    fill_price_curr_code,
    fill_price_uom_code,
    fill_status,
    fill_date,
    bsi_fill_num,
    efp_post_date,
    inhouse_trade_num,
    inhouse_order_num,
    inhouse_item_num,
    inhouse_fill_num,
    in_out_house_ind,
    outhouse_profit_center,
    outhouse_acct_alloc,
    fill_closed_qty,
    broker_fifo_qty,
    port_match_qty, 
    fifo_qty,
    external_trade_num,
    trans_id,
    resp_trans_id)
select
   d.trade_num,
   d.order_num,
   d.item_num,
   d.item_fill_num,
   d.fill_qty,
   d.fill_qty_uom_code,
   d.fill_price,
   d.fill_price_curr_code,
   d.fill_price_uom_code,
   d.fill_status,
   d.fill_date,
   d.bsi_fill_num,
   d.efp_post_date,
   d.inhouse_trade_num,
   d.inhouse_order_num,
   d.inhouse_item_num,
   d.inhouse_fill_num,
   d.in_out_house_ind,
   d.outhouse_profit_center,
   d.outhouse_acct_alloc,
   d.fill_closed_qty,
   d.broker_fifo_qty,
   d.port_match_qty,
   d.fifo_qty,
   d.external_trade_num,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'DELETE',
       'TradeItemFill',
       'DIRECT',
       convert(varchar(40), d.trade_num),
       convert(varchar(40), d.order_num),
       convert(varchar(40), d.item_num),
       convert(varchar(40), d.item_fill_num),
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

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_item_fill_instrg]
on [dbo].[trade_item_fill]
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
          'TradeItemFill',
          'DIRECT',
          convert(varchar(40), i.trade_num),
          convert(varchar(40), i.order_num),
          convert(varchar(40), i.item_num),
          convert(varchar(40), i.item_fill_num),
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

create trigger [dbo].[trade_item_fill_updtrg]
on [dbo].[trade_item_fill]
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
   raiserror ('(trade_item_fill) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(trade_item_fill) New trans_id must be larger than original trans_id.'
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
                 i.item_num = d.item_num and
                 i.item_fill_num = d.item_fill_num )
begin
   raiserror ('(trade_item_fill) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(trade_num) or 
   update(order_num) or  
   update(item_num) or
   update(item_fill_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.trade_num = d.trade_num and 
                                   i.order_num = d.order_num and 
                                   i.item_num = d.item_num and
                                   i.item_fill_num = d.item_fill_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(trade_item_fill) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_trade_item_fill
      (trade_num,
       order_num,
       item_num,
       item_fill_num,
       fill_qty,
       fill_qty_uom_code,
       fill_price,
       fill_price_curr_code,
       fill_price_uom_code,
       fill_status,
       fill_date,
       bsi_fill_num,
       efp_post_date,
       inhouse_trade_num,
       inhouse_order_num,
       inhouse_item_num,
       inhouse_fill_num,
       in_out_house_ind,
       outhouse_profit_center,
       outhouse_acct_alloc,
       fill_closed_qty,
       broker_fifo_qty,
       port_match_qty,    
       fifo_qty,
       trans_id,
       resp_trans_id)
   select
      d.trade_num,
      d.order_num,
      d.item_num,
      d.item_fill_num,
      d.fill_qty,
      d.fill_qty_uom_code,
      d.fill_price,
      d.fill_price_curr_code,
      d.fill_price_uom_code,
      d.fill_status,
      d.fill_date,
      d.bsi_fill_num,
      d.efp_post_date,
      d.inhouse_trade_num,
      d.inhouse_order_num,
      d.inhouse_item_num,
      d.inhouse_fill_num,
      d.in_out_house_ind,
      d.outhouse_profit_center,
      d.outhouse_acct_alloc,
      d.fill_closed_qty,
      d.broker_fifo_qty,
      d.port_match_qty,    
      d.fifo_qty,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.trade_num = i.trade_num and
         d.order_num = i.order_num and
         d.item_num = i.item_num and
         d.item_fill_num = i.item_fill_num 

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'UPDATE',
       'TradeItemFill',
       'DIRECT',
       convert(varchar(40), i.trade_num),
       convert(varchar(40), i.order_num),
       convert(varchar(40), i.item_num),
       convert(varchar(40), i.item_fill_num),
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
ALTER TABLE [dbo].[trade_item_fill] ADD CONSTRAINT [trade_item_fill_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [item_num], [item_fill_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_fill_idx1] ON [dbo].[trade_item_fill] ([fill_date], [external_trade_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_fill] ADD CONSTRAINT [trade_item_fill_fk1] FOREIGN KEY ([fill_price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item_fill] ADD CONSTRAINT [trade_item_fill_fk4] FOREIGN KEY ([fill_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_fill] ADD CONSTRAINT [trade_item_fill_fk5] FOREIGN KEY ([fill_price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[trade_item_fill] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_item_fill] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_item_fill] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_item_fill] TO [next_usr]
GO
