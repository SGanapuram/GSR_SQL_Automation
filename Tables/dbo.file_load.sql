CREATE TABLE [dbo].[file_load]
(
[id] [int] NOT NULL,
[data_file_id] [int] NOT NULL,
[failed_records] [int] NOT NULL,
[load_end_time] [datetime] NULL,
[load_start_time] [datetime] NOT NULL,
[preprocessed_records] [int] NOT NULL,
[total_records] [int] NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
create trigger [dbo].[file_load_deltrg]
on [dbo].[file_load]
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
   set @errmsg = '(file_load) Failed to obtain a valid responsible trans_id.'
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
 
insert dbo.aud_file_load
(
   id,
   data_file_id,
   failed_records,
   load_end_time,
   load_start_time,
   preprocessed_records,
   total_records,
   trans_id,
   resp_trans_id
)
select
   d.id,
   d.data_file_id,
   d.failed_records,
   d.load_end_time,
   d.load_start_time,
   d.preprocessed_records,
   d.total_records,
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
 
create trigger [dbo].[file_load_updtrg]
on [dbo].[file_load]
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
   raiserror('(file_load) The change needs to be attached with a new trans_id.', 16, 1)
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
      set @errmsg = '(file_load) New trans_id must be larger than original trans_id.'
      set @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror(@errmsg, 16, 1)
      if @@trancount > 0 rollback tran
      return
   end
end
 
if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.id = d.id)
begin
   raiserror('(file_load) new trans_id must not be older than current trans_id.', 16, 1)
   if @@trancount > 0 rollback tran
   return
end
 
/* RECORD_STAMP_END */
if update(id)
begin
   set @count_num_rows = (select count(*) from inserted i, deleted d
                          where i.id = d.id)
   if (@count_num_rows = @num_rows)
      set @dummy_update = 1
   else
   begin
      raiserror('(file_load) primary key can not be changed.', 16, 1)
      if @@trancount > 0 rollback tran
      return
   end
end
 
if @dummy_update = 0
   insert dbo.aud_file_load
     (
      id,
      data_file_id,
      failed_records,
      load_end_time,
      load_start_time,
      preprocessed_records,
      total_records,
      trans_id,
      resp_trans_id
     )
   select
      d.id,
      d.data_file_id,
      d.failed_records,
      d.load_end_time,
      d.load_start_time,
      d.preprocessed_records,
      d.total_records,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.id = i.id
   
return
GO
ALTER TABLE [dbo].[file_load] ADD CONSTRAINT [file_load_pk] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[file_load] ADD CONSTRAINT [file_load_fk1] FOREIGN KEY ([data_file_id]) REFERENCES [dbo].[data_file] ([id])
GO
GRANT DELETE ON  [dbo].[file_load] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[file_load] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[file_load] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[file_load] TO [next_usr]
GO
