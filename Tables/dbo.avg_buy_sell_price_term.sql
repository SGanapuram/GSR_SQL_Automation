CREATE TABLE [dbo].[avg_buy_sell_price_term]
(
[formula_num] [int] NOT NULL,
[roll_days] [smallint] NULL,
[exclusion_days] [smallint] NULL,
[determination_opt] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[determination_mths_num] [tinyint] NULL,
[price_term_start_date] [datetime] NOT NULL,
[price_term_end_date] [datetime] NOT NULL,
[quote_type] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[buyer_seller_opt] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[all_quotes_reqd_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[link_to_actuals] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trigger_qty_spec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trigger_qty_uom_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[avg_buy_sell_price_term_deltrg]
on [dbo].[avg_buy_sell_price_term]
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
   select @errmsg = '(avg_buy_sell_price_term) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror(@errmsg,16,1)
   rollback tran
   return
end


insert dbo.aud_avg_buy_sell_price_term
   (formula_num,
    roll_days,
    exclusion_days,
    determination_opt,
    determination_mths_num,
    price_term_start_date,
    price_term_end_date,
    quote_type,
    buyer_seller_opt,
    all_quotes_reqd_ind,
    trans_id,
    resp_trans_id,
    link_to_actuals,
	trigger_qty_spec_ind,
	trigger_qty_uom_ind)
select
   d.formula_num,
   d.roll_days,
   d.exclusion_days,
   d.determination_opt,
   d.determination_mths_num,
   d.price_term_start_date,
   d.price_term_end_date,
   d.quote_type,
   d.buyer_seller_opt,
   d.all_quotes_reqd_ind,
   d.trans_id,
   @atrans_id,
   d.link_to_actuals,
   d.trigger_qty_spec_ind,
   d.trigger_qty_uom_ind
from deleted d

/* AUDIT_CODE_END */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[avg_buy_sell_price_term_instrg]
on [dbo].[avg_buy_sell_price_term]
for insert
as
declare @num_rows        int

select @num_rows = @@rowcount
if @num_rows = 0
   return
   
/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'INSERT',
       'AvgBuySellPriceTerm',
       'DIRECT',
       convert(varchar(40), i.formula_num),
       null,
       null,
       null,
       null,
       null,
       null,
       null,
       i.trans_id,
       it.sequence
from inserted i, 
     dbo.icts_transaction it
where i.trans_id = it.trans_id and
      it.type != 'E'
 
/* END_TRANSACTION_TOUCH */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[avg_buy_sell_price_term_updtrg]
on [dbo].[avg_buy_sell_price_term]
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
   raiserror('(avg_buy_sell_price_term) The change needs to be attached with a new trans_id',16,1)
   rollback tran
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
      select @errmsg = '(avg_buy_sell_price_term) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      rollback tran
      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.formula_num = d.formula_num )
begin
   raiserror ('(avg_buy_sell_price_term) new trans_id must not be older than current trans_id.',16,1)
   rollback tran
   return
end

/* RECORD_STAMP_END */

if update(formula_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.formula_num = d.formula_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(avg_buy_sell_price_term) primary key can not be changed.',16,1)
      rollback tran
      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_avg_buy_sell_price_term
      (formula_num,
       roll_days,
       exclusion_days,
       determination_opt,
       determination_mths_num,
       price_term_start_date,
       price_term_end_date,
       quote_type,
       buyer_seller_opt,
       all_quotes_reqd_ind,
       trans_id,
       resp_trans_id,
       link_to_actuals,
		trigger_qty_spec_ind,
		trigger_qty_uom_ind)
   select
      d.formula_num,
      d.roll_days,
      d.exclusion_days,
      d.determination_opt,
      d.determination_mths_num,
      d.price_term_start_date,
      d.price_term_end_date,
      d.quote_type,
      d.buyer_seller_opt,
      d.all_quotes_reqd_ind,
      d.trans_id,
      i.trans_id,
      d.link_to_actuals,
      d.trigger_qty_spec_ind,
      d.trigger_qty_uom_ind
   from deleted d, inserted i
   where d.formula_num = i.formula_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[avg_buy_sell_price_term] ADD CONSTRAINT [chk_avg_buy_sell_price_term_trigger_qty_spec_ind] CHECK (([trigger_qty_spec_ind]='A' OR [trigger_qty_spec_ind]='T'))
GO
ALTER TABLE [dbo].[avg_buy_sell_price_term] ADD CONSTRAINT [chk_avg_buy_sell_price_term_trigger_qty_uom_ind] CHECK (([trigger_qty_uom_ind]='P' OR [trigger_qty_uom_ind]='B'))
GO
ALTER TABLE [dbo].[avg_buy_sell_price_term] ADD CONSTRAINT [avg_buy_sell_price_term_pk] PRIMARY KEY CLUSTERED  ([formula_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[avg_buy_sell_price_term] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[avg_buy_sell_price_term] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[avg_buy_sell_price_term] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[avg_buy_sell_price_term] TO [next_usr]
GO
