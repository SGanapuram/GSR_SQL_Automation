CREATE TABLE [dbo].[release_document_driver]
(
[oid] [int] NOT NULL,
[release_doc_num] [int] NOT NULL,
[driver_name] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[license_number] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[registration_id] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[truck_type] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[release_doc_driver_deltrg]
on [dbo].[release_document_driver]
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
from icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(release_document_driver) Failed to obtain a valid responsible trans_id. '
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

insert dbo.aud_release_document_driver
(  
   oid,
   release_doc_num,
   driver_name,
   license_number,
   registration_id,
   truck_type,
   trans_id,
   resp_trans_id
)
select
   d.oid,
   d.release_doc_num,
   d.driver_name,
   d.license_number,
   d.registration_id,
   d.truck_type,
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

create trigger [dbo].[release_doc_driver_updtrg]
on [dbo].[release_document_driver]
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
   raiserror ('(release_document_driver) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(release_document_driver) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid)
begin
   select @errmsg = '(release_document_driver) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.oid) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
   return
end

/* RECORD_STAMP_END */

if update(oid)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.oid = d.oid)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(release_document_driver) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_release_document_driver
      (oid,
       release_doc_num,
       driver_name,
       license_number,
       registration_id,
       truck_type,
       trans_id,
       resp_trans_id)
   select
 	    d.oid,
      d.release_doc_num,
      d.driver_name,
      d.license_number,
      d.registration_id,
      d.truck_type,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid 

return
GO
ALTER TABLE [dbo].[release_document_driver] ADD CONSTRAINT [release_document_driver_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [release_document_driver_idx1] ON [dbo].[release_document_driver] ([release_doc_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[release_document_driver] ADD CONSTRAINT [release_document_driver_fk1] FOREIGN KEY ([release_doc_num]) REFERENCES [dbo].[release_document] ([release_doc_num])
GO
GRANT DELETE ON  [dbo].[release_document_driver] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[release_document_driver] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[release_document_driver] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[release_document_driver] TO [next_usr]
GO
