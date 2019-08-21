CREATE TABLE [dbo].[payment_term]
(
[pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pay_term_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_days] [smallint] NULL,
[pay_term_contr_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_event1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_event2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_event3] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_ba_ind1] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_ba_ind2] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_ba_ind3] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_days1] [smallint] NULL,
[pay_term_days2] [smallint] NULL,
[pay_term_days3] [smallint] NULL,
[accounting_pay_term] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[accounting_trans_cat1] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[accounting_trans_cat2] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[holiday_split] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[weekend_split] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[payment_term_deltrg]
on [dbo].[payment_term]
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
   select @errmsg = '(payment_term) Failed to obtain a valid responsible trans_id.'
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


/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'DELETE',
       'PaymentTerm',
       'DIRECT',
       convert(varchar(40), d.pay_term_code),
       null,
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

/* AUDIT_CODE_BEGIN */

insert dbo.aud_payment_term
   (pay_term_code,
    pay_term_desc,
    pay_days,
    pay_term_contr_desc,
    pay_term_event1,
    pay_term_event2,
    pay_term_event3,
    pay_term_ba_ind1,
    pay_term_ba_ind2,
    pay_term_ba_ind3,
    pay_term_days1,
    pay_term_days2,
    pay_term_days3,
    accounting_pay_term,
    accounting_trans_cat1,
    accounting_trans_cat2,
    holiday_split, 
	  weekend_split, 
    trans_id,
    resp_trans_id)
select
   d.pay_term_code,
   d.pay_term_desc,
   d.pay_days,
   d.pay_term_contr_desc,
   d.pay_term_event1,
   d.pay_term_event2,
   d.pay_term_event3,
   d.pay_term_ba_ind1,
   d.pay_term_ba_ind2,
   d.pay_term_ba_ind3,
   d.pay_term_days1,
   d.pay_term_days2,
   d.pay_term_days3,
   d.accounting_pay_term,
   d.accounting_trans_cat1,
   d.accounting_trans_cat2,
   d.holiday_split, 
	 d.weekend_split, 
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

create trigger [dbo].[payment_term_instrg]
on [dbo].[payment_term]
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
          'PaymentTerm',
          'DIRECT',
          convert(varchar(40), i.pay_term_code),
          null,
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

create trigger [dbo].[payment_term_updtrg]
on [dbo].[payment_term]
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
   raiserror ('(payment_term) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(payment_term) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.pay_term_code = d.pay_term_code )
begin
   raiserror ('(payment_term) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(pay_term_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.pay_term_code = d.pay_term_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(payment_term) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'UPDATE',
       'PaymentTerm',
       'DIRECT',
       convert(varchar(40), i.pay_term_code),
       null,
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
 
/* YOU MAY INSERT MORE CODES HERE TO ADD INDIRECT */
/* RECORD INTO THE transaction_touch TABLE       */
/*                                               */
/* PLEASE CHECK WITH DEVELOPERs FOR THIS         */
 
/* The following is a template code ....
 
insert dbo.transaction_touch
select 'UPDATE',
       '<tablename>',
       'INDIRECT',
       convert(varchar(40), i.<column name>),
       null,
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
*/
 
/* END_TRANSACTION_TOUCH */


/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_payment_term
      (pay_term_code,
       pay_term_desc,
       pay_days,
       pay_term_contr_desc,
       pay_term_event1,
       pay_term_event2,
       pay_term_event3,
       pay_term_ba_ind1,
       pay_term_ba_ind2,
       pay_term_ba_ind3,
       pay_term_days1,
       pay_term_days2,
       pay_term_days3,
       accounting_pay_term,
       accounting_trans_cat1,
       accounting_trans_cat2,
       holiday_split, 
	     weekend_split, 
       trans_id,
       resp_trans_id)
   select
      d.pay_term_code,
      d.pay_term_desc,
      d.pay_days,
      d.pay_term_contr_desc,
      d.pay_term_event1,
      d.pay_term_event2,
      d.pay_term_event3,
      d.pay_term_ba_ind1,
      d.pay_term_ba_ind2,
      d.pay_term_ba_ind3,
      d.pay_term_days1,
      d.pay_term_days2,
      d.pay_term_days3,
      d.accounting_pay_term,
      d.accounting_trans_cat1,
      d.accounting_trans_cat2,
      d.holiday_split, 
	    d.weekend_split, 
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.pay_term_code = i.pay_term_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[payment_term] ADD CONSTRAINT [chk_payment_term_holiday_split] CHECK (([holiday_split]='Previous' OR [holiday_split]='Next' OR [holiday_split] IS NULL))
GO
ALTER TABLE [dbo].[payment_term] ADD CONSTRAINT [chk_payment_term_weekend_split] CHECK (([weekend_split]='Previous' OR [weekend_split]='Next' OR [weekend_split]='Split' OR [weekend_split] IS NULL))
GO
ALTER TABLE [dbo].[payment_term] ADD CONSTRAINT [payment_term_pk] PRIMARY KEY CLUSTERED  ([pay_term_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[payment_term] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[payment_term] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[payment_term] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[payment_term] TO [next_usr]
GO
