CREATE TABLE [dbo].[market_price_quote_dates]
(
[cmf_num] [int] NOT NULL,
[calendar_date] [datetime] NOT NULL,
[quote_date] [datetime] NOT NULL,
[priced_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_market_price_quote_dates_priced_ind] DEFAULT ('N'),
[end_of_period_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_market_price_quote_dates_end_of_period_ind] DEFAULT ('N'),
[fiscal_month] [smallint] NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[mkt_price_quo_dates_deltrg]
on [dbo].[market_price_quote_dates]
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
   select @errmsg = '(market_price_quote_dates) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_market_price_quote_dates
   (cmf_num,
    calendar_date,
    quote_date,
    priced_ind,
    end_of_period_ind,
    fiscal_month,
    trans_id,
    resp_trans_id)
select
   d.cmf_num,
   d.calendar_date,
   d.quote_date,
   d.priced_ind,
   d.end_of_period_ind,
   d.fiscal_month,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'DELETE',
       'MarketPriceQuoteDates',
       'DIRECT',
       convert(varchar(40), d.cmf_num),
       convert(varchar(40), d.calendar_date),
       null,
       null,
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

create trigger [dbo].[mkt_price_quo_dates_instrg]
on [dbo].[market_price_quote_dates]
for insert
as
declare @num_rows       int,
        @count_num_rows int,
        @errmsg         varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

   /* BEGIN_TRANSACTION_TOUCH */
 
   insert dbo.transaction_touch
   select 'INSERT',
          'MarketPriceQuoteDates',
          'DIRECT',
          convert(varchar(40), i.cmf_num),
          convert(varchar(40), i.calendar_date),
          null,
          null,
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

create trigger [dbo].[mkt_price_quo_dates_updtrg]
on [dbo].[market_price_quote_dates]
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
   raiserror ('(market_price_quote_dates) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(market_price_quote_dates) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.cmf_num = d.cmf_num)
begin
   raiserror ('(market_price_quote_dates) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(cmf_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where  i.cmf_num = d.cmf_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(market_price_quote_dates) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_market_price_quote_dates
      (cmf_num,
       calendar_date,
       quote_date,
       priced_ind,
       end_of_period_ind,
       fiscal_month,
       trans_id,
       resp_trans_id)
    select
       d.cmf_num,
       d.calendar_date,
       d.quote_date,
       d.priced_ind,
       d.end_of_period_ind,
       d.fiscal_month,
       d.trans_id,
       i.trans_id
   from deleted d, inserted i
   where d.cmf_num = i.cmf_num

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'UPDATE',
       'MarketPriceQuoteDates',
       'DIRECT',
       convert(varchar(40), i.cmf_num),
       convert(varchar(40), i.calendar_date),
       null,
       null,
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
ALTER TABLE [dbo].[market_price_quote_dates] ADD CONSTRAINT [market_price_quote_dates_pk] PRIMARY KEY CLUSTERED  ([cmf_num], [calendar_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[market_price_quote_dates] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[market_price_quote_dates] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[market_price_quote_dates] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[market_price_quote_dates] TO [next_usr]
GO
