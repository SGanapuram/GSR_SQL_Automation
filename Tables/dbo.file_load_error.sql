CREATE TABLE [dbo].[file_load_error]
(
[sequence] [int] NOT NULL IDENTITY(1, 1),
[error_reason] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[file_load_id] [int] NOT NULL,
[source_data] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
create trigger [dbo].[file_load_error_deltrg]
on [dbo].[file_load_error]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
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
   set @errmsg = '(file_load_error) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      set @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror(@errmsg, 16, 1)
   if @@trancount > 0 rollback tran
   return
end
 
insert dbo.aud_file_load_error
(
   sequence,
   error_reason, 
   file_load_id,  
   source_data, 
   trans_id,
   resp_trans_id
)
select
   d.sequence,
   d.error_reason, 
   d.file_load_id,  
   d.source_data, 
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
 
create trigger [dbo].[file_load_error_updtrg]
on [dbo].[file_load_error]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errmsg           varchar(255)
 
set @num_rows = @@rowcount
if @num_rows = 0
   return
 
select @dummy_update = 0
 
/* RECORD_STAMP_BEGIN */
if not update(trans_id)
begin
   raiserror('(file_load_error) The change needs to be attached with a new trans_id.', 16, 1)
   if @@trancount > 0 rollback tran
   return
end
 
if exists (select 1
           from master.dbo.sysprocesses
           where spid = @@spid and
                (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                 program_name like 'Microsoft SQL Server Management Studio%') )
begin
   if (select count(*) from inserted, deleted where inserted.trans_id <= deleted.trans_id) > 0
   begin
      set @errmsg = '(file_load_error) New trans_id must be larger than original trans_id.'
      set @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror(@errmsg, 16, 1)
      if @@trancount > 0 rollback tran
      return
   end
end
 
if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.sequence = d.sequence)
begin
   raiserror('(file_load_error) new trans_id must not be older than current trans_id.', 16, 1)
   if @@trancount > 0 rollback tran
   return
end
 
/* RECORD_STAMP_END */
if update(sequence)
begin
   set @count_num_rows = (select count(*) from inserted i, deleted d
                          where i.sequence = d.sequence)
   if (@count_num_rows = @num_rows)
      set @dummy_update = 1
   else
   begin
      raiserror('(file_load_error) primary key can not be changed.', 16, 1)
      if @@trancount > 0 rollback tran
      return
   end
end
 
if @dummy_update = 0
   insert dbo.aud_file_load_error
     (
      sequence,
      error_reason,
      file_load_id,
      source_data,
      trans_id,
      resp_trans_id
     )
   select
      d.sequence,
      d.error_reason,
      d.file_load_id,
      d.source_data,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.sequence = i.sequence
   
return
GO
ALTER TABLE [dbo].[file_load_error] ADD CONSTRAINT [file_load_error_pk] PRIMARY KEY CLUSTERED  ([sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[file_load_error] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[file_load_error] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[file_load_error] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[file_load_error] TO [next_usr]
GO
