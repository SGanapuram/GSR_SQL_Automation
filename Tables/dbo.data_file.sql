CREATE TABLE [dbo].[data_file]
(
[id] [int] NOT NULL,
[name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[parser_id] [int] NULL,
[trans_id] [int] NOT NULL,
[type] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_data_file_type] DEFAULT ('Market'),
[track_successes] [bit] NOT NULL CONSTRAINT [df_data_file_track_successes] DEFAULT ((0)),
[skip_unmapped_records] [bit] NULL CONSTRAINT [df_data_file_skip_unmapped_records] DEFAULT ((0)),
[is_active] [bit] NOT NULL CONSTRAINT [df_data_file_is_active] DEFAULT ((1))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[data_file_deltrg]
on [dbo].[data_file]
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
   set @errmsg = '(data_file) Failed to obtain a valid responsible trans_id.'
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
 
insert dbo.aud_data_file
(
   id,
   name,
   parser_id,
   trans_id,
   type,
   track_successes,
   skip_unmapped_records,
   is_active,
   resp_trans_id
)
select
   d.id,
   d.name,
   d.parser_id,
   d.trans_id,
   d.type,
   d.track_successes,
   d.skip_unmapped_records,
   d.is_active,
   @atrans_id
from deleted d
 
/* AUDIT_CODE_END */
return
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[data_file_updtrg]
on [dbo].[data_file]
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
   raiserror('(data_file) The change needs to be attached with a new trans_id.', 16, 1)
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
      set @errmsg = '(data_file) New trans_id must be larger than original trans_id.'
      set @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg, 16, 1)
      if @@trancount > 0 rollback tran
      return
   end
end
 
if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.id = d.id)
begin
   raiserror ('(data_file) new trans_id must not be older than current trans_id.', 16, 1)
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
      raiserror ('(data_file) primary key can not be changed.', 16, 1)
      if @@trancount > 0 rollback tran
      return
   end
end
 
if @dummy_update = 0
   insert dbo.aud_data_file
 	    (id,
 	     name,
 	     parser_id,
 	     trans_id,
		 type,
		 track_successes,
		 skip_unmapped_records,
		 is_active,
         resp_trans_id)
   select
 	    d.id,
 	    d.name,
 	    d.parser_id,
 	    d.trans_id,
		d.type,
		d.track_successes,
		d.skip_unmapped_records,
		d.is_active,
 	    i.trans_id
   from deleted d, inserted i
   where d.id = i.id
return
GO
ALTER TABLE [dbo].[data_file] ADD CONSTRAINT [data_file_pk] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[data_file] ADD CONSTRAINT [data_file_fk1] FOREIGN KEY ([parser_id]) REFERENCES [dbo].[parser] ([id]) ON DELETE SET NULL
GO
GRANT DELETE ON  [dbo].[data_file] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[data_file] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[data_file] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[data_file] TO [next_usr]
GO
