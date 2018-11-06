CREATE TABLE [dbo].[fb_event_price_term]
(
[formula_num] [int] NOT NULL,
[formula_body_num] [tinyint] NOT NULL,
[event_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[event_oper] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_pricing_prds] [smallint] NULL,
[event_pricing_prd_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_start_prds] [smallint] NULL,
[event_start_prd_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[deemed_date_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[deemed_event_date] [datetime] NULL,
[event_date_saturdays] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_date_sundays] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_date_holidays] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[adj_pricing_date_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[add_trigger_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trigger_start_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trig_start_prds] [int] NULL,
[trig_start_prd_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trig_event_oper] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trig_event_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[adj_trig_start_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trigger_opt] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[field1] [int] NULL,
[field2] [float] NULL,
[field3] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[field4] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[fb_event_price_term_deltrg]
on [dbo].[fb_event_price_term]
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
   select @errmsg = '(fb_event_price_term) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_fb_event_price_term
   (formula_num,
    formula_body_num,
    event_name,
    event_oper,
    event_pricing_prds,
    event_pricing_prd_type,
    event_start_prds,
    event_start_prd_type,
    deemed_date_ind,
    deemed_event_date,
    event_date_saturdays,
    event_date_sundays,
    event_date_holidays,
    adj_pricing_date_ind,
    add_trigger_ind,
    trigger_start_type,
    trig_start_prds,
    trig_start_prd_type,
    trig_event_oper,
    trig_event_name,
    adj_trig_start_ind,
    trigger_opt,
    field1,
    field2,
    field3,
    field4,
    trans_id,
    resp_trans_id)
select
    formula_num,
    d.formula_body_num,
    d.event_name,
    d.event_oper,
    d.event_pricing_prds,
    d.event_pricing_prd_type,
    d.event_start_prds,
    d.event_start_prd_type,
    d.deemed_date_ind,
    d.deemed_event_date,
    d.event_date_saturdays,
    d.event_date_sundays,
    d.event_date_holidays,
    d.adj_pricing_date_ind,
    d.add_trigger_ind,
    d.trigger_start_type,
    d.trig_start_prds,
    d.trig_start_prd_type,
    d.trig_event_oper,
    d.trig_event_name,
    d.adj_trig_start_ind,
    d.trigger_opt,
    d.field1,
    d.field2,
    d.field3,
    d.field4,
    d.trans_id,
    @atrans_id
from deleted d

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'DELETE',
       'FbEventPriceTerm',
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

create trigger [dbo].[fb_event_price_term_instrg]
on [dbo].[fb_event_price_term]
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
          'FbEventPriceTerm',
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
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[fb_event_price_term_updtrg]
on [dbo].[fb_event_price_term]
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
   raiserror ('(fb_event_price_term) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(fb_event_price_term) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and 
                 i.formula_num = d.formula_num and 
                 i.formula_body_num = d.formula_body_num)
begin
   raiserror ('(fb_event_price_term) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(formula_num) or  
   update(formula_body_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.formula_num = d.formula_num and 
                                   i.formula_body_num = d.formula_body_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(fb_event_price_term) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_fb_event_price_term
      (formula_num,
       formula_body_num,
       event_name,
       event_oper,
       event_pricing_prds,
       event_pricing_prd_type,
       event_start_prds,
       event_start_prd_type,
       deemed_date_ind,
       deemed_event_date,
       event_date_saturdays,
       event_date_sundays,
       event_date_holidays,
       adj_pricing_date_ind,
       add_trigger_ind,
       trigger_start_type,
       trig_start_prds,
       trig_start_prd_type,
       trig_event_oper,
       trig_event_name,
       adj_trig_start_ind,
       trigger_opt,
       field1,
       field2,
       field3,
       field4,
       trans_id,
       resp_trans_id)
    select
       d.formula_num,
       d.formula_body_num,
       d.event_name,
       d.event_oper,
       d.event_pricing_prds,
       d.event_pricing_prd_type,
       d.event_start_prds,
       d.event_start_prd_type,
       d.deemed_date_ind,
       d.deemed_event_date,
       d.event_date_saturdays,
       d.event_date_sundays,
       d.event_date_holidays,
       d.adj_pricing_date_ind,
       d.add_trigger_ind,
       d.trigger_start_type,
       d.trig_start_prds,
       d.trig_start_prd_type,
       d.trig_event_oper,
       d.trig_event_name,
       d.adj_trig_start_ind,
       d.trigger_opt,
       d.field1,
       d.field2,
       d.field3,
       d.field4,
       d.trans_id,
       i.trans_id
    from deleted d, inserted i
    where d.formula_num = i.formula_num and
          d.formula_body_num = i.formula_body_num

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'UPDATE',
       'FbEventPriceTerm',
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
ALTER TABLE [dbo].[fb_event_price_term] ADD CONSTRAINT [fb_event_price_term_pk] PRIMARY KEY CLUSTERED  ([formula_num], [formula_body_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[fb_event_price_term] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[fb_event_price_term] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[fb_event_price_term] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[fb_event_price_term] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'fb_event_price_term', NULL, NULL
GO
