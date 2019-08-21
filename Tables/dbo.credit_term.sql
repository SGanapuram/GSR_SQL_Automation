CREATE TABLE [dbo].[credit_term]
(
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[credit_term_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[credit_term_contr_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_secure_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[doc_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[credit_term_deltrg]
on [dbo].[credit_term]
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
   select @errmsg = '(credit_term) Failed to obtain a valid responsible trans_id.'
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
       'CreditTerm',
       'DIRECT',
       convert(varchar(40), d.credit_term_code),
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
insert dbo.aud_credit_term
   (credit_term_code,
    credit_term_desc,
    credit_term_contr_desc,
    credit_secure_ind,
    doc_type_code,
    trans_id,
    resp_trans_id)
select
   d.credit_term_code,
   d.credit_term_desc,
   d.credit_term_contr_desc,
   d.credit_secure_ind,
   d.doc_type_code,
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

create trigger [dbo].[credit_term_instrg]
on [dbo].[credit_term]
for insert
as
declare @num_rows        int,
        @count_num_rows  int,
        @errmsg          varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

   /* BEGIN_TRANSACTION_TOUCH */
 
   insert dbo.transaction_touch
   select 'INSERT',
          'CreditTerm',
          'DIRECT',
          convert(varchar(40), i.credit_term_code),
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

create trigger [dbo].[credit_term_updtrg]
on [dbo].[credit_term]
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
   raiserror ('(credit_term) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(credit_term) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.credit_term_code = d.credit_term_code )
begin
   raiserror ('(credit_term) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(credit_term_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.credit_term_code = d.credit_term_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(credit_term) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end


/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'UPDATE',
       'CreditTerm',
       'DIRECT',
       convert(varchar(40), i.credit_term_code),
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

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_credit_term
      (credit_term_code,
       credit_term_desc,
       credit_term_contr_desc,
       credit_secure_ind,
       doc_type_code,
       trans_id,
       resp_trans_id)
   select
      d.credit_term_code,
      d.credit_term_desc,
      d.credit_term_contr_desc,
      d.credit_secure_ind,
      d.doc_type_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.credit_term_code = i.credit_term_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[credit_term] ADD CONSTRAINT [credit_term_pk] PRIMARY KEY CLUSTERED  ([credit_term_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[credit_term] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[credit_term] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[credit_term] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[credit_term] TO [next_usr]
GO
