CREATE TABLE [dbo].[trade_formula]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[formula_num] [int] NOT NULL,
[fall_back_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[fall_back_to_formula_num] [int] NULL,
[formula_qty_opt] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_formula_deltrg]
on [dbo].[trade_formula]
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
   select @errmsg = '(trade_formula) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_trade_formula
   (trade_num,
    order_num,
    item_num,
    formula_num,
    fall_back_ind,
    fall_back_to_formula_num,
    formula_qty_opt,
    trans_id,
    resp_trans_id)
select
   d.trade_num,
   d.order_num,
   d.item_num,
   d.formula_num,
   d.fall_back_ind,
   d.fall_back_to_formula_num,
   d.formula_qty_opt,
   d.trans_id,
   @atrans_id
from deleted d


/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'DELETE',
       'TradeFormula',
       'DIRECT',
       convert(varchar(40),d.trade_num),
       convert(varchar(40),d.order_num),
       convert(varchar(40),d.item_num),
       convert(varchar(40),d.formula_num),
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

create trigger [dbo].[trade_formula_instrg]
on [dbo].[trade_formula]
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
          'TradeFormula',
          'DIRECT',
          convert(varchar(40),trade_num),
          convert(varchar(40),order_num),
          convert(varchar(40),item_num),
          convert(varchar(40),formula_num),
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

create trigger [dbo].[trade_formula_updtrg]
on [dbo].[trade_formula]
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
   raiserror ('(trade_formula) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(trade_formula) New trans_id must be larger than original trans_id.'
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
                 i.formula_num = d.formula_num )
begin
   raiserror ('(trade_formula) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */
 
if update(trade_num) or 
   update(order_num) or  
   update(item_num) or
   update(formula_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.trade_num = d.trade_num and 
                                   i.order_num = d.order_num and 
                                   i.item_num = d.item_num and
                                   i.formula_num = d.formula_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(trade_formula) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_trade_formula
      (trade_num,
       order_num,
       item_num,
       formula_num,
       fall_back_ind,
       fall_back_to_formula_num,
       formula_qty_opt,
       trans_id,
       resp_trans_id)
    select
       d.trade_num,
       d.order_num,
       d.item_num,
       d.formula_num,
       d.fall_back_ind,
       d.fall_back_to_formula_num,
       d.formula_qty_opt,
       d.trans_id,
       i.trans_id
   from deleted d, inserted i
   where d.trade_num = i.trade_num and
         d.order_num = i.order_num and
         d.item_num = i.item_num and
         d.formula_num = i.formula_num
 
/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'UPDATE',
       'TradeFormula',
       'DIRECT',
       convert(varchar(40),trade_num),
       convert(varchar(40),order_num),
       convert(varchar(40),item_num),
       convert(varchar(40),formula_num),
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
ALTER TABLE [dbo].[trade_formula] ADD CONSTRAINT [trade_formula_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [item_num], [formula_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_formula_idx2] ON [dbo].[trade_formula] ([formula_num], [trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_formula_idx1] ON [dbo].[trade_formula] ([trade_num], [order_num], [item_num], [trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[trade_formula] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_formula] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_formula] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_formula] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'trade_formula', NULL, NULL
GO
