CREATE TABLE [dbo].[price_temp]
(
[commkt_key] [int] NOT NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_quote_date] [datetime] NOT NULL,
[low_bid_price] [float] NULL,
[high_asked_price] [float] NULL,
[avg_closed_price] [float] NULL,
[open_interest] [float] NULL,
[vol_traded] [float] NULL,
[creation_type] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[price_temp_updtrg]
on [dbo].[price_temp]
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
   raiserror ('(price_temp) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(price_temp) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.commkt_key = d.commkt_key and 
                 i.price_source_code = d.price_source_code and 
                 i.trading_prd = d.trading_prd and 
                 i.price_quote_date = d.price_quote_date )
begin
   raiserror ('(price_temp) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(commkt_key) or  
   update(price_source_code) or 
   update(trading_prd) or  
   update(price_quote_date) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.commkt_key = d.commkt_key and 
                                   i.price_source_code = d.price_source_code and 
                                   i.trading_prd = d.trading_prd and 
                                   i.price_quote_date = d.price_quote_date )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(account_address) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[price_temp] ADD CONSTRAINT [price_temp_pk] PRIMARY KEY CLUSTERED  ([commkt_key], [price_source_code], [trading_prd], [price_quote_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[price_temp] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[price_temp] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[price_temp] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[price_temp] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'price_temp', NULL, NULL
GO
