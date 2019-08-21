CREATE TABLE [dbo].[file_load_iteration]
(
[id] [int] NOT NULL,
[load_start_time] [datetime] NULL,
[load_end_time] [datetime] NULL,
[file_load_id] [int] NOT NULL,
[processed_records] [int] NOT NULL CONSTRAINT [df_file_load_iteration_processed_records] DEFAULT ((0)),
[trans_id] [int] NOT NULL,
[parser_version_id] [int] NULL,
[failed_records] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

 
CREATE trigger [dbo].[file_load_iteration_deltrg]
on [dbo].[file_load_iteration]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
        @atrans_id bigint
 
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
   set @errmsg = '(file_load_iteration) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      set @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror(@errmsg, 10, 1)
   if @@trancount > 0 rollback tran
   return
end
 

insert dbo.aud_file_load_iteration
(
   id, 
   load_start_time, 
   load_end_time, 
   file_load_id, 
   processed_records,
   parser_version_id, 
   failed_records,
   trans_id, 
   resp_trans_id   
)
select
	d.id, 
	d.load_start_time, 
	d.load_end_time, 
	d.file_load_id, 
	d.processed_records, 
	d.parser_version_id,
	d.failed_records,
	d.trans_id,
    @atrans_id
from deleted d
 
/* AUDIT_CODE_END */
return
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

 
CREATE trigger [dbo].[file_load_iteration_updtrg]
on [dbo].[file_load_iteration]
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
   raiserror('(file_load_iteration) The change needs to be attached with a new trans_id.', 10, 1)
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
      set @errmsg = '(file_load_iteration) New trans_id must be larger than original trans_id.'
      set @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg, 10, 1)
      if @@trancount > 0 rollback tran
      return
   end
end
 
if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.id = d.id)
begin
   raiserror ('(file_load_iteration) new trans_id must not be older than current trans_id.', 10, 1)
   if @@trancount > 0 rollback tran
   return
end
 
/* RECORD_STAMP_END */
if update(id)
begin
   set @count_num_rows = (select count(*) from inserted i, deleted d
                          where i.id = d.id)
   if (@count_num_rows = @num_rows)
   begin
      set @dummy_update = 1
   end
   else
   begin
      raiserror ('(file_load_iteration) primary key can not be changed.', 10, 1)
      if @@trancount > 0 rollback tran
      return
   end
end
 
if @dummy_update = 0
	insert dbo.aud_file_load_iteration
	(
	   id, 
	   load_start_time, 
	   load_end_time, 
	   file_load_id, 
	   processed_records,
	   parser_version_id, 
	   failed_records,
	   trans_id, 
	   resp_trans_id   
	)
	select
		d.id, 
		d.load_start_time, 
		d.load_end_time, 
		d.file_load_id, 
		d.processed_records, 
		d.parser_version_id,
		d.failed_records,
		d.trans_id,
		i.trans_id
   from deleted d, inserted i
   where d.id = i.id

/* AUDIT_CODE_END */
return
GO
ALTER TABLE [dbo].[file_load_iteration] ADD CONSTRAINT [file_load_iteration_pk] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[file_load_iteration] ADD CONSTRAINT [file_load_iteration_fk1] FOREIGN KEY ([file_load_id]) REFERENCES [dbo].[file_load] ([id])
GO
ALTER TABLE [dbo].[file_load_iteration] ADD CONSTRAINT [file_load_iteration_fk2] FOREIGN KEY ([parser_version_id]) REFERENCES [dbo].[parser_version] ([oid])
GO
GRANT DELETE ON  [dbo].[file_load_iteration] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[file_load_iteration] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[file_load_iteration] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[file_load_iteration] TO [next_usr]
GO
