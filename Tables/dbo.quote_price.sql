CREATE TABLE [dbo].[quote_price]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[accum_num] [smallint] NOT NULL,
[qpp_num] [smallint] NOT NULL,
[nominal_date] [datetime] NOT NULL,
[price_quote_date] [datetime] NOT NULL,
[final_price] [float] NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_used_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[manual_override_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[quote_price_deltrg]
on [dbo].[quote_price]
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
   select @errmsg = '(quote_price) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_quote_price
   (trade_num,
    order_num,
    item_num,
    accum_num,
    qpp_num,
    nominal_date,
    price_quote_date,
    final_price,
    price_curr_code,
    price_uom_code,
    price_used_ind,
    manual_override_type,
    trans_id,
    resp_trans_id)
select
   d.trade_num,
   d.order_num,
   d.item_num,
   d.accum_num,
   d.qpp_num,
   d.nominal_date,
   d.price_quote_date,
   d.final_price,
   d.price_curr_code,
   d.price_uom_code,
   d.price_used_ind,
   d.manual_override_type,
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

create trigger [dbo].[quote_price_updtrg]
on [dbo].[quote_price]
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
   raiserror ('(quote_price) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(quote_price) New trans_id must be larger than original trans_id.'
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
                 i.nominal_date = d.nominal_date )
begin
   raiserror ('(quote_price) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(trade_num) or  
   update(order_num) or  
   update(item_num) or  
   update(accum_num) or  
   update(qpp_num) or
   update(nominal_date)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.trade_num = d.trade_num and 
                                   i.order_num = d.order_num and 
                                   i.item_num = d.item_num and 
                                   i.accum_num = d.accum_num and 
                                   i.qpp_num = d.qpp_num and
                                   i.nominal_date = d.nominal_date )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(quote_price) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_quote_price
      (trade_num,
       order_num,
       item_num,
       accum_num,
       qpp_num,
       nominal_date,
       price_quote_date,
       final_price,
       price_curr_code,
       price_uom_code,
       price_used_ind,
       manual_override_type,
       trans_id,
       resp_trans_id)
   select
      d.trade_num,
      d.order_num,
      d.item_num,
      d.accum_num,
      d.qpp_num,
      d.nominal_date,
      d.price_quote_date,
      d.final_price,
      d.price_curr_code,
      d.price_uom_code,
      d.price_used_ind,
      d.manual_override_type,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.trade_num = i.trade_num and
         d.order_num = i.order_num and
         d.item_num = i.item_num and
         d.accum_num = i.accum_num and
         d.qpp_num = i.qpp_num and
         d.nominal_date = i.nominal_date 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[quote_price] ADD CONSTRAINT [quote_price_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [item_num], [accum_num], [qpp_num], [nominal_date]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[quote_price] ADD CONSTRAINT [quote_price_fk1] FOREIGN KEY ([price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[quote_price] ADD CONSTRAINT [quote_price_fk3] FOREIGN KEY ([price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[quote_price] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[quote_price] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[quote_price] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[quote_price] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'quote_price', NULL, NULL
GO
