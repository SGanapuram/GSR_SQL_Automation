CREATE TABLE [dbo].[formula_body_trigger]
(
[formula_num] [int] NOT NULL,
[formula_body_num] [tinyint] NOT NULL,
[trigger_num] [tinyint] NOT NULL,
[trigger_qty] [float] NOT NULL,
[trigger_date] [datetime] NOT NULL,
[trans_id] [int] NOT NULL,
[trigger_price] [float] NULL,
[trigger_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trigger_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trigger_qty_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[input_qty] [float] NULL,
[input_qty_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[input_lock_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[formula_body_trigger_deltrg]
on [dbo].[formula_body_trigger]
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
   select @errmsg = '(formula_body_trigger) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_formula_body_trigger
   (formula_num,
    formula_body_num,
    trigger_num,
    trigger_qty,
    trigger_date,
    trigger_price,
    trigger_price_curr_code,
    trigger_price_uom_code,
    trigger_qty_uom_code,
    input_qty,
    input_qty_uom_code,
    input_lock_ind,
    trans_id,
    resp_trans_id)
select
formula_num,
    d.formula_body_num,
    d.trigger_num,
    d.trigger_qty,
    d.trigger_date,
    d.trigger_price,
    d.trigger_price_curr_code,
    d.trigger_price_uom_code,
    d.trigger_qty_uom_code,
    d.input_qty,
    d.input_qty_uom_code,
    d.input_lock_ind,
    d.trans_id,
    @atrans_id
from deleted d

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'DELETE',
       'FormulaBodyTrigger',
       'DIRECT',   
       convert(varchar(40),d.formula_num),
       convert(varchar(40),d.formula_body_num),
       convert(varchar(40),d.trigger_num),
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

create trigger [dbo].[formula_body_trigger_instrg]
on [dbo].[formula_body_trigger]
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
          'FormulaBodyTrigger',
          'DIRECT',
          convert(varchar(40),formula_num),
          convert(varchar(40),formula_body_num),
          convert(varchar(40),trigger_num),
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

create trigger [dbo].[formula_body_trigger_updtrg]
on [dbo].[formula_body_trigger]
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
   raiserror ('(formula_body_trigger) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(formula_body_trigger) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and 
                 i.formula_num = d.formula_num and 
                 i.formula_body_num = d.formula_body_num and 
                 i.trigger_num= d.trigger_num)
begin
   raiserror ('(formula_body_trigger) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(formula_num) or  
   update(formula_body_num) or 
   update(trigger_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.formula_num = d.formula_num and 
                                   i.formula_body_num = d.formula_body_num and 
                                   i.trigger_num= d.trigger_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(formula_body_trigger) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_formula_body_trigger
      (formula_num,
       formula_body_num,
       trigger_num,
       trigger_qty,
       trigger_date,
       trigger_price,
       trigger_price_curr_code,
       trigger_price_uom_code,
       trigger_qty_uom_code,
       input_qty,
       input_qty_uom_code,
       input_lock_ind,
       trans_id,
       resp_trans_id)
    select
       d.formula_num,
       d.formula_body_num,
       d.trigger_num,
       d.trigger_qty,
       d.trigger_date,
       d.trigger_price,
       d.trigger_price_curr_code,
       d.trigger_price_uom_code,
       d.trigger_qty_uom_code,
       d.input_qty,
       d.input_qty_uom_code,
       d.input_lock_ind,
       d.trans_id,
       i.trans_id
    from deleted d, inserted i
    where d.formula_num = i.formula_num and
          d.formula_body_num = i.formula_body_num and
          d.trigger_num = i.trigger_num

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'UPDATE',
       'FormulaBodyTrigger',
       'DIRECT',
       convert(varchar(40),formula_num),
       convert(varchar(40),formula_body_num),
       convert(varchar(40),trigger_num),
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
ALTER TABLE [dbo].[formula_body_trigger] ADD CONSTRAINT [formula_body_trigger_pk] PRIMARY KEY NONCLUSTERED  ([formula_num], [formula_body_num], [trigger_num]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [formula_body_trigger] ON [dbo].[formula_body_trigger] ([formula_body_num], [formula_num], [trigger_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[formula_body_trigger] ADD CONSTRAINT [formula_body_trigger_fk1] FOREIGN KEY ([trigger_price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[formula_body_trigger] ADD CONSTRAINT [formula_body_trigger_fk2] FOREIGN KEY ([trigger_price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[formula_body_trigger] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[formula_body_trigger] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[formula_body_trigger] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[formula_body_trigger] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'formula_body_trigger', NULL, NULL
GO
