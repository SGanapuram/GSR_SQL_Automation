CREATE TABLE [dbo].[trade_order]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[order_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[order_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[parent_order_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[parent_order_num] [smallint] NULL,
[order_strategy_num] [smallint] NULL,
[order_strategy_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[order_strip_num] [smallint] NULL,
[strip_summary_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[strip_detail_order_count] [smallint] NULL,
[strip_periodicity] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[strip_order_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[term_evergreen_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bal_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[margin_amt] [float] NULL,
[margin_amt_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[efp_last_post_date] [datetime] NULL,
[cash_settle_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cash_settle_saturdays] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cash_settle_sundays] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cash_settle_holidays] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cash_settle_prd_freq] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cash_settle_prd_start_date] [datetime] NULL,
[commitment_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[max_item_num] [smallint] NULL,
[trans_id] [int] NOT NULL,
[internal_parent_trade_num] [int] NULL,
[internal_parent_order_num] [smallint] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_order_deltrg]
on [dbo].[trade_order]
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
   select @errmsg = '(trade_order) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_trade_order
   (trade_num,
    order_num,
    order_type_code,
    order_status_code,
    parent_order_ind,
    parent_order_num,
    order_strategy_num,
    order_strategy_name,
    order_strip_num,
    strip_summary_ind,
    strip_detail_order_count,
    strip_periodicity,
    strip_order_status,
    term_evergreen_ind,
    bal_ind,
    margin_amt,
    margin_amt_curr_code,
    cmnt_num,
    efp_last_post_date,
    cash_settle_type,
    cash_settle_saturdays,
    cash_settle_sundays,
    cash_settle_holidays,
    cash_settle_prd_freq,
    cash_settle_prd_start_date,
    commitment_ind,
    max_item_num,
    internal_parent_trade_num,
    internal_parent_order_num,
    trans_id,
    resp_trans_id)
select
   d.trade_num,
   d.order_num,
   d.order_type_code,
   d.order_status_code,
   d.parent_order_ind,
   d.parent_order_num,
   d.order_strategy_num,
   d.order_strategy_name,
   d.order_strip_num,
   d.strip_summary_ind,
   d.strip_detail_order_count,
   d.strip_periodicity,
   d.strip_order_status,
   d.term_evergreen_ind,
   d.bal_ind,
   d.margin_amt,
   d.margin_amt_curr_code,
   d.cmnt_num,
   d.efp_last_post_date,
   d.cash_settle_type,
   d.cash_settle_saturdays,
   d.cash_settle_sundays,
   d.cash_settle_holidays,
   d.cash_settle_prd_freq,
   d.cash_settle_prd_start_date,
   d.commitment_ind,
   d.max_item_num,
   d.internal_parent_trade_num,
   d.internal_parent_order_num,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'DELETE',
       'TradeOrder',
       'DIRECT',
       convert(varchar(40),d.trade_num),
       convert(varchar(40),d.order_num),
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

create trigger [dbo].[trade_order_instrg]
on [dbo].[trade_order]
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
          'TradeOrder',
          'DIRECT',
          convert(varchar(40),trade_num),
          convert(varchar(40),order_num),
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

create trigger [dbo].[trade_order_updtrg]
on [dbo].[trade_order]
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
   raiserror ('(trade_order) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(trade_order) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.trade_num = d.trade_num and 
                 i.order_num = d.order_num )
begin
   raiserror ('(trade_order) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(trade_num) or  
   update(order_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.trade_num = d.trade_num and 
                                   i.order_num = d.order_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(trade_order) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_trade_order
      (trade_num,
       order_num,
       order_type_code,
       order_status_code,
       parent_order_ind,
       parent_order_num,
       order_strategy_num,
       order_strategy_name,
       order_strip_num,
       strip_summary_ind,
       strip_detail_order_count,
       strip_periodicity,
       strip_order_status,
       term_evergreen_ind,
       bal_ind,
       margin_amt,
       margin_amt_curr_code,
       cmnt_num,
       efp_last_post_date,
       cash_settle_type,
       cash_settle_saturdays,
       cash_settle_sundays,
       cash_settle_holidays,
       cash_settle_prd_freq,
       cash_settle_prd_start_date,
       commitment_ind,
       max_item_num,
       internal_parent_trade_num,
       internal_parent_order_num,
       trans_id,
       resp_trans_id)
   select
      d.trade_num,
      d.order_num,
      d.order_type_code,
      d.order_status_code,
      d.parent_order_ind,
      d.parent_order_num,
      d.order_strategy_num,
      d.order_strategy_name,
      d.order_strip_num,
      d.strip_summary_ind,
      d.strip_detail_order_count,
      d.strip_periodicity,
      d.strip_order_status,
      d.term_evergreen_ind,
      d.bal_ind,
      d.margin_amt,
      d.margin_amt_curr_code,
      d.cmnt_num,
      d.efp_last_post_date,
      d.cash_settle_type,
      d.cash_settle_saturdays,
      d.cash_settle_sundays,
      d.cash_settle_holidays,
      d.cash_settle_prd_freq,
      d.cash_settle_prd_start_date,
      d.commitment_ind,
      d.max_item_num,
      d.internal_parent_trade_num,
      d.internal_parent_order_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.trade_num = i.trade_num and
         d.order_num = i.order_num 

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'UPDATE',
       'TradeOrder',
       'DIRECT',
       convert(varchar(40),trade_num),
       convert(varchar(40),order_num),
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
ALTER TABLE [dbo].[trade_order] ADD CONSTRAINT [trade_order_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_order_TS_idx90] ON [dbo].[trade_order] ([trade_num], [order_num], [order_type_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_order_idx2] ON [dbo].[trade_order] ([trade_num], [order_num], [strip_summary_ind]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_order_idx1] ON [dbo].[trade_order] ([trade_num], [trans_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_order] ADD CONSTRAINT [trade_order_fk2] FOREIGN KEY ([margin_amt_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_order] ADD CONSTRAINT [trade_order_fk3] FOREIGN KEY ([order_type_code]) REFERENCES [dbo].[order_type] ([order_type_code])
GO
ALTER TABLE [dbo].[trade_order] ADD CONSTRAINT [trade_order_fk5] FOREIGN KEY ([order_status_code]) REFERENCES [dbo].[trade_status] ([trade_status_code])
GO
GRANT DELETE ON  [dbo].[trade_order] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_order] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_order] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_order] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'trade_order', NULL, NULL
GO
