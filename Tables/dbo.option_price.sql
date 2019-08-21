CREATE TABLE [dbo].[option_price]
(
[commkt_key] [int] NOT NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[opt_strike_price] [float] NOT NULL,
[put_call_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[opt_price_quote_date] [datetime] NOT NULL,
[low_bid_price] [float] NULL,
[high_asked_price] [float] NULL,
[avg_closed_price] [float] NULL,
[open_interest] [float] NULL,
[vol_traded] [float] NULL,
[creation_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[volatility] [float] NULL,
[low_bid_creation_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[high_asked_creation_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[avg_closed_creation_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[volatility_creation_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[option_price_deltrg]
on [dbo].[option_price]
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
   select @errmsg = '(option_price) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_option_price
   (commkt_key,
    price_source_code,
    trading_prd,
    opt_strike_price,
    put_call_ind,
    opt_price_quote_date,
    low_bid_price,
    high_asked_price,
    avg_closed_price,
    open_interest,
    vol_traded,
    creation_type,
    volatility,
    low_bid_creation_ind,
    high_asked_creation_ind,
    avg_closed_creation_ind,
    volatility_creation_ind,
    trans_id,
    resp_trans_id)
select
   d.commkt_key,
   d.price_source_code,
   d.trading_prd,
   d.opt_strike_price,
   d.put_call_ind,
   d.opt_price_quote_date,
   d.low_bid_price,
   d.high_asked_price,
   d.avg_closed_price,
   d.open_interest,
   d.vol_traded,
   d.creation_type,
   d.volatility,
   d.low_bid_creation_ind,
   d.high_asked_creation_ind,
   d.avg_closed_creation_ind,
   d.volatility_creation_ind,
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

create trigger [dbo].[option_price_updtrg]
on [dbo].[option_price]
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
   raiserror ('(option_price) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(option_price) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.commkt_key = d.commkt_key and 
                 i.price_source_code = d.price_source_code and 
                 i.trading_prd = d.trading_prd and 
                 i.opt_strike_price = d.opt_strike_price and 
                 i.put_call_ind = d.put_call_ind and
                 i.opt_price_quote_date = d.opt_price_quote_date )
begin
   raiserror ('(option_price) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(commkt_key) or  
   update(price_source_code) or  
   update(trading_prd) or  
   update(opt_strike_price) or  
   update(put_call_ind) or
   update(opt_price_quote_date) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.commkt_key = d.commkt_key and 
                                   i.price_source_code = d.price_source_code and 
                                   i.trading_prd = d.trading_prd and 
                                   i.opt_strike_price = d.opt_strike_price and 
                                   i.put_call_ind = d.put_call_ind and
                                   i.opt_price_quote_date = d.opt_price_quote_date )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(option_price) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end 
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_option_price
      (commkt_key,
       price_source_code,
       trading_prd,
       opt_strike_price,
       put_call_ind,
       opt_price_quote_date,
       low_bid_price,
       high_asked_price,
       avg_closed_price,
       open_interest,
       vol_traded,
       creation_type,
       volatility,
       low_bid_creation_ind,
       high_asked_creation_ind,
       avg_closed_creation_ind,
       volatility_creation_ind,
       trans_id,
       resp_trans_id)
   select
      d.commkt_key,
      d.price_source_code,
      d.trading_prd,
      d.opt_strike_price,
      d.put_call_ind,
      d.opt_price_quote_date,
      d.low_bid_price,
      d.high_asked_price,
      d.avg_closed_price,
      d.open_interest,
      d.vol_traded,
      d.creation_type,
      d.volatility,
      d.low_bid_creation_ind,
      d.high_asked_creation_ind,
      d.avg_closed_creation_ind,
      d.volatility_creation_ind,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.commkt_key = i.commkt_key and
         d.price_source_code = i.price_source_code and
         d.trading_prd = i.trading_prd and
         d.opt_strike_price = i.opt_strike_price and
         d.put_call_ind = i.put_call_ind and
         d.opt_price_quote_date = i.opt_price_quote_date 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[option_price] ADD CONSTRAINT [option_price_pk] PRIMARY KEY CLUSTERED  ([commkt_key], [price_source_code], [trading_prd], [opt_strike_price], [put_call_ind], [opt_price_quote_date]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[option_price] ADD CONSTRAINT [option_price_fk1] FOREIGN KEY ([commkt_key], [trading_prd], [opt_strike_price], [put_call_ind]) REFERENCES [dbo].[option_strike] ([commkt_key], [trading_prd], [opt_strike_price], [put_call_ind])
GO
ALTER TABLE [dbo].[option_price] ADD CONSTRAINT [option_price_fk2] FOREIGN KEY ([price_source_code]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
GRANT DELETE ON  [dbo].[option_price] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[option_price] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[option_price] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[option_price] TO [next_usr]
GO
