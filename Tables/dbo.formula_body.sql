CREATE TABLE [dbo].[formula_body]
(
[formula_num] [int] NOT NULL,
[formula_body_num] [tinyint] NOT NULL,
[formula_body_string] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_parse_string] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_body_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_qty_pcnt_val] [float] NULL,
[formula_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_body_text] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_parse_text] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[avg_price_start_date] [datetime] NULL,
[avg_price_end_date] [datetime] NULL,
[range_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[complexity_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[differential_val] [float] NULL,
[trans_id] [int] NOT NULL,
[holiday_pricing_rule] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[saturday_pricing_rule] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sunday_pricing_rule] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[parent_fb_num] [int] NULL,
[fb_trigger_num] [tinyint] NULL,
[float_value] [float] NULL,
[char_value] [char] (25) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[formula_body_deltrg]
on [dbo].[formula_body]
instead of delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   bigint

select @num_rows = @@rowcount
if @num_rows = 0
   return

delete dbo.formula_body 
from deleted d
where formula_body.formula_num = d.formula_num and
      formula_body.formula_body_num = d.formula_body_num

/* AUDIT_CODE_BEGIN */
select @atrans_id = max(trans_id)
from dbo.icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(formula_body) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_formula_body
   (formula_num,
    formula_body_num,
    formula_body_string,
    formula_parse_string,
    formula_body_type,
    formula_qty_pcnt_val,
    formula_qty_uom_code,
    formula_body_text,
    formula_parse_text,
    avg_price_start_date,
    avg_price_end_date,
    range_type,
    complexity_ind,
    differential_val,
    holiday_pricing_rule,
    saturday_pricing_rule,
    sunday_pricing_rule,
    parent_fb_num, 
    fb_trigger_num,
    float_value,
    char_value,
    trans_id,    
    resp_trans_id)
select
   d.formula_num,
   d.formula_body_num,
   d.formula_body_string,
   d.formula_parse_string,
   d.formula_body_type,
   d.formula_qty_pcnt_val,
   d.formula_qty_uom_code,
   d.formula_body_text,
   d.formula_parse_text,
   d.avg_price_start_date,
   d.avg_price_end_date,
   d.range_type,
   d.complexity_ind,
   d.differential_val,
   d.holiday_pricing_rule,
   d.saturday_pricing_rule,
   d.sunday_pricing_rule,
   d.parent_fb_num, 
   d.fb_trigger_num,
   d.float_value,
   d.char_value,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'DELETE',
       'FormulaBody',
       'DIRECT',
       convert(varchar(40),d.formula_num),
       convert(varchar(40),d.formula_body_num),
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

create trigger [dbo].[formula_body_updtrg]
on [dbo].[formula_body]
instead of update
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
   raiserror ('(formula_body) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(formula_body) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.formula_num = d.formula_num and 
                 i.formula_body_num = d.formula_body_num )
begin
   raiserror ('(formula_body) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(formula_num)  or  
   update(formula_body_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.formula_num = d.formula_num and 
                                   i.formula_body_num = d.formula_body_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(formula_body) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

update formula_body
set formula_body_string = i.formula_body_string,
    formula_parse_string = i.formula_parse_string,
    formula_body_type = i.formula_body_type,
    formula_qty_pcnt_val = i.formula_qty_pcnt_val,
    formula_qty_uom_code = i.formula_qty_uom_code,
    formula_body_text = i.formula_body_text,
    formula_parse_text = i.formula_parse_text,
    avg_price_start_date = i.avg_price_start_date,
    avg_price_end_date = i.avg_price_end_date,
    range_type = i.range_type,
    complexity_ind = i.complexity_ind,
    differential_val = i.differential_val,
    holiday_pricing_rule = i.holiday_pricing_rule,
    saturday_pricing_rule = i.saturday_pricing_rule,
    sunday_pricing_rule = i.sunday_pricing_rule,
    parent_fb_num = i.parent_fb_num,  
    fb_trigger_num = i.fb_trigger_num,  
    float_value = i.float_value,  
    char_value = i.char_value,
    trans_id = i.trans_id
from deleted d, inserted i
where formula_body.formula_num = d.formula_num and
      formula_body.formula_body_num = d.formula_body_num and
      d.formula_num = i.formula_num and
      d.formula_body_num = i.formula_body_num

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_formula_body
      (formula_num,
       formula_body_num,
       formula_body_string,
       formula_parse_string,
       formula_body_type,
       formula_qty_pcnt_val,
       formula_qty_uom_code,
       formula_body_text,
       formula_parse_text,
       avg_price_start_date,
       avg_price_end_date,
       range_type,
       complexity_ind,
       differential_val,
       holiday_pricing_rule,
       saturday_pricing_rule,
       sunday_pricing_rule,
       parent_fb_num, 
       fb_trigger_num,
       float_value,
       char_value,
       trans_id,
       resp_trans_id)
    select
       d.formula_num,
       d.formula_body_num,
       d.formula_body_string,
       d.formula_parse_string,
       d.formula_body_type,
       d.formula_qty_pcnt_val,
       d.formula_qty_uom_code,
       d.formula_body_text,
       d.formula_parse_text,
       d.avg_price_start_date,
       d.avg_price_end_date,
       d.range_type,
       d.complexity_ind,
       d.differential_val,
       d.holiday_pricing_rule,
       d.saturday_pricing_rule,
       d.sunday_pricing_rule,
       d.parent_fb_num, 
       d.fb_trigger_num,
       d.float_value,
       d.char_value,
       d.trans_id,
       i.trans_id
    from deleted d, inserted i
    where d.formula_num = i.formula_num and
          d.formula_body_num = i.formula_body_num

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'UPDATE',
       'FormulaBody',
       'DIRECT',
       convert(varchar(40),formula_num),
       convert(varchar(40),formula_body_num),
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
ALTER TABLE [dbo].[formula_body] ADD CONSTRAINT [formula_body_pk] PRIMARY KEY NONCLUSTERED  ([formula_num], [formula_body_num]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [formula_body] ON [dbo].[formula_body] ([formula_body_num], [formula_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [formula_body_TS_idx90] ON [dbo].[formula_body] ([formula_body_type], [formula_num], [formula_body_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [formula_body_idx2] ON [dbo].[formula_body] ([formula_num], [formula_body_type]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [formula_body_idx1] ON [dbo].[formula_body] ([formula_num], [trans_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[formula_body] ADD CONSTRAINT [formula_body_fk2] FOREIGN KEY ([formula_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[formula_body] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[formula_body] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[formula_body] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[formula_body] TO [next_usr]
GO
