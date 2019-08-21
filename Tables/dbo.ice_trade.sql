CREATE TABLE [dbo].[ice_trade]
(
[external_trade_oid] [int] NOT NULL,
[begin_date] [datetime] NULL,
[buyer_company_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[buyer_first_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[buyer_last_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[clearing_firm_name] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[consummate_date] [datetime] NOT NULL,
[deal_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[deal_lot_size] [int] NULL,
[end_date] [datetime] NULL,
[hub] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[market_id] [int] NOT NULL,
[market_lot_size] [int] NULL,
[mkt_bprod_currency] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mkt_bprod_unit_price] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mkt_bprod_units] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[number_of_cycles] [int] NOT NULL,
[order_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price] [float] NULL,
[qty_multiplied_out] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[seller_company_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[seller_first_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[seller_last_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[buyer_user_id] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[seller_user_id] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ice_trade_deltrg]
on [dbo].[ice_trade]
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
   select @errmsg = '(ice_trade) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_ice_trade
   (external_trade_oid,
    begin_date,
    buyer_company_name,
    buyer_first_name, 
    buyer_last_name, 
    clearing_firm_name, 
    consummate_date,
    deal_id,
    deal_lot_size,
    end_date,
    hub,
    market_id,
    market_lot_size,
    mkt_bprod_currency,
    mkt_bprod_unit_price,
    mkt_bprod_units,
    number_of_cycles,
    order_type,
    price,
    qty_multiplied_out,
    seller_company_name,
    seller_first_name, 
    seller_last_name, 
    buyer_user_id,
    seller_user_id,
    trans_id,
    resp_trans_id)
select
   d.external_trade_oid,
   d.begin_date,
   d.buyer_company_name,
   d.buyer_first_name, 
   d.buyer_last_name, 
   d.clearing_firm_name, 
   d.consummate_date,
   d.deal_id,
   d.deal_lot_size,
   d.end_date,
   d.hub,
   d.market_id,
   d.market_lot_size,
   d.mkt_bprod_currency,
   d.mkt_bprod_unit_price,
   d.mkt_bprod_units,
   d.number_of_cycles,
   d.order_type,
   d.price,
   d.qty_multiplied_out,
   d.seller_company_name,
   d.seller_first_name, 
   d.seller_last_name, 
   d.buyer_user_id,
   d.seller_user_id,
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

create trigger [dbo].[ice_trade_updtrg]
on [dbo].[ice_trade]
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
   raiserror ('(ice_trade) The change needs to be attached with a new trans_id',16,1)
   if @@trancount > 0 rollback tran

   return
end

if exists (select 1
           from master.dbo.sysprocesses
           where spid = @@spid and
                (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                 program_name like 'Microsoft SQL Server Management Studio%') )
begin
   if (select count(*) from inserted, deleted where inserted.trans_id <= deleted.trans_id) > 0
   begin
      select @errmsg = '(ice_trade) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.external_trade_oid = d.external_trade_oid)
begin
   raiserror ('(ice_trade) new trans_id must not be older than current trans_id.',16,1)
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
      raiserror ('(ice_trade) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_ice_trade
      (external_trade_oid,
       begin_date,
       buyer_company_name,
       buyer_first_name, 
       buyer_last_name, 
       clearing_firm_name, 
       consummate_date,
       deal_id,
       deal_lot_size,
       end_date,
       hub,
       market_id,
       market_lot_size,
       mkt_bprod_currency,
       mkt_bprod_unit_price,
       mkt_bprod_units,
       number_of_cycles,
       order_type,
       price,
       qty_multiplied_out,
       seller_company_name,
       seller_first_name, 
       seller_last_name, 
       buyer_user_id,
       seller_user_id,
       trans_id,
       resp_trans_id)
   select
      d.external_trade_oid,
      d.begin_date,
      d.buyer_company_name,
      d.buyer_first_name, 
      d.buyer_last_name, 
      d.clearing_firm_name, 
      d.consummate_date,
      d.deal_id,
      d.deal_lot_size,
      d.end_date,
      d.hub,
      d.market_id,
      d.market_lot_size,
      d.mkt_bprod_currency,
      d.mkt_bprod_unit_price,
      d.mkt_bprod_units,
      d.number_of_cycles,
      d.order_type,
      d.price,
      d.qty_multiplied_out,
      d.seller_company_name,
      d.seller_first_name, 
      d.seller_last_name, 
      d.buyer_user_id,
      d.seller_user_id,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.external_trade_oid = i.external_trade_oid 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[ice_trade] ADD CONSTRAINT [ice_trade_pk] PRIMARY KEY CLUSTERED  ([external_trade_oid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ice_trade_idx1] ON [dbo].[ice_trade] ([deal_id], [consummate_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ice_trade_idx2] ON [dbo].[ice_trade] ([external_trade_oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ice_trade] ADD CONSTRAINT [ice_trade_fk1] FOREIGN KEY ([external_trade_oid]) REFERENCES [dbo].[external_trade] ([oid])
GO
GRANT DELETE ON  [dbo].[ice_trade] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[ice_trade] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[ice_trade] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[ice_trade] TO [next_usr]
GO
