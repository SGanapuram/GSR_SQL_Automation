CREATE TABLE [dbo].[qpp_mark_to_market]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[accum_num] [smallint] NOT NULL,
[qpp_num] [smallint] NOT NULL,
[mtm_pl_asof_date] [datetime] NOT NULL,
[quote_start_date] [datetime] NULL,
[quote_end_date] [datetime] NULL,
[num_of_pricing_days] [smallint] NULL,
[num_of_days_priced] [smallint] NULL,
[open_price] [numeric] (20, 8) NULL,
[priced_price] [numeric] (20, 8) NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[qpp_mark_to_market_updtrg]
on [dbo].[qpp_mark_to_market]
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
   raiserror ('(qpp_mark_to_market) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(qpp_mark_to_market) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.trade_num = d.trade_num and
                 i.order_num = d.order_num and
                 i.item_num = d.item_num and
                 i.accum_num = d.accum_num and
                 i.qpp_num = d.qpp_num and
                 i.mtm_pl_asof_date = d.mtm_pl_asof_date )
begin
   raiserror ('(qpp_mark_to_market) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(trade_num) or
   update(order_num) or
   update(item_num) or
   update(accum_num) or
   update(qpp_num) or
   update(mtm_pl_asof_date)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.trade_num = d.trade_num and
                                   i.order_num = d.order_num and
                                   i.item_num = d.item_num and
                                   i.accum_num = d.accum_num and
                                   i.qpp_num = d.qpp_num and
                                   i.mtm_pl_asof_date = d.mtm_pl_asof_date )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(qpp_mark_to_market) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end


return
GO
ALTER TABLE [dbo].[qpp_mark_to_market] ADD CONSTRAINT [qpp_mark_to_market_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [item_num], [accum_num], [qpp_num], [mtm_pl_asof_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [qpp_mark_to_market_idx1] ON [dbo].[qpp_mark_to_market] ([mtm_pl_asof_date]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[qpp_mark_to_market] ADD CONSTRAINT [qpp_mark_to_market_fk2] FOREIGN KEY ([price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[qpp_mark_to_market] ADD CONSTRAINT [qpp_mark_to_market_fk3] FOREIGN KEY ([price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[qpp_mark_to_market] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[qpp_mark_to_market] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[qpp_mark_to_market] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[qpp_mark_to_market] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'qpp_mark_to_market', NULL, NULL
GO
