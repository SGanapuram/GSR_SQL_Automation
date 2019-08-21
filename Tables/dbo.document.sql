CREATE TABLE [dbo].[document]
(
[doc_num] [int] NOT NULL,
[doc_rev_num] [smallint] NOT NULL,
[doc_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[doc_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[doc_status_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[doc_owner_code] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[doc_owner_key1] [int] NOT NULL,
[doc_owner_key2] [int] NULL,
[doc_owner_key3] [int] NULL,
[doc_owner_key4] [int] NULL,
[doc_owner_key5] [int] NULL,
[doc_owner_key6] [int] NULL,
[doc_owner_key7] [int] NULL,
[doc_owner_key8] [int] NULL,
[doc_text] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[doc_creation_date] [datetime] NOT NULL,
[doc_creator_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[document_deltrg]
on [dbo].[document]
instead of delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   bigint

select @num_rows = @@rowcount
if @num_rows = 0
   return

delete dbo.document 
from deleted d
where document.doc_num = d.doc_num and
      document.doc_rev_num = d.doc_rev_num

/* AUDIT_CODE_BEGIN */
select @atrans_id = max(trans_id)
from dbo.icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(document) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_document
   (doc_num,
    doc_rev_num,
    doc_name,
    doc_type,
    doc_status_code,
    doc_owner_code,
    doc_owner_key1,
    doc_owner_key2,
    doc_owner_key3,
    doc_owner_key4,
    doc_owner_key5,
    doc_owner_key6,
    doc_owner_key7,
    doc_owner_key8,
    doc_text,
    doc_creation_date,
    doc_creator_init,
    trans_id,
    resp_trans_id)
select
   d.doc_num,
   d.doc_rev_num,
   d.doc_name,
   d.doc_type,
   d.doc_status_code,
   d.doc_owner_code,
   d.doc_owner_key1,
   d.doc_owner_key2,
   d.doc_owner_key3,
   d.doc_owner_key4,
   d.doc_owner_key5,
   d.doc_owner_key6,
   d.doc_owner_key7,
   d.doc_owner_key8,
   d.doc_text,
   d.doc_creation_date,
   d.doc_creator_init,
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

create trigger [dbo].[document_updtrg]
on [dbo].[document]
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
   raiserror ('(document) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(document) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.doc_num = d.doc_num and 
                 i.doc_rev_num = d.doc_rev_num )
begin
   raiserror ('(document) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(doc_num)  or  
   update(doc_rev_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.doc_num = d.doc_num and 
                                   i.doc_rev_num = d.doc_rev_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(document) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

update dbo.document
set doc_name = i.doc_name,
    doc_type = i.doc_type,
    doc_status_code = i.doc_status_code,
    doc_owner_code = i.doc_owner_code,
    doc_owner_key1 = i.doc_owner_key1,
    doc_owner_key2 = i.doc_owner_key2,
    doc_owner_key3 = i.doc_owner_key3,
    doc_owner_key4 = i.doc_owner_key4,
    doc_owner_key5 = i.doc_owner_key5,
    doc_owner_key6 = i.doc_owner_key6,
    doc_owner_key7 = i.doc_owner_key7,
    doc_owner_key8 = i.doc_owner_key8,
    doc_text = i.doc_text,
    doc_creation_date = i.doc_creation_date,
    doc_creator_init = i.doc_creator_init,
    trans_id = i.trans_id
from deleted d, inserted i
where document.doc_num = d.doc_num and
      document.doc_rev_num = d.doc_rev_num and
      d.doc_num = i.doc_num and
      d.doc_rev_num = i.doc_rev_num

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_document
      (doc_num,
       doc_rev_num,
       doc_name,
       doc_type,
       doc_status_code,
       doc_owner_code,
       doc_owner_key1,
       doc_owner_key2,
       doc_owner_key3,
       doc_owner_key4,
       doc_owner_key5,
       doc_owner_key6,
       doc_owner_key7,
       doc_owner_key8,
       doc_text,
       doc_creation_date,
       doc_creator_init,
       trans_id,
       resp_trans_id)
   select
      d.doc_num,
      d.doc_rev_num,
      d.doc_name,
      d.doc_type,
      d.doc_status_code,
      d.doc_owner_code,
      d.doc_owner_key1,
      d.doc_owner_key2,
      d.doc_owner_key3,
      d.doc_owner_key4,
      d.doc_owner_key5,
      d.doc_owner_key6,
      d.doc_owner_key7,
      d.doc_owner_key8,
      d.doc_text,
      d.doc_creation_date,
      d.doc_creator_init,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.doc_num = i.doc_num and
         d.doc_rev_num = i.doc_rev_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[document] ADD CONSTRAINT [document_pk] PRIMARY KEY CLUSTERED  ([doc_num], [doc_rev_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[document] ADD CONSTRAINT [document_fk1] FOREIGN KEY ([doc_creator_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
GRANT DELETE ON  [dbo].[document] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[document] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[document] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[document] TO [next_usr]
GO
