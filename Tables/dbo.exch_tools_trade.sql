CREATE TABLE [dbo].[exch_tools_trade]
(
[external_trade_oid] [int] NOT NULL,
[accepted_action] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[accepted_broker] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[accepted_company] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[accepted_trader] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[buyer_account] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commodity] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[creation_date] [datetime] NOT NULL,
[exch_tools_trade_num] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[input_action] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[input_broker] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[input_company] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[input_trader] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price] [float] NOT NULL,
[quantity] [float] NOT NULL,
[seller_account] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trading_period] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[begin_date] [datetime] NULL,
[end_date] [datetime] NULL,
[call_put] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[strike_price] [float] NULL,
[buyer_comm_cost] [float] NULL,
[buyer_comm_curr] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[seller_comm_cost] [float] NULL,
[seller_comm_curr] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[buyer_clrng_broker] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[seller_clrng_broker] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[external_comment_oid] [int] NULL,
[acct_contact] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[gtc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trade_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[risk_market] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[title_market] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qty_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_date_from] [datetime] NULL,
[del_date_to] [datetime] NULL,
[mot] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[title_transfer] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_deemed_date] [datetime] NULL,
[price_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_currency] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[template_trade_num] [int] NULL,
[float_market_quote1] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[float_market_quote2] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[float_qty1] [numeric] (20, 8) NULL,
[float_qty2] [numeric] (20, 8) NULL,
[premium_date] [datetime] NULL,
[auto_exerc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[product_id] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[exch_tools_trade_deltrg]
on [dbo].[exch_tools_trade]
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
   select @errmsg = '(exch_tools_trade) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_exch_tools_trade
   (external_trade_oid,
    accepted_action,
    accepted_broker,
    accepted_company,
    accepted_trader,
    buyer_account,
    commodity,
    creation_date,
    exch_tools_trade_num,
    input_action,
    input_broker,
    input_company,
    input_trader,
    price,
    quantity,
    seller_account,
    trading_period,
    begin_date,
    end_date,
    call_put,
    strike_price,
    buyer_comm_cost, 
    buyer_comm_curr,
    seller_comm_cost, 
    seller_comm_curr,
    buyer_clrng_broker, 
    seller_clrng_broker,
    external_comment_oid,
    acct_contact,
    gtc,
    trade_type,
    risk_market, 
    title_market,
    qty_uom,
    del_date_from,
    del_date_to,
    mot,
    title_transfer,
    price_type,
    formula_name,
    event_deemed_date,
    price_uom,
    price_currency,
    template_trade_num,
    float_market_quote1,
    float_market_quote2,
    float_qty1,
    float_qty2,
    premium_date,
    auto_exerc_ind,
    product_id,
    trans_id,
    resp_trans_id)
select
   d.external_trade_oid,
   d.accepted_action,
   d.accepted_broker,
   d.accepted_company,
   d.accepted_trader,
   d.buyer_account,
   d.commodity,
   d.creation_date,
   d.exch_tools_trade_num,
   d.input_action,
   d.input_broker,
   d.input_company,
   d.input_trader,
   d.price,
   d.quantity,
   d.seller_account,
   d.trading_period,
   d.begin_date,
   d.end_date,
   d.call_put,
   d.strike_price,
   d.buyer_comm_cost, 
   d.buyer_comm_curr,
   d.seller_comm_cost, 
   d.seller_comm_curr,
   d.buyer_clrng_broker, 
   d.seller_clrng_broker,
   d.external_comment_oid,
   d.acct_contact,
   d.gtc,
   d.trade_type,
   d.risk_market, 
   d.title_market,
   d.qty_uom,
   d.del_date_from,
   d.del_date_to,
   d.mot,
   d.title_transfer,
   d.price_type,
   d.formula_name,
   d.event_deemed_date,
   d.price_uom,
   d.price_currency,
   d.template_trade_num,
   d.float_market_quote1,
   d.float_market_quote2,
   d.float_qty1,
   d.float_qty2,
   d.premium_date,
   d.auto_exerc_ind,
   d.product_id,
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

create trigger [dbo].[exch_tools_trade_updtrg]
on [dbo].[exch_tools_trade]
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
   raiserror ('(exch_tools_trade) The change needs to be attached with a new trans_id',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* added by Peter Lo  Sep-4-2002 */
if exists (select 1
           from master.dbo.sysprocesses
           where spid = @@spid and
                 (rtrim(program_name) = 'isql' or rtrim(program_name) = 'ctisql') )
begin
   if (select count(*) from inserted, deleted where inserted.trans_id <= deleted.trans_id) > 0
   begin
      select @errmsg = '(exch_tools_trade) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.external_trade_oid = d.external_trade_oid)
begin
   raiserror ('(exch_tools_trade) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(external_trade_oid) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.external_trade_oid = d.external_trade_oid)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(exch_tools_trade) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_exch_tools_trade
      (external_trade_oid,
       accepted_action,
       accepted_broker,
       accepted_company,
       accepted_trader,
       buyer_account,
       commodity,
       creation_date,
       exch_tools_trade_num,
       input_action,
       input_broker,
       input_company,
       input_trader,
       price,
       quantity,
       seller_account,
       trading_period,
       begin_date,
       end_date,
       call_put,
       strike_price,
       buyer_comm_cost, 
       buyer_comm_curr,
       seller_comm_cost, 
       seller_comm_curr,
       buyer_clrng_broker, 
       seller_clrng_broker,
       external_comment_oid,
       acct_contact,
       gtc,
       trade_type,
       risk_market, 
       title_market,
       qty_uom,
       del_date_from,
       del_date_to,
       mot,
       title_transfer,
       price_type,
       formula_name,
       event_deemed_date,
       price_uom,
       price_currency,
       template_trade_num,
       float_market_quote1,
       float_market_quote2,
       float_qty1,
       float_qty2,
       premium_date,
       auto_exerc_ind,
       product_id,
       trans_id,
       resp_trans_id)
   select
      d.external_trade_oid,
      d.accepted_action,
      d.accepted_broker,
      d.accepted_company,
      d.accepted_trader,
      d.buyer_account,
      d.commodity,
      d.creation_date,
      d.exch_tools_trade_num,
      d.input_action,
      d.input_broker,
      d.input_company,
      d.input_trader,
      d.price,
      d.quantity,
      d.seller_account,
      d.trading_period,
      d.begin_date,
      d.end_date,
      d.call_put,
      d.strike_price,
      d.buyer_comm_cost, 
      d.buyer_comm_curr,
      d.seller_comm_cost, 
      d.seller_comm_curr,
      d.buyer_clrng_broker, 
      d.seller_clrng_broker,
      d.external_comment_oid,
      d.acct_contact,
      d.gtc,
      d.trade_type,
      d.risk_market, 
      d.title_market,
      d.qty_uom,
      d.del_date_from,
      d.del_date_to,
      d.mot,
      d.title_transfer,
      d.price_type,
      d.formula_name,
      d.event_deemed_date,
      d.price_uom,
      d.price_currency,
      d.template_trade_num,
      d.float_market_quote1,
      d.float_market_quote2,
      d.float_qty1,
      d.float_qty2,
      d.premium_date,
      d.auto_exerc_ind,
      d.product_id,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.external_trade_oid = i.external_trade_oid 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[exch_tools_trade] ADD CONSTRAINT [exch_tools_trade_pk] PRIMARY KEY CLUSTERED  ([external_trade_oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[exch_tools_trade] ADD CONSTRAINT [exch_tools_trade_fk1] FOREIGN KEY ([external_trade_oid]) REFERENCES [dbo].[external_trade] ([oid])
GO
ALTER TABLE [dbo].[exch_tools_trade] ADD CONSTRAINT [exch_tools_trade_fk2] FOREIGN KEY ([external_comment_oid]) REFERENCES [dbo].[external_comment] ([oid])
GO
GRANT DELETE ON  [dbo].[exch_tools_trade] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[exch_tools_trade] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[exch_tools_trade] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[exch_tools_trade] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'exch_tools_trade', NULL, NULL
GO
