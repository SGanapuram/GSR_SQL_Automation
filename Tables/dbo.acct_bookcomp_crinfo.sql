CREATE TABLE [dbo].[acct_bookcomp_crinfo]
(
[acct_bookcomp_key] [int] NOT NULL,
[dflt_cr_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[acct_bookcomp_crinfo_deltrg]
on [dbo].[acct_bookcomp_crinfo]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
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
   select @errmsg = '(acct_bookcomp_crinfo) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_acct_bookcomp_crinfo
(  
   acct_bookcomp_key,
   dflt_cr_term_code,
   trans_id,
   resp_trans_id
)
select
   d.acct_bookcomp_key,
   d.dflt_cr_term_code,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'DELETE',
       'AcctBookcompCrinfo',
       'DIRECT',
       convert(varchar(40), d.acct_bookcomp_key),
       null,
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

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[acct_bookcomp_crinfo_instrg]
on [dbo].[acct_bookcomp_crinfo]
for insert
as
declare @num_rows        int

select @num_rows = @@rowcount
if @num_rows = 0
   return
   
/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'INSERT',
       'AcctBookcompCrinfo',
       'DIRECT',
       convert(varchar(40), i.acct_bookcomp_key),
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

create trigger [dbo].[acct_bookcomp_crinfo_updtrg]
on [dbo].[acct_bookcomp_crinfo]
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
   raiserror ('(acct_bookcomp_crinfo) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(acct_bookcomp_crinfo) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.acct_bookcomp_key = d.acct_bookcomp_key)
begin
   select @errmsg = '(acct_bookcomp_crinfo) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.acct_bookcomp_key) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
   return
end

/* RECORD_STAMP_END */

if update(acct_bookcomp_key)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.acct_bookcomp_key = d.acct_bookcomp_key)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(acct_bookcomp_crinfo) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_acct_bookcomp_crinfo
 	    (acct_bookcomp_key,
       dflt_cr_term_code,
       trans_id,
       resp_trans_id)
   select
 	    d.acct_bookcomp_key,
      d.dflt_cr_term_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.acct_bookcomp_key = i.acct_bookcomp_key 

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'UPDATE',
       'AcctBookcompCrinfo',
       'DIRECT',
       convert(varchar(40), i.acct_bookcomp_key),
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
ALTER TABLE [dbo].[acct_bookcomp_crinfo] ADD CONSTRAINT [acct_bookcomp_crinfo_pk] PRIMARY KEY CLUSTERED  ([acct_bookcomp_key]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[acct_bookcomp_crinfo] ADD CONSTRAINT [acct_bookcomp_crinfo_fk1] FOREIGN KEY ([acct_bookcomp_key]) REFERENCES [dbo].[acct_bookcomp] ([acct_bookcomp_key])
GO
ALTER TABLE [dbo].[acct_bookcomp_crinfo] ADD CONSTRAINT [acct_bookcomp_crinfo_fk2] FOREIGN KEY ([dflt_cr_term_code]) REFERENCES [dbo].[credit_term] ([credit_term_code])
GO
GRANT DELETE ON  [dbo].[acct_bookcomp_crinfo] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[acct_bookcomp_crinfo] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[acct_bookcomp_crinfo] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[acct_bookcomp_crinfo] TO [next_usr]
GO
