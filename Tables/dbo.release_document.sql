CREATE TABLE [dbo].[release_document]
(
[release_doc_num] [int] NOT NULL,
[trade_num] [int] NULL,
[selling_office_addr_num] [int] NULL,
[release_printed_ind] [bit] NOT NULL CONSTRAINT [DF__release_d__relea__60B24907] DEFAULT ((0)),
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[release_document_deltrg]
on [dbo].[release_document]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
        @atrans_id int

select @num_rows = @@rowcount
if @num_rows = 0
   return

/* AUDIT_CODE_BEGIN */
select @atrans_id = max(trans_id)
from icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(release_document) Failed to obtain a valid responsible trans_id. '
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

insert dbo.aud_release_document
(  
   release_doc_num,
   trade_num,
   selling_office_addr_num,
   release_printed_ind,
   trans_id,
   resp_trans_id
)
select
   d.release_doc_num,
   d.trade_num,
   d.selling_office_addr_num,
   d.release_printed_ind,
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

create trigger [dbo].[release_document_updtrg]
on [dbo].[release_document]
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
   raiserror ('(release_document) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(release_document) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.release_doc_num = d.release_doc_num)
begin
   select @errmsg = '(release_document) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.release_doc_num) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(release_doc_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.release_doc_num = d.release_doc_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(release_document) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_release_document
 	    (release_doc_num,
       trade_num,
       selling_office_addr_num,
       release_printed_ind,
       trans_id,
       resp_trans_id)
   select
 	    d.release_doc_num,
      d.trade_num,
      d.selling_office_addr_num,
      d.release_printed_ind,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.release_doc_num = i.release_doc_num 

return
GO
ALTER TABLE [dbo].[release_document] ADD CONSTRAINT [release_document_pk] PRIMARY KEY CLUSTERED  ([release_doc_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[release_document] ADD CONSTRAINT [release_document_fk1] FOREIGN KEY ([trade_num]) REFERENCES [dbo].[trade] ([trade_num])
GO
GRANT DELETE ON  [dbo].[release_document] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[release_document] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[release_document] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[release_document] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'release_document', NULL, NULL
GO
