CREATE TABLE [dbo].[event_price_term]
(
[formula_num] [int] NOT NULL,
[price_term_num] [smallint] NOT NULL,
[event_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[event_oper] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_pricing_days] [smallint] NULL,
[event_start_end_days] [smallint] NULL,
[quote_type] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_include_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[event_dflt_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[event_trig_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[parent_price_term_num] [smallint] NULL,
[deemed_event_date] [datetime] NULL,
[event_date_saturdays] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_date_sundays] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_date_holidays] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[adj_pricing_date_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[date_deemed] [datetime] NULL,
[adj_days] [smallint] NULL,
[adj_pricing_prd_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[event_price_term_deltrg]
on [dbo].[event_price_term]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   bigint

set @num_rows = @@rowcount
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
   set @errmsg = '(event_price_term) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer') )
      set @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror(@errmsg, 16, 1)
   if @@trancount > 0 rollback tran

   return
end


insert dbo.aud_event_price_term
   (formula_num,
	price_term_num,
	event_name,
	event_oper,
	event_pricing_days,
	event_start_end_days,
	quote_type,
    event_include_ind,
    event_dflt_ind,
    event_trig_ind,
    parent_price_term_num,
    deemed_event_date,
    event_date_saturdays,
    event_date_sundays,
    event_date_holidays,
    adj_pricing_date_ind,
    trans_id,
    resp_trans_id,
    date_deemed,
    adj_days,
    adj_pricing_prd_type)
select
   d.formula_num,
   d.price_term_num,
   d.event_name,
   d.event_oper,
   d.event_pricing_days,
   d.event_start_end_days,
   d.quote_type,
   d.event_include_ind,
   d.event_dflt_ind,
   d.event_trig_ind,
   d.parent_price_term_num,
   d.deemed_event_date,
   d.event_date_saturdays,
   d.event_date_sundays,
   d.event_date_holidays,
   d.adj_pricing_date_ind,
   d.trans_id,
   @atrans_id,
   d.date_deemed,
   d.adj_days,
   d.adj_pricing_prd_type
from deleted d

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'DELETE',
       'EventPriceTerm',
       'DIRECT',
       convert(varchar(40), d.formula_num),
       convert(varchar(40), d.price_term_num),
       null,
       null,
       null,
       null,
       null,
       null,
       @atrans_id,
       it.sequence
from dbo.icts_transaction it,
     deleted d
where it.trans_id = @atrans_id and
      it.type != 'E'

/* END_TRANSACTION_TOUCH */
      
return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[event_price_term_instrg]
on [dbo].[event_price_term]
for insert
as
declare @num_rows        int

select @num_rows = @@rowcount
if @num_rows = 0
   return
   
/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'INSERT',
       'EventPriceTerm',
       'DIRECT',
       convert(varchar(40), i.formula_num),
       convert(varchar(40), i.price_term_num),
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

create trigger [dbo].[event_price_term_updtrg]
on [dbo].[event_price_term]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errmsg           varchar(255)

set @num_rows = @@rowcount
if @num_rows = 0
   return

set @dummy_update = 0

/* RECORD_STAMP_BEGIN */
if not update(trans_id) 
begin
   raiserror('(event_price_term) The change needs to be attached with a new trans_id.', 16, 1)
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
      set @errmsg = '(event_price_term) New trans_id must be larger than original trans_id.'
      set @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror(@errmsg, 16, 1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.formula_num = d.formula_num and 
                 i.price_term_num = d.price_term_num)
begin
   set @errmsg = '(event_price_term) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.formula_num) + ',' + 
                                        convert(varchar, i.price_term_num) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror(@errmsg, 16, 1)
   return
end

/* RECORD_STAMP_END */

if update(formula_num) or  
   update(price_term_num) 
begin
   set @count_num_rows = (select count(*) from inserted i, deleted d
                          where i.formula_num = d.formula_num and 
                                i.price_term_num = d.price_term_num )
   if (@count_num_rows = @num_rows)
      set @dummy_update = 1
   else
   begin
      raiserror('(event_price_term) primary key can not be changed.', 16, 1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_event_price_term
      (formula_num,
	   price_term_num,
	   event_name,
	   event_oper,
	   event_pricing_days,
	   event_start_end_days,
	   quote_type,
	   event_include_ind,
	   event_dflt_ind,
	   event_trig_ind,
	   parent_price_term_num,
	   deemed_event_date,
	   event_date_saturdays,
	   event_date_sundays,
	   event_date_holidays,
	   adj_pricing_date_ind,
	   trans_id,
	   resp_trans_id,
	   date_deemed,
	   adj_days,
	   adj_pricing_prd_type)
   select
      d.formula_num,
	  d.price_term_num,
	  d.event_name,
	  d.event_oper,
	  d.event_pricing_days,
	  d.event_start_end_days,
	  d.quote_type,
	  d.event_include_ind,
	  d.event_dflt_ind,
	  d.event_trig_ind,
	  d.parent_price_term_num,
	  d.deemed_event_date,
	  d.event_date_saturdays,
	  d.event_date_sundays,
	  d.event_date_holidays,
	  d.adj_pricing_date_ind,
	  d.trans_id,
	  i.trans_id,
	  d.date_deemed,
	  d.adj_days,
	  d.adj_pricing_prd_type
   from deleted d, inserted i
   where d.formula_num = i.formula_num and
         d.price_term_num = i.price_term_num 

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'UPDATE',
       'EventPriceTerm',
       'DIRECT',
       convert(varchar(40), formula_num),
       convert(varchar(40), price_term_num),
       null,
       null,
       null,
       null,
       null,
       null,
       i.trans_id,
       it.sequence
from dbo.icts_transaction it,
     inserted i
where i.trans_id = it.trans_id and
      it.type != 'E'
            
/* END_TRANSACTION_TOUCH */
      
return
GO
ALTER TABLE [dbo].[event_price_term] ADD CONSTRAINT [event_price_term_pk] PRIMARY KEY CLUSTERED  ([formula_num], [price_term_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[event_price_term] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[event_price_term] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[event_price_term] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[event_price_term] TO [next_usr]
GO
