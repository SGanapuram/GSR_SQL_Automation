CREATE TABLE [dbo].[ti_mark_to_market]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[mtm_pl_asof_date] [datetime] NOT NULL,
[acct_num] [int] NULL,
[real_port_num] [int] NULL,
[trader_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[creation_date] [datetime] NOT NULL,
[contr_date] [datetime] NULL,
[order_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[booking_comp_num] [int] NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[risk_mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[last_trade_date] [datetime] NULL,
[contr_qty] [numeric] (20, 8) NULL,
[contr_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_qty_periodicity] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[open_qty] [numeric] (20, 8) NULL,
[trans_id] [bigint] NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ti_mark_to_market_deltrg]
on [dbo].[ti_mark_to_market]
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
   select @errmsg = '(ti_mark_to_market) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,16,1)
   if @@trancount > 0 rollback tran

   return
end


insert dbo.aud_ti_mark_to_market
   (trade_num,
    order_num,
    item_num,
    mtm_pl_asof_date,
    acct_num,
    real_port_num,
    trader_init,
    creation_date,
    contr_date,
    order_type_code,
    booking_comp_num,
    p_s_ind,
    cmdty_code,
    risk_mkt_code,
    trading_prd,
    last_trade_date,
    contr_qty,
    contr_qty_uom_code,
    contr_qty_periodicity,
    open_qty,
    trans_id,
    resp_trans_id)
select
   d.trade_num,
   d.order_num,
   d.item_num,
   d.mtm_pl_asof_date,
   d.acct_num,
   d.real_port_num,
   d.trader_init,
   d.creation_date,
   d.contr_date,
   d.order_type_code,
   d.booking_comp_num,
   d.p_s_ind,
   d.cmdty_code,
   d.risk_mkt_code,
   d.trading_prd,
   d.last_trade_date,
   d.contr_qty,
   d.contr_qty_uom_code,
   d.contr_qty_periodicity,
   d.open_qty,
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

create trigger [dbo].[ti_mark_to_market_updtrg]
on [dbo].[ti_mark_to_market]
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
   raiserror ('(ti_mark_to_market) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(ti_mark_to_market) New trans_id must be larger than original trans_id.'
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
                 i.mtm_pl_asof_date = d.mtm_pl_asof_date )
begin
   raiserror ('(ti_mark_to_market) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(trade_num) or
   update(order_num) or
   update(item_num) or
   update(mtm_pl_asof_date)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.trade_num = d.trade_num and
                                   i.order_num = d.order_num and
                                   i.item_num = d.item_num and
                                   i.mtm_pl_asof_date = d.mtm_pl_asof_date )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(ti_mark_to_market) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_ti_mark_to_market
      (trade_num,
       order_num,
       item_num,
       mtm_pl_asof_date,
       acct_num,
       real_port_num,
       trader_init,
       creation_date,
       contr_date,
       order_type_code,
       booking_comp_num,
       p_s_ind,
       cmdty_code,
       risk_mkt_code,
       trading_prd,
       last_trade_date,
       contr_qty,
       contr_qty_uom_code,
       contr_qty_periodicity,
       open_qty,
       trans_id,
       resp_trans_id)
   select
      d.trade_num,
      d.order_num,
      d.item_num,
      d.mtm_pl_asof_date,
      d.acct_num,
      d.real_port_num,
      d.trader_init,
      d.creation_date,
      d.contr_date,
      d.order_type_code,
      d.booking_comp_num,
      d.p_s_ind,
      d.cmdty_code,
      d.risk_mkt_code,
      d.trading_prd,
      d.last_trade_date,
      d.contr_qty,
      d.contr_qty_uom_code,
      d.contr_qty_periodicity,
      d.open_qty,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.trade_num = i.trade_num and
         d.order_num = i.order_num and 
         d.item_num = i.item_num and
         d.mtm_pl_asof_date = i.mtm_pl_asof_date 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[ti_mark_to_market] ADD CONSTRAINT [ti_mark_to_market_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [item_num], [mtm_pl_asof_date]) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ti_mark_to_market_idx1] ON [dbo].[ti_mark_to_market] ([mtm_pl_asof_date]) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ti_mark_to_market] ADD CONSTRAINT [ti_mark_to_market_fk4] FOREIGN KEY ([trader_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[ti_mark_to_market] ADD CONSTRAINT [ti_mark_to_market_fk5] FOREIGN KEY ([order_type_code]) REFERENCES [dbo].[order_type] ([order_type_code])
GO
ALTER TABLE [dbo].[ti_mark_to_market] ADD CONSTRAINT [ti_mark_to_market_fk6] FOREIGN KEY ([booking_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[ti_mark_to_market] ADD CONSTRAINT [ti_mark_to_market_fk7] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[ti_mark_to_market] ADD CONSTRAINT [ti_mark_to_market_fk8] FOREIGN KEY ([risk_mkt_code]) REFERENCES [dbo].[market] ([mkt_code])
GO
ALTER TABLE [dbo].[ti_mark_to_market] ADD CONSTRAINT [ti_mark_to_market_fk9] FOREIGN KEY ([contr_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[ti_mark_to_market] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[ti_mark_to_market] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[ti_mark_to_market] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[ti_mark_to_market] TO [next_usr]
GO
